import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_gym/models/app_settings.dart';
import 'package:my_gym/models/workout_plan.dart';
import 'package:my_gym/models/workout_session.dart';
import 'package:my_gym/providers/workout_provider.dart';
import 'package:my_gym/screens/home_screen.dart';
import 'package:my_gym/services/storage_service.dart';
import 'package:my_gym/services/workout_parser_impl.dart';
import 'package:provider/provider.dart';

class _FakeStorage implements StorageService {
  List<WorkoutPlan>? _cachedPlans;
  final List<WorkoutSession> _history = [];
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
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HomeScreen widget', () {
    late _FakeStorage storage;
    late WorkoutProvider provider;
    late WorkoutParserImpl parser;

    setUp(() async {
      storage = _FakeStorage();
      parser = WorkoutParserImpl();
      final plans = [
        const WorkoutPlan(
          id: 'day_1',
          name: 'Upper Body',
          dayNumber: 1,
          muscleGroups: [
            MuscleGroup(
              name: 'Chest',
              exercises: [
                Exercise(name: 'Bench Press', order: 1, muscleGroup: 'Chest'),
                Exercise(
                  name: 'Incline Dumbbell',
                  order: 2,
                  muscleGroup: 'Chest',
                ),
              ],
            ),
          ],
        ),
        const WorkoutPlan(
          id: 'day_2',
          name: 'Lower Body',
          dayNumber: 2,
          muscleGroups: [
            MuscleGroup(
              name: 'Legs',
              exercises: [
                Exercise(name: 'Squats', order: 1, muscleGroup: 'Legs'),
              ],
            ),
          ],
        ),
        const WorkoutPlan(
          id: 'day_3',
          name: 'Back',
          dayNumber: 3,
          muscleGroups: [
            MuscleGroup(
              name: 'Back',
              exercises: [
                Exercise(name: 'Deadlift', order: 1, muscleGroup: 'Back'),
              ],
            ),
          ],
        ),
        const WorkoutPlan(
          id: 'day_4',
          name: 'Arms',
          dayNumber: 4,
          muscleGroups: [
            MuscleGroup(
              name: 'Arms',
              exercises: [
                Exercise(name: 'Curls', order: 1, muscleGroup: 'Arms'),
              ],
            ),
          ],
        ),
      ];
      await storage.saveCachedWorkoutPlans(plans, DateTime.now());
      provider = WorkoutProvider(parser, storage);
      await provider.initialize();
    });

    testWidgets('renders day header and muscle group', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle(); // Wait for all async operations

      // final allText = find.byType(Text);
      // for (final element in allText.evaluate()) {
      //   final widget = element.widget as Text;
      //   // print('Found text: ${widget.data}');
      // }

      expect(find.textContaining('Day'), findsOneWidget);
      // Check if Legs is there (Day 2 is the current workout based on weekday)
      expect(find.text('Legs'), findsOneWidget);
    });

    testWidgets('expands muscle group to show exercises', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle(); // Wait for all async operations
      await tester.tap(find.text('Legs'));
      await tester.pumpAndSettle();
      expect(find.text('Squats'), findsOneWidget);
    });
  });
}
