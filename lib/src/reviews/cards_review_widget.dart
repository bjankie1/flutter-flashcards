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

  void nextCard(int cardIndex) {
    setState(() {
      _answered = false;
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ContentMarkdown(
              markdown: card.question.text,
              color: Theme.of(context).colorScheme.secondaryContainer,
            ),
            Divider(),
            Visibility(
              visible: !_answered,
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: FilledButton(
                  child: Text(context.l10n.showAnswer),
                  onPressed: () => setState(() => _answered = true),
                ),
              ),
            ),
            Visibility(visible: !_answered, child: Spacer()),
            Visibility(
              visible: _answered,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      card.answer,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: _answered &&
                  card.explanation?.text != null &&
                  card.explanation?.text != '',
              child: ContentMarkdown(
                markdown: card.explanation?.text ?? '',
                color: Theme.of(context).colorScheme.surfaceContainerLow,
              ),
            ),
            Visibility(
              visible: _answered,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: RateAnswer(card, () => nextCard(index)),
              ),
            ),
          ],
        );
      },
    );
  }
}

class RateAnswer extends StatefulWidget {
  final model.Card card;

  final void Function() onRated;

  RateAnswer(this.card, this.onRated);

  @override
  State<RateAnswer> createState() => _RateAnswerState();
}

class _RateAnswerState extends State<RateAnswer> {
  model.Rating? _reviewRate;

  updateStats(BuildContext context, CardsRepository repository,
      model.Rating rating, model.Card card) async {
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
    return SegmentedButton<model.Rating>(
      emptySelectionAllowed: true,
      segments: [
        ButtonSegment<model.Rating>(
            value: model.Rating.again,
            label: Text(
              context.l10n.rateAgainLabel,
              style: Theme.of(context).textTheme.displaySmall,
            )),
        ButtonSegment<model.Rating>(
            value: model.Rating.hard,
            label: Text(
              context.l10n.rateHardLabel,
              style: Theme.of(context).textTheme.displaySmall,
            )),
        ButtonSegment<model.Rating>(
            value: model.Rating.good,
            label: Text(
              context.l10n.rateGoodLabel,
              style: Theme.of(context).textTheme.displaySmall,
            )),
        ButtonSegment<model.Rating>(
            value: model.Rating.easy,
            label: Text(
              context.l10n.rateEasyLabel,
              style: Theme.of(context).textTheme.displaySmall,
            )),
      ],
      selected: _reviewRate != null ? {_reviewRate!} : {},
      onSelectionChanged: (value) async {
        setState(() => _reviewRate = value.first);
        final repository = context.read<CardsRepository>();
        await updateStats(context, repository, value.first, widget.card);
        widget.onRated();
      },
    );
  }
}

class ContentMarkdown extends StatelessWidget {
  const ContentMarkdown({super.key, required this.markdown, this.color});

  final String markdown;

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          color: color,
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: GptMarkdown(
              markdown,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ),
        ),
      ),
    );
  }
}
