import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/dates.dart';
import 'package:flutter_flashcards/src/statistics/base_statistics_table.dart';
import 'package:flutter_flashcards/src/statistics/decks_reviews_pie_chart.dart';
import 'package:flutter_flashcards/src/statistics/review_hours_histogram.dart';
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
              return ListView(
                children: [
                  IntrinsicWidth(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: BaseStatisticsTable(result),
                      )),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AspectRatio(
                      aspectRatio: 4,
                      child: Row(
                        children: [
                          Flexible(
                            flex: 2,
                            child: Container(
                              color:
                                  ColorScheme.of(context).surfaceContainerLow,
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
                        height: 500,
                        child: Row(
                          spacing: 8,
                          children: [
                            ColoredBox(
                              color:
                                  ColorScheme.of(context).surfaceContainerLow,
                              child: DecksReviewsPieChart(result,
                                  type: SummaryType.count),
                            ),
                            ColoredBox(
                              color:
                                  ColorScheme.of(context).surfaceContainerLow,
                              child: DecksReviewsPieChart(result,
                                  type: SummaryType.time),
                            ),
                          ],
                        ),
                      )),
                ],
              );
            });
      },
    );
  }
}