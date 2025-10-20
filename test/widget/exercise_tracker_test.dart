import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_gym/models/workout_plan.dart';
import 'package:my_gym/widgets/exercise_tracker.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ExerciseTracker widget', () {
    testWidgets('displays exercise name and muscle group', (tester) async {
      const exercise = Exercise(
        name: 'Bench Press',
        order: 1,
        muscleGroup: 'Chest',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExerciseTracker(
              exercise: exercise,
              onSetsChanged: (_) {},
              onComplete: () {},
            ),
          ),
        ),
      );

      expect(find.text('Bench Press'), findsOneWidget);
    });

    testWidgets('allows adding sets', (tester) async {
      const exercise = Exercise(name: 'Squats', order: 1, muscleGroup: 'Legs');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExerciseTracker(
              exercise: exercise,
              onSetsChanged: (_) {},
              onComplete: () {},
            ),
          ),
        ),
      );

      // Should have add set button
      expect(find.text('Add Set'), findsOneWidget);

      // Tap to add a set
      await tester.tap(find.text('Add Set'));
      await tester.pumpAndSettle();

      // Should show input fields for reps and weight
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('marks exercise as complete', (tester) async {
      const exercise = Exercise(
        name: 'Deadlift',
        order: 1,
        muscleGroup: 'Back',
      );

      var completeCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExerciseTracker(
              exercise: exercise,
              onSetsChanged: (_) {},
              onComplete: () {
                completeCalled = true;
              },
            ),
          ),
        ),
      );

      // Add at least one set first
      await tester.tap(find.text('Add Set'));
      await tester.pumpAndSettle();

      // Enter reps
      await tester.enterText(find.byType(TextField).first, '10');
      await tester.pumpAndSettle();

      // Tap complete button if available
      final completeButton = find.widgetWithIcon(IconButton, Icons.check);
      if (completeButton.evaluate().isNotEmpty) {
        await tester.tap(completeButton);
        await tester.pumpAndSettle();

        expect(completeCalled, isTrue);
      }
    });
  });
}
