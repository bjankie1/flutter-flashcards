import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/dates.dart';
import 'package:flutter_flashcards/src/statistics/base_statistics_table.dart';
import 'package:flutter_flashcards/src/statistics/decks_reviews_pie_chart.dart';
import 'package:flutter_flashcards/src/statistics/review_hours_histogram.dart';
import 'package:flutter_flashcards/src/statistics/reviews_history.dart';
import 'package:flutter_flashcards/src/statistics/statistics_page.dart';
import 'package:flutter_flashcards/src/widgets.dart';
import 'package:provider/provider.dart';

class StatisticsCharts extends StatelessWidget {
  final String? uid;

  const StatisticsCharts(this.uid);

  @override
  Widget build(BuildContext context) {
    return Consumer<FiltersModel>(
      builder: (context, value, _) {
        return RepositoryLoader(
          fetcher: (repository) => repository.loadAnswers(
              value.selectedDates.start.dayStart,
              value.selectedDates.end.dayEnd,
              uid: uid),
          builder: (context, result, _) {
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
                        BaseStatistic(
                            answers: result, type: StatisticType.totalCount),
                        BaseStatistic(
                            answers: result, type: StatisticType.totalTime),
                        BaseStatistic(
                            answers: result, type: StatisticType.avgTime),
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
                              color:
                                  ColorScheme.of(context).surfaceContainerLow,
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: ReviewHoursHistogram(result),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 400,
                            child: Container(
                              color:
                                  ColorScheme.of(context).surfaceContainerLow,
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: ReviewHistory(
                                  answers: result,
                                  dateRange: value.selectedDates,
                                ),
                              ),
                            ),
                          ),
                          ColoredBox(
                            color: ColorScheme.of(context).surfaceContainerLow,
                            child: DecksReviewsPieChart(result,
                                type: SummaryType.count),
                          ),
                          ColoredBox(
                            color: ColorScheme.of(context).surfaceContainerLow,
                            child: DecksReviewsPieChart(result,
                                type: SummaryType.time),
                          ),
                        ]),
                      ),
                    ),
                    SliverFillRemaining(),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}