import 'package:flutter/material.dart';
import '../models/workout_plan.dart';

class ExerciseListItem extends StatelessWidget {
  const ExerciseListItem({required this.exercise, this.onTap, super.key});

  final Exercise exercise;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    leading: CircleAvatar(
      radius: 16,
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      child: Text(
        '${exercise.order}',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
      ),
    ),
    title: Text(exercise.name, style: Theme.of(context).textTheme.bodyLarge),
    onTap: onTap,
  );
}
