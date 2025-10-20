import 'package:flutter_test/flutter_test.dart';
import 'package:my_gym/providers/workout_provider.dart';

void main() {
  group('Daily Workout Logic', () {
    test('computeWorkoutDayIndex returns correct day for Sunday (0)', () {
      // Sunday should map to Day 1 (index 0)
      final sunday = DateTime(2024, 1, 7); // A known Sunday
      expect(sunday.weekday, equals(DateTime.sunday));
      expect(WorkoutProvider.computeWorkoutDayIndex(sunday), equals(0));
    });

    test('computeWorkoutDayIndex returns correct day for Monday (1)', () {
      // Monday should map to Day 2 (index 1)
      final monday = DateTime(2024, 1, 8); // A known Monday
      expect(monday.weekday, equals(DateTime.monday));
      expect(WorkoutProvider.computeWorkoutDayIndex(monday), equals(1));
    });

    test('computeWorkoutDayIndex returns correct day for Tuesday (2)', () {
      // Tuesday should map to Day 3 (index 2)
      final tuesday = DateTime(2024, 1, 9); // A known Tuesday
      expect(tuesday.weekday, equals(DateTime.tuesday));
      expect(WorkoutProvider.computeWorkoutDayIndex(tuesday), equals(2));
    });

    test('computeWorkoutDayIndex returns correct day for Wednesday (3)', () {
      // Wednesday should map to Day 4 (index 3)
      final wednesday = DateTime(2024, 1, 10); // A known Wednesday
      expect(wednesday.weekday, equals(DateTime.wednesday));
      expect(WorkoutProvider.computeWorkoutDayIndex(wednesday), equals(3));
    });

    test('computeWorkoutDayIndex cycles back for Thursday', () {
      // Thursday should cycle back to Day 1 (index 0)
      final thursday = DateTime(2024, 1, 11); // A known Thursday
      expect(thursday.weekday, equals(DateTime.thursday));
      expect(WorkoutProvider.computeWorkoutDayIndex(thursday), equals(0));
    });

    test('computeWorkoutDayIndex cycles back for Friday', () {
      // Friday should cycle back to Day 2 (index 1)
      final friday = DateTime(2024, 1, 12); // A known Friday
      expect(friday.weekday, equals(DateTime.friday));
      expect(WorkoutProvider.computeWorkoutDayIndex(friday), equals(1));
    });

    test('computeWorkoutDayIndex cycles back for Saturday', () {
      // Saturday should cycle back to Day 3 (index 2)
      final saturday = DateTime(2024, 1, 13); // A known Saturday
      expect(saturday.weekday, equals(DateTime.saturday));
      expect(WorkoutProvider.computeWorkoutDayIndex(saturday), equals(2));
    });

    test('computeWorkoutDayIndex handles different weeks consistently', () {
      // Test that the same weekday in different weeks maps to the same index
      final sunday1 = DateTime(2024, 1, 7);
      final sunday2 = DateTime(2024, 1, 14);
      final sunday3 = DateTime(2024, 2, 4);

      expect(
        WorkoutProvider.computeWorkoutDayIndex(sunday1),
        equals(WorkoutProvider.computeWorkoutDayIndex(sunday2)),
      );
      expect(
        WorkoutProvider.computeWorkoutDayIndex(sunday1),
        equals(WorkoutProvider.computeWorkoutDayIndex(sunday3)),
      );
    });

    test('4-day cycle covers all days of the week', () {
      // Verify that all 7 days map to indices 0-3
      final dates = [
        DateTime(2024, 1, 7), // Sunday
        DateTime(2024, 1, 8), // Monday
        DateTime(2024, 1, 9), // Tuesday
        DateTime(2024, 1, 10), // Wednesday
        DateTime(2024, 1, 11), // Thursday
        DateTime(2024, 1, 12), // Friday
        DateTime(2024, 1, 13), // Saturday
      ];

      final indices = dates
          .map(WorkoutProvider.computeWorkoutDayIndex)
          .toList();

      // Should only contain values 0, 1, 2, 3
      expect(indices.every((index) => index >= 0 && index <= 3), isTrue);

      // Should contain all four values
      expect(indices.toSet().length, equals(4));
    });
  });
}
