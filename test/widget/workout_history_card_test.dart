import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_gym/models/workout_session.dart';
import 'package:my_gym/widgets/workout_history_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WorkoutHistoryCard widget', () {
    testWidgets('displays workout session summary', (tester) async {
      final now = DateTime.now();
      final session = WorkoutSession(
        id: 'test_session',
        workoutPlanId: 'day_1',
        startTime: now,
        endTime: now.add(const Duration(minutes: 45)),
        status: SessionStatus.completed,
        completedExercises: [
          ExerciseSet(
            exerciseName: 'Bench Press',
            completedAt: now,
            sets: const [
              SetData(reps: 10, weight: 100),
              SetData(reps: 8, weight: 110),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WorkoutHistoryCard(session: session)),
        ),
      );

      expect(find.text('Workout day_1'), findsOneWidget);
      expect(find.textContaining('45m'), findsOneWidget);
      expect(find.textContaining('completed'), findsOneWidget);
    });

    testWidgets('displays empty state when no exercises', (tester) async {
      final now = DateTime.now();
      final session = WorkoutSession(
        id: 'empty_session',
        workoutPlanId: 'day_2',
        startTime: now,
        endTime: now.add(const Duration(minutes: 5)),
        status: SessionStatus.completed,
        completedExercises: const [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WorkoutHistoryCard(session: session)),
        ),
      );

      // Initially collapsed - tap to expand
      await tester.tap(find.text('Workout day_2'));
      await tester.pumpAndSettle();

      expect(find.text('No exercises recorded'), findsOneWidget);
    });

    testWidgets('expands to show exercise details when tapped', (tester) async {
      final now = DateTime.now();
      final session = WorkoutSession(
        id: 'test_session',
        workoutPlanId: 'day_1',
        startTime: now,
        endTime: now.add(const Duration(minutes: 30)),
        status: SessionStatus.completed,
        completedExercises: [
          ExerciseSet(
            exerciseName: 'Squats',
            completedAt: now,
            sets: const [
              SetData(reps: 12, weight: 80),
              SetData(reps: 10, weight: 90),
              SetData(reps: 8, weight: 100),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WorkoutHistoryCard(session: session)),
        ),
      );

      // Initially, exercise details should not be visible
      expect(find.text('Squats'), findsNothing);

      // Tap to expand
      await tester.tap(find.text('Workout day_1'));
      await tester.pumpAndSettle();

      // Now exercise details should be visible
      expect(find.text('Squats'), findsOneWidget);
      expect(find.textContaining('Sets: 3'), findsOneWidget);
    });

    testWidgets('calculates and displays volume correctly', (tester) async {
      final now = DateTime.now();
      final session = WorkoutSession(
        id: 'volume_test',
        workoutPlanId: 'day_3',
        startTime: now,
        endTime: now.add(const Duration(minutes: 60)),
        status: SessionStatus.completed,
        completedExercises: [
          ExerciseSet(
            exerciseName: 'Deadlift',
            completedAt: now,
            sets: const [
              SetData(reps: 5, weight: 100), // 500
              SetData(reps: 5, weight: 110), // 550
              SetData(reps: 5, weight: 120), // 600
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WorkoutHistoryCard(session: session)),
        ),
      );

      // Tap to expand
      await tester.tap(find.text('Workout day_3'));
      await tester.pumpAndSettle();

      // Volume should be 500 + 550 + 600 = 1650.0
      expect(find.textContaining('Volume: 1650.0'), findsOneWidget);
    });

    testWidgets('displays multiple exercises', (tester) async {
      final now = DateTime.now();
      final session = WorkoutSession(
        id: 'multi_exercise',
        workoutPlanId: 'day_4',
        startTime: now,
        endTime: now.add(const Duration(minutes: 90)),
        status: SessionStatus.completed,
        completedExercises: [
          ExerciseSet(
            exerciseName: 'Bench Press',
            completedAt: now,
            sets: const [SetData(reps: 10, weight: 100)],
          ),
          ExerciseSet(
            exerciseName: 'Incline Press',
            completedAt: now,
            sets: const [SetData(reps: 10, weight: 80)],
          ),
          ExerciseSet(
            exerciseName: 'Cable Flys',
            completedAt: now,
            sets: const [SetData(reps: 12, weight: 20)],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WorkoutHistoryCard(session: session)),
        ),
      );

      // Tap to expand
      await tester.tap(find.text('Workout day_4'));
      await tester.pumpAndSettle();

      // All exercises should be visible
      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('Incline Press'), findsOneWidget);
      expect(find.text('Cable Flys'), findsOneWidget);
    });

    testWidgets('formats duration correctly', (tester) async {
      final now = DateTime.now();

      // Test 1 hour 23 minutes
      final session1 = WorkoutSession(
        id: 'duration_test_1',
        workoutPlanId: 'day_1',
        startTime: now,
        endTime: now.add(const Duration(hours: 1, minutes: 23)),
        status: SessionStatus.completed,
        completedExercises: const [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WorkoutHistoryCard(session: session1)),
        ),
      );

      expect(
        find.textContaining('83m'),
        findsOneWidget,
      ); // 60 + 23 = 83 minutes
    });

    testWidgets('shows session status', (tester) async {
      final now = DateTime.now();
      final session = WorkoutSession(
        id: 'status_test',
        workoutPlanId: 'day_1',
        startTime: now,
        endTime: now.add(const Duration(minutes: 30)),
        status: SessionStatus.abandoned,
        completedExercises: const [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WorkoutHistoryCard(session: session)),
        ),
      );

      expect(find.textContaining('abandoned'), findsOneWidget);
    });
  });
}
