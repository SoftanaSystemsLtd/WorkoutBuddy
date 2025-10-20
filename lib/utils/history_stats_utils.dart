import '../models/workout_session.dart';
import '../providers/history_provider.dart';

/// Compute statistics for a list of sessions. Kept pure for easy testing.
HistoryStats computeHistoryStats(List<WorkoutSession> sessions) {
  if (sessions.isEmpty) {
    return HistoryStats.empty;
  }

  final totalWorkouts = sessions.length;
  int totalSets = 0;
  double totalVolume = 0;
  Duration totalDuration = Duration.zero;
  final volumePerExercise = <String, double>{};
  final setsPerExercise = <String, int>{};

  for (final session in sessions) {
    totalDuration += session.duration;
    for (final ex in session.completedExercises) {
      totalSets += ex.sets.length;
      for (final set in ex.sets) {
        final volume = set.weight != null ? set.weight! * set.reps : 0.0;
        totalVolume += volume;
        volumePerExercise.update(
          ex.exerciseName,
          (v) => v + volume,
          ifAbsent: () => volume,
        );
        setsPerExercise.update(
          ex.exerciseName,
          (c) => c + 1,
          ifAbsent: () => 1,
        );
      }
    }
  }

  final averageDuration = Duration(
    seconds: (totalDuration.inSeconds / totalWorkouts).round(),
  );

  return HistoryStats(
    totalWorkouts: totalWorkouts,
    totalSets: totalSets,
    totalVolume: double.parse(totalVolume.toStringAsFixed(2)),
    averageDuration: averageDuration,
    volumePerExercise: volumePerExercise,
    setsPerExercise: setsPerExercise,
  );
}
