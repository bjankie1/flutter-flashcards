import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/model/cards.dart' as model;
import 'package:flutter_flashcards/src/statistics/part_of_day.dart';

class ReviewHoursHistogram extends StatefulWidget {
  final Iterable<model.CardAnswer> answers;

  ReviewHoursHistogram(this.answers);

  @override
  State<ReviewHoursHistogram> createState() => _ReviewHoursHistogramState();
}

class _ReviewHoursHistogramState extends State<ReviewHoursHistogram> {
  int _chartDetails = 0;

  Map<int, int> get cardReviewedPerHour {
    return widget.answers.map((e) => e.reviewStart.hour).fold<Map<int, int>>(
      {},
      (previousValue, hour) {
        previousValue[hour] = (previousValue[hour] ?? 0) + 1;
        return previousValue;
      },
    );
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
    const style = TextStyle(fontWeight: FontWeight.bold);
    Widget text;
    if (_chartDetails == 1) {
      text = Text(value.toString(), style: style);
    } else {
      text = Text(PartOfDay.values[value.toInt()].name, style: style);
    }
    return SideTitleWidget(meta: meta, space: 16, child: text);
  }

  List<BarChartGroupData> barGroups(int type) {
    if (type == 1) {
      return List.generate(24, (h) => h)
          .map(
            (hour) => BarChartGroupData(
              x: hour,
              barRods: [
                BarChartRodData(
                  width: 20,
                  toY: (cardReviewedPerHour[hour] ?? 0).toDouble(),
                ),
              ],
            ),
          )
          .toList();
    }
    return PartOfDay.values
        .map(
          (part) => BarChartGroupData(
            x: part.index,
            barRods: [
              BarChartRodData(
                width: 20,
                toY: (cardReviewedPerPartOfDay[part] ?? 0).toDouble(),
              ),
            ],
          ),
        )
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
                child: Center(
                  child: Text(
                    context.l10n.cardReviewedPerHourHeader,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
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
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: barGroups(_chartDetails),
            ),
          ),
        ),
      ],
    );
  }
}
