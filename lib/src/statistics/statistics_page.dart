import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/dates.dart';
import 'package:flutter_flashcards/src/layout/base_layout.dart';
import 'package:flutter_flashcards/src/model/users_collaboration.dart';
import 'package:flutter_flashcards/src/statistics/select_person_focus.dart';
import 'package:flutter_flashcards/src/statistics/statistics_charts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class StudyStatisticsPage extends StatefulWidget {
  @override
  State<StudyStatisticsPage> createState() => _StudyStatisticsPageState();
}

class _StudyStatisticsPageState extends State<StudyStatisticsPage> {
  ValueNotifier<String?> selectedUser = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
        title: Text(context.l10n.statistics),
        currentPage: PageIndex.statistics,
        child: ChangeNotifierProvider(
          create: (context) => FiltersModel(),
          child: Column(
            children: [
              Row(
                children: [
                  StatisticsFilter(),
                  Spacer(),
                  SelectPersonFocus(
                    onUserChange: (uid) {
                      selectedUser.value = uid;
                    },
                  ),
                  SizedBox(
                    width: 20,
                  ),
                ],
              ),
              Expanded(
                child: ValueListenableBuilder(
                    valueListenable: selectedUser,
                    builder: (context, uid, _) {
                      return StatisticsCharts(uid);
                    }),
              )
            ],
          ),
        ));
  }
}

enum PartOfDay {
  morning(8),
  afternoon(12),
  evening(18),
  night(24);

  final int lastHour;

  const PartOfDay(this.lastHour);

  static fromHour(int hour) =>
      PartOfDay.values.firstWhere((p) => p.lastHour >= hour);
}

/// Date filtering

enum DateFilter {
  lastWeek,
  lastMonth,
  custom;

  DateTimeRange range() {
    switch (this) {
      case lastWeek:
        return DateTimeRange(
            start: currentClockDateTime.subtract(Duration(days: 7)),
            end: currentClockDateTime);
      case DateFilter.lastMonth:
        return DateTimeRange(
            start: currentClockDateTime.subtract(Duration(days: 30)),
            end: currentClockDateTime);
      case DateFilter.custom:
        throw UnimplementedError();
    }
  }
}

class FiltersModel extends ChangeNotifier {
  DateTimeRange _selectedDates = DateFilter.lastWeek.range();

  DateFilter _dateFilter = DateFilter.lastWeek;

  DateTimeRange get selectedDates => _selectedDates;

  DateFilter get dateFilter => _dateFilter;

  set dateFilter(DateFilter value) {
    _dateFilter = value;
    if (value != DateFilter.custom) _selectedDates = value.range();
    notifyListeners();
  }

  set selectedDates(DateTimeRange value) {
    _selectedDates = value;
    _dateFilter = DateFilter.custom;
    notifyListeners();
  }
}

class StatisticsFilter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserProfile?>(
        // Add this ValueListenableBuilder
        valueListenable: context.appState.userProfile,
        builder: (context, userProfile, _) {
          final locale = userProfile?.locale;
          final dateFormat = DateFormat.yMEd(locale?.toLanguageTag());

          return Consumer<FiltersModel>(builder: (context, model, child) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: SegmentedButton(
                emptySelectionAllowed: true,
                onSelectionChanged: (value) {
                  model.dateFilter = value.first;
                },
                segments: [
                  ButtonSegment(
                      value: DateFilter.lastWeek,
                      label: Text(context.l10n.weekDurationFilterLabel)),
                  ButtonSegment(
                      value: DateFilter.lastMonth,
                      label: Text(context.l10n.monthDurationFilterLabel)),
                  ButtonSegment(
                      value: DateFilter.custom,
                      label: Row(
                        children: [
                          Text(
                              '${dateFormat.format(model.selectedDates.start)} - ${dateFormat.format(model.selectedDates.end)}'),
                          IconButton(
                            onPressed: () async {
                              DateTimeRange? range = await showDateRangePicker(
                                  context: context,
                                  firstDate: DateTime(2024),
                                  lastDate: currentClockDateTime);
                              if (range != null) {
                                model.selectedDates = range;
                              }
                            },
                            icon: Icon(Icons.calendar_month),
                          )
                        ],
                      ))
                ],
                selected: {model._dateFilter},
              ),
            );
          });
        });
  }
}