import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
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

  Future<List<PieChartSectionData>> showingSections(
      CardsRepository repository) async {
    final data = await summarise(repository, widget.type);

    return data.entries.map((entry) {
      final deckName = entry.key.name;
      final count = entry.value;
      return PieChartSectionData(
        color: Colors.primaries[
            data.entries.toList().indexOf(entry) % Colors.primaries.length],
        value: count.toDouble(),
        title: deckName,
        radius: 40,
        titleStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: const Color(0xffffffff)),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryLoader(
      fetcher: (repository) => showingSections(repository),
      builder: (context, sections, _) => AspectRatio(
        aspectRatio: 1,
        child: PieChart(
          PieChartData(
            pieTouchData: PieTouchData(
              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                setState(() {
                  if (!event.isInterestedForInteractions ||
                      pieTouchResponse == null ||
                      pieTouchResponse.touchedSection == null) {
                    touchedIndex = -1;
                    return;
                  }
                  touchedIndex =
                      pieTouchResponse.touchedSection!.touchedSectionIndex;
                });
              },
            ),
            startDegreeOffset: 180,
            borderData: FlBorderData(
              show: false,
            ),
            sectionsSpace: 1,
            centerSpaceRadius: 0,
            sections: sections,
          ),
        ),
      ),
    );
  }
}
