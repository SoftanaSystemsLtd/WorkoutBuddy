import 'package:flutter_test/flutter_test.dart';
import 'package:my_gym/models/app_settings.dart';
import 'package:my_gym/models/workout_session.dart';
import 'package:my_gym/services/storage_service_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StorageServiceImpl', () {
    late StorageServiceImpl storage;

    setUp(() async {
      // Mock shared preferences for testing
      SharedPreferences.setMockInitialValues({});
      storage = StorageServiceImpl();
      await storage.init();
    });

    test('initializes successfully', () async {
      expect(storage, isNotNull);
    });

    test('loads default settings when none exist', () async {
      final settings = await storage.loadSettings();
      expect(settings.workoutStartTime.hour, 18);
      expect(settings.defaultRestTime.inSeconds, 90);
    });

    test('saves and loads settings', () async {
      final settings = AppSettings.defaults().copyWith(reminderEnabled: false);

      await storage.saveSettings(settings);
      final loaded = await storage.loadSettings();

      expect(loaded.reminderEnabled, false);
      expect(loaded.workoutStartTime.hour, 18);
    });

    test('saves and loads active session', () async {
      final session = WorkoutSession(
        id: 'test-session',
        workoutPlanId: 'day_1',
        startTime: DateTime(2025, 10, 20, 18),
        status: SessionStatus.inProgress,
        completedExercises: const [],
      );

      await storage.saveActiveSession(session);
      final loaded = await storage.loadActiveSession();

      expect(loaded, isNotNull);
      expect(loaded!.id, 'test-session');
      expect(loaded.status, SessionStatus.inProgress);
    });

    test('clears active session', () async {
      final session = WorkoutSession(
        id: 'test-session',
        workoutPlanId: 'day_1',
        startTime: DateTime.now(),
        status: SessionStatus.inProgress,
        completedExercises: const [],
      );

      await storage.saveActiveSession(session);
      await storage.clearActiveSession();

      final loaded = await storage.loadActiveSession();
      expect(loaded, isNull);
    });

    test('appends to history', () async {
      final session1 = WorkoutSession(
        id: 'session-1',
        workoutPlanId: 'day_1',
        startTime: DateTime(2025, 10, 20, 18),
        endTime: DateTime(2025, 10, 20, 19),
        status: SessionStatus.completed,
        completedExercises: const [],
      );

      final session2 = WorkoutSession(
        id: 'session-2',
        workoutPlanId: 'day_2',
        startTime: DateTime(2025, 10, 21, 18),
        endTime: DateTime(2025, 10, 21, 19),
        status: SessionStatus.completed,
        completedExercises: const [],
      );

      await storage.appendToHistory(session1);
      await storage.appendToHistory(session2);

      final history = await storage.loadHistory();
      expect(history.length, 2);
      // Most recent first
      expect(history.first.id, 'session-2');
    });

    test('limits history results', () async {
      for (var i = 0; i < 5; i++) {
        final session = WorkoutSession(
          id: 'session-$i',
          workoutPlanId: 'day_1',
          startTime: DateTime(2025, 10, 20 + i, 18),
          endTime: DateTime(2025, 10, 20 + i, 19),
          status: SessionStatus.completed,
          completedExercises: const [],
        );
        await storage.appendToHistory(session);
      }

      final limited = await storage.loadHistory(limit: 3);
      expect(limited.length, 3);
    });

    test('throws on appending in-progress session to history', () async {
      final session = WorkoutSession(
        id: 'active',
        workoutPlanId: 'day_1',
        startTime: DateTime.now(),
        status: SessionStatus.inProgress,
        completedExercises: const [],
      );

      expect(() => storage.appendToHistory(session), throwsA(isA<Exception>()));
    });

    test('exports and imports data', () async {
      final session = WorkoutSession(
        id: 'export-test',
        workoutPlanId: 'day_1',
        startTime: DateTime(2025, 10, 20, 18),
        endTime: DateTime(2025, 10, 20, 19),
        status: SessionStatus.completed,
        completedExercises: const [],
      );

      await storage.appendToHistory(session);

      final exported = await storage.exportData();
      expect(exported, isNotEmpty);

      // Clear and reimport
      await storage.overwriteHistory([]);
      await storage.importData(exported);

      final history = await storage.loadHistory();
      expect(history.length, 1);
      expect(history.first.id, 'export-test');
    });
  });
}
