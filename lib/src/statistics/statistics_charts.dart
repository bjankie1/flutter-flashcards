import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
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
      data: (answers) => StatisticsChartsContent(
        answers: answers,
        dateRange: statisticsData.selectedDateRange,
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
    );
  }
}

class StatisticsChartsContent extends StatelessWidget {
  final Iterable<model.CardAnswer> answers;
  final DateTimeRange dateRange;

  const StatisticsChartsContent({
    super.key,
    required this.answers,
    required this.dateRange,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final isMobile = constraints.maxWidth < 900;
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Summary Stats Row (or Column on mobile)
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  _SummaryStatCard(
                    icon: Icons.check_circle_outline,
                    label: context.l10n.answersLabel,
                    value: answers.length.toString(),
                    tooltip: context.l10n.answersLabelTooltip,
                  ),
                  _SummaryStatCard(
                    icon: Icons.timer_outlined,
                    label: context.l10n.totalTimeLabel,
                    value:
                        BaseStatistic(
                          answers: answers,
                          type: StatisticType.totalTime,
                        ).printDuration(
                          context,
                          BaseStatistic(
                            answers: answers,
                            type: StatisticType.totalTime,
                          ).totalTime,
                        ),
                    tooltip: context.l10n.totalTimeLabelTooltip,
                  ),
                  _SummaryStatCard(
                    icon: Icons.av_timer_outlined,
                    label: context.l10n.averageTimeLabel,
                    value:
                        BaseStatistic(
                          answers: answers,
                          type: StatisticType.avgTime,
                        ).printDuration(
                          context,
                          BaseStatistic(
                            answers: answers,
                            type: StatisticType.avgTime,
                          ).averageTime,
                        ),
                    tooltip: context.l10n.averageTimeLabelTooltip,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Charts
              Wrap(
                spacing: 24,
                runSpacing: 24,
                alignment: WrapAlignment.center,
                children: [
                  SizedBox(
                    width: isMobile ? double.infinity : 420,
                    child: _ChartCard(
                      title: context.l10n.cardReviewedPerHourHeader,
                      tooltip: context.l10n.cardReviewedPerHourTooltip,
                      child: SizedBox(
                        height: 320,
                        child: ReviewHoursHistogram(answers),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: isMobile ? double.infinity : 420,
                    child: _ChartCard(
                      title: context.l10n.cardReviewDaily,
                      tooltip: context.l10n.cardReviewDailyTooltip,
                      child: SizedBox(
                        height: 320,
                        child: ReviewHistory(
                          answers: answers,
                          dateRange: dateRange,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: isMobile ? double.infinity : 420,
                    child: _ChartCard(
                      title: context.l10n.countCardsPerDeckChartTitle,
                      tooltip: context.l10n.countCardsPerDeckChartTooltip,
                      child: SizedBox(
                        height: 320,
                        child: DecksReviewsPieChart(
                          answers,
                          type: SummaryType.count,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: isMobile ? double.infinity : 420,
                    child: _ChartCard(
                      title: context.l10n.timePerDeckChartTitle,
                      tooltip: context.l10n.timePerDeckChartTooltip,
                      child: SizedBox(
                        height: 320,
                        child: DecksReviewsPieChart(
                          answers,
                          type: SummaryType.time,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String tooltip;

  const _SummaryStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.bodyMedium),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String tooltip;
  final Widget child;

  const _ChartCard({
    required this.title,
    required this.tooltip,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(width: 8),
                Tooltip(
                  message: tooltip,
                  child: Icon(
                    Icons.info_outline,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
