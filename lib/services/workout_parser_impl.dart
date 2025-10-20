import 'package:flutter/services.dart' show rootBundle;
import '../models/workout_plan.dart';
import 'workout_parser_service.dart';

/// Concrete implementation of workout parser service.
class WorkoutParserImpl implements WorkoutParserService {
  DateTime? _cacheTimestamp;

  @override
  Future<ParsedWorkoutData> parse(String markdown) async {
    final sections = <String, String>{};
    final lines = markdown.split('\n');

    String? currentDay;
    final buffer = StringBuffer();

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      // Match day headers: Day 1:, Day 2:, etc.
      final dayMatch = RegExp(
        r'^Day\s+(\d+):\s*(.*)$',
        caseSensitive: false,
      ).firstMatch(line);

      if (dayMatch != null) {
        // Save previous section
        if (currentDay != null && buffer.isNotEmpty) {
          sections[currentDay] = buffer.toString().trim();
          buffer.clear();
        }

        final dayNum = dayMatch.group(1)!;
        currentDay = 'day_$dayNum';
        buffer.writeln(line); // Include header in section
      } else if (currentDay != null) {
        buffer.writeln(line);
      }
    }

    // Save last section
    if (currentDay != null && buffer.isNotEmpty) {
      sections[currentDay] = buffer.toString().trim();
    }

    // Validate we have 4 days
    if (sections.length != 4) {
      throw WorkoutParseException(
        'Expected 4 workout days, found ${sections.length}',
      );
    }

    for (var i = 1; i <= 4; i++) {
      if (!sections.containsKey('day_$i')) {
        throw WorkoutParseException('Missing day_$i in workout file');
      }
    }

    _cacheTimestamp = DateTime.now();

    return ParsedWorkoutData(sections);
  }

  @override
  Future<ParsedWorkoutData> parseAsset(String assetPath) async {
    try {
      final content = await rootBundle.loadString(assetPath);
      return parse(content);
    } catch (e) {
      throw WorkoutParseException('Failed to load asset: $assetPath - $e');
    }
  }

  @override
  void clearCache() {
    _cacheTimestamp = null;
  }

  /// Parse structured WorkoutPlan objects from cached sections.
  Future<List<WorkoutPlan>> parseWorkoutPlans(ParsedWorkoutData data) async {
    final plans = <WorkoutPlan>[];

    for (var i = 1; i <= 4; i++) {
      final id = 'day_$i';
      final content = data.rawSections[id]!;

      // Extract day name from first line: "Day 1: (Back and Biceps)"
      final lines = content.split('\n');
      final firstLine = lines.first;
      final nameMatch = RegExp(
        r'Day\s+\d+:\s*\(([^)]+)\)',
        caseSensitive: false,
      ).firstMatch(firstLine);
      final name = nameMatch?.group(1)?.trim() ?? 'Day $i';

      final muscleGroups = _parseMuscleGroups(lines.skip(1).toList());

      plans.add(
        WorkoutPlan(
          id: id,
          name: name,
          dayNumber: i,
          muscleGroups: muscleGroups,
        ),
      );
    }

    return plans;
  }

  List<MuscleGroup> _parseMuscleGroups(List<String> lines) {
    final groups = <MuscleGroup>[];
    String? currentGroup;
    final exercises = <Exercise>[];
    var exerciseOrder = 1;

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        continue;
      }

      // Exercise line: starts with number and period (e.g., "1. High Row")
      final exerciseMatch = RegExp(r'^\d+\.\s+(.+)$').firstMatch(trimmed);

      if (exerciseMatch != null) {
        // This is an exercise
        final exerciseName = exerciseMatch.group(1)!.trim();
        exercises.add(
          Exercise(
            name: exerciseName,
            order: exerciseOrder++,
            muscleGroup: currentGroup ?? '',
          ),
        );
      } else if (trimmed.isNotEmpty && !trimmed.startsWith('Day')) {
        // This is a muscle group header
        // Save previous group
        if (currentGroup != null && exercises.isNotEmpty) {
          groups.add(
            MuscleGroup(name: currentGroup, exercises: List.from(exercises)),
          );
          exercises.clear();
          exerciseOrder = 1;
        }

        currentGroup = trimmed;
      }
    }

    // Save last group
    if (currentGroup != null && exercises.isNotEmpty) {
      groups.add(
        MuscleGroup(name: currentGroup, exercises: List.from(exercises)),
      );
    }

    return groups;
  }

  DateTime? get cacheTimestamp => _cacheTimestamp;
}
