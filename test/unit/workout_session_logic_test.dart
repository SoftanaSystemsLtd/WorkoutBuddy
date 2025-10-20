import 'package:flutter_test/flutter_test.dart';
import 'package:my_gym/models/app_settings.dart';
import 'package:my_gym/models/workout_plan.dart';
import 'package:my_gym/models/workout_session.dart';
import 'package:my_gym/providers/workout_provider.dart';
import 'package:my_gym/services/storage_service.dart';
import 'package:my_gym/services/workout_parser_impl.dart';

class _FakeStorage implements StorageService {
  List<WorkoutPlan>? _cachedPlans;
  WorkoutSession? _active;
  final List<WorkoutSession> _history = [];

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
  Future<List<WorkoutSession>> loadHistory({int? limit}) async => _history;
  @override
  Future<void> appendToHistory(WorkoutSession session) async =>
      _history.add(session);
  @override
  Future<void> overwriteHistory(List<WorkoutSession> sessions) async {
    _history
      ..clear()
      ..addAll(sessions);
  }

  @override
  Future<void> deleteSession(String sessionId) async {}
  @override
  Future<void> clearHistory() async => _history.clear();
  @override
  Future<AppSettings> loadSettings() async => AppSettings.defaults();
  @override
  Future<void> saveSettings(AppSettings settings) async {}
  @override
  Future<String> exportData() async => '{}';
  @override
  Future<void> importData(String jsonPayload) async {}
  @override
  Future<void> saveCachedWorkoutPlans(
    List<WorkoutPlan> plans,
    DateTime timestamp,
  ) async => _cachedPlans = plans;
  @override
  Future<List<WorkoutPlan>?> loadCachedWorkoutPlans() async => _cachedPlans;
  @override
  Future<DateTime?> getCacheTimestamp() async => DateTime.now();
  @override
  Future<void> clearWorkoutCache() async => _cachedPlans = null;

  @override
  Future<void> saveManualPlanIndex(int? index) async {}
  @override
  Future<int?> loadManualPlanIndex() async => null;
}

void main() {
  group('WorkoutSession logic', () {
    late _FakeStorage storage;
    late WorkoutProvider provider;
    late WorkoutParserImpl parser;

    setUp(() async {
      storage = _FakeStorage();
      parser = WorkoutParserImpl();

      final plans = [
        const WorkoutPlan(
          id: 'day_1',
          name: 'Test Workout',
          dayNumber: 1,
          muscleGroups: [
            MuscleGroup(
              name: 'Chest',
              exercises: [
                Exercise(name: 'Bench Press', order: 1, muscleGroup: 'Chest'),
                Exercise(name: 'Incline Press', order: 2, muscleGroup: 'Chest'),
              ],
            ),
          ],
        ),
        const WorkoutPlan(
          id: 'day_2',
          name: 'Day 2',
          dayNumber: 2,
          muscleGroups: [],
        ),
        const WorkoutPlan(
          id: 'day_3',
          name: 'Day 3',
          dayNumber: 3,
          muscleGroups: [],
        ),
        const WorkoutPlan(
          id: 'day_4',
          name: 'Day 4',
          dayNumber: 4,
          muscleGroups: [],
        ),
      ];

      await storage.saveCachedWorkoutPlans(plans, DateTime.now());
      provider = WorkoutProvider(parser, storage);
      await provider.initialize();
    });

    test('starts a new session', () async {
      await provider.startSession('day_1');

      expect(provider.activeSession, isNotNull);
      expect(provider.activeSession!.workoutPlanId, equals('day_1'));
      expect(provider.activeSession!.completedExercises, isEmpty);
    });

    test('records exercise sets', () async {
      await provider.startSession('day_1');

      const sets = [
        SetData(reps: 10, weight: 100),
        SetData(reps: 8, weight: 110),
      ];

      await provider.recordExercise('Bench Press', sets);

      expect(provider.activeSession!.completedExercises, hasLength(1));
      expect(
        provider.activeSession!.completedExercises.first.exerciseName,
        equals('Bench Press'),
      );
      expect(
        provider.activeSession!.completedExercises.first.sets,
        hasLength(2),
      );
    });

    test('ends session and saves to history', () async {
      await provider.startSession('day_1');

      final sets = [const SetData(reps: 10, weight: 100)];
      await provider.recordExercise('Bench Press', sets);

      await provider.endSession();

      expect(provider.activeSession, isNull);
      expect(storage._history, hasLength(1));
      expect(storage._history.first.workoutPlanId, equals('day_1'));
    });

    test('persists active session', () async {
      await provider.startSession('day_1');

      final sets = [const SetData(reps: 10, weight: 100)];
      await provider.recordExercise('Bench Press', sets);

      // Verify session was saved to storage
      expect(storage._active, isNotNull);
      expect(storage._active!.workoutPlanId, equals('day_1'));
      expect(storage._active!.completedExercises, hasLength(1));
    });

    test('retrieves completed sets for exercise', () async {
      await provider.startSession('day_1');

      const sets = [
        SetData(reps: 10, weight: 100),
        SetData(reps: 8, weight: 110),
      ];

      await provider.recordExercise('Bench Press', sets);

      final retrievedSets = provider.getCompletedSets('Bench Press');
      expect(retrievedSets, hasLength(2));
      expect(retrievedSets!.first.reps, equals(10));
    });
  });
}
