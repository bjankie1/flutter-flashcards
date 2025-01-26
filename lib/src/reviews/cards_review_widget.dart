import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/card_image.dart';
import 'package:flutter_flashcards/src/model/cards.dart' as model;
import 'package:flutter_flashcards/src/model/study_session.dart';
import 'package:gpt_markdown/gpt_markdown.dart';

class CardsReview extends StatefulWidget {
  final StudySession session;

  CardsReview({required this.session});

  @override
  State<StatefulWidget> createState() => _CardsReviewState();
}

class _CardsReviewState extends State<CardsReview> {
  bool _answerRevealed = false;

  void revealAnswer() {
    setState(() => _answerRevealed = true);
  }

  recordAnswerRating(BuildContext context, model.Rating rating) async {
    try {
      await widget.session.rateAnswer(rating);
      setState(() {
        _answerRevealed = false;
      });
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
    return ListenableBuilder(
      listenable: widget.session,
      builder: (context, _) {
        final card = widget.session.currentCard;
        if (card != null) {
          return ReviewWidget(
              card: card,
              answerRevealed: _answerRevealed,
              tapRevealAnswer: revealAnswer,
              tapRating: (rating) => recordAnswerRating(context, rating));
        }
        return Column(
          children: [
            Text(context.l10n.allCardsReviewedMessage,
                style: Theme.of(context).textTheme.headlineLarge),
            Expanded(
              child: Center(
                child: Image.asset('images/celebration2.jpg'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class ReviewWidget extends StatelessWidget {
  final model.Card card;

  final bool answerRevealed;

  final Function tapRevealAnswer;
  final Function(model.Rating) tapRating;

  ReviewWidget(
      {required this.card,
      required this.answerRevealed,
      required this.tapRevealAnswer,
      required this.tapRating});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: CardSideContent(
            card: card,
            front: true,
          ),
        ),
        Visibility(
          visible: !answerRevealed,
          child: Expanded(
            child: Padding(
                padding: EdgeInsets.all(4.0),
                child: AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeIn,
                    child: Material(
                      color: Colors.lightGreenAccent,
                      borderRadius: BorderRadius.circular(12.0),
                      child: InkWell(
                        onTap: () {
                          tapRevealAnswer();
                        },
                        child: FittedBox(
                          child: Text(
                            '?',
                            style: TextStyle(fontSize: 30),
                          ),
                        ),
                      ),
                    ))),
          ),
        ),
        Visibility(
          visible: answerRevealed,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GptMarkdown(
                  card.answer,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
            ),
          ),
        ),
        Visibility(
          visible: answerRevealed &&
              card.explanation != null &&
              card.explanation != '',
          child: CardSideContent(
            card: card,
            front: false,
          ),
        ),
        Visibility(
          visible: answerRevealed,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: RateAnswer(
              card: card,
              onRated: tapRating,
            ),
          ),
        ),
      ],
    );
  }
}

class RateAnswer extends StatefulWidget {
  final model.Card card;

  final void Function(model.Rating) onRated;

  RateAnswer({required this.card, required this.onRated});

  @override
  State<RateAnswer> createState() => _RateAnswerState();
}

class _RateAnswerState extends State<RateAnswer> {
  model.Rating? _reviewRate;

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
        widget.onRated(_reviewRate!);
      },
    );
  }
}

class CardSideContent extends StatelessWidget {
  const CardSideContent({super.key, required this.card, this.front = true});

  final model.Card card;

  final bool front;

  Color color(BuildContext context) => front
      ? Theme.of(context).colorScheme.secondaryContainer
      : Theme.of(context).colorScheme.surfaceContainerLow;

  String get markdown => front ? card.question : card.answer;

  bool get showImage =>
      front && card.questionImageAttached ||
      !front && card.explanationImageAttached;

  model.ImagePlacement get placement =>
      front ? model.ImagePlacement.question : model.ImagePlacement.explanation;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        color: color(context),
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Stack(
            children: [
              Text(front ? 'Question' : 'Explanation'),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: FittedBox(
                      child: GptMarkdown(
                        markdown,
                        // style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ),
                  ),
                  if (showImage)
                    Expanded(
                      flex: 1,
                      child: LayoutBuilder(
                        builder: (context, constraints) => CardImage(
                          cardId: card.id!,
                          placement: placement,
                          height: constraints.maxHeight,
                        ),
                      ),
                    ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
