import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/deck_selection.dart';
import 'package:flutter_flashcards/src/layout/base_layout.dart';
import 'package:flutter_flashcards/src/model/cards.dart' as model;
import 'package:flutter_flashcards/src/model/repository.dart';
import 'package:flutter_flashcards/src/widgets.dart';

class ProvisionaryCardsReviewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RepositoryLoader(
        fetcher: (repository) => repository.listProvisionaryCards(),
        builder: (context, data, _) {
          return BaseLayout(
              title: Text(context.l10n.provisionaryCardsReviewHeadline),
              child: ProvisionaryCardsReview(provisionaryCards: data.toList()));
        });
  }
}

class ProvisionaryCardsReview extends StatefulWidget {
  final List<model.ProvisionaryCard> provisionaryCards;

  const ProvisionaryCardsReview({super.key, required this.provisionaryCards});

  @override
  State<ProvisionaryCardsReview> createState() =>
      _ProvisionaryCardsReviewState();
}

class _ProvisionaryCardsReviewState extends State<ProvisionaryCardsReview> {
  final Set<int> finalizedCardsIndexes = {};
  final Set<int> discardedCardsIndexes = {};
  int currentIndex = 0;
  String? lastDeckId;
  bool doubleSided = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 4,
          children: widget.provisionaryCards
              .asMap()
              .entries
              .map((entry) => ProvisionaryCardChip(
                    text: entry.value.text,
                    finalized: finalizedCardsIndexes.contains(entry.key),
                    discarded: discardedCardsIndexes.contains(entry.key),
                    active: currentIndex == entry.key,
                    onDelete: () async =>
                        await _discardProposal(context, entry.key, entry.value),
                  ))
              .toList(),
        ),
        if (currentIndex >= 0)
          ProvisionaryCardFinalization(
            doubleSidedValue: doubleSided,
            deckId: lastDeckId,
            provisionaryCard: widget.provisionaryCards[currentIndex],
            onFinalize: (deckId, question, answer, doubleSided) async =>
                await _finalizeProposal(
                    context,
                    currentIndex,
                    widget.provisionaryCards.toList()[currentIndex],
                    deckId,
                    question,
                    answer,
                    doubleSided),
            onDiscard: () async => await _discardProposal(context, currentIndex,
                widget.provisionaryCards.toList()[currentIndex]),
            onSnooze: () => setState(() {
              _progressIndex();
            }),
          )
      ],
    );
  }

  Future<void> _discardProposal(BuildContext context, int index,
      model.ProvisionaryCard provisionaryCard) async {
    await context.cardRepository
        .finalizeProvisionaryCard(provisionaryCard.id, null);
    setState(() {
      discardedCardsIndexes.add(index);
      _progressIndex();
    });
  }

  Future<void> _finalizeProposal(
      BuildContext context,
      int index,
      model.ProvisionaryCard provisionaryCard,
      String deckId,
      String question,
      String answer,
      bool doubleSided) async {
    final cardId = context.cardRepository.nextCardId();
    final card = model.Card(
        id: cardId,
        deckId: deckId,
        question: question,
        answer: answer,
        options: model.CardOptions(learnBothSides: doubleSided));
    await context.cardRepository.saveCard(card);
    await context.cardRepository
        .finalizeProvisionaryCard(provisionaryCard.id, cardId);
    setState(() {
      this.doubleSided = doubleSided;
      lastDeckId = deckId;
      finalizedCardsIndexes.add(index);
      _progressIndex();
    });
  }

  void _progressIndex() {
    if (finalizedCardsIndexes.length + discardedCardsIndexes.length ==
        widget.provisionaryCards.length) {
      currentIndex = -1;
    } else {
      do {
        currentIndex = (currentIndex + 1) % widget.provisionaryCards.length;
      } while (finalizedCardsIndexes.contains(currentIndex) ||
          discardedCardsIndexes.contains(currentIndex));
    }
  }
}

class ProvisionaryCardChip extends StatelessWidget {
  final String text;
  final bool finalized;
  final bool discarded;
  final bool active;
  final VoidCallback onDelete;

  const ProvisionaryCardChip({
    super.key,
    required this.text,
    required this.finalized,
    required this.discarded,
    required this.active,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(text),
      deleteIcon: Icon(Icons.delete),
      onDeleted: finalized || discarded ? null : onDelete,
      labelStyle: active
          ? TextStyle(fontWeight: FontWeight.bold)
          : discarded
              ? TextStyle(decoration: TextDecoration.lineThrough)
              : null,
    );
  }
}

class ProvisionaryCardFinalization extends StatefulWidget {
  final model.ProvisionaryCard provisionaryCard;
  final bool doubleSidedValue;
  final String? deckId;
  final Function(
          String deckId, String question, String answer, bool doubleSided)
      onFinalize;
  final VoidCallback onDiscard;
  final VoidCallback onSnooze;

  const ProvisionaryCardFinalization(
      {super.key,
      required this.doubleSidedValue,
      this.deckId,
      required this.provisionaryCard,
      required this.onFinalize,
      required this.onDiscard,
      required this.onSnooze});

  @override
  State<ProvisionaryCardFinalization> createState() =>
      _ProvisionaryCardFinalizationState();
}

class _ProvisionaryCardFinalizationState
    extends State<ProvisionaryCardFinalization> {
  bool doubleSided = true;
  String? deckId;
  bool isQuestion = true;

  final questionController = TextEditingController();
  final answerController = TextEditingController();

  bool get isComplete =>
      questionController.text.isNotEmpty &&
      answerController.text.isNotEmpty &&
      deckId != null;

  static const WidgetStateProperty<Icon> doubleSidedIcon =
      WidgetStateProperty<Icon>.fromMap(
    <WidgetStatesConstraint, Icon>{
      WidgetState.selected: Icon(Icons.swap_vert),
      WidgetState.any: Icon(Icons.flip_to_front),
    },
  );

  static const WidgetStateProperty<Icon> frontBackIcon =
      WidgetStateProperty<Icon>.fromMap(
    <WidgetStatesConstraint, Icon>{
      WidgetState.selected: Icon(Icons.flip_to_front),
      WidgetState.any: Icon(Icons.flip_to_back),
    },
  );

  @override
  void dispose() {
    questionController.dispose();
    answerController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _reset();
  }

  void _reset() {
    doubleSided = widget.doubleSidedValue;
    deckId = widget.deckId;
    questionController.text = isQuestion ? widget.provisionaryCard.text : '';
    answerController.text = isQuestion ? '' : widget.provisionaryCard.text;
  }

  @override
  @mustCallSuper
  @protected
  void didUpdateWidget(covariant ProvisionaryCardFinalization oldWidget) {
    super.didUpdateWidget(oldWidget);
    _reset();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 600),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: FocusTraversalGroup(
            policy: OrderedTraversalPolicy(),
            child: Column(spacing: 8, children: [
              Text(widget.provisionaryCard.text),
              Row(
                children: [
                  Expanded(
                      child: Text(isQuestion
                          ? context.l10n.questionLabel
                          : context.l10n.answerLabel)),
                  FocusTraversalOrder(
                    order: NumericFocusOrder(1),
                    child: Switch(
                      value: isQuestion,
                      thumbIcon: frontBackIcon,
                      onChanged: (value) => setState(() {
                        isQuestion = value;
                        questionController.text =
                            isQuestion ? widget.provisionaryCard.text : '';
                        answerController.text =
                            isQuestion ? '' : widget.provisionaryCard.text;
                      }),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(child: Text('Double sided')),
                  FocusTraversalOrder(
                    order: NumericFocusOrder(2),
                    child: Switch(
                      value: doubleSided,
                      thumbIcon: doubleSidedIcon,
                      onChanged: (value) => setState(() {
                        doubleSided = value;
                      }),
                    ),
                  ),
                ],
              ),
              FocusTraversalOrder(
                order: NumericFocusOrder(3),
                child: TextFormField(
                  controller: questionController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: context.l10n.questionLabel,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              FocusTraversalOrder(
                order: NumericFocusOrder(4),
                child: TextFormField(
                  controller: answerController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: context.l10n.answerLabel,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              FocusTraversalOrder(
                order: NumericFocusOrder(5),
                child: DeckSelection(
                  initialDeckId: deckId,
                  onDeckSelected: (deckId) => setState(() {
                    this.deckId = deckId;
                  }),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: widget.onDiscard,
                    icon: Icon(Icons.cancel),
                    label: Text(context.l10n.discard),
                  ),
                  TextButton.icon(
                    onPressed: widget.onSnooze,
                    icon: Icon(Icons.snooze),
                    label: Text(context.l10n.later),
                  ),
                  FocusTraversalOrder(
                    order: NumericFocusOrder(5),
                    child: FilledButton.icon(
                        onPressed: isComplete
                            ? () => widget.onFinalize(
                                deckId!,
                                questionController.text,
                                answerController.text,
                                doubleSided)
                            : null,
                        icon: Icon(Icons.save),
                        label: Text(context.l10n.saveAndNext)),
                  ),
                ],
              ),
            ]),
          ),
        ),
      ),
    );
  }
}