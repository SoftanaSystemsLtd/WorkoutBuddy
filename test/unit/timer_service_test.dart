import 'package:flutter_test/flutter_test.dart';
import 'package:my_gym/services/timer_service.dart';

void main() {
  group('TimerService unit tests', () {
    late TimerService timerService;

    setUp(() {
      timerService = TimerService();
    });

    tearDown(() {
      timerService.stop();
      timerService.dispose();
    });

    test('initializes with zero elapsed time', () {
      expect(timerService.elapsed, equals(Duration.zero));
      expect(timerService.isRunning, isFalse);
    });

    test('starts timer from given start time', () {
      final startTime = DateTime.now();
      timerService.start(startTime);

      expect(timerService.isRunning, isTrue);
      expect(timerService.startTime, equals(startTime));
    });

    test('calculates elapsed time correctly', () {
      final pastTime = DateTime.now().subtract(const Duration(seconds: 5));
      timerService.start(pastTime);

      expect(timerService.elapsed.inSeconds, greaterThanOrEqualTo(5));
    });

    test('stops timer', () {
      timerService.start(DateTime.now());
      expect(timerService.isRunning, isTrue);

      timerService.stop();
      expect(timerService.isRunning, isFalse);
    });

    test('resets timer to zero', () {
      final pastTime = DateTime.now().subtract(const Duration(minutes: 1));
      timerService.start(pastTime);

      timerService.reset();

      expect(timerService.elapsed, equals(Duration.zero));
      expect(timerService.isRunning, isFalse);
      expect(timerService.startTime, isNull);
    });

    test('formats duration as HH:MM:SS', () {
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
      expect(timerService.formatDuration(Duration.zero), equals('00:00:00'));
    });
  });
}
