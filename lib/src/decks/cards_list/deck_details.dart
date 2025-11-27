import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/async_operation_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';

import 'package:flutter_flashcards/src/common/themes.dart';
import 'package:logger/logger.dart';

import '../../model/cards.dart' as model;
import '../../common/editable_text.dart' as custom;
import 'deck_details_controller.dart';
import 'card_descriptions_dialog.dart';

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
        return _ErrorDisplayWidget(deck: deck);
      },
    );
  }
}

class _ErrorDisplayWidget extends ConsumerWidget {
  const _ErrorDisplayWidget({required this.deck});

  final model.Deck deck;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: custom.EditableText(
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
            ),
            IconButton(
              onPressed: () => _showCardDescriptionsDialog(context),
              icon: const Icon(Icons.settings),
              tooltip: context.l10n.cardDescriptions,
            ),
          ],
        ),
        custom.EditableText(
          text: currentDeck.description ?? '',
          style: context.theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: context.isDarkTheme
                ? context.theme.colorScheme.onSurface.darken(30)
                : context.theme.colorScheme.onSurface.lighten(30),
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
      ],
    );
  }

  void _showCardDescriptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CardDescriptionsDialog(deck: deck),
    );
  }
}
