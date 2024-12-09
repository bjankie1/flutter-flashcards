import 'package:flutter_test/flutter_test.dart';

Matcher closeToTime(DateTime expected,
    {Duration tolerance = const Duration(seconds: 1)}) {
  return predicate<DateTime>((actual) {
    final diff = (actual.difference(expected)).abs();
    return diff <= tolerance;
  }, 'is within $tolerance of $expected');
}
