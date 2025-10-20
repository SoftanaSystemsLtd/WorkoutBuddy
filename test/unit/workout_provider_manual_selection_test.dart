import 'package:flutter_test/flutter_test.dart';
import 'package:my_gym/providers/workout_provider.dart';
import 'package:my_gym/services/storage_service_impl.dart';
import 'package:my_gym/services/workout_parser_impl.dart';
import 'package:my_gym/services/workout_parser_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeParser extends WorkoutParserImpl {
  _FakeParser() : super();

  @override
  Future<ParsedWorkoutData> parseAsset(String path) async =>
      const ParsedWorkoutData({
        'day_1': 'Day 1: (Day 1)\nGroup A\n1. Exercise 1',
        'day_2': 'Day 2: (Day 2)\nGroup B\n1. Exercise 1',
        'day_3': 'Day 3: (Day 3)\nGroup C\n1. Exercise 1',
        'day_4': 'Day 4: (Day 4)\nGroup D\n1. Exercise 1',
      });
}

Future<StorageServiceImpl> _initStorage() async {
  SharedPreferences.setMockInitialValues({});
  final storage = StorageServiceImpl();
  await storage.init();
  return storage;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WorkoutProvider manual selection persistence', () {
    test('manual selection persists across provider instances', () async {
      final storage = await _initStorage();
      final parser = _FakeParser();
      final provider = WorkoutProvider(parser, storage);

      await provider.initialize();
      expect(provider.workoutPlans, isNotNull);
      await provider.initialize();
      provider.selectPlanByIndex(2); // Select third plan
      // Allow async persistence to complete
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(provider.manualPlanIndex, equals(2));
      final selectedId = provider.currentDayPlan?.id;

      // Recreate provider with same storage (simulating app restart)
      final provider2 = WorkoutProvider(parser, storage);
      await provider2.initialize();
      expect(provider2.manualPlanIndex, equals(2));
      expect(provider2.currentDayPlan?.id, equals(selectedId));

      // Clear manual selection and ensure it resets
      provider2.clearManualPlanSelection();
      expect(provider2.manualPlanIndex, isNull);

      // Recreate again and ensure manual selection not restored
      final provider3 = WorkoutProvider(parser, storage);
      await provider3.initialize();
      expect(provider3.manualPlanIndex, isNull);
    });
  });
}
