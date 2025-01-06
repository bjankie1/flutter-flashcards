import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/app.dart';
import 'package:flutter_flashcards/src/app_state.dart';
import 'package:flutter_flashcards/src/base_layout.dart';
import 'package:flutter_flashcards/src/common/dates.dart';
import 'package:flutter_flashcards/src/statistics/base_statistics_table.dart';
import 'package:flutter_flashcards/src/statistics/decks_reviews_pie_chart.dart';
import 'package:flutter_flashcards/src/statistics/review_hours_histogram.dart';
import 'package:flutter_flashcards/src/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class StudyStatisticsPage extends StatefulWidget {
  @override
  State<StudyStatisticsPage> createState() => _StudyStatisticsPageState();
}

class _StudyStatisticsPageState extends State<StudyStatisticsPage> {
  @override
  Widget build(BuildContext context) {
    return BaseLayout(
        title: context.l10n.statistics,
        currentPage: PageIndex.statistics,
        child: ChangeNotifierProvider(
          create: (context) => FiltersModel(),
          child: Column(
            children: [StatisticsFilter(), Expanded(child: StatisticsCharts())],
          ),
        ));
  }
}

class StatisticsCharts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<FiltersModel>(
      builder: (BuildContext context, FiltersModel value, Widget? child) {
        return RepositoryLoader(
            fetcher: (repository) => repository.loadAnswers(
                value.selectedDates.start.dayStart,
                value.selectedDates.end.dayEnd),
            builder: (context, result, _) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AspectRatio(
                      aspectRatio: 4,
                      child: Row(
                        children: [
                          Flexible(
                              flex: 1,
                              child: Card(
                                  child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: BaseStatisticsTable(result),
                              ))),
                          Flexible(
                            flex: 2,
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: ReviewHoursHistogram(result),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 400,
                        child: Row(
                          children: [
                            DecksReviewsPieChart(result,
                                type: SummaryType.count),
                            DecksReviewsPieChart(result,
                                type: SummaryType.time),
                          ],
                        ),
                      )),
                  Spacer()
                ],
              );
            });
      },
    );
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
            start: DateTime.now().subtract(Duration(days: 7)),
            end: DateTime.now());
      case DateFilter.lastMonth:
        return DateTimeRange(
            start: DateTime.now().subtract(Duration(days: 30)),
            end: DateTime.now());
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
    return ValueListenableBuilder<Locale>(
        // Add this ValueListenableBuilder
        valueListenable: context.watch<AppState>().currentLocale,
        builder: (context, currentLocale, _) {
          final locale = currentLocale;
          final dateFormat = DateFormat.yMEd(locale.toLanguageTag());

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
                                  lastDate: DateTime.now());
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
