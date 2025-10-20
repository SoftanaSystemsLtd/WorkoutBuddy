import 'package:flutter/foundation.dart';

enum SessionStatus { inProgress, completed, abandoned }

@immutable
class WorkoutSession {
  const WorkoutSession({
    required this.id,
    required this.workoutPlanId,
    required this.startTime,
    required this.status,
    required this.completedExercises,
    this.endTime,
  });

  factory WorkoutSession.fromJson(Map<String, dynamic> json) => WorkoutSession(
    id: json['id'] as String,
    workoutPlanId: json['workoutPlanId'] as String,
    startTime: DateTime.parse(json['startTime'] as String),
    endTime: (json['endTime'] as String?)?.let(DateTime.parse),
    status: SessionStatus.values.firstWhere(
      (e) => e.name == (json['status'] as String),
    ),
    completedExercises: (json['completedExercises'] as List<dynamic>)
        .map((e) => ExerciseSet.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  final String id; // UUID
  final String workoutPlanId;
  final DateTime startTime;
  final DateTime? endTime;
  final SessionStatus status;
  final List<ExerciseSet> completedExercises;

  /// Runtime validation for invariants that cannot be expressed in const asserts.
  /// Throws [ArgumentError] describing the first violation found.
  void validate() {
    if (id.isEmpty) {
      throw ArgumentError('id cannot be empty');
    }
    if (workoutPlanId.isEmpty) {
      throw ArgumentError('workoutPlanId cannot be empty');
    }
    if (endTime != null && !endTime!.isAfter(startTime)) {
      throw ArgumentError('endTime must be after startTime');
    }
    for (final e in completedExercises) {
      e.validate();
    }
  }

  Duration get duration => (endTime ?? DateTime.now()).difference(startTime);

  bool get isActive => status == SessionStatus.inProgress;

  WorkoutSession copyWith({
    DateTime? endTime,
    SessionStatus? status,
    List<ExerciseSet>? completedExercises,
  }) => WorkoutSession(
    id: id,
    workoutPlanId: workoutPlanId,
    startTime: startTime,
    endTime: endTime ?? this.endTime,
    status: status ?? this.status,
    completedExercises: completedExercises ?? this.completedExercises,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'workoutPlanId': workoutPlanId,
    'startTime': startTime.toIso8601String(),
    if (endTime != null) 'endTime': endTime!.toIso8601String(),
    'status': status.name,
    'completedExercises': completedExercises.map((e) => e.toJson()).toList(),
  };
}

@immutable
class ExerciseSet {
  const ExerciseSet({
    required this.exerciseName,
    required this.sets,
    required this.completedAt,
    this.notes,
  }) : assert(exerciseName != '');

  factory ExerciseSet.fromJson(Map<String, dynamic> json) => ExerciseSet(
    exerciseName: json['exerciseName'] as String,
    sets: (json['sets'] as List<dynamic>)
        .map((e) => SetData.fromJson(e as Map<String, dynamic>))
        .toList(),
    completedAt: DateTime.parse(json['completedAt'] as String),
    notes: json['notes'] as String?,
  );

  final String exerciseName;
  final List<SetData> sets;
  final DateTime completedAt;
  final String? notes;

  /// Validate dynamic invariants. Throws [ArgumentError] if invalid.
  void validate() {
    if (exerciseName.isEmpty) {
      throw ArgumentError('exerciseName cannot be empty');
    }
    if (sets.isEmpty) {
      throw ArgumentError('sets cannot be empty for $exerciseName');
    }
    if (completedAt.isAfter(DateTime.now())) {
      throw ArgumentError(
        'completedAt cannot be in the future for $exerciseName',
      );
    }
    for (final s in sets) {
      s.validate();
    }
  }

  Map<String, dynamic> toJson() => {
    'exerciseName': exerciseName,
    'sets': sets.map((e) => e.toJson()).toList(),
    'completedAt': completedAt.toIso8601String(),
    if (notes != null) 'notes': notes,
  };
}

@immutable
class SetData {
  const SetData({required this.reps, this.weight, this.restTime})
    : assert(reps > 0),
      assert(weight == null || weight >= 0);

  factory SetData.fromJson(Map<String, dynamic> json) => SetData(
    reps: json['reps'] as int,
    weight: (json['weight'] as num?)?.toDouble(),
    restTime: (json['restTime'] as String?)?.let(_parseDurationIso8601),
  );

  final int reps;
  final double? weight; // in kg
  final Duration? restTime;

  void validate() {
    if (reps <= 0) {
      throw ArgumentError('reps must be > 0');
    }
    if (weight != null && weight! < 0) {
      throw ArgumentError('weight must be >= 0');
    }
    if (restTime != null && restTime!.isNegative) {
      throw ArgumentError('restTime must be positive');
    }
  }

  Map<String, dynamic> toJson() => {
    'reps': reps,
    if (weight != null) 'weight': weight,
    if (restTime != null) 'restTime': _durationToIso8601(restTime!),
  };
}

String _durationToIso8601(Duration d) => 'PT${d.inSeconds}S';
Duration _parseDurationIso8601(String input) {
  // Very simple parser PT<seconds>S
  final match = RegExp(r'^PT(\d+)S$').firstMatch(input);
  if (match == null) {
    throw ArgumentError('Invalid duration format: $input');
  }
  return Duration(seconds: int.parse(match.group(1)!));
}

extension _NullableMap<T> on T? {
  R? let<R>(R Function(T value) block) {
    final self = this;
    return self == null ? null : block(self);
  }
}
