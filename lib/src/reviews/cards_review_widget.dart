import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/assets.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/card_image.dart';
import 'package:flutter_flashcards/src/common/containers.dart';
import 'package:flutter_flashcards/src/common/themes.dart';
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
        final current = widget.session.currentCard;
        if (current != null) {
          final (variant, card) = current;
          return ReviewWidget(
              card: card,
              variant: variant,
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
                child: Image(image: celebrationImage),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Widget displays card to learn and asks for answer.
/// When user clicks on question mark answer is revealed along with the
/// explanation.
class ReviewWidget extends StatelessWidget {
  final model.Card card;

  final model.CardReviewVariant variant;

  final bool answerRevealed;

  final Function tapRevealAnswer;

  final Function(model.Rating) tapRating;

  ReviewWidget(
      {required this.card,
      required this.variant,
      required this.answerRevealed,
      required this.tapRevealAnswer,
      required this.tapRating});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: RichTextCard(
            cardId: card.id,
            title: context.l10n.questionLabel,
            text: variant == model.CardReviewVariant.front
                ? card.question
                : card.answer,
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            imagePlacement: card.questionImageAttached
                ? model.ImagePlacement.question
                : null,
          ),
        ),
        Visibility(
          visible: !answerRevealed,
          child: RevealAnswerWidget(tapRevealAnswer: tapRevealAnswer),
        ),
        Visibility(
          visible: answerRevealed,
          child: AnswerCard(card: card, variant: variant),
        ),
        Visibility(
          visible: answerRevealed &&
              card.explanation != null &&
              card.explanation != '' &&
              card.explanation! != card.answer,
          child: RichTextCard(
            cardId: card.id,
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            title: context.l10n.explanationLabel,
            text: card.explanation!,
            imagePlacement: card.explanationImageAttached
                ? model.ImagePlacement.explanation
                : null,
          ),
        ),
        Visibility(
          visible: answerRevealed,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 30.0, horizontal: 8.0),
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

class AnswerCard extends StatelessWidget {
  final model.Card card;
  final model.CardReviewVariant variant;

  const AnswerCard({
    super.key,
    required this.card,
    required this.variant,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: CardsContainer(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: GptMarkdown(
                variant == model.CardReviewVariant.back
                    ? card.question
                    : card.answer,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RevealAnswerWidget extends StatelessWidget {
  const RevealAnswerWidget({
    super.key,
    required this.tapRevealAnswer,
  });

  final Function tapRevealAnswer;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
          padding: EdgeInsets.all(4.0),
          child: AnimatedContainer(
              duration: const Duration(seconds: 1),
              curve: Curves.easeIn,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  color: context.theme
                      .extension<ContainersColors>()
                      ?.mainContainerBackground,
                ),
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

/// Displays question on the card. What is considered the question depends on
/// the variant. `front` is set to true if the CardReviewVariant is front.
class RichTextCard extends StatelessWidget {
  final String cardId;

  final String title;
  final String text;

  final model.ImagePlacement? imagePlacement;

  final Color color;

  const RichTextCard({
    super.key,
    required this.cardId,
    required this.title,
    required this.text,
    required this.imagePlacement,
    required this.color,
  });

  bool get showImage => imagePlacement != null;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        color: color,
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: FittedBox(
                        child: GptMarkdown(
                          text,
                          // style: Theme.of(context).textTheme.headlineLarge,
                        ),
                      ),
                    ),
                    if (showImage)
                      Expanded(
                        flex: 1,
                        child: LayoutBuilder(
                          builder: (context, constraints) => CardImage(
                            cardId: cardId,
                            placement: imagePlacement!,
                            height: constraints.maxHeight,
                          ),
                        ),
                      ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

/// Container used to show question answer.
class QuestionAnswerContainer extends StatelessWidget {
  final Color color;

  final String text;

  final Function onTap;

  const QuestionAnswerContainer(
      {super.key,
      required this.color,
      required this.text,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GptMarkdown(
            text,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ),
      ),
    );
  }
}