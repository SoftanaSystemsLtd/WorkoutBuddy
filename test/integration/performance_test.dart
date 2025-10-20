import 'package:flutter_test/flutter_test.dart';
import 'package:my_gym/models/workout_session.dart';
import 'package:my_gym/providers/history_provider.dart';
import 'package:my_gym/providers/workout_provider.dart';
import 'package:my_gym/services/storage_service_impl.dart';
import 'package:my_gym/services/workout_parser_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Performance tests for app startup and navigation
/// Validates response times meet <100ms target where applicable
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Performance Tests', () {
    late StorageServiceImpl storage;
    late WorkoutParserImpl parser;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = StorageServiceImpl();
      await storage.init();
      parser = WorkoutParserImpl();
    });

    test('Workout plan parsing completes in reasonable time', () async {
      final stopwatch = Stopwatch()..start();

      final provider = WorkoutProvider(parser, storage);
      await provider.initialize();

      stopwatch.stop();

      // Should complete within 500ms (initial load with file parsing)
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(500),
        reason:
            'Workout plan initialization took ${stopwatch.elapsedMilliseconds}ms',
      );

      // Should have loaded plans
      expect(provider.workoutPlans, isNotEmpty);
    });

    test('Cached workout plan loading is fast', () async {
      // First load to populate cache
      final provider1 = WorkoutProvider(parser, storage);
      await provider1.initialize();

      // Second load from cache
      final stopwatch = Stopwatch()..start();
      final provider2 = WorkoutProvider(parser, storage);
      await provider2.initialize();
      stopwatch.stop();

      // Cached load should be very fast (<50ms)
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(50),
        reason: 'Cached plan loading took ${stopwatch.elapsedMilliseconds}ms',
      );
    });

    test('Starting workout session is responsive', () async {
      final provider = WorkoutProvider(parser, storage);
      await provider.initialize();

      final stopwatch = Stopwatch()..start();
      await provider.startSession('day_1');
      stopwatch.stop();

      // Should start session quickly (<100ms)
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(100),
        reason: 'Starting session took ${stopwatch.elapsedMilliseconds}ms',
      );

      expect(provider.activeSession, isNotNull);
    });

    test('Recording exercise is responsive', () async {
      final provider = WorkoutProvider(parser, storage);
      await provider.initialize();
      await provider.startSession('day_1');

      final stopwatch = Stopwatch()..start();
      await provider.recordExercise('Bench Press', [
        const SetData(reps: 10, weight: 100),
      ]);
      stopwatch.stop();

      // Should record quickly (<50ms)
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(50),
        reason: 'Recording exercise took ${stopwatch.elapsedMilliseconds}ms',
      );
    });

    test('History loading with moderate data is performant', () async {
      final provider = WorkoutProvider(parser, storage);
      await provider.initialize();

      // Create 20 workout sessions
      for (var i = 0; i < 20; i++) {
        await provider.startSession('day_${(i % 4) + 1}');
        await provider.recordExercise('Exercise $i', [
          const SetData(reps: 10, weight: 100),
        ]);
        await provider.endSession();
      }

      // Load history
      final historyProvider = HistoryProvider(storage);
      final stopwatch = Stopwatch()..start();
      await historyProvider.loadHistory();
      stopwatch.stop();

      // Should load 20 sessions quickly (<100ms)
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(100),
        reason: 'Loading 20 sessions took ${stopwatch.elapsedMilliseconds}ms',
      );

      expect(historyProvider.sessions, hasLength(20));
    });

    test('History statistics calculation is performant', () async {
      final provider = WorkoutProvider(parser, storage);
      await provider.initialize();

      // Create workout sessions with varied exercises
      for (var i = 0; i < 50; i++) {
        await provider.startSession('day_${(i % 4) + 1}');

        // Add multiple exercises per session
        for (var j = 0; j < 5; j++) {
          await provider.recordExercise('Exercise ${i}_$j', [
            SetData(reps: 10, weight: 80 + (i % 20).toDouble()),
            SetData(reps: 8, weight: 90 + (i % 20).toDouble()),
          ]);
        }

        await provider.endSession();
      }

      // Calculate statistics
      final historyProvider = HistoryProvider(storage);
      final stopwatch = Stopwatch()..start();
      await historyProvider.loadHistory();
      stopwatch.stop();

      // Should calculate stats for 50 sessions quickly (<200ms)
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(200),
        reason:
            'Stats calculation for 50 sessions took ${stopwatch.elapsedMilliseconds}ms',
      );

      expect(historyProvider.stats.totalWorkouts, equals(50));
    });

    test('Ending workout session is responsive', () async {
      final provider = WorkoutProvider(parser, storage);
      await provider.initialize();
      await provider.startSession('day_1');

      // Add some exercises
      for (var i = 0; i < 5; i++) {
        await provider.recordExercise('Exercise $i', [
          const SetData(reps: 10, weight: 100),
        ]);
      }

      final stopwatch = Stopwatch()..start();
      await provider.endSession();
      stopwatch.stop();

      // Should end session quickly (<100ms)
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(100),
        reason: 'Ending session took ${stopwatch.elapsedMilliseconds}ms',
      );

      expect(provider.activeSession, isNull);
    });

    test('Data export with large history is reasonable', () async {
      final provider = WorkoutProvider(parser, storage);
      await provider.initialize();

      // Create 30 workout sessions
      for (var i = 0; i < 30; i++) {
        await provider.startSession('day_${(i % 4) + 1}');
        await provider.recordExercise('Exercise $i', [
          const SetData(reps: 10, weight: 100),
          const SetData(reps: 8, weight: 110),
        ]);
        await provider.endSession();
      }

      // Export data
      final stopwatch = Stopwatch()..start();
      final data = await storage.exportData();
      stopwatch.stop();

      // Should export within reasonable time (<500ms)
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(500),
        reason: 'Exporting 30 sessions took ${stopwatch.elapsedMilliseconds}ms',
      );

      expect(data, isNotEmpty);
    });

    test('Memory usage is reasonable with large dataset', () async {
      final provider = WorkoutProvider(parser, storage);
      await provider.initialize();

      // Create 100 workout sessions (stress test)
      for (var i = 0; i < 100; i++) {
        await provider.startSession('day_${(i % 4) + 1}');

        for (var j = 0; j < 3; j++) {
          await provider.recordExercise('Exercise ${i}_$j', [
            const SetData(reps: 10, weight: 100),
          ]);
        }

        await provider.endSession();
      }

      // Load all history
      final historyProvider = HistoryProvider(storage);
      await historyProvider.loadHistory();

      // Should have all 100 sessions
      expect(historyProvider.sessions, hasLength(100));

      // This test passes if it completes without running out of memory
    });
  });
}
