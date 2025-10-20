import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/workout_plan.dart';
import '../providers/workout_provider.dart';
import '../widgets/muscle_group_card.dart';
import '../widgets/workout_day_picker.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Today\'s Workout'),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            context.read<WorkoutProvider>().refreshWorkoutPlans();
          },
          tooltip: 'Refresh workout plans',
        ),
        IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () => showWorkoutDayPicker(context),
          tooltip: 'Select workout day',
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
          tooltip: 'Settings',
        ),
      ],
    ),
    body: Consumer<WorkoutProvider>(
      builder: (context, provider, child) {
        // Loading state
        if (provider.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading workout plans...'),
              ],
            ),
          );
        }

        // Error state
        if (provider.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage ?? 'An error occurred',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => provider.initialize(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Empty state
        final currentPlan = provider.currentDayPlan;
        if (currentPlan == null) {
          return const Center(child: Text('No workout plan available'));
        }

        // Success state - display workout plan
        return RefreshIndicator(
          onRefresh: () => provider.refreshWorkoutPlans(),
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Day header
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Day ${currentPlan.dayNumber}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentPlan.name,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${currentPlan.muscleGroups.length} muscle groups • '
                        '${_countTotalExercises(currentPlan)} exercises',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Muscle groups
              ...currentPlan.muscleGroups.map(
                (group) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: MuscleGroupCard(muscleGroup: group),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );

  int _countTotalExercises(WorkoutPlan workoutPlan) =>
      workoutPlan.muscleGroups.fold<int>(
        0,
        (int sum, MuscleGroup group) => sum + group.exercises.length,
      );
}
