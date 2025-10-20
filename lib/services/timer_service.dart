import 'dart:async';
import 'package:flutter/foundation.dart';

/// Service for tracking workout session time.
class TimerService extends ChangeNotifier {
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  DateTime? _startTime;
  bool _isRunning = false;

  Duration get elapsed => _elapsed;
  bool get isRunning => _isRunning;
  DateTime? get startTime => _startTime;

  /// Start the timer from a specific start time
  void start(DateTime startTime) {
    if (_isRunning) {
      return;
    }

    _startTime = startTime;
    _isRunning = true;

    // Calculate initial elapsed time if resuming
    _elapsed = DateTime.now().difference(startTime);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsed = DateTime.now().difference(_startTime!);
      notifyListeners();
    });

    notifyListeners();
  }

  /// Stop the timer
  void stop() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    notifyListeners();
  }

  /// Reset the timer
  void reset() {
    stop();
    _elapsed = Duration.zero;
    _startTime = null;
    notifyListeners();
  }

  /// Format duration as HH:MM:SS
  String formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
