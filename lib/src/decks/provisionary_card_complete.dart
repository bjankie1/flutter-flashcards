import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/deck_selection.dart';
import 'package:flutter_flashcards/src/common/themes.dart';
import 'package:flutter_flashcards/src/layout/base_layout.dart';
import 'package:flutter_flashcards/src/model/cards.dart' as model;
import 'package:flutter_flashcards/src/model/repository.dart';
import 'package:flutter_flashcards/src/widgets.dart';
import 'package:logger/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'cards_list/deck_details_controller.dart';

class ProvisionaryCardsReviewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RepositoryLoader(
      fetcher: (repository) => repository.listProvisionaryCards(),
      builder: (context, data, _) {
        return BaseLayout(
          title: Text(context.l10n.provisionaryCardsReviewHeadline),
          child: data.isEmpty
              ? Text(
                  context.l10n.noProvisionaryCardsHeadline,
                  style: context.textTheme.titleLarge,
                )
              : ProvisionaryCardsReview(provisionaryCards: data.toList()),
        );
      },
    );
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
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600, maxHeight: 50),
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            scrollDirection: Axis.horizontal,
            children: widget.provisionaryCards
                .asMap()
                .entries
                .map(
                  (entry) => ProvisionaryCardChip(
                    text: entry.value.text,
                    finalized: finalizedCardsIndexes.contains(entry.key),
                    discarded: discardedCardsIndexes.contains(entry.key),
                    active: currentIndex == entry.key,
                    onDelete: () async =>
                        await _discardProposal(context, entry.key, entry.value),
                  ),
                )
                .toList(),
          ),
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
                  doubleSided,
                ),
            onDiscard: () async => await _discardProposal(
              context,
              currentIndex,
              widget.provisionaryCards.toList()[currentIndex],
            ),
            onSnooze: () => setState(() {
              _progressIndex();
            }),
          ),
      ],
    );
  }

  Future<void> _discardProposal(
    BuildContext context,
    int index,
    model.ProvisionaryCard provisionaryCard,
  ) async {
    await context.cardRepository.finalizeProvisionaryCard(
      provisionaryCard.id,
      null,
    );
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
    bool doubleSided,
  ) async {
    final cardId = context.cardRepository.nextCardId();
    final card = model.Card(
      id: cardId,
      deckId: deckId,
      question: question,
      answer: answer,
      options: model.CardOptions(learnBothSides: doubleSided),
    );
    await context.cardRepository.saveCard(card);
    await context.cardRepository.finalizeProvisionaryCard(
      provisionaryCard.id,
      cardId,
    );
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Chip(
        label: Text(
          text,
          style: TextStyle(
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
            color: _getTextColor(context),
          ),
        ),
        deleteIcon: Icon(Icons.delete, color: _getTextColor(context), size: 18),
        onDeleted: finalized || discarded ? null : onDelete,
        backgroundColor: _getBackgroundColor(context),
        side: BorderSide(
          color: _getBorderColor(context),
          width: active ? 2.0 : 1.0,
        ),
        elevation: active ? 4.0 : 1.0,
        shadowColor: active
            ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
            : null,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      ),
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    if (discarded) {
      return Theme.of(context).colorScheme.errorContainer.withOpacity(0.3);
    }
    if (finalized) {
      return Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3);
    }
    if (active) {
      return Theme.of(context).colorScheme.primaryContainer;
    }
    return Theme.of(context).colorScheme.surfaceVariant;
  }

  Color _getTextColor(BuildContext context) {
    if (discarded) {
      return Theme.of(context).colorScheme.onErrorContainer;
    }
    if (finalized) {
      return Theme.of(context).colorScheme.onPrimaryContainer;
    }
    if (active) {
      return Theme.of(context).colorScheme.onPrimaryContainer;
    }
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  Color _getBorderColor(BuildContext context) {
    if (discarded) {
      return Theme.of(context).colorScheme.error;
    }
    if (finalized) {
      return Theme.of(context).colorScheme.primary;
    }
    if (active) {
      return Theme.of(context).colorScheme.primary;
    }
    return Theme.of(context).colorScheme.outline;
  }
}

class ProvisionaryCardFinalization extends StatefulWidget {
  final model.ProvisionaryCard provisionaryCard;
  final bool doubleSidedValue;
  final String? deckId;
  final Function(
    String deckId,
    String question,
    String answer,
    bool doubleSided,
  )
  onFinalize;
  final VoidCallback onDiscard;
  final VoidCallback onSnooze;

  const ProvisionaryCardFinalization({
    super.key,
    required this.doubleSidedValue,
    this.deckId,
    required this.provisionaryCard,
    required this.onFinalize,
    required this.onDiscard,
    required this.onSnooze,
  });

  @override
  State<ProvisionaryCardFinalization> createState() =>
      _ProvisionaryCardFinalizationState();
}

class _ProvisionaryCardFinalizationState
    extends State<ProvisionaryCardFinalization> {
  final _log = Logger();

  bool doubleSided = true;
  String? deckId;
  bool isQuestion = true;
  model.Deck? deck;

  final questionController = TextEditingController();
  final answerController = TextEditingController();

  bool fetchingSuggestion = false;

  bool get isComplete =>
      questionController.text.isNotEmpty &&
      answerController.text.isNotEmpty &&
      deckId != null;

  static const WidgetStateProperty<Icon> doubleSidedIcon =
      WidgetStateProperty<Icon>.fromMap(<WidgetStatesConstraint, Icon>{
        WidgetState.selected: Icon(Icons.swap_vert),
        WidgetState.any: Icon(Icons.flip_to_front),
      });

  static const WidgetStateProperty<Icon> frontBackIcon =
      WidgetStateProperty<Icon>.fromMap(<WidgetStatesConstraint, Icon>{
        WidgetState.selected: Icon(Icons.flip_to_front),
        WidgetState.any: Icon(Icons.flip_to_back),
      });

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
  void didUpdateWidget(covariant ProvisionaryCardFinalization oldWidget) async {
    super.didUpdateWidget(oldWidget);
    _reset();
    _geminiSuggestion();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 600, minHeight: 300),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: FocusTraversalGroup(
            policy: OrderedTraversalPolicy(),
            child: ListView(
              shrinkWrap: true,
              children: [
                // Prominent display of the provisionary card text
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.cardProposalLabel,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        widget.provisionaryCard.text,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isQuestion
                            ? context.l10n.questionLabel
                            : context.l10n.answerLabel,
                      ),
                    ),
                    FocusTraversalOrder(
                      order: NumericFocusOrder(1),
                      child: Switch(
                        value: isQuestion,
                        thumbIcon: frontBackIcon,
                        onChanged: (value) {
                          setState(() {
                            isQuestion = value;
                            questionController.text = isQuestion
                                ? widget.provisionaryCard.text
                                : '';
                            answerController.text = isQuestion
                                ? ''
                                : widget.provisionaryCard.text;
                          });
                          _geminiSuggestion();
                        },
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
                SizedBox(height: 20),
                FocusTraversalOrder(
                  order: NumericFocusOrder(2.5),
                  child: DeckSelection(
                    initialDeckId: deckId,
                    onDeckSelected: (deckId) async {
                      setState(() {
                        this.deckId = deckId;
                      });
                      await _geminiSuggestion();
                    },
                  ),
                ),
                SizedBox(height: 20),
                FocusTraversalOrder(
                  order: NumericFocusOrder(3),
                  child: TextFormField(
                    controller: questionController,
                    minLines: 1,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: context.l10n.questionLabel,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                if (!isQuestion)
                  AnimatedOpacity(
                    opacity: fetchingSuggestion ? 1 : 0,
                    duration: Duration(milliseconds: 500),
                    child: LinearProgressIndicator(),
                  ),
                SizedBox(height: 20),
                FocusTraversalOrder(
                  order: NumericFocusOrder(4),
                  child: TextFormField(
                    controller: answerController,
                    minLines: 1,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: context.l10n.answerLabel,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                if (isQuestion)
                  AnimatedOpacity(
                    opacity: fetchingSuggestion ? 1 : 0,
                    duration: Duration(milliseconds: 500),
                    child: LinearProgressIndicator(),
                  ),
                SizedBox(height: 40),
                FittedBox(
                  child: Row(
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
                        child: ListenableBuilder(
                          listenable: Listenable.merge([
                            questionController,
                            answerController,
                          ]),
                          builder: (context, _) {
                            return FilledButton.icon(
                              onPressed: isComplete
                                  ? () => widget.onFinalize(
                                      deckId!,
                                      questionController.text,
                                      answerController.text,
                                      doubleSided,
                                    )
                                  : null,
                              icon: Icon(Icons.save),
                              label: Text(context.l10n.saveAndNext),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _geminiSuggestion() async {
    if (deckId != null && (deck == null || deck!.id != deckId)) {
      try {
        deck = await context.cardRepository.loadDeck(deckId!);
      } catch (e) {
        _log.e('Error loading deck for suggestion', error: e);
        return; // Exit early if deck loading fails
      }
    }

    if (deck == null) {
      _log.d('No deck available for suggestion');
      return;
    }

    _log.d('Fetching suggestion for deck $deck');
    _log.d(
      'Deck descriptions: front=${deck?.frontCardDescription}, back=${deck?.backCardDescription}, explanation=${deck?.explanationDescription}',
    );

    if (deck?.category != null) {
      setState(() {
        fetchingSuggestion = true;
      });
      try {
        // Use a more robust way to access the controller
        final container = ProviderScope.containerOf(context);
        final controller = container.read(
          deckDetailsControllerProvider(deck!.id!).notifier,
        );

        // Ensure the deck is loaded in the controller
        await controller.ensureDeckLoaded();

        // Check if the controller is ready and has a valid deck loaded
        if (!controller.isReady) {
          _log.w('DeckDetailsController is not ready for deck: ${deck!.id}');
          return;
        }

        final currentDeck = controller.getDeck();
        if (currentDeck == null) {
          _log.w(
            'DeckDetailsController has no deck loaded, skipping suggestion',
          );
          return;
        }

        final suggestion = await controller.generateCardAnswer(
          widget.provisionaryCard.text,
          context,
        );
        setState(() {
          if (isQuestion) {
            answerController.text = suggestion.answer;
          } else {
            questionController.text = suggestion.answer;
          }
        });
      } catch (e) {
        _log.e('Error generating card answer suggestion', error: e);

        // Fallback: try to generate suggestion directly using cloud functions
        try {
          _log.d(
            'Attempting fallback suggestion generation for deck: ${deck!.id}',
          );

          if (deck!.category == null) {
            _log.w('Deck has no category, cannot generate suggestion');
            return;
          }

          // Use translated descriptions if available, otherwise fall back to original
          final effectiveFrontDescription =
              deck!.frontCardDescriptionTranslated ??
              deck!.frontCardDescription;
          final effectiveBackDescription =
              deck!.backCardDescriptionTranslated ?? deck!.backCardDescription;
          final effectiveExplanationDescription =
              deck!.explanationDescriptionTranslated ??
              deck!.explanationDescription;

          // Determine the category to use
          model.DeckCategory categoryToUse = deck!.category!;

          final suggestion = await context.cloudFunctions.generateCardAnswer(
            categoryToUse,
            deck!.name,
            deck!.description ?? '',
            widget.provisionaryCard.text,
            frontCardDescription: effectiveFrontDescription,
            backCardDescription: effectiveBackDescription,
            explanationDescription: effectiveExplanationDescription,
          );

          setState(() {
            if (isQuestion) {
              answerController.text = suggestion.answer;
            } else {
              questionController.text = suggestion.answer;
            }
          });

          _log.d('Fallback suggestion generation successful');
        } catch (fallbackError) {
          _log.e(
            'Fallback suggestion generation also failed',
            error: fallbackError,
          );
          // Don't show error to user for suggestions, just log it
        }
      } finally {
        setState(() {
          fetchingSuggestion = false;
        });
      }
    }
  }
}
