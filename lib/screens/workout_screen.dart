import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/workout_provider.dart';
import '../services/timer_service.dart';
import '../widgets/exercise_tracker.dart';
import '../widgets/workout_timer.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) => Consumer<WorkoutProvider>(
    builder: (context, provider, child) {
      // No active session - show start workout screen
      if (provider.activeSession == null) {
        return _buildStartWorkoutScreen(context, provider);
      }

      // Active session - show workout tracking
      return _buildActiveWorkoutScreen(context, provider);
    },
  );

  Widget _buildStartWorkoutScreen(
    BuildContext context,
    WorkoutProvider provider,
  ) {
    final currentPlan = provider.currentDayPlan;

    return Scaffold(
      appBar: AppBar(title: const Text('Start Workout')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.fitness_center,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Ready to workout?',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              if (currentPlan != null) ...[
                Text(
                  currentPlan.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${currentPlan.muscleGroups.length} muscle groups',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: currentPlan != null
                    ? () => _startWorkout(context, provider, currentPlan.id)
                    : null,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Workout'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveWorkoutScreen(
    BuildContext context,
    WorkoutProvider provider,
  ) {
    final session = provider.activeSession!;
    final plan = provider.workoutPlans?.firstWhere(
      (p) => p.id == session.workoutPlanId,
    );

    if (plan == null) {
      return const Scaffold(
        body: Center(child: Text('Workout plan not found')),
      );
    }

    // Flatten all exercises from all muscle groups
    final allExercises = plan.muscleGroups
        .expand((group) => group.exercises)
        .toList();

    final completedCount = session.completedExercises.length;
    final totalCount = allExercises.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(plan.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.stop),
            onPressed: () => _showEndWorkoutDialog(context, provider),
            tooltip: 'End workout',
          ),
        ],
      ),
      body: Column(
        children: [
          // Timer and progress header
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Column(
              children: [
                const WorkoutTimer(),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: totalCount > 0 ? completedCount / totalCount : 0,
                ),
                const SizedBox(height: 8),
                Text(
                  '$completedCount of $totalCount exercises completed',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),

          // Exercise list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: allExercises.length,
              itemBuilder: (context, index) {
                final exercise = allExercises[index];
                final existingSets = provider.getCompletedSets(exercise.name);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ExerciseTracker(
                    exercise: exercise,
                    existingSets: existingSets,
                    onSetsChanged: (sets) {
                      // Auto-save sets as they're entered
                      if (sets.isNotEmpty) {
                        provider.recordExercise(exercise.name, sets);
                      }
                    },
                    onComplete: () {
                      // Exercise marked complete
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${exercise.name} completed!'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: completedCount > 0
          ? FloatingActionButton.extended(
              onPressed: () => _showEndWorkoutDialog(context, provider),
              icon: const Icon(Icons.check),
              label: const Text('Finish Workout'),
            )
          : null,
    );
  }

  Future<void> _startWorkout(
    BuildContext context,
    WorkoutProvider provider,
    String planId,
  ) async {
    // Capture dependencies before async gap to avoid using BuildContext after await.
    final messenger = ScaffoldMessenger.of(context);
    final timer = context.read<TimerService>();

    await provider.startSession(planId);

    timer.start(DateTime.now());

    if (!context.mounted) {
      return;
    }
    messenger.showSnackBar(const SnackBar(content: Text('Workout started!')));
  }

  Future<void> _showEndWorkoutDialog(
    BuildContext context,
    WorkoutProvider provider,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Workout?'),
        content: const Text(
          'Are you sure you want to end this workout session? '
          'Your progress will be saved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('End Workout'),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      await _endWorkout(context, provider);
    }
  }

  Future<void> _endWorkout(
    BuildContext context,
    WorkoutProvider provider,
  ) async {
    // Stop timer
    final timer = context.read<TimerService>();
    timer.stop();

    await provider.endSession();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Workout completed! Great job!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
