import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../common/build_context_extensions.dart';
import '../../common/deck_selection.dart';
import '../../common/editable_text_field.dart';
import '../../layout/base_layout.dart';
import 'provisionary_cards_review_controller.dart';
import '../../model/cards.dart' as model;

class ProvisionaryCardsReviewPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provisionaryCardsAsync = ref.watch(
      provisionaryCardsReviewControllerProvider,
    );

    return provisionaryCardsAsync.when(
      data: (data) {
        return BaseLayout(
          title: Text(context.l10n.provisionaryCardsReviewHeadline),
          child: ProvisionaryCardsReview(),
        );
      },
      loading: () => BaseLayout(
        title: Text(context.l10n.provisionaryCardsReviewHeadline),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => BaseLayout(
        title: Text(context.l10n.provisionaryCardsReviewHeadline),
        child: Center(child: Text('Error: $error')),
      ),
    );
  }
}

class ProvisionaryCardsReview extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provisionaryCardsAsync = ref.watch(
      provisionaryCardsReviewControllerProvider,
    );
    final controller = ref.read(
      provisionaryCardsReviewControllerProvider.notifier,
    );

    return provisionaryCardsAsync.when(
      data: (data) => Column(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600, maxHeight: 50),
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              scrollDirection: Axis.horizontal,
              children: data.provisionaryCards
                  .asMap()
                  .entries
                  .map(
                    (entry) => ProvisionaryCardChip(
                      text: entry.value.text,
                      finalized: data.finalizedCardsIndexes.contains(entry.key),
                      discarded: data.discardedCardsIndexes.contains(entry.key),
                      active: data.currentIndex == entry.key,
                      onDelete: () async {
                        await controller.discardCard(entry.key, entry.value);
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
          if (data.currentIndex >= 0 && data.currentCard != null)
            ProvisionaryCardFinalization()
          else
            _NoProvisionaryCardsMessage(),
        ],
      ),
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
    );
  }
}

/// Widget for displaying empty state messages in the provisionary cards review
class _NoProvisionaryCardsMessage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(provisionaryCardsReviewControllerProvider).value;
    if (data == null) return const SizedBox.shrink();

    final isEmpty = data.provisionaryCards.isEmpty;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600, minHeight: 300),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isEmpty ? Icons.inbox_outlined : Icons.check_circle_outline,
                size: 64,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
              ),
              const SizedBox(height: 24),
              Text(
                isEmpty
                    ? context.l10n.noProvisionaryCardsMessage
                    : context.l10n.allProvisionaryCardsReviewedMessage,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                isEmpty
                    ? context.l10n.noProvisionaryCardsDescription
                    : context.l10n.allProvisionaryCardsReviewedDescription,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        context.go('/');
                      }
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: Text(context.l10n.goBack),
                  ),
                  if (!isEmpty && data.selectedDeckId != null) ...[
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.go('/decks/${data.selectedDeckId}');
                      },
                      icon: const Icon(Icons.deck),
                      label: Text(context.l10n.openDeck),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
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

/// Widget for finalizing a provisionary card, fully driven by controller state.
class ProvisionaryCardFinalization extends ConsumerStatefulWidget {
  const ProvisionaryCardFinalization({super.key});

  @override
  ConsumerState<ProvisionaryCardFinalization> createState() =>
      _ProvisionaryCardFinalizationState();
}

class _ProvisionaryCardFinalizationState
    extends ConsumerState<ProvisionaryCardFinalization> {
  bool _isQuestionEditing = false;
  bool _isAnswerEditing = false;
  bool _isExplanationEditing = false;
  bool _isFinalizing = false;

  bool get _anyEditing =>
      _isQuestionEditing || _isAnswerEditing || _isExplanationEditing;

  Future<void> _showEditingWarning(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.warningTitle),
        content: Text(context.l10n.finalizeEditingWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.ok),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<ProvisionaryCardsReviewData> state = ref.watch(
      provisionaryCardsReviewControllerProvider,
    );
    final ProvisionaryCardsReviewController controller = ref.read(
      provisionaryCardsReviewControllerProvider.notifier,
    );

    return state.when(
      data: (ProvisionaryCardsReviewData data) {
        if (data.currentCard == null) {
          return const SizedBox.shrink();
        }
        final model.ProvisionaryCard provisionaryCard = data.currentCard!;
        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600, minHeight: 300),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: FocusTraversalGroup(
                policy: OrderedTraversalPolicy(),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 20,
                      ),
                      margin: const EdgeInsets.only(bottom: 20),
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
                          const SizedBox(height: 8),
                          Text(
                            provisionaryCard.text,
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
                            data.isQuestion
                                ? context.l10n.questionLabel
                                : context.l10n.answerLabel,
                          ),
                        ),
                        FocusTraversalOrder(
                          order: const NumericFocusOrder(1),
                          child: Switch(
                            value: data.isQuestion,
                            thumbIcon: frontBackIcon,
                            onChanged: (bool value) async {
                              await controller.setIsQuestion(
                                value,
                                context.cloudFunctions,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Expanded(child: Text('Double sided')),
                        FocusTraversalOrder(
                          order: const NumericFocusOrder(2),
                          child: Switch(
                            value: data.selectedDoubleSided,
                            thumbIcon: doubleSidedIcon,
                            onChanged: (bool value) =>
                                controller.setSelectedDoubleSided(value),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    FocusTraversalOrder(
                      order: const NumericFocusOrder(2.5),
                      child: DeckSelection(
                        initialDeckId: data.selectedDeckId,
                        onDeckSelected: (String? deckId) async {
                          await controller.setSelectedDeckId(
                            deckId,
                            context.cloudFunctions,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    FocusTraversalOrder(
                      order: const NumericFocusOrder(3),
                      child: EditableTextField(
                        initialValue: data.questionText,
                        labelText: context.l10n.questionLabel,
                        onSave: (String newValue) async {
                          controller.setQuestionText(newValue);
                          if (data.isQuestion) {
                            await controller.triggerGeneration(
                              context.cloudFunctions,
                            );
                          }
                        },
                        onEditingStateChanged: (editing) {
                          setState(() => _isQuestionEditing = editing);
                        },
                      ),
                    ),
                    if (!data.isQuestion)
                      AnimatedOpacity(
                        opacity: data.fetchingSuggestion ? 1 : 0,
                        duration: const Duration(milliseconds: 500),
                        child: const LinearProgressIndicator(),
                      ),
                    const SizedBox(height: 20),
                    FocusTraversalOrder(
                      order: const NumericFocusOrder(4),
                      child: EditableTextField(
                        initialValue: data.answerText,
                        labelText: context.l10n.answerLabel,
                        onSave: (String newValue) async {
                          controller.setAnswerText(newValue);
                          if (!data.isQuestion) {
                            await controller.triggerGeneration(
                              context.cloudFunctions,
                            );
                          }
                        },
                        onEditingStateChanged: (editing) {
                          setState(() => _isAnswerEditing = editing);
                        },
                      ),
                    ),
                    if (data.isQuestion)
                      AnimatedOpacity(
                        opacity: data.fetchingSuggestion ? 1 : 0,
                        duration: const Duration(milliseconds: 500),
                        child: const LinearProgressIndicator(),
                      ),
                    const SizedBox(height: 20),
                    FocusTraversalOrder(
                      order: const NumericFocusOrder(5),
                      child: EditableTextField(
                        initialValue: data.explanationText,
                        labelText: context.l10n.explanationLabel,
                        onSave: (String newValue) {
                          controller.setExplanationText(newValue);
                        },
                        onEditingStateChanged: (editing) {
                          setState(() => _isExplanationEditing = editing);
                        },
                      ),
                    ),
                    const SizedBox(height: 40),
                    FittedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () async {
                              await controller.discardCard(
                                data.currentIndex,
                                provisionaryCard,
                              );
                            },
                            icon: const Icon(Icons.cancel),
                            label: Text(context.l10n.discard),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              controller.snoozeCard();
                            },
                            icon: const Icon(Icons.snooze),
                            label: Text(context.l10n.later),
                          ),
                          FocusTraversalOrder(
                            order: const NumericFocusOrder(6),
                            child: FilledButton.icon(
                              onPressed:
                                  (controller.isCardFinalizationComplete &&
                                      !_isFinalizing)
                                  ? () async {
                                      if (_anyEditing) {
                                        await _showEditingWarning(context);
                                        return;
                                      }
                                      setState(() => _isFinalizing = true);
                                      try {
                                        await controller.finalizeCard(
                                          data.currentIndex,
                                          provisionaryCard,
                                          data.selectedDeckId!,
                                          data.questionText,
                                          data.answerText,
                                          data.explanationText,
                                          data.selectedDoubleSided,
                                          cloudFunctions:
                                              context.cloudFunctions,
                                        );
                                      } finally {
                                        setState(() => _isFinalizing = false);
                                      }
                                    }
                                  : null,
                              icon: _isFinalizing
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Icon(Icons.save),
                              label: _isFinalizing
                                  ? Text(context.l10n.saving)
                                  : Text(context.l10n.saveAndNext),
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
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, StackTrace? stackTrace) =>
          Center(child: Text('Error: $error')),
    );
  }

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
}
