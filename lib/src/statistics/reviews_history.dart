import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/dates.dart';
import 'package:flutter_flashcards/src/model/cards.dart' as model;
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class ReviewHistory extends StatefulWidget {
  final _log = Logger();

  final Iterable<model.CardAnswer> answers;
  final DateTimeRange dateRange;

  ReviewHistory({required this.answers, required this.dateRange});

  /// List of dates within date range. Each day is represented by a [DateTime]
  /// of the day beginning.
  List<DateTime> get days {
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

  Map<DateTime, int> get cardReviewedPerDay =>
      answers.fold<Map<DateTime, int>>({}, (acc, answer) {
        final day = answer.reviewStart.dayStart;
        acc[day] = (acc[day] ?? 0) + 1;
        return acc;
      });

  @override
  State<ReviewHistory> createState() => _ReviewHistoryState();
}

class _ReviewHistoryState extends State<ReviewHistory> {
  String formatDate(DateTime date) {
    final dateFormat =
        DateFormat.yMd(context.appState.userProfile.value?.locale.languageCode);
    return dateFormat.format(date);
  }

  /// Generates widgets used to display the days under the axis.
  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
    );
    Widget text = Text(formatDate(widget.days[value.toInt()]), style: style);
    return SideTitleWidget(
      meta: meta,
      space: 16,
      child: RotatedBox(quarterTurns: 3, child: text),
    );
  }

  List<BarChartGroupData> barGroups() {
    widget._log.d('Generating bar groups for ${widget.cardReviewedPerDay}');
    return List.generate(widget.days.length, (i) => i).map((dayIndex) {
      final day = widget.days[dayIndex];
      final value = widget.cardReviewedPerDay[day] ?? 0;
      widget._log.d('Chart data for $dayIndex:$day:$value');
      return BarChartGroupData(
        x: dayIndex,
        barRods: [
          BarChartRodData(
            width: 20,
            toY: value.toDouble(),
          ),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 20,
          child: Center(
            child: Text(context.l10n.cardReviewDaily,
                style: Theme.of(context).textTheme.titleMedium),
          ),
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
                    reservedSize: 100,
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
              barGroups: barGroups(),
            ),
          ),
        ),
      ],
    );
  }
}