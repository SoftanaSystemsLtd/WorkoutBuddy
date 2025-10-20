import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/workout_plan.dart';
import '../providers/workout_provider.dart';

/// A bottom sheet / panel widget that lets user pick which workout day
/// to use manually or revert to automatic recommendation.
class WorkoutDayPicker extends StatelessWidget {
  const WorkoutDayPicker({super.key});

  @override
  Widget build(BuildContext context) => Consumer<WorkoutProvider>(
    builder: (context, provider, _) {
      final plans = provider.workoutPlans;
      if (plans == null) {
        return const Center(child: CircularProgressIndicator());
      }
      final manualIndex = provider.manualPlanIndex;
      final recommendedIndex = provider.recommendedPlanIndex;

      return ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Select Workout Day',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ],
            ),
          ),
          const Divider(height: 0),
          ...List.generate(plans.length, (index) {
            final plan = plans[index];
            final isManual = manualIndex == index;
            final isRecommended = recommendedIndex == index;
            return _DayTile(
              plan: plan,
              index: index,
              isManual: isManual,
              isRecommended: isRecommended,
              onTap: () {
                provider.selectPlanByIndex(index);
                Navigator.of(context).pop();
              },
            );
          }),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Revert to automatic selection'),
            subtitle: const Text('Use weekday-based rotation'),
            onTap: () {
              provider.clearManualPlanSelection();
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

class _DayTile extends StatelessWidget {
  const _DayTile({
    required this.plan,
    required this.index,
    required this.isManual,
    required this.isRecommended,
    required this.onTap,
  });

  final WorkoutPlan plan;
  final int index;
  final bool isManual;
  final bool isRecommended;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final badgeColor = isManual
        ? colorScheme.primary
        : (isRecommended ? colorScheme.secondary : null);
    final badgeLabel = isManual
        ? 'Selected'
        : (isRecommended ? 'Recommended' : null);
    final backgroundColor = badgeColor?.withValues(alpha: 0.15);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: backgroundColor,
        child: Text('${plan.dayNumber}'),
      ),
      title: Text(plan.name),
      subtitle: Text('${plan.muscleGroups.length} groups'),
      trailing: badgeLabel == null
          ? null
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: badgeColor ?? Colors.transparent),
              ),
              child: Text(
                badgeLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: badgeColor,
                ),
              ),
            ),
      onTap: onTap,
    );
  }
}

/// Helper to display the picker as a modal bottom sheet.
Future<void> showWorkoutDayPicker(BuildContext context) async {
  await showModalBottomSheet(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (context) =>
        const SizedBox(height: 420, child: WorkoutDayPicker()),
  );
}
