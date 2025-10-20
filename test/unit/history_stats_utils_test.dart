import 'package:flutter_test/flutter_test.dart';
import 'package:my_gym/models/workout_session.dart';
import 'package:my_gym/utils/history_stats_utils.dart';

void main() {
  group('computeHistoryStats', () {
    test('returns empty stats for empty list', () {
      final stats = computeHistoryStats([]);
      expect(stats.totalWorkouts, 0);
      expect(stats.totalSets, 0);
      expect(stats.totalVolume, 0);
      expect(stats.averageDuration, Duration.zero);
      expect(stats.volumePerExercise, isEmpty);
    });

    test('computes basic aggregates', () {
      final sessions = [
        WorkoutSession(
          id: '1',
          workoutPlanId: 'A',
          startTime: DateTime.now().subtract(const Duration(minutes: 50)),
          endTime: DateTime.now().subtract(const Duration(minutes: 10)),
          status: SessionStatus.completed,
          completedExercises: [
            ExerciseSet(
              exerciseName: 'Bench Press',
              completedAt: DateTime.now().subtract(const Duration(minutes: 20)),
              sets: const [
                SetData(reps: 8, weight: 60),
                SetData(reps: 6, weight: 65),
              ],
            ),
            ExerciseSet(
              exerciseName: 'Push Up',
              completedAt: DateTime.now().subtract(const Duration(minutes: 18)),
              sets: const [SetData(reps: 15)],
            ),
          ],
        ),
        WorkoutSession(
          id: '2',
          workoutPlanId: 'B',
          startTime: DateTime.now().subtract(const Duration(minutes: 30)),
          endTime: DateTime.now(),
          status: SessionStatus.completed,
          completedExercises: [
            ExerciseSet(
              exerciseName: 'Bench Press',
              completedAt: DateTime.now().subtract(const Duration(minutes: 5)),
              sets: const [SetData(reps: 10, weight: 55)],
            ),
          ],
        ),
      ];

      final stats = computeHistoryStats(sessions);
      expect(stats.totalWorkouts, 2);
      expect(
        stats.totalSets,
        4,
      ); // Bench Press: 2 + 1 sets, Push Up: 1 set => 4 total (each SetData entry counts)
      // Volume: BenchPress: (8*60)+(6*65)+(10*55)=480+390+550=1420
      expect(stats.totalVolume, 1420);
      expect(stats.volumePerExercise['Bench Press'], 1420);
      expect(stats.volumePerExercise.containsKey('Push Up'), true);
      expect(stats.setsPerExercise['Bench Press'], 3);
      expect(stats.setsPerExercise['Push Up'], 1);
      expect(stats.averageDuration.inMinutes, greaterThan(0));
    });
  });
}
