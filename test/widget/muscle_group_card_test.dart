import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_gym/models/workout_plan.dart';
import 'package:my_gym/widgets/muscle_group_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MuscleGroupCard widget', () {
    testWidgets('displays muscle group name and exercise count', (
      tester,
    ) async {
      final muscleGroup = const MuscleGroup(
        name: 'Chest',
        exercises: [
          Exercise(name: 'Bench Press', order: 1, muscleGroup: 'Chest'),
          Exercise(name: 'Incline Dumbbell', order: 2, muscleGroup: 'Chest'),
          Exercise(name: 'Cable Flyes', order: 3, muscleGroup: 'Chest'),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MuscleGroupCard(muscleGroup: muscleGroup)),
        ),
      );

      expect(find.text('Chest'), findsOneWidget);
      expect(find.textContaining('3 exercises'), findsOneWidget);
    });

    testWidgets('expands to show exercise list when tapped', (tester) async {
      final muscleGroup = const MuscleGroup(
        name: 'Back',
        exercises: [
          Exercise(name: 'Deadlift', order: 1, muscleGroup: 'Back'),
          Exercise(name: 'Pull-ups', order: 2, muscleGroup: 'Back'),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MuscleGroupCard(muscleGroup: muscleGroup)),
        ),
      );

      // Initially, exercises should not be visible (collapsed)
      expect(find.text('Deadlift'), findsNothing);
      expect(find.text('Pull-ups'), findsNothing);

      // Tap to expand
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();

      // Now exercises should be visible
      expect(find.text('Deadlift'), findsOneWidget);
      expect(find.text('Pull-ups'), findsOneWidget);
    });

    testWidgets('collapses when tapped again', (tester) async {
      final muscleGroup = const MuscleGroup(
        name: 'Arms',
        exercises: [
          Exercise(name: 'Bicep Curls', order: 1, muscleGroup: 'Arms'),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MuscleGroupCard(muscleGroup: muscleGroup)),
        ),
      );

      // Expand
      await tester.tap(find.text('Arms'));
      await tester.pumpAndSettle();
      expect(find.text('Bicep Curls'), findsOneWidget);

      // Collapse
      await tester.tap(find.text('Arms'));
      await tester.pumpAndSettle();
      expect(find.text('Bicep Curls'), findsNothing);
    });
  });
}
