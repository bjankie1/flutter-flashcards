import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/app.dart';
import 'package:flutter_flashcards/src/model/cards.dart' as model;
import 'package:flutter_flashcards/src/model/repository.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:provider/provider.dart';

class CardsReview extends StatefulWidget {
  final List<model.Card> cards;

  final ValueListenable<int> currentCardIndex;

  final ValueChanged<int> onNextCard;

  CardsReview(
      {required Iterable<model.Card> cards,
      required this.currentCardIndex,
      required this.onNextCard})
      : cards = cards.toList();

  @override
  State<StatefulWidget> createState() => _CardsReviewState();
}

class _CardsReviewState extends State<CardsReview> {
  bool _answered = false;
  model.Rating? _reviewRate;

  void nextCard(int cardIndex) {
    setState(() {
      _answered = false;
      _reviewRate = null;
      widget.onNextCard((cardIndex + 1) % widget.cards.length);
    });
  }

  updateStats(
      CardsRepository repository, model.Rating rating, model.Card card) async {
    try {
      await repository.recordAnswer(
          card.id!, model.CardReviewVariant.front, rating);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Text('Error recording answer',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer)),
            ],
          )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.currentCardIndex,
      builder: (context, index, _) {
        final card = widget.cards[index];
        return Card(
          child: Column(
            children: [
              Expanded(
                child: SizedBox(
                  width: 800,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TexMarkdown(
                      card.question.text,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                ),
              ),
              Divider(),
              Visibility(
                visible: !_answered,
                child: ElevatedButton(
                  child: Text(context.l10n.showAnswer),
                  onPressed: () => setState(() => _answered = true),
                ),
              ),
              Visibility(
                visible: _answered,
                child: Expanded(
                  child: SizedBox(
                    width: 800,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TexMarkdown(card.answer),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: _answered,
                child: SegmentedButton<model.Rating>(
                  emptySelectionAllowed: true,
                  segments: [
                    ButtonSegment<model.Rating>(
                        value: model.Rating.again, label: Text('No idea')),
                    ButtonSegment<model.Rating>(
                        value: model.Rating.hard, label: Text('Hard')),
                    ButtonSegment<model.Rating>(
                        value: model.Rating.good, label: Text('Good')),
                    ButtonSegment<model.Rating>(
                        value: model.Rating.easy, label: Text('Easy')),
                  ],
                  selected: _reviewRate != null ? {_reviewRate!} : {},
                  onSelectionChanged: (value) async {
                    setState(() => _reviewRate = value.first);
                    final repository = context.read<CardsRepository>();
                    await updateStats(repository, _reviewRate!, card);
                    nextCard(index);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
