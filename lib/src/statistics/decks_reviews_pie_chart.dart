import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/app.dart';
import 'package:flutter_flashcards/src/common/custom_theme.dart';
import 'package:flutter_flashcards/src/common/indicator.dart';
import 'package:flutter_flashcards/src/model/cards.dart' as model;
import 'package:flutter_flashcards/src/model/repository.dart';
import 'package:flutter_flashcards/src/widgets.dart';

class DecksReviewsPieChart extends StatefulWidget {
  final Iterable<model.CardAnswer> answers;

  final SummaryType type;

  const DecksReviewsPieChart(this.answers, {required this.type});

  @override
  State<DecksReviewsPieChart> createState() {
    return _DecksReviewsPieChartState();
  }
}

enum SummaryType { count, time }

class _DecksReviewsPieChartState extends State<DecksReviewsPieChart> {
  int touchedIndex = -1;

  Future<Map<model.Deck, double>> summarise(
      CardsRepository repository, SummaryType type) async {
    final cardIds = widget.answers.map((c) => c.cardId);
    final cardToDeck = await repository.mapCardsToDecks(cardIds);
    final Map<model.Deck, double> result = widget.answers.fold(
        {},
        (agg, next) => {
              ...agg,
              cardToDeck[next.cardId]!: (agg[cardToDeck[next.cardId]] ?? 0) + 1
            });
    return result;
  }

  Future<Map<model.Deck, PieChartSectionData>> showingSections(
      CardsRepository repository) async {
    final data = await summarise(repository, widget.type);
    final total = data.values.reduce((a, b) => a + b);
    final colors = context.chartColors(data.keys.length);
    int colorIndex = 0;
    return data.map((key, value) {
      final color = colors[colorIndex];
      final contrastingColor =
          color.computeLuminance() < 0.5 ? Colors.white : Colors.black;
      final section = PieChartSectionData(
        color: color,
        value: value.toDouble(),
        title: '${(value / total * 100).toStringAsFixed(1)}%',
        radius: 80,
        titleStyle: TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: contrastingColor),
      );
      colorIndex++;
      return MapEntry(key, section);
    });
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryLoader(
      fetcher: (repository) => showingSections(repository),
      builder: (context, sections, _) => Expanded(
        child: Card(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                    widget.type == SummaryType.count
                        ? context.l10n.countCardsPerDeckChartTitle
                        : context.l10n.timePerDeckChartTitle,
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              Expanded(
                child: Row(
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                              // touchCallback: (FlTouchEvent event, pieTouchResponse) {
                              //   setState(() {
                              //     if (!event.isInterestedForInteractions ||
                              //         pieTouchResponse == null ||
                              //         pieTouchResponse.touchedSection == null) {
                              //       touchedIndex = -1;
                              //       return;
                              //     }
                              //     touchedIndex =
                              //         pieTouchResponse.touchedSection!.touchedSectionIndex;
                              //   });
                              // },
                              ),
                          startDegreeOffset: 180,
                          borderData: FlBorderData(
                            show: false,
                          ),
                          sectionsSpace: 0,
                          centerSpaceRadius: 40,
                          sections: sections.values.toList(),
                        ),
                      ),
                    ),
                    ChartLegend(sections: sections),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChartLegend extends StatelessWidget {
  final Map<model.Deck, PieChartSectionData> sections;
  const ChartLegend({super.key, required this.sections});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...sections.entries
            .map((entry) => [
                  Indicator(
                    color: entry.value.color,
                    text: entry.key.name,
                    isSquare: false,
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                ])
            .expand((a) => a),
        const SizedBox(
          height: 18,
        ),
      ],
    );
  }
}