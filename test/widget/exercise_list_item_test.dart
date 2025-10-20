import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_gym/models/workout_plan.dart';
import 'package:my_gym/widgets/exercise_list_item.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ExerciseListItem widget', () {
    testWidgets('displays exercise order number and name', (tester) async {
      const exercise = Exercise(
        name: 'Bench Press',
        order: 1,
        muscleGroup: 'Chest',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ExerciseListItem(exercise: exercise)),
        ),
      );

      // Should show order number
      expect(find.text('1'), findsOneWidget);
      // Should show exercise name
      expect(find.text('Bench Press'), findsOneWidget);
    });

    testWidgets('displays correct order for multiple exercises', (
      tester,
    ) async {
      const exercises = [
        Exercise(name: 'Squats', order: 1, muscleGroup: 'Legs'),
        Exercise(name: 'Leg Press', order: 2, muscleGroup: 'Legs'),
        Exercise(name: 'Lunges', order: 3, muscleGroup: 'Legs'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: exercises.length,
              itemBuilder: (context, index) =>
                  ExerciseListItem(exercise: exercises[index]),
            ),
          ),
        ),
      );

      // Verify all order numbers are displayed
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);

      // Verify all exercise names are displayed
      expect(find.text('Squats'), findsOneWidget);
      expect(find.text('Leg Press'), findsOneWidget);
      expect(find.text('Lunges'), findsOneWidget);
    });

    testWidgets('renders as a list tile', (tester) async {
      const exercise = Exercise(
        name: 'Deadlift',
        order: 5,
        muscleGroup: 'Back',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ExerciseListItem(exercise: exercise)),
        ),
      );

      // Should contain a ListTile widget
      expect(find.byType(ListTile), findsOneWidget);
    });
  });
}
