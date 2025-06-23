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
        SizedBox(
          height: 20,
          child: Center(
            child: Text(
              context.l10n.cardReviewDaily,
              style: context.textTheme.titleMedium,
            ),
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
                    getTitlesWidget: (value, meta) => ReviewHistoryTitleWidget(
                      value: value,
                      meta: meta,
                      days: reviewHistoryData.days,
                    ),
                    reservedSize: 100,
                  ),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
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

class ReviewHistoryTitleWidget extends StatelessWidget {
  final double value;
  final TitleMeta meta;
  final List<DateTime> days;

  const ReviewHistoryTitleWidget({
    super.key,
    required this.value,
    required this.meta,
    required this.days,
  });

  String _formatDate(BuildContext context, DateTime date) {
    final dateFormat = DateFormat.yMd(
      context.appState.userProfile.value?.locale.languageCode,
    );
    return dateFormat.format(date);
  }

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontWeight: FontWeight.bold);
    Widget text = Text(_formatDate(context, days[value.toInt()]), style: style);
    return SideTitleWidget(
      meta: meta,
      space: 16,
      child: RotatedBox(quarterTurns: 3, child: text),
    );
  }
}
