extension NullableStringX on String? {
  bool get isNullOrEmpty => this == null || this!.trim().isEmpty;
}

extension IterableX<T> on Iterable<T> {
  bool get isNullOrEmpty => isEmpty;
}

extension DateTimeX on DateTime {
  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;
}
