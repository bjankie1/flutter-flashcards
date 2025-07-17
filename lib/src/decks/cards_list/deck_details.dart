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

class _CardDescriptionFields extends StatelessWidget
    with AsyncOperationHandler {
  final model.Deck deck;
  final DeckDetailsController controller;

  _CardDescriptionFields({required this.deck, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CollapsibleDescriptionField(
          text: deck.frontCardDescription,
          onTextChanged: (value) => executeWithFeedback(
            context: context,
            operation: () => controller.updateFrontCardDescription(value),
            successMessage: context.l10n.frontCardDescriptionSavedMessage,
            errorMessage: context.l10n.frontCardDescriptionSaveErrorMessage,
            logErrorPrefix: 'Error saving front card description',
          ),
          addButtonText: context.l10n.addFrontCardDescription,
          label: context.l10n.frontCardDescriptionLabel,
          hint: context.l10n.frontCardDescriptionHint,
        ),
        const SizedBox(height: 12),
        CollapsibleDescriptionField(
          text: deck.backCardDescription,
          onTextChanged: (value) => executeWithFeedback(
            context: context,
            operation: () => controller.updateBackCardDescription(value),
            successMessage: context.l10n.backCardDescriptionSavedMessage,
            errorMessage: context.l10n.backCardDescriptionSaveErrorMessage,
            logErrorPrefix: 'Error saving back card description',
          ),
          addButtonText: context.l10n.addBackCardDescription,
          label: context.l10n.backCardDescriptionLabel,
          hint: context.l10n.backCardDescriptionHint,
        ),
        const SizedBox(height: 12),
        CollapsibleDescriptionField(
          text: deck.explanationDescription,
          onTextChanged: (value) => executeWithFeedback(
            context: context,
            operation: () => controller.updateExplanationDescription(value),
            successMessage: context.l10n.explanationDescriptionSavedMessage,
            errorMessage: context.l10n.explanationDescriptionSaveErrorMessage,
            logErrorPrefix: 'Error saving explanation description',
          ),
          addButtonText: context.l10n.addExplanationDescription,
          label: context.l10n.explanationDescriptionLabel,
          hint: context.l10n.explanationDescriptionHint,
        ),
      ],
    );
  }
}
