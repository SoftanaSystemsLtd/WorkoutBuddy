import 'package:intl/intl.dart';

/// Date and time helper utilities for workout scheduling.
class DateHelpers {
  /// Returns an integer day index (Sunday=1 ... Wednesday=4 cycling across 4-day plan)
  static int dayCycleIndex(DateTime date) {
    // Sunday=7 per DateTime.weekday; map Sunday->1, Monday->2, Tuesday->3, Wednesday->4, then cycle
    final weekday = date.weekday; // Monday=1 .. Sunday=7
    switch (weekday) {
      case DateTime.sunday: // 7
        return 1;
      case DateTime.monday:
        return 2;
      case DateTime.tuesday:
        return 3;
      case DateTime.wednesday:
        return 4;
      case DateTime.thursday:
        return 1;
      case DateTime.friday:
        return 2;
      case DateTime.saturday:
        return 3; // Start next cycle
      default:
        return 1;
    }
  }

  static String humanDate(DateTime date) => DateFormat('y-MM-dd').format(date);
}
