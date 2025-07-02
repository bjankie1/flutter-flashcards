import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/snackbar_messaging.dart';
import 'package:flutter_flashcards/src/common/themes.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

import '../../model/cards.dart' as model;
import '../../common/editable_text.dart' as custom;
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

    return deckDetailsAsync.when(
      data: (currentDeck) => _buildDeckDetails(context, ref, currentDeck),
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

  Widget _buildDeckDetails(
    BuildContext context,
    WidgetRef ref,
    model.Deck currentDeck,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        custom.EditableText(
          text: currentDeck.name,
          style: context.theme.textTheme.headlineSmall,
          onTextChanged: (value) async {
            try {
              await ref
                  .read(deckDetailsControllerProvider(deck.id!).notifier)
                  .updateDeckName(value, context.cloudFunctions);
              context.showInfoSnackbar(context.l10n.deckNameSavedMessage);
            } catch (e, stackTrace) {
              _log.e(
                'Error saving deck name',
                error: e,
                stackTrace: stackTrace,
              );
              context.showErrorSnackbar(
                context.l10n.deckDescriptionSaveErrorMessage,
              );
            }
          },
        ),
        const SizedBox(height: 8),
        custom.EditableText(
          text: currentDeck.description ?? '',
          style: context.theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: context.theme.colorScheme.onSurface,
          ),
          placeholder: 'Add description',
          onTextChanged: (value) async {
            try {
              await ref
                  .read(deckDetailsControllerProvider(deck.id!).notifier)
                  .updateDeckDescription(value, context.cloudFunctions);
              context.showInfoSnackbar(
                context.l10n.deckDescriptionSavedMessage,
              );
            } catch (e, stackTrace) {
              _log.e(
                'Error saving deck description',
                error: e,
                stackTrace: stackTrace,
              );
              context.showErrorSnackbar(
                context.l10n.deckDescriptionSaveErrorMessage,
              );
            }
          },
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildCardCount(context, ref),
              if (currentDeck.category != null && !context.isMobile) ...[
                const SizedBox(width: 16),
                Chip(label: Text(currentDeck.category?.name ?? '')),
              ],
              const Spacer(),
              _buildLearnButton(context, ref),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardCount(BuildContext context, WidgetRef ref) {
    final cardCountAsync = ref.watch(deckInfoControllerProvider(deck.id!));

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

  Widget _buildLearnButton(BuildContext context, WidgetRef ref) {
    final cardCountAsync = ref.watch(deckInfoControllerProvider(deck.id!));

    return cardCountAsync.when(
      data: (totalCards) {
        if (totalCards == 0) return const SizedBox.shrink();

        final cardsToReviewAsync = ref.watch(
          deckCardsToReviewControllerProvider(deck.id!),
        );

        return cardsToReviewAsync.when(
          data: (countStat) {
            final count = countStat.values.fold(0, (p, c) => p + c);
            return Badge(
              isLabelVisible: count > 0,
              label: Text(count.toString()),
              child: ElevatedButton.icon(
                onPressed: () {
                  try {
                    context.go('/learn?deckId=${deck.id}');
                  } on Exception {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor:
                            context.theme.colorScheme.errorContainer,
                        content: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: context.theme.colorScheme.onErrorContainer,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              context.l10n.errorLoadingCards,
                              style: TextStyle(
                                color:
                                    context.theme.colorScheme.onErrorContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
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
          loading: () => const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          error: (error, stackTrace) => ElevatedButton.icon(
            onPressed: () {
              try {
                context.go('/learn?deckId=${deck.id}');
              } on Exception {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: context.theme.colorScheme.errorContainer,
                    content: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: context.theme.colorScheme.onErrorContainer,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          context.l10n.errorLoadingCards,
                          style: TextStyle(
                            color: context.theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
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
