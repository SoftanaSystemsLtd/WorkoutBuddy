import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_gym/models/app_settings.dart';
import 'package:my_gym/models/workout_plan.dart';
import 'package:my_gym/models/workout_session.dart';
import 'package:my_gym/providers/history_provider.dart';
import 'package:my_gym/screens/history_screen.dart';
import 'package:my_gym/services/storage_service.dart';
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

  group('HistoryScreen widget', () {
    late _FakeStorage storage;
    late HistoryProvider provider;

    setUp(() async {
      storage = _FakeStorage();

      // Add some sample workout sessions
      final now = DateTime.now();
      storage._history.addAll([
        WorkoutSession(
          id: 'session1',
          workoutPlanId: 'day_1',
          startTime: now.subtract(const Duration(days: 2)),
          endTime: now.subtract(const Duration(days: 2, hours: -1)),
          status: SessionStatus.completed,
          completedExercises: [
            ExerciseSet(
              exerciseName: 'Bench Press',
              completedAt: now.subtract(const Duration(days: 2)),
              sets: const [
                SetData(reps: 10, weight: 100),
                SetData(reps: 8, weight: 110),
              ],
            ),
          ],
        ),
        WorkoutSession(
          id: 'session2',
          workoutPlanId: 'day_2',
          startTime: now.subtract(const Duration(days: 1)),
          endTime: now.subtract(const Duration(days: 1, hours: -1)),
          status: SessionStatus.completed,
          completedExercises: [
            ExerciseSet(
              exerciseName: 'Squats',
              completedAt: now.subtract(const Duration(days: 1)),
              sets: const [SetData(reps: 12, weight: 80)],
            ),
          ],
        ),
      ]);

      provider = HistoryProvider(storage);
    });

    testWidgets('displays history screen with title', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(home: HistoryScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('History & Stats'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('displays workout sessions after loading', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(home: HistoryScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Should display both workout sessions
      expect(find.text('Workout day_1'), findsOneWidget);
      expect(find.text('Workout day_2'), findsOneWidget);
    });

    testWidgets('displays statistics summary', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(home: HistoryScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Should show summary section
      expect(find.text('Summary'), findsOneWidget);
      expect(find.textContaining('Workouts'), findsOneWidget);
    });

    testWidgets('shows empty state when no sessions', (tester) async {
      storage._history.clear();
      final emptyProvider = HistoryProvider(storage);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: emptyProvider,
          child: const MaterialApp(home: HistoryScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No sessions match current filters'), findsOneWidget);
    });

    testWidgets('can tap refresh button', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(home: HistoryScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Find and tap refresh button
      final refreshButton = find.byIcon(Icons.refresh);
      expect(refreshButton, findsOneWidget);

      await tester.tap(refreshButton);
      await tester.pumpAndSettle();

      // History should still be displayed
      expect(find.text('Workout day_1'), findsOneWidget);
    });

    testWidgets('displays search and filter controls', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(home: HistoryScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Should have search field
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search Exercise'), findsOneWidget);

      // Should have date range button
      expect(find.byIcon(Icons.date_range), findsOneWidget);

      // Should have clear filter button
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });
  });
}
