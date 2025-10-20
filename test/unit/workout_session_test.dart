import 'package:flutter_test/flutter_test.dart';
import 'package:my_gym/models/workout_session.dart';

void main() {
  group('WorkoutSession', () {
    test('creates valid workout session', () {
      final session = WorkoutSession(
        id: 'test-123',
        workoutPlanId: 'day_1',
        startTime: DateTime(2025, 10, 20, 18),
        status: SessionStatus.inProgress,
        completedExercises: const [],
      );

      expect(session.id, 'test-123');
      expect(session.isActive, true);
      expect(session.endTime, null);
    });

    test('validates with validate() method', () {
      final session = WorkoutSession(
        id: '',
        workoutPlanId: 'day_1',
        startTime: DateTime.now(),
        status: SessionStatus.inProgress,
        completedExercises: const [],
      );

      expect(() => session.validate(), throwsArgumentError);
    });

    test('validates endTime after startTime', () {
      final now = DateTime.now();
      final session = WorkoutSession(
        id: 'test-123',
        workoutPlanId: 'day_1',
        startTime: now,
        endTime: now.subtract(const Duration(hours: 1)),
        status: SessionStatus.completed,
        completedExercises: const [],
      );

      expect(() => session.validate(), throwsArgumentError);
    });

    test('calculates duration correctly', () {
      final start = DateTime(2025, 10, 20, 18);
      final end = DateTime(2025, 10, 20, 19, 30);

      final session = WorkoutSession(
        id: 'test-123',
        workoutPlanId: 'day_1',
        startTime: start,
        endTime: end,
        status: SessionStatus.completed,
        completedExercises: const [],
      );

      expect(session.duration.inMinutes, 90);
    });

    test('serializes to and from JSON', () {
      final session = WorkoutSession(
        id: 'test-123',
        workoutPlanId: 'day_2',
        startTime: DateTime(2025, 10, 20, 18),
        endTime: DateTime(2025, 10, 20, 19),
        status: SessionStatus.completed,
        completedExercises: [
          ExerciseSet(
            exerciseName: 'Bench Press',
            completedAt: DateTime(2025, 10, 20, 18, 30),
            sets: const [SetData(reps: 10, weight: 100)],
          ),
        ],
      );

      final json = session.toJson();
      final restored = WorkoutSession.fromJson(json);

      expect(restored.id, session.id);
      expect(restored.workoutPlanId, session.workoutPlanId);
      expect(restored.status, SessionStatus.completed);
      expect(restored.completedExercises.length, 1);
    });

    test('copyWith updates fields correctly', () {
      final session = WorkoutSession(
        id: 'test-123',
        workoutPlanId: 'day_1',
        startTime: DateTime.now(),
        status: SessionStatus.inProgress,
        completedExercises: const [],
      );

      final updated = session.copyWith(
        status: SessionStatus.completed,
        endTime: DateTime.now().add(const Duration(hours: 1)),
      );

      expect(updated.status, SessionStatus.completed);
      expect(updated.endTime, isNotNull);
      expect(updated.id, session.id); // Unchanged
    });
  });

  group('ExerciseSet', () {
    test('creates valid exercise set', () {
      final set = ExerciseSet(
        exerciseName: 'Squat',
        completedAt: DateTime.now(),
        sets: const [
          SetData(reps: 8, weight: 200),
          SetData(reps: 8, weight: 200),
        ],
      );

      expect(set.exerciseName, 'Squat');
      expect(set.sets.length, 2);
    });

    test('validates with validate() method', () {
      final futureTime = DateTime.now().add(const Duration(days: 1));
      final set = ExerciseSet(
        exerciseName: 'Test',
        completedAt: futureTime,
        sets: const [],
      );

      expect(() => set.validate(), throwsArgumentError);
    });

    test('serializes with optional notes', () {
      final set = ExerciseSet(
        exerciseName: 'Deadlift',
        completedAt: DateTime(2025, 10, 20, 18),
        sets: const [SetData(reps: 5, weight: 300)],
        notes: 'Felt strong today',
      );

      final json = set.toJson();
      expect(json['notes'], 'Felt strong today');

      final restored = ExerciseSet.fromJson(json);
      expect(restored.notes, 'Felt strong today');
    });
  });

  group('SetData', () {
    test('creates valid set data', () {
      const set = SetData(
        reps: 10,
        weight: 150,
        restTime: Duration(seconds: 90),
      );

      expect(set.reps, 10);
      expect(set.weight, 150);
      expect(set.restTime!.inSeconds, 90);
    });

    test('validates positive reps', () {
      expect(() => SetData(reps: 0), throwsA(isA<AssertionError>()));
    });

    test('validates non-negative weight', () {
      expect(
        () => SetData(reps: 10, weight: -5),
        throwsA(isA<AssertionError>()),
      );
    });

    test('validates with validate() method', () {
      const set = SetData(reps: 10, restTime: Duration(seconds: -10));
      expect(() => set.validate(), throwsArgumentError);
    });

    test('serializes duration in ISO8601 format', () {
      const set = SetData(
        reps: 12,
        weight: 50,
        restTime: Duration(seconds: 120),
      );

      final json = set.toJson();
      expect(json['restTime'], 'PT120S');

      final restored = SetData.fromJson(json);
      expect(restored.restTime!.inSeconds, 120);
    });
  });
}
