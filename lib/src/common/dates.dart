extension DateTimeExtensions on DateTime {
  DateTime get dayEnd =>
      copyWith(hour: 23, minute: 59, second: 59, millisecond: 999);
  DateTime get dayStart =>
      copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);
}
