import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/async_operation_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/collapsible_description_field.dart';
import 'package:flutter_flashcards/src/common/themes.dart';
import 'package:flutter_flashcards/src/common/category_image.dart';
import 'package:logger/logger.dart';

import '../../model/cards.dart' as model;
import '../../common/editable_text.dart' as custom;
import '../../app_router.dart';
import '../../genkit/functions.dart';
import 'deck_details_controller.dart';
import '../deck_list/deck_info_controller.dart';
import '../deck_list/deck_cards_to_review_controller.dart';

/// Shows Deck metadata information enabling user to edit those details.
final class DeckDetails extends ConsumerWidget {
  final Logger _log = Logger();

  final model.Deck deck;

  DeckDetails({super.key, required this.deck});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deckDetailsAsync = ref.watch(deckDetailsControllerProvider(deck.id!));
    final controller = ref.read(
      deckDetailsControllerProvider(deck.id!).notifier,
    );

    return deckDetailsAsync.when(
      data: (currentDeck) => _DeckDetailsContent(
        deck: deck,
        currentDeck: currentDeck,
        controller: controller,
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) {
        _log.e(
          'Error loading deck details',
          error: error,
          stackTrace: stackTrace,
        );
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: context.theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading deck details',
                style: context.theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () =>
                    ref.refresh(deckDetailsControllerProvider(deck.id!)),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Content widget for displaying and editing deck details
final class _DeckDetailsContent extends ConsumerWidget
    with AsyncOperationHandler {
  final model.Deck deck;
  final model.Deck currentDeck;
  final DeckDetailsController controller;

  _DeckDetailsContent({
    required this.deck,
    required this.currentDeck,
    required this.controller,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryImage = currentDeck.category != null
        ? CategoryImage(
            category: currentDeck.category!,
            size: 120,
            borderRadius: BorderRadius.circular(24),
          )
        : null;

    final leftColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        custom.EditableText(
          text: currentDeck.name,
          style: context.theme.textTheme.headlineSmall,
          onTextChanged: (value) => executeWithFeedback(
            context: context,
            operation: () =>
                controller.updateDeckName(value, context.cloudFunctions),
            successMessage: context.l10n.deckNameSavedMessage,
            errorMessage: context.l10n.deckDescriptionSaveErrorMessage,
            logErrorPrefix: 'Error saving deck name',
          ),
        ),
        custom.EditableText(
          text: currentDeck.description ?? '',
          style: context.theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: context.theme.colorScheme.onSurface,
          ),
          placeholder: 'Add description',
          onTextChanged: (value) => executeWithFeedback(
            context: context,
            operation: () =>
                controller.updateDeckDescription(value, context.cloudFunctions),
            successMessage: context.l10n.deckDescriptionSavedMessage,
            errorMessage: context.l10n.deckDescriptionSaveErrorMessage,
            logErrorPrefix: 'Error saving deck description',
          ),
        ),
        const SizedBox(height: 20),
        _CardDescriptionFields(deck: currentDeck, controller: controller),
      ],
    );

    final rightColumn = categoryImage != null
        ? Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              categoryImage,
              const SizedBox(height: 16),
              CardCountWidget(deckId: deck.id!),
            ],
          )
        : const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: leftColumn),
            const SizedBox(width: 32),
            rightColumn,
          ],
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LearnButtonWidget(deckId: deck.id!),
              const SizedBox(width: 16),
              GenerateFromGoogleDocButtonWidget(deckId: deck.id!),
            ],
          ),
        ),
      ],
    );
  }
}

/// Widget for displaying the card count
final class CardCountWidget extends ConsumerWidget {
  final String deckId;

  const CardCountWidget({super.key, required this.deckId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardCountAsync = ref.watch(deckInfoControllerProvider(deckId));

    return cardCountAsync.when(
      data: (totalCards) => Text(
        "${context.l10n.cards}: $totalCards",
        style: context.theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: context.theme.colorScheme.onSurface,
        ),
      ),
      loading: () => const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (error, stackTrace) => Text(
        "${context.l10n.cards}: 0",
        style: context.theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: context.theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}

/// Widget for the learn button with review count badge
final class LearnButtonWidget extends ConsumerWidget
    with AsyncOperationHandler {
  final String deckId;

  LearnButtonWidget({super.key, required this.deckId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardCountAsync = ref.watch(deckInfoControllerProvider(deckId));

    return cardCountAsync.when(
      data: (totalCards) {
        if (totalCards == 0) return const SizedBox.shrink();

        final cardsToReviewAsync = ref.watch(
          deckCardsToReviewControllerProvider(deckId),
        );

        return cardsToReviewAsync.when(
          data: (countStat) {
            final count = countStat.values.fold(0, (p, c) => p + c);
            return Badge(
              isLabelVisible: count > 0,
              label: Text(count.toString()),
              child: ElevatedButton.icon(
                onPressed: () {
                  executeNavigation(
                    context: context,
                    operation: () {
                      AppNavigation.goToLearn(context, deckId);
                    },
                    errorMessage: context.l10n.errorLoadingCards,
                  );
                },
                icon: const Icon(
                  Icons.play_circle_fill,
                  color: Colors.white,
                  size: 24,
                ),
                label: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    context.l10n.learn,
                    style: context.theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                ),
              ),
            );
          },
          loading: () => const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          error: (error, stackTrace) => ElevatedButton.icon(
            onPressed: () {
              executeNavigation(
                context: context,
                operation: () {
                  AppNavigation.goToLearn(context, deckId);
                },
                errorMessage: context.l10n.errorLoadingCards,
              );
            },
            icon: const Icon(Icons.play_circle_fill),
            label: Text(context.l10n.learn),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }
}

/// Widget for the generate from Google Doc button
final class GenerateFromGoogleDocButtonWidget extends ConsumerWidget
    with AsyncOperationHandler {
  final String deckId;

  GenerateFromGoogleDocButtonWidget({super.key, required this.deckId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      onPressed: () {
        executeNavigation(
          context: context,
          operation: () {
            AppNavigation.goToGenerateFromGoogleDoc(context, deckId: deckId);
          },
          errorMessage: context.l10n.errorLoadingCards,
        );
      },
      icon: const Icon(Icons.description, color: Colors.white, size: 24),
      label: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Text(
          context.l10n.generateFromGoogleDoc,
          style: context.theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _CardDescriptionFields extends StatefulWidget with AsyncOperationHandler {
  final model.Deck deck;
  final DeckDetailsController controller;

  _CardDescriptionFields({required this.deck, required this.controller});

  @override
  State<_CardDescriptionFields> createState() => _CardDescriptionFieldsState();
}

class _CardDescriptionFieldsState extends State<_CardDescriptionFields>
    with AsyncOperationHandler {
  bool _isFrontLoading = false;
  bool _isBackLoading = false;
  bool _isExplanationLoading = false;
  bool _isGeneratingDescriptions = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Generate descriptions button
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: ElevatedButton.icon(
            onPressed: _isGeneratingDescriptions
                ? null
                : _generateCardDescriptions,
            icon: _isGeneratingDescriptions
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(context.l10n.generateCardDescriptions),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[700],
              foregroundColor: Colors.white,
            ),
          ),
        ),
        CollapsibleDescriptionField(
          text: widget.deck.frontCardDescription,
          isLoading: _isFrontLoading,
          onTextChanged: (value) async {
            setState(() {
              _isFrontLoading = true;
            });

            try {
              await executeWithFeedback(
                context: context,
                operation: () => widget.controller.updateFrontCardDescription(
                  value,
                  context.cloudFunctions,
                ),
                successMessage: context.l10n.frontCardDescriptionSavedMessage,
                errorMessage: context.l10n.frontCardDescriptionSaveErrorMessage,
                logErrorPrefix: 'Error saving front card description',
              );
            } finally {
              if (mounted) {
                setState(() {
                  _isFrontLoading = false;
                });
              }
            }
          },
          addButtonText: context.l10n.addFrontCardDescription,
          label: context.l10n.frontCardDescriptionLabel,
          hint: context.l10n.frontCardDescriptionHint,
        ),
        const SizedBox(height: 12),
        CollapsibleDescriptionField(
          text: widget.deck.backCardDescription,
          isLoading: _isBackLoading,
          onTextChanged: (value) async {
            setState(() {
              _isBackLoading = true;
            });

            try {
              await executeWithFeedback(
                context: context,
                operation: () => widget.controller.updateBackCardDescription(
                  value,
                  context.cloudFunctions,
                ),
                successMessage: context.l10n.backCardDescriptionSavedMessage,
                errorMessage: context.l10n.backCardDescriptionSaveErrorMessage,
                logErrorPrefix: 'Error saving back card description',
              );
            } finally {
              if (mounted) {
                setState(() {
                  _isBackLoading = false;
                });
              }
            }
          },
          addButtonText: context.l10n.addBackCardDescription,
          label: context.l10n.backCardDescriptionLabel,
          hint: context.l10n.backCardDescriptionHint,
        ),
        const SizedBox(height: 12),
        CollapsibleDescriptionField(
          text: widget.deck.explanationDescription,
          isLoading: _isExplanationLoading,
          onTextChanged: (value) async {
            setState(() {
              _isExplanationLoading = true;
            });

            try {
              await executeWithFeedback(
                context: context,
                operation: () =>
                    widget.controller.updateExplanationDescription(value),
                successMessage: context.l10n.explanationDescriptionSavedMessage,
                errorMessage:
                    context.l10n.explanationDescriptionSaveErrorMessage,
                logErrorPrefix: 'Error saving explanation description',
              );
            } finally {
              if (mounted) {
                setState(() {
                  _isExplanationLoading = false;
                });
              }
            }
          },
          addButtonText: context.l10n.addExplanationDescription,
          label: context.l10n.explanationDescriptionLabel,
          hint: context.l10n.explanationDescriptionHint,
        ),
      ],
    );
  }

  Future<void> _generateCardDescriptions() async {
    setState(() {
      _isGeneratingDescriptions = true;
    });

    try {
      final result = await widget.controller.generateCardDescriptions(context);

      // Show a dialog with the generated descriptions and analysis
      if (mounted) {
        _showGeneratedDescriptionsDialog(result);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingDescriptions = false;
        });
      }
    }
  }

  void _showGeneratedDescriptionsDialog(CardDescriptionResult result) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(context.l10n.generatedCardDescriptions),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.confidenceLevel,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text('${(result.confidence * 100).toStringAsFixed(1)}%'),
                const SizedBox(height: 16),
                Text(
                  context.l10n.analysis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(result.analysis),
                const SizedBox(height: 16),
                if (result.frontCardDescription != null) ...[
                  Text(
                    context.l10n.frontCardDescriptionLabel,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(result.frontCardDescription!),
                  const SizedBox(height: 16),
                ],
                if (result.backCardDescription != null) ...[
                  Text(
                    context.l10n.backCardDescriptionLabel,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(result.backCardDescription!),
                  const SizedBox(height: 16),
                ],
                if (result.explanationDescription != null) ...[
                  Text(
                    context.l10n.explanationDescriptionLabel,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(result.explanationDescription!),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _applyGeneratedDescriptions(result);
              },
              child: Text(context.l10n.apply),
            ),
          ],
        );
      },
    );
  }

  Future<void> _applyGeneratedDescriptions(CardDescriptionResult result) async {
    // Apply the generated descriptions to the deck
    await executeWithFeedback(
      context: context,
      operation: () async {
        if (result.frontCardDescription != null) {
          await widget.controller.updateFrontCardDescription(
            result.frontCardDescription!,
            context.cloudFunctions,
          );
        }
        if (result.backCardDescription != null) {
          await widget.controller.updateBackCardDescription(
            result.backCardDescription!,
            context.cloudFunctions,
          );
        }
        if (result.explanationDescription != null) {
          await widget.controller.updateExplanationDescription(
            result.explanationDescription!,
          );
        }

        // Note: Reverse descriptions are now handled by the dedicated generateFrontFromBack function
        // No need to generate reverse descriptions separately
      },
      successMessage: context.l10n.cardDescriptionsAppliedMessage,
      errorMessage: context.l10n.cardDescriptionsApplyErrorMessage,
      logErrorPrefix: 'Error applying generated card descriptions',
    );
  }
}
