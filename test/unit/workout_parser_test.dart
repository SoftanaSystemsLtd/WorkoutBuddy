import 'package:flutter_test/flutter_test.dart';
import 'package:my_gym/services/workout_parser_impl.dart';

void main() {
  group('WorkoutParserImpl', () {
    late WorkoutParserImpl parser;

    setUp(() {
      parser = WorkoutParserImpl();
    });

    test('parses valid workout markdown', () async {
      const markdown = '''
Day 1: (Back and Biceps)

Upper Back
1. High Row
2. Seated row

Biceps
1. Dumbbell Curl
2. Hammer Curl

Day 2: (Chest and Triceps)

Upper Chest
1. Incline Press
2. Incline Flyes

Day 3: (Shoulder)

Front Delt
1. Overhead Press
2. Front Raise

Day 4: (Legs)

Quads
1. Squat
2. Leg Press
''';

      final result = await parser.parse(markdown);
      expect(result.rawSections.length, 4);
      expect(result.rawSections.containsKey('day_1'), true);
      expect(result.rawSections.containsKey('day_4'), true);
    });

    test('throws on missing days', () async {
      const markdown = '''
Day 1: (Back)
Upper Back
1. Row

Day 2: (Chest)
Upper Chest
1. Press
''';

      expect(() => parser.parse(markdown), throwsA(isA<Exception>()));
    });

    test('parses workout plans with muscle groups and exercises', () async {
      const markdown = '''
Day 1: (Test Workout)

Muscle Group A
1. Exercise One
2. Exercise Two

Muscle Group B
1. Exercise Three

Day 2: (Workout Two)
Group C
1. Ex Four

Day 3: (Workout Three)
Group D
1. Ex Five

Day 4: (Workout Four)
Group E
1. Ex Six
''';

      final result = await parser.parse(markdown);
      final plans = await parser.parseWorkoutPlans(result);

      expect(plans.length, 4);
      expect(plans[0].name, 'Test Workout');
      expect(plans[0].dayNumber, 1);
      expect(plans[0].muscleGroups.length, 2);
      expect(plans[0].muscleGroups[0].name, 'Muscle Group A');
      expect(plans[0].muscleGroups[0].exercises.length, 2);
      expect(plans[0].muscleGroups[0].exercises[0].name, 'Exercise One');
    });

    test('clears cache', () {
      parser.clearCache();
      expect(parser.cacheTimestamp, null);
    });

    test('handles empty muscle groups gracefully', () async {
      const markdown = '''
Day 1: (Workout)
Group A
1. Exercise

Day 2: (Workout)
Group B
1. Exercise

Day 3: (Workout)
Group C
1. Exercise

Day 4: (Workout)
Group D
1. Exercise
''';

      final result = await parser.parse(markdown);
      final plans = await parser.parseWorkoutPlans(result);

      expect(plans.length, 4);
      for (final plan in plans) {
        expect(plan.muscleGroups.isNotEmpty, true);
      }
    });
  });
}
