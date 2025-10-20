import 'package:flutter/material.dart';

@immutable
class AppSettings {
  const AppSettings({
    required this.workoutStartTime,
    required this.defaultRestTime,
    required this.weekStartDay,
    required this.reminderEnabled,
    required this.themeMode,
  });

  factory AppSettings.defaults() => const AppSettings(
    workoutStartTime: TimeOfDay(hour: 18, minute: 0),
    defaultRestTime: Duration(seconds: 90),
    weekStartDay: Weekday.sunday,
    reminderEnabled: true,
    themeMode: ThemeMode.system,
  );

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    workoutStartTime: _parseTime(json['workoutStartTime'] as String),
    defaultRestTime: Duration(seconds: json['defaultRestTime'] as int),
    weekStartDay: Weekday.values.firstWhere(
      (e) => e.name == (json['weekStartDay'] as String),
      orElse: () => Weekday.sunday,
    ),
    reminderEnabled: json['reminderEnabled'] as bool? ?? true,
    themeMode: _parseThemeMode(json['themeMode'] as String?),
  );

  final TimeOfDay workoutStartTime;
  final Duration defaultRestTime;
  final Weekday weekStartDay;
  final bool reminderEnabled;
  final ThemeMode themeMode;

  AppSettings copyWith({
    TimeOfDay? workoutStartTime,
    Duration? defaultRestTime,
    Weekday? weekStartDay,
    bool? reminderEnabled,
    ThemeMode? themeMode,
  }) => AppSettings(
    workoutStartTime: workoutStartTime ?? this.workoutStartTime,
    defaultRestTime: defaultRestTime ?? this.defaultRestTime,
    weekStartDay: weekStartDay ?? this.weekStartDay,
    reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    themeMode: themeMode ?? this.themeMode,
  );

  Map<String, dynamic> toJson() => {
    'workoutStartTime': _formatTime(workoutStartTime),
    'defaultRestTime': defaultRestTime.inSeconds,
    'weekStartDay': weekStartDay.name,
    'reminderEnabled': reminderEnabled,
    'themeMode': themeMode.name,
  };
}

enum Weekday { sunday, monday, tuesday, wednesday, thursday, friday, saturday }

String _formatTime(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
TimeOfDay _parseTime(String s) {
  final parts = s.split(':');
  return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
}

ThemeMode _parseThemeMode(String? name) {
  if (name == null) {
    return ThemeMode.system;
  }
  return ThemeMode.values.firstWhere(
    (e) => e.name == name,
    orElse: () => ThemeMode.system,
  );
}
