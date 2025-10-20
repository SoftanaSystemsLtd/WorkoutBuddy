import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({
    required this.currentIndex,
    required this.onSelected,
    super.key,
  });
  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => NavigationBar(
    selectedIndex: currentIndex,
    onDestinationSelected: onSelected,
    destinations: const [
      NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
      NavigationDestination(icon: Icon(Icons.fitness_center), label: 'Workout'),
      NavigationDestination(icon: Icon(Icons.history), label: 'History'),
    ],
  );
}
