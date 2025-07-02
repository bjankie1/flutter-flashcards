import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';
import '../model/users_collaboration.dart';
import '../decks/deck_list/decks_controller.dart';
import '../common/dates.dart';

part 'statistics_page_controller.g.dart';

/// Data class representing the statistics page state
class StatisticsPageData {
  final String? selectedUserId;
  final DateTimeRange selectedDateRange;
  final DateFilter dateFilter;
  final bool isLoading;
  final String? errorMessage;

  const StatisticsPageData({
    this.selectedUserId,
    required this.selectedDateRange,
    required this.dateFilter,
    this.isLoading = false,
    this.errorMessage,
  });

  StatisticsPageData copyWith({
    String? selectedUserId,
    DateTimeRange? selectedDateRange,
    DateFilter? dateFilter,
    bool? isLoading,
    String? errorMessage,
  }) {
    return StatisticsPageData(
      selectedUserId: selectedUserId ?? this.selectedUserId,
      selectedDateRange: selectedDateRange ?? this.selectedDateRange,
      dateFilter: dateFilter ?? this.dateFilter,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Date filtering options
enum DateFilter {
  lastWeek,
  lastMonth,
  custom;

  DateTimeRange range() {
    switch (this) {
      case lastWeek:
        return DateTimeRange(
          start: currentClockDateTime.subtract(Duration(days: 7)),
          end: currentClockDateTime,
        );
      case DateFilter.lastMonth:
        return DateTimeRange(
          start: currentClockDateTime.subtract(Duration(days: 30)),
          end: currentClockDateTime,
        );
      case DateFilter.custom:
        throw UnimplementedError();
    }
  }
}

/// Controller for managing statistics page operations
@riverpod
class StatisticsPageController extends _$StatisticsPageController {
  final _log = Logger();

  @override
  StatisticsPageData build() {
    return StatisticsPageData(
      selectedDateRange: DateFilter.lastWeek.range(),
      dateFilter: DateFilter.lastWeek,
    );
  }

  /// Updates the selected user ID
  void updateSelectedUser(String? userId) {
    _log.d('Updating selected user to: $userId');
    state = state.copyWith(selectedUserId: userId);
  }

  /// Updates the date filter
  void updateDateFilter(DateFilter filter) {
    _log.d('Updating date filter to: $filter');
    DateTimeRange newRange;
    if (filter != DateFilter.custom) {
      newRange = filter.range();
    } else {
      newRange = state.selectedDateRange;
    }
    state = state.copyWith(dateFilter: filter, selectedDateRange: newRange);
  }

  /// Updates the custom date range
  void updateCustomDateRange(DateTimeRange range) {
    _log.d('Updating custom date range to: ${range.start} - ${range.end}');
    state = state.copyWith(
      dateFilter: DateFilter.custom,
      selectedDateRange: range,
    );
  }
}

/// Provider for loading users with stats access
@riverpod
Future<Iterable<UserProfile>> usersWithStatsAccess(Ref ref) async {
  final repository = ref.read(cardsRepositoryProvider);
  return await repository.listOwnStatsGrants();
}
