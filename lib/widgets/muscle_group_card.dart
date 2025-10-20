import 'package:flutter/material.dart';
import '../models/workout_plan.dart';
import 'exercise_list_item.dart';

class MuscleGroupCard extends StatelessWidget {
  const MuscleGroupCard({required this.muscleGroup, super.key});

  final MuscleGroup muscleGroup;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 1,
    child: ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      childrenPadding: const EdgeInsets.only(bottom: 8),
      title: Text(
        muscleGroup.name,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${muscleGroup.exercises.length} exercises',
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
      ),
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(
          _getIcon(muscleGroup.name),
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: muscleGroup.exercises.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) =>
              ExerciseListItem(exercise: muscleGroup.exercises[index]),
        ),
      ],
    ),
  );

  IconData _getIcon(String muscleGroupName) {
    final name = muscleGroupName.toLowerCase();
    if (name.contains('back')) {
      return Icons.fitness_center;
    }
    if (name.contains('chest')) {
      return Icons.favorite;
    }
    if (name.contains('shoulder') || name.contains('delt')) {
      return Icons.accessibility_new;
    }
    if (name.contains('bicep')) {
      return Icons.sports_martial_arts;
    }
    if (name.contains('tricep')) {
      return Icons.sports_martial_arts;
    }
    if (name.contains('leg') || name.contains('quad') || name.contains('ham')) {
      return Icons.directions_run;
    }
    if (name.contains('glute')) {
      return Icons.fitness_center;
    }
    if (name.contains('calf')) {
      return Icons.directions_walk;
    }
    if (name.contains('trap')) {
      return Icons.accessibility;
    }
    return Icons.fitness_center;
  }
}
