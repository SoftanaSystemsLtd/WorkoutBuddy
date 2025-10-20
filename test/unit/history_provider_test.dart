import 'package:flutter_test/flutter_test.dart';
import 'package:my_gym/models/app_settings.dart';
import 'package:my_gym/models/workout_plan.dart';
import 'package:my_gym/models/workout_session.dart';
import 'package:my_gym/providers/history_provider.dart';
import 'package:my_gym/services/storage_service.dart';

class _FakeStorage implements StorageService {
  List<WorkoutSession> _history = [];
  WorkoutSession? _active;

  @override
  Future<void> init() async {}

  @override
  Future<WorkoutSession?> loadActiveSession() async => _active;

  @override
  Future<void> saveActiveSession(WorkoutSession session) async =>
      _active = session;

  @override
  Future<void> clearActiveSession() async => _active = null;

  @override
  Future<List<WorkoutSession>> loadHistory({int? limit}) async {
    final list = List<WorkoutSession>.from(_history);
    list.sort((a, b) => b.startTime.compareTo(a.startTime));
    if (limit != null && list.length > limit) {
      return list.take(limit).toList();
    }
    return list;
  }

  @override
  Future<void> appendToHistory(WorkoutSession session) async {
    _history.add(session);
  }

  @override
  Future<void> overwriteHistory(List<WorkoutSession> sessions) async {
    _history = List<WorkoutSession>.from(sessions);
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    _history.removeWhere((s) => s.id == sessionId);
  }

  @override
  Future<void> clearHistory() async => _history.clear();

  // Unused for this test
  @override
  Future<String> exportData() async => '{}';
  @override
  Future<void> importData(String jsonPayload) async {}
  @override
  Future<AppSettings> loadSettings() async => AppSettings.defaults();
  @override
  Future<void> saveSettings(AppSettings settings) async {}
  @override
  Future<void> saveCachedWorkoutPlans(
    List<WorkoutPlan> plans,
    DateTime timestamp,
  ) async {}
  @override
  Future<List<WorkoutPlan>?> loadCachedWorkoutPlans() async => null;
  @override
  Future<DateTime?> getCacheTimestamp() async => null;
  @override
  Future<void> clearWorkoutCache() async {}
}

void main() {
  group('HistoryProvider', () {
    late _FakeStorage storage;
    late HistoryProvider provider;

    WorkoutSession buildSession({
      required String id,
      required DateTime start,
      int benchSets = 0,
      int squatSets = 0,
    }) {
      final List<ExerciseSet> exercises = [];
      if (benchSets > 0) {
        exercises.add(
          ExerciseSet(
            exerciseName: 'Bench Press',
            completedAt: start.add(const Duration(minutes: 30)),
            sets: List.generate(
              benchSets,
              (i) => SetData(reps: 8, weight: 60 + i.toDouble()),
            ),
          ),
        );
      }
      if (squatSets > 0) {
        exercises.add(
          ExerciseSet(
            exerciseName: 'Squat',
            completedAt: start.add(const Duration(minutes: 40)),
            sets: List.generate(
              squatSets,
              (i) => SetData(reps: 6, weight: 80 + i.toDouble()),
            ),
          ),
        );
      }
      return WorkoutSession(
        id: id,
        workoutPlanId: 'plan',
        startTime: start,
        endTime: start.add(const Duration(hours: 1)),
        status: SessionStatus.completed,
        completedExercises: exercises,
      );
    }

    setUp(() async {
      storage = _FakeStorage();

      // Create history data across different days
      final now = DateTime.now();
      await storage.appendToHistory(
        buildSession(
          id: 's1',
          start: now.subtract(const Duration(days: 3)),
          benchSets: 2,
        ),
      );
      await storage.appendToHistory(
        buildSession(
          id: 's2',
          start: now.subtract(const Duration(days: 2)),
          benchSets: 1,
          squatSets: 1,
        ),
      );
      await storage.appendToHistory(
        buildSession(
          id: 's3',
          start: now.subtract(const Duration(days: 1)),
          squatSets: 3,
        ),
      );

      provider = HistoryProvider(storage);
    });

    test('loadHistory populates sessions and stats', () async {
      await provider.loadHistory();
      expect(provider.sessions.length, 3);
      expect(provider.stats.totalWorkouts, 3);
      expect(provider.stats.totalSets, greaterThan(0));
      expect(provider.stats.volumePerExercise.containsKey('Bench Press'), true);
    });

    test('applyFilter reduces sessions by date range', () async {
      await provider.loadHistory();
      final now = DateTime.now();
      // Filter to only last 1 day (expect s3)
      provider.applyFilter(
        HistoryFilter(from: now.subtract(const Duration(days: 1, hours: 1))),
      );
      expect(provider.sessions.length, 1);
      expect(provider.sessions.first.id, 's3');
    });

    test('exercise name filter matches subset', () async {
      await provider.loadHistory();
      provider.applyFilter(const HistoryFilter(exerciseNameQuery: 'bench'));
      // Only sessions containing Bench Press -> s1 & s2
      expect(provider.sessions.map((s) => s.id), containsAll(['s1', 's2']));
      expect(provider.sessions.length, 2);
    });

    test('clearFilter restores all sessions', () async {
      await provider.loadHistory();
      provider.applyFilter(const HistoryFilter(exerciseNameQuery: 'squat'));
      expect(provider.sessions.length, 2); // s2 & s3
      provider.clearFilter();
      expect(provider.sessions.length, 3);
      expect(provider.stats.totalWorkouts, 3);
    });
  });
}
