import 'package:flutter/foundation.dart';

/// Errors that can occur during parsing of workout definitions.
class WorkoutParseException implements Exception {
  WorkoutParseException(this.message, {this.line});
  final String message;
  final int? line;
  @override
  String toString() =>
      'WorkoutParseException: $message${line != null ? ' (line $line)' : ''}';
}

/// Result of parsing: list of plan IDs mapped to raw text segments or structured objects later.
@immutable
class ParsedWorkoutData {
  const ParsedWorkoutData(this.rawSections);
  final Map<String, String> rawSections; // id -> raw markdown section
}

abstract class WorkoutParserService {
  /// Parses a markdown string containing workout plan definitions.
  /// Expected format sections starting with `## <id>`.
  /// Throws [WorkoutParseException] on structural errors.
  Future<ParsedWorkoutData> parse(String markdown);

  /// Convenience to parse from an asset path.
  Future<ParsedWorkoutData> parseAsset(String assetPath);

  /// Clears any in-memory cache.
  void clearCache();
}
