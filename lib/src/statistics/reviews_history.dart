import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/themes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/model/cards.dart' as model;
import 'package:flutter_flashcards/src/statistics/reviews_history_controller.dart';
import 'package:intl/intl.dart';

class ReviewHistory extends ConsumerWidget {
  final Iterable<model.CardAnswer> answers;
  final DateTimeRange dateRange;

  ReviewHistory({required this.answers, required this.dateRange});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewHistoryData = ref.watch(
      reviewHistoryControllerProvider(answers, dateRange),
    );

    return Column(
      children: [
        Expanded(
          child: BarChart(
            BarChartData(
              gridData: FlGridData(
                show: true,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (value) =>
                    FlLine(color: Colors.grey.shade300, strokeWidth: 1),
                drawVerticalLine: false,
              ),
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
                    getTitlesWidget: (value, meta) =>
                        ReviewHistoryMondayTitleWidget(
                          value: value,
                          meta: meta,
                          days: reviewHistoryData.days,
                        ),
                    reservedSize: 40,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    getTitlesWidget: (value, meta) {
                      if (value % 1 == 0 && value > 0) {
                        return SideTitleWidget(
                          meta: meta,
                          space: 8,
                          child: Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: _barGroups(reviewHistoryData),
            ),
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> _barGroups(ReviewHistoryData data) {
    return List.generate(data.days.length, (i) => i).map((dayIndex) {
      final day = data.days[dayIndex];
      final value = data.cardReviewedPerDay[day] ?? 0;
      return BarChartGroupData(
        x: dayIndex,
        barRods: [BarChartRodData(width: 20, toY: value.toDouble())],
      );
    }).toList();
  }
}

class ReviewHistoryMondayTitleWidget extends StatelessWidget {
  final double value;
  final TitleMeta meta;
  final List<DateTime> days;

  const ReviewHistoryMondayTitleWidget({
    super.key,
    required this.value,
    required this.meta,
    required this.days,
  });

  @override
  Widget build(BuildContext context) {
    final int index = value.toInt();
    final day = days[index];
    final int totalDays = days.length;
    // Calculate step to show at most 10 labels
    final int step = (totalDays / 10).ceil().clamp(1, totalDays);
    // Only show label for every n-th day
    if (index % step == 0) {
      final dateFormat = DateFormat.Md(
        Localizations.localeOf(context).toLanguageTag(),
      );
      const style = TextStyle(fontWeight: FontWeight.normal);
      Widget text = Text(dateFormat.format(day), style: style);
      return SideTitleWidget(
        meta: meta,
        space: 8,
        child: Transform.rotate(
          angle: -0.785398, // -45 degrees in radians
          alignment: Alignment.topRight,
          child: text,
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
