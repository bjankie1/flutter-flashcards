import 'dart:math';

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Error recording answer',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ],
          ),
        ),
      );
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
            tapRating: (rating) => recordAnswerRating(context, rating),
          );
        }
        return Column(
          children: [
            Text(
              context.l10n.allCardsReviewedMessage,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            Expanded(
              child: Center(child: Image(image: celebrationImage)),
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

  ReviewWidget({
    required this.card,
    required this.variant,
    required this.answerRevealed,
    required this.tapRevealAnswer,
    required this.tapRating,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 600, maxWidth: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RichTextCard(
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
            Expanded(
              child: CardFlipAnimation(
                key: Key('${card.id}_${variant.name}'),
                front: RevealAnswerWidget(tapRevealAnswer: tapRevealAnswer),
                back: AnswerCard(card: card, variant: variant),
                onFlipped: tapRevealAnswer,
              ),
            ),
            AnimatedOpacity(
              opacity: answerRevealed ? 1 : 0,
              duration: Duration(milliseconds: 500),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 30.0,
                  horizontal: 8.0,
                ),
                child: RateAnswer(
                  key: ValueKey('${card.id}_${variant.name}'),
                  card: card,
                  onRated: tapRating,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnswerCard extends StatelessWidget {
  final model.Card card;
  final model.CardReviewVariant variant;

  const AnswerCard({super.key, required this.card, required this.variant});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: CardsContainer(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Center(
                child: GptMarkdown(
                  variant == model.CardReviewVariant.back
                      ? card.question
                      : card.answer,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
              Visibility(
                visible:
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
            ],
          ),
        ),
      ),
    );
  }
}

class RevealAnswerWidget extends StatelessWidget {
  const RevealAnswerWidget({super.key, required this.tapRevealAnswer});

  final Function tapRevealAnswer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: context.theme
              .extension<ContainersColors>()
              ?.mainContainerBackground,
        ),
        child: FittedBox(child: Text('?')),
      ),
    );
  }
}

class RateAnswer extends StatefulWidget {
  final model.Card card;
  final void Function(model.Rating) onRated;

  RateAnswer({super.key, required this.card, required this.onRated});

  @override
  State<RateAnswer> createState() => _RateAnswerState();
}

class _RateAnswerState extends State<RateAnswer> {
  model.Rating? _reviewRate;

  Color _getRatingColor(BuildContext context, model.Rating rating) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (rating) {
      case model.Rating.again:
        return isDark ? Colors.red.shade900 : Colors.red.shade300;
      case model.Rating.hard:
        return isDark ? Colors.orange.shade900 : Colors.orange.shade300;
      case model.Rating.good:
        return isDark ? Colors.blue.shade900 : Colors.blue.shade300;
      case model.Rating.easy:
        return isDark ? Colors.green.shade900 : Colors.green.shade300;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = context.isMobile ? null : context.textTheme.displaySmall;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _RatingButton(
          rating: model.Rating.again,
          label: context.l10n.rateAgainLabel,
          textStyle: textStyle,
          color: _getRatingColor(context, model.Rating.again),
          isSelected: _reviewRate == model.Rating.again,
          onTap: () {
            setState(() => _reviewRate = model.Rating.again);
            widget.onRated(model.Rating.again);
          },
        ),
        const SizedBox(width: 8),
        _RatingButton(
          rating: model.Rating.hard,
          label: context.l10n.rateHardLabel,
          textStyle: textStyle,
          color: _getRatingColor(context, model.Rating.hard),
          isSelected: _reviewRate == model.Rating.hard,
          onTap: () {
            setState(() => _reviewRate = model.Rating.hard);
            widget.onRated(model.Rating.hard);
          },
        ),
        const SizedBox(width: 8),
        _RatingButton(
          rating: model.Rating.good,
          label: context.l10n.rateGoodLabel,
          textStyle: textStyle,
          color: _getRatingColor(context, model.Rating.good),
          isSelected: _reviewRate == model.Rating.good,
          onTap: () {
            setState(() => _reviewRate = model.Rating.good);
            widget.onRated(model.Rating.good);
          },
        ),
        const SizedBox(width: 8),
        _RatingButton(
          rating: model.Rating.easy,
          label: context.l10n.rateEasyLabel,
          textStyle: textStyle,
          color: _getRatingColor(context, model.Rating.easy),
          isSelected: _reviewRate == model.Rating.easy,
          onTap: () {
            setState(() => _reviewRate = model.Rating.easy);
            widget.onRated(model.Rating.easy);
          },
        ),
      ],
    );
  }
}

class _RatingButton extends StatelessWidget {
  final model.Rating rating;
  final String label;
  final TextStyle? textStyle;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _RatingButton({
    required this.rating,
    required this.label,
    required this.textStyle,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  IconData _getRatingIcon() {
    switch (rating) {
      case model.Rating.again:
        return Icons.refresh;
      case model.Rating.hard:
        return Icons.trending_down;
      case model.Rating.good:
        return Icons.thumb_up;
      case model.Rating.easy:
        return Icons.sentiment_very_satisfied;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = context.isMobile;

    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: isSelected ? 3 : 1,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 8 : 12,
        ),
        minimumSize: Size(isMobile ? 48 : 120, isMobile ? 48 : 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide(
          color: isSelected
              ? theme.colorScheme.outline
              : theme.colorScheme.outline.withOpacity(0.5),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: isMobile
          ? Icon(_getRatingIcon(), size: 24)
          : Text(
              label,
              style: textStyle?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: theme.colorScheme.onSurface,
              ),
            ),
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
              ),
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

  const QuestionAnswerContainer({
    super.key,
    required this.color,
    required this.text,
    required this.onTap,
  });

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

class CardFlipAnimation extends StatefulWidget {
  final Widget front;
  final Widget back;
  final Function onFlipped;

  const CardFlipAnimation({
    super.key,
    required this.front,
    required this.back,
    required this.onFlipped,
  });

  @override
  State<StatefulWidget> createState() => _CardFlipAnimationState();
}

class _CardFlipAnimationState extends State<CardFlipAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubic, // Adjust curve for animation feel
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // After the animation completes (flipped to back), switch the child
        setState(() {
          _showFront = false;
        });
      } else if (status == AnimationStatus.dismissed) {
        // After the animation dismisses (flipped to front), switch the child
        setState(() {
          _showFront = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void flipCard() {
    if (_showFront) {
      _controller.forward(); // Flip to back
      widget.onFlipped();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final isHalfway = _animation.value > pi / 2;
        final currentRotation = isHalfway
            ? pi - _animation.value
            : _animation.value;

        // Apply perspective transformation
        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.001) // Perspective
          ..rotateY(currentRotation); // Rotate around Y-axis

        return GestureDetector(
          onTap: flipCard, // Flip the card on tap
          child: Transform(
            transform: transform,
            alignment: Alignment.center,
            child: isHalfway ? widget.back : widget.front, // Show back or front
          ),
        );
      },
    );
  }
}
