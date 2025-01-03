import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/app.dart';
import 'package:flutter_flashcards/src/app_state.dart';
import 'package:flutter_flashcards/src/base_layout.dart';
import 'package:flutter_flashcards/src/common/dates.dart';
import 'package:flutter_flashcards/src/model/cards.dart' as model;
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
        title: 'Statistics',
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
                  Spacer()
                ],
              );
            });
      },
    );
  }
}

class BaseStatisticsTable extends StatelessWidget {
  final Iterable<model.CardAnswer> result;
  const BaseStatisticsTable(this.result);

  String printDuration(BuildContext context, Duration duration) {
    final seconds = duration.inSeconds;
    final remainingSeconds = seconds % 60;
    final minutes = seconds ~/ 60;
    final remainingMinutes = minutes % 60;
    final hours = minutes ~/ 60;
    String result = '';
    if (hours > 0) {
      result += context.l10n.printHours(hours);
    }
    if (remainingMinutes > 0) {
      result += context.l10n.printMinutes(remainingMinutes);
    }
    result += result += context.l10n.printSeconds(remainingSeconds);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      children: <Widget>[
        Row(
          children: [
            ReportLabel(
              'Answers:',
              alignRight: true,
              bold: true,
            ),
            ReportLabel(result.length.toString()),
          ],
        ),
        Row(
          children: [
            ReportLabel(
              'Total time:',
              alignRight: true,
              bold: true,
            ),
            ReportLabel(printDuration(
                context,
                result.fold<Duration>(
                    Duration.zero, (agg, next) => agg + next.timeSpent))),
          ],
        ),
        Row(
          children: [
            ReportLabel(
              'Average (s):',
              alignRight: true,
              bold: true,
            ),
            ReportLabel(printDuration(
                context,
                result.fold<Duration>(
                    Duration.zero, (agg, next) => agg + next.timeSpent))),
          ],
        ),
      ],
    );
  }
}

class ReportLabel extends StatelessWidget {
  final String label;
  final bool alignRight;
  final bool bold;

  const ReportLabel(
    this.label, {
    this.alignRight = false,
    this.bold = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
        padding: const EdgeInsets.all(8),
        child: FittedBox(
          child: Text(label,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: bold ? FontWeight.bold : null)),
        ),
      ),
    );
  }
}

class ReviewHoursHistogram extends StatefulWidget {
  final Iterable<model.CardAnswer> answers;

  ReviewHoursHistogram(this.answers);

  @override
  State<ReviewHoursHistogram> createState() => _ReviewHoursHistogramState();
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

class _ReviewHoursHistogramState extends State<ReviewHoursHistogram> {
  int _chartDetails = 0;

  Map<int, int> get cardReviewedPerHour {
    return widget.answers.map((e) => e.reviewStart.hour).fold<Map<int, int>>({},
        (previousValue, hour) {
      previousValue[hour] = (previousValue[hour] ?? 0) + 1;
      return previousValue;
    });
  }

  Map<PartOfDay, int> get cardReviewedPerPartOfDay {
    return widget.answers
        .map((e) => e.reviewStart.hour)
        .fold<Map<PartOfDay, int>>({}, (previousValue, hour) {
      var partOfDay = PartOfDay.fromHour(hour);
      previousValue[partOfDay] = (previousValue[partOfDay] ?? 0) + 1;
      return previousValue;
    });
  }

  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
    );
    Widget text;
    if (_chartDetails == 1) {
      text = Text(value.toString(), style: style);
    } else {
      text = Text(PartOfDay.values[value.toInt()].name, style: style);
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: text,
    );
  }

  List<BarChartGroupData> barGroups(int type) {
    if (type == 1) {
      return List.generate(24, (h) => h)
          .map((hour) => BarChartGroupData(
                x: hour,
                barRods: [
                  BarChartRodData(
                    width: 20,
                    toY: (cardReviewedPerHour[hour] ?? 0).toDouble(),
                  ),
                ],
              ))
          .toList();
    }
    return PartOfDay.values
        .map((part) => BarChartGroupData(
              x: part.index,
              barRods: [
                BarChartRodData(
                  width: 20,
                  toY: (cardReviewedPerPartOfDay[part] ?? 0).toDouble(),
                ),
              ],
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            SegmentedButton(
              segments: [
                ButtonSegment(value: 0, label: Text('Simple')),
                ButtonSegment(value: 1, label: Text('Detailed')),
              ],
              selected: {_chartDetails},
              onSelectionChanged: (selected) {
                setState(() {
                  _chartDetails = selected.first;
                });
              },
            ),
            Expanded(
              child: SizedBox(
                height: 40,
                child: FittedBox(
                  child: Text(context.l10n.cardReviewedPerHourHeader,
                      style: Theme.of(context).textTheme.titleMedium),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: BarChart(
            BarChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: getTitles,
                    reservedSize: 38,
                  ),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false,
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: false,
              ),
              barGroups: barGroups(_chartDetails),
            ),
          ),
        ),
      ],
    );
  }
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
