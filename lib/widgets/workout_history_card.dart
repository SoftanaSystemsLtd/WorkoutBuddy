import 'package:flutter/material.dart';
import '../models/workout_session.dart';

/// Widget that displays a single workout session in the history list.
/// Shows session summary with expandable details of exercises and sets.
class WorkoutHistoryCard extends StatelessWidget {
  const WorkoutHistoryCard({required this.session, super.key});

  final WorkoutSession session;

  @override
  Widget build(BuildContext context) {
    final durationStr = _formatDuration(session.duration);
    return ExpansionTile(
      title: Text('Workout ${session.workoutPlanId}'),
      subtitle: Text(
        '${_formatDate(session.startTime)} \u2022 $durationStr \u2022 ${session.status.name}',
      ),
      children: [
        if (session.completedExercises.isEmpty)
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text('No exercises recorded'),
          )
        else
          ...session.completedExercises.map((ex) {
            final volume = ex.sets.fold<double>(
              0,
              (v, s) => v + (s.weight != null ? s.weight! * s.reps : 0),
            );
            return ListTile(
              dense: true,
              title: Text(ex.exerciseName),
              subtitle: Text(
                'Sets: ${ex.sets.length} \u2022 Volume: ${volume.toStringAsFixed(1)}',
              ),
              trailing: _buildSetDetails(ex.sets),
            );
          }),
      ],
    );
  }

  Widget _buildSetDetails(List<SetData> sets) => sets.isEmpty
      ? const SizedBox.shrink()
      : SizedBox(
          width: 100,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: sets.take(2).map((set) {
              final weight = set.weight != null ? '${set.weight}kg' : '';
              return Text(
                '${set.reps} reps $weight',
                style: const TextStyle(fontSize: 11),
                overflow: TextOverflow.ellipsis,
              );
            }).toList(),
          ),
        );

  String _formatDuration(Duration d) => '${d.inMinutes}m ${d.inSeconds % 60}s';
  String _formatDate(DateTime dt) =>
      '${dt.year}-${_twoDigits(dt.month)}-${_twoDigits(dt.day)}';
  String _twoDigits(int v) => v.toString().padLeft(2, '0');
}
