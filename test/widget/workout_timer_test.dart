import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_gym/services/timer_service.dart';
import 'package:my_gym/widgets/workout_timer.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WorkoutTimer widget', () {
    test('initializes to 00:00:00', () {
      final timerService = TimerService();
      expect(timerService.elapsed, equals(Duration.zero));
      expect(timerService.formatDuration(Duration.zero), equals('00:00:00'));
    });

    testWidgets('displays formatted time', (tester) async {
      final timerService = TimerService();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: timerService,
          child: const MaterialApp(home: Scaffold(body: WorkoutTimer())),
        ),
      );

      expect(find.textContaining('00:00:0'), findsOneWidget);

      timerService.dispose();
    });

    test('formats time correctly for different durations', () {
      final timerService = TimerService();
      expect(
        timerService.formatDuration(
          const Duration(hours: 1, minutes: 23, seconds: 45),
        ),
        equals('01:23:45'),
      );
      expect(
        timerService.formatDuration(const Duration(minutes: 5, seconds: 9)),
        equals('00:05:09'),
      );
      expect(
        timerService.formatDuration(const Duration(seconds: 1)),
        equals('00:00:01'),
      );
    });

    test('formats time correctly for different durations', () {
      final timerService = TimerService();
      expect(
        timerService.formatDuration(
          const Duration(hours: 1, minutes: 23, seconds: 45),
        ),
        equals('01:23:45'),
      );
      expect(
        timerService.formatDuration(const Duration(minutes: 5, seconds: 9)),
        equals('00:05:09'),
      );
      expect(
        timerService.formatDuration(const Duration(seconds: 1)),
        equals('00:00:01'),
      );
    });
  });
}
