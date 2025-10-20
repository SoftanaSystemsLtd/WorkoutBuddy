import 'package:flutter/material.dart';

/// Centralized application constants and theme references.
class AppColors {
  static const primary = Colors.blueGrey;
  static const accent = Colors.indigo;
  static const success = Colors.green;
  static const warning = Colors.orange;
  static const error = Colors.redAccent;
}

class AppDurations {
  static const short = Duration(milliseconds: 150);
  static const medium = Duration(milliseconds: 300);
  static const long = Duration(milliseconds: 600);
}

class AppStrings {
  static const appName = 'My Gym';
  static const homeTitle = 'Daily Workout';
  static const workoutTitle = 'Active Workout';
  static const historyTitle = 'Workout History';
}
