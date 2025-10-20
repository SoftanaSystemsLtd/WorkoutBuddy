import 'package:flutter/foundation.dart';

@immutable
class WorkoutPlan {
  const WorkoutPlan({
    required this.id,
    required this.name,
    required this.dayNumber,
    required this.muscleGroups,
  }) : assert(dayNumber >= 1 && dayNumber <= 4, 'dayNumber must be 1-4');

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) => WorkoutPlan(
    id: json['id'] as String,
    name: json['name'] as String,
    dayNumber: json['dayNumber'] as int,
    muscleGroups: (json['muscleGroups'] as List<dynamic>)
        .map((e) => MuscleGroup.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  final String id; // day_1 .. day_4
  final String name; // e.g. Back and Biceps
  final int dayNumber; // 1..4
  final List<MuscleGroup> muscleGroups;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'dayNumber': dayNumber,
    'muscleGroups': muscleGroups.map((e) => e.toJson()).toList(),
  };
}

@immutable
class MuscleGroup {
  const MuscleGroup({
    required this.name,
    required this.exercises,
    this.category,
  }) : assert(name != '');

  factory MuscleGroup.fromJson(Map<String, dynamic> json) => MuscleGroup(
    name: json['name'] as String,
    category: json['category'] as String?,
    exercises: (json['exercises'] as List<dynamic>)
        .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  final String name;
  final List<Exercise> exercises;
  final String? category;

  Map<String, dynamic> toJson() => {
    'name': name,
    if (category != null) 'category': category,
    'exercises': exercises.map((e) => e.toJson()).toList(),
  };
}

@immutable
class Exercise {
  const Exercise({
    required this.name,
    required this.order,
    required this.muscleGroup,
  }) : assert(name != ''),
       assert(order >= 1);

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
    name: json['name'] as String,
    order: json['order'] as int,
    muscleGroup: json['muscleGroup'] as String? ?? '',
  );

  final String name;
  final int order;
  final String muscleGroup; // parent name reference

  Map<String, dynamic> toJson() => {
    'name': name,
    'order': order,
    'muscleGroup': muscleGroup,
  };
}
