import 'package:flutter_test/flutter_test.dart';
import 'package:my_gym/models/workout_plan.dart';

void main() {
  group('WorkoutPlan', () {
    test('creates valid workout plan', () {
      const plan = WorkoutPlan(
        id: 'day_1',
        name: 'Back and Biceps',
        dayNumber: 1,
        muscleGroups: [
          MuscleGroup(
            name: 'Upper Back',
            exercises: [
              Exercise(name: 'High Row', order: 1, muscleGroup: 'Upper Back'),
              Exercise(name: 'Seated row', order: 2, muscleGroup: 'Upper Back'),
            ],
          ),
        ],
      );

      expect(plan.id, 'day_1');
      expect(plan.name, 'Back and Biceps');
      expect(plan.dayNumber, 1);
      expect(plan.muscleGroups.length, 1);
    });

    test('validates dayNumber range', () {
      expect(
        () => WorkoutPlan(
          id: 'day_5',
          name: 'Invalid',
          dayNumber: 5,
          muscleGroups: const [],
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('serializes to and from JSON', () {
      const plan = WorkoutPlan(
        id: 'day_2',
        name: 'Chest and Triceps',
        dayNumber: 2,
        muscleGroups: [
          MuscleGroup(
            name: 'Upper Chest',
            exercises: [
              Exercise(
                name: 'Incline Barbell Press',
                order: 1,
                muscleGroup: 'Upper Chest',
              ),
            ],
          ),
        ],
      );

      final json = plan.toJson();
      final restored = WorkoutPlan.fromJson(json);

      expect(restored.id, plan.id);
      expect(restored.name, plan.name);
      expect(restored.dayNumber, plan.dayNumber);
      expect(restored.muscleGroups.length, 1);
      expect(restored.muscleGroups.first.name, 'Upper Chest');
      expect(restored.muscleGroups.first.exercises.length, 1);
    });
  });

  group('MuscleGroup', () {
    test('creates valid muscle group', () {
      const group = MuscleGroup(
        name: 'Biceps',
        exercises: [Exercise(name: 'Curl', order: 1, muscleGroup: 'Biceps')],
      );

      expect(group.name, 'Biceps');
      expect(group.exercises.length, 1);
    });

    test('validates non-empty name', () {
      expect(
        () => MuscleGroup(name: '', exercises: const []),
        throwsA(isA<AssertionError>()),
      );
    });

    test('serializes with optional category', () {
      const group = MuscleGroup(
        name: 'Biceps',
        category: 'Arms',
        exercises: [Exercise(name: 'Curl', order: 1, muscleGroup: 'Biceps')],
      );

      final json = group.toJson();
      expect(json['category'], 'Arms');

      final restored = MuscleGroup.fromJson(json);
      expect(restored.category, 'Arms');
    });
  });

  group('Exercise', () {
    test('creates valid exercise', () {
      const exercise = Exercise(
        name: 'Bench Press',
        order: 1,
        muscleGroup: 'Chest',
      );

      expect(exercise.name, 'Bench Press');
      expect(exercise.order, 1);
      expect(exercise.muscleGroup, 'Chest');
    });

    test('validates positive order', () {
      expect(
        () => Exercise(name: 'Test', order: 0, muscleGroup: 'Test'),
        throwsA(isA<AssertionError>()),
      );
    });

    test('validates non-empty name', () {
      expect(
        () => Exercise(name: '', order: 1, muscleGroup: 'Test'),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
