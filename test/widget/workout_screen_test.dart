import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_gym/models/app_settings.dart';
import 'package:my_gym/models/workout_plan.dart';
import 'package:my_gym/models/workout_session.dart';
import 'package:my_gym/providers/workout_provider.dart';
import 'package:my_gym/screens/workout_screen.dart';
import 'package:my_gym/services/storage_service.dart';
import 'package:my_gym/services/timer_service.dart';
import 'package:my_gym/services/workout_parser_impl.dart';
import 'package:provider/provider.dart';

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
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WorkoutScreen widget', () {
    late _FakeStorage storage;
    late WorkoutProvider provider;
    late WorkoutParserImpl parser;
    late TimerService timerService;

    setUp(() async {
      storage = _FakeStorage();
      parser = WorkoutParserImpl();
      timerService = TimerService();

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

    testWidgets('shows start workout button when no active session', (
      tester,
    ) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: provider),
            ChangeNotifierProvider.value(value: timerService),
          ],
          child: const MaterialApp(home: WorkoutScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ready to workout?'), findsOneWidget);
      expect(find.textContaining('Start'), findsWidgets);
    });
  });
}
