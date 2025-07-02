import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/model/cards.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';
import '../model/cards.dart' as model;
import '../common/dates.dart';

part 'reviews_history_controller.g.dart';

/// Data class representing the review history state
class ReviewHistoryData {
  final List<DateTime> days;
  final Map<DateTime, int> cardReviewedPerDay;
  final bool isLoading;
  final String? errorMessage;

  const ReviewHistoryData({
    required this.days,
    required this.cardReviewedPerDay,
    this.isLoading = false,
    this.errorMessage,
  });

  ReviewHistoryData copyWith({
    List<DateTime>? days,
    Map<DateTime, int>? cardReviewedPerDay,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ReviewHistoryData(
      days: days ?? this.days,
      cardReviewedPerDay: cardReviewedPerDay ?? this.cardReviewedPerDay,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Controller for managing review history operations
@riverpod
class ReviewHistoryController extends _$ReviewHistoryController {
  final _log = Logger();

  @override
  ReviewHistoryData build(
    Iterable<model.CardAnswer> answers,
    DateTimeRange dateRange,
  ) {
    _log.d(
      'Building review history data for date range: ${dateRange.start} to ${dateRange.end}',
    );

    final days = _generateDays(dateRange);
    final cardReviewedPerDay = _calculateCardReviewedPerDay(answers);

    return ReviewHistoryData(
      days: days,
      cardReviewedPerDay: cardReviewedPerDay,
    );
  }

  /// Generates list of dates within date range. Each day is represented by a [DateTime]
  /// of the day beginning.
  List<DateTime> _generateDays(DateTimeRange dateRange) {
    final days = <DateTime>[];
    DateTime current = dateRange.start.dayStart;
    while (current.isBefore(dateRange.end)) {
      days.add(current);
      current = current
          .add(const Duration(days: 1))
          .dayStart; // start of day conversion required again due to daytime saving
    }
    return days;
  }

  /// Calculates the number of cards reviewed per day
  Map<DateTime, int> _calculateCardReviewedPerDay(
    Iterable<model.CardAnswer> answers,
  ) {
    return answers.fold<Map<DateTime, int>>({}, (acc, answer) {
      final day = answer.reviewStart.dayStart;
      acc[day] = (acc[day] ?? 0) + 1;
      return acc;
    });
  }

  /// Refreshes the data with new answers and date range
  void refreshData(
    Iterable<model.CardAnswer> answers,
    DateTimeRange dateRange,
  ) {
    _log.d('Refreshing review history data');
    state = build(answers, dateRange);
  }
}
