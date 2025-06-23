import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_flashcards/src/common/dates.dart';
import 'package:flutter_flashcards/src/statistics/base_statistics_table.dart';
import 'package:flutter_flashcards/src/statistics/decks_reviews_pie_chart.dart';
import 'package:flutter_flashcards/src/statistics/review_hours_histogram.dart';
import 'package:flutter_flashcards/src/statistics/reviews_history.dart';
import 'package:flutter_flashcards/src/statistics/statistics_charts_controller.dart';
import 'package:flutter_flashcards/src/statistics/statistics_page_controller.dart';
import 'package:flutter_flashcards/src/model/cards.dart' as model;

class StatisticsCharts extends ConsumerWidget {
  final String? uid;

  const StatisticsCharts(this.uid);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statisticsData = ref.watch(statisticsPageControllerProvider);

    final params = StatisticsLoadParams(
      startDate: statisticsData.selectedDateRange.start.dayStart,
      endDate: statisticsData.selectedDateRange.end.dayEnd,
      uid: uid,
    );

    final statisticsAsync = ref.watch(
      statisticsChartsControllerProvider(params),
    );

    return statisticsAsync.when(
      data: (answers) =>
          _buildCharts(context, answers, statisticsData.selectedDateRange),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildCharts(
    BuildContext context,
    Iterable<model.CardAnswer> answers,
    DateTimeRange dateRange,
  ) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return CustomScrollView(
          slivers: <Widget>[
            SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: constraints.maxWidth < 600 ? 1 : 3,
                childAspectRatio: 5,
                mainAxisSpacing: 0, // Space between rows
                crossAxisSpacing: 0, // Space between columns
              ),
              delegate: SliverChildListDelegate([
                BaseStatistic(answers: answers, type: StatisticType.totalCount),
                BaseStatistic(answers: answers, type: StatisticType.totalTime),
                BaseStatistic(answers: answers, type: StatisticType.avgTime),
              ]),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(8.0),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: constraints.maxWidth < 900 ? 1 : 2,
                  mainAxisSpacing: 8, // Space between rows
                  crossAxisSpacing: 8, // Space between columns
                  childAspectRatio: 1.5,
                ),
                delegate: SliverChildListDelegate([
                  SizedBox(
                    height: 400,
                    child: Container(
                      color: ColorScheme.of(context).surfaceContainerLow,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: ReviewHoursHistogram(answers),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 400,
                    child: Container(
                      color: ColorScheme.of(context).surfaceContainerLow,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: ReviewHistory(
                          answers: answers,
                          dateRange: dateRange,
                        ),
                      ),
                    ),
                  ),
                  ColoredBox(
                    color: ColorScheme.of(context).surfaceContainerLow,
                    child: DecksReviewsPieChart(
                      answers,
                      type: SummaryType.count,
                    ),
                  ),
                  ColoredBox(
                    color: ColorScheme.of(context).surfaceContainerLow,
                    child: DecksReviewsPieChart(
                      answers,
                      type: SummaryType.time,
                    ),
                  ),
                ]),
              ),
            ),
            SliverFillRemaining(),
          ],
        );
      },
    );
  }
}
