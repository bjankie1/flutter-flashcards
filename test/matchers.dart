import 'package:flutter_test/flutter_test.dart';

Matcher closeToTime(DateTime expected,
    {Duration tolerance = const Duration(seconds: 1)}) {
  return predicate<DateTime>((actual) {
    final diff = (actual.difference(expected)).abs();
    return diff <= tolerance;
  }, 'is within $tolerance of $expected');
}

Matcher isBefore(DateTime expected) => _IsBefore(expected);

class _IsBefore extends Matcher {
  final DateTime _other;
  _IsBefore(this._other);

  @override
  bool matches(Object? item, Map matchState) =>
      item is DateTime && item.isBefore(_other);

  @override
  Description describe(Description description) =>
      description.add('is before ').addDescriptionOf(_other);
}

Matcher isAfter(DateTime expected) => _IsAfter(expected);

class _IsAfter extends Matcher {
  final DateTime _other;
  _IsAfter(this._other);

  @override
  bool matches(Object? item, Map matchState) =>
      item is DateTime && item.isAfter(_other);

  @override
  Description describe(Description description) =>
      description.add('is after ').addDescriptionOf(_other);
}
