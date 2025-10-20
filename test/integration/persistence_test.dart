import 'package:flutter_test/flutter_test.dart';
import 'package:my_gym/models/workout_session.dart';
import 'package:my_gym/providers/workout_provider.dart';
import 'package:my_gym/services/storage_service_impl.dart';
import 'package:my_gym/services/workout_parser_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Integration test for data persistence across app sessions
/// Tests: active session persistence, history persistence, settings persistence
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Data Persistence Integration Tests', () {
    late StorageServiceImpl storage;
    late WorkoutParserImpl parser;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = StorageServiceImpl();
      await storage.init();
      await storage.clearHistory();
      await storage.clearActiveSession();

      parser = WorkoutParserImpl();
    });

    test(
      'Active workout session persists across provider recreations',
      () async {
        // Create first provider and start a session
        final provider1 = WorkoutProvider(parser, storage);
        await provider1.initialize();

        // Start a workout session
        await provider1.startSession('day_1');
        expect(provider1.activeSession, isNotNull);
        final sessionId = provider1.activeSession!.id;

        // Simulate app restart by creating new provider instance
        final provider2 = WorkoutProvider(parser, storage);
        await provider2.initialize();
        await provider2.loadActiveSession();

        // Active session should be restored
        expect(provider2.activeSession, isNotNull);
        expect(provider2.activeSession!.id, equals(sessionId));
        expect(provider2.activeSession!.workoutPlanId, equals('day_1'));
      },
    );

    test('Workout history persists and accumulates', () async {
      final provider = WorkoutProvider(parser, storage);
      await provider.initialize();

      // Complete first workout
      await provider.startSession('day_1');
      await provider.recordExercise('Test Exercise', [
        const SetData(reps: 10, weight: 100),
      ]);
      await provider.endSession();

      // Verify first workout saved
      final history1 = await storage.loadHistory();
      expect(history1, hasLength(1));
      expect(history1.first.workoutPlanId, equals('day_1'));

      // Complete second workout
      await provider.startSession('day_2');
      await provider.recordExercise('Another Exercise', [
        const SetData(reps: 12, weight: 80),
      ]);
      await provider.endSession();

      // Verify both workouts saved
      final history2 = await storage.loadHistory();
      expect(history2, hasLength(2));
    });

    test('Exercise data persists during active session', () async {
      final provider = WorkoutProvider(parser, storage);
      await provider.initialize();

      // Start session and record multiple exercises
      await provider.startSession('day_1');

      await provider.recordExercise('Exercise 1', [
        const SetData(reps: 10, weight: 100),
        const SetData(reps: 8, weight: 110),
      ]);

      await provider.recordExercise('Exercise 2', [
        const SetData(reps: 12, weight: 80),
      ]);

      // Simulate app restart
      final provider2 = WorkoutProvider(parser, storage);
      await provider2.initialize();
      await provider2.loadActiveSession();

      // Exercises should be restored
      expect(provider2.activeSession!.completedExercises, hasLength(2));
      expect(
        provider2.activeSession!.completedExercises[0].exerciseName,
        equals('Exercise 1'),
      );
      expect(provider2.activeSession!.completedExercises[0].sets, hasLength(2));
      expect(
        provider2.activeSession!.completedExercises[1].exerciseName,
        equals('Exercise 2'),
      );
      expect(provider2.activeSession!.completedExercises[1].sets, hasLength(1));
    });

    test('Workout plans cache persists', () async {
      final provider1 = WorkoutProvider(parser, storage);
      await provider1.initialize();

      // Verify plans are loaded
      expect(provider1.workoutPlans, isNotEmpty);
      final planCount = provider1.workoutPlans!.length;

      // Create new provider - should load from cache
      final provider2 = WorkoutProvider(parser, storage);
      await provider2.initialize();

      expect(provider2.workoutPlans, isNotEmpty);
      expect(provider2.workoutPlans!.length, equals(planCount));
    });

    test('Storage handles concurrent operations safely', () async {
      final provider = WorkoutProvider(parser, storage);
      await provider.initialize();

      // Start multiple operations in parallel
      await provider.startSession('day_1');

      final futures = <Future>[];
      for (var i = 0; i < 5; i++) {
        futures.add(
          provider.recordExercise('Exercise $i', [
            const SetData(reps: 10, weight: 100),
          ]),
        );
      }

      await Future.wait(futures);

      // All exercises should be recorded
      expect(provider.activeSession!.completedExercises, hasLength(5));
    });

    test('Data export includes all history', () async {
      final provider = WorkoutProvider(parser, storage);
      await provider.initialize();

      // Create some workout history
      for (var i = 1; i <= 3; i++) {
        await provider.startSession('day_$i');
        await provider.recordExercise('Exercise $i', [
          const SetData(reps: 10, weight: 100),
        ]);
        await provider.endSession();
      }

      // Export data
      final exportedData = await storage.exportData();

      // Should be valid JSON string
      expect(exportedData, isNotEmpty);
      expect(exportedData, contains('history'));
      expect(exportedData, contains('settings'));
    });
  });
}
