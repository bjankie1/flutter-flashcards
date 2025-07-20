import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/dates.dart';
import 'package:flutter_flashcards/src/layout/base_layout.dart';
import 'package:flutter_flashcards/src/model/users_collaboration.dart';
import 'package:flutter_flashcards/src/statistics/select_person_focus.dart';
import 'package:flutter_flashcards/src/statistics/statistics_charts.dart';
import 'package:flutter_flashcards/src/statistics/statistics_page_controller.dart';
import 'package:intl/intl.dart';

class StudyStatisticsPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statisticsData = ref.watch(statisticsPageControllerProvider);

    return BaseLayout(
      title: Text(context.l10n.statistics),
      currentPage: PageIndex.statistics,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StatisticsFilter(),
                const SizedBox(width: 16),
                SelectPersonFocus(
                  userId: statisticsData.selectedUserId,
                  onUserChange: (uid) {
                    ref
                        .read(statisticsPageControllerProvider.notifier)
                        .updateSelectedUser(uid);
                  },
                ),
              ],
            ),
          ),
          Expanded(child: StatisticsCharts(statisticsData.selectedUserId)),
        ],
      ),
    );
  }
}

/// Date filtering

class StatisticsFilter extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ValueListenableBuilder<UserProfile?>(
      valueListenable: context.appState.userProfile,
      builder: (context, userProfile, _) {
        final locale = userProfile?.locale;
        final dateFormat = DateFormat.yMEd(locale?.toLanguageTag());
        final statisticsData = ref.watch(statisticsPageControllerProvider);

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SegmentedButton(
            emptySelectionAllowed: true,
            onSelectionChanged: (value) {
              ref
                  .read(statisticsPageControllerProvider.notifier)
                  .updateDateFilter(value.first);
            },
            segments: [
              ButtonSegment(
                value: DateFilter.lastWeek,
                label: Text(context.l10n.weekDurationFilterLabel),
              ),
              ButtonSegment(
                value: DateFilter.lastMonth,
                label: Text(context.l10n.monthDurationFilterLabel),
              ),
              ButtonSegment(
                value: DateFilter.custom,
                label: Row(
                  children: [
                    Text(
                      '${dateFormat.format(statisticsData.selectedDateRange.start)} - ${dateFormat.format(statisticsData.selectedDateRange.end)}',
                    ),
                    IconButton(
                      onPressed: () async {
                        DateTimeRange? range = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2024),
                          lastDate: currentClockDateTime,
                        );
                        if (range != null) {
                          ref
                              .read(statisticsPageControllerProvider.notifier)
                              .updateCustomDateRange(range);
                        }
                      },
                      icon: Icon(Icons.calendar_month),
                    ),
                  ],
                ),
              ),
            ],
            selected: {statisticsData.dateFilter},
          ),
        );
      },
    );
  }
}
