import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/snackbar_messaging.dart';
import 'package:flutter_flashcards/src/common/themes.dart';
import 'package:flutter_flashcards/src/model/repository.dart';
import 'package:logger/logger.dart';
import 'package:flutter_flashcards/src/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../model/cards.dart' as model;
import '../../common/editable_text.dart' as custom;

/// Shows Deck metadata information enabling user to edit those details.
final class DeckDetails extends StatelessWidget {
  final Logger _log = Logger();

  final model.Deck deck;

  DeckDetails({super.key, required this.deck});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        custom.EditableText(
          text: deck.name,
          style: context.theme.textTheme.headlineSmall,
          onTextChanged: (value) async {
            var newDeck = deck.copyWith(name: value);
            try {
              final category = await context.cloudFunctions.deckCategory(
                value,
                deck.description ?? '',
              );
              newDeck = newDeck.copyWith(category: category);
            } catch (e, stackTrace) {
              _log.e(
                'Error saving deck name',
                error: e,
                stackTrace: stackTrace,
              );
            }
            await context.cardRepository.saveDeck(newDeck);
            context.showInfoSnackbar(context.l10n.deckNameSavedMessage);
          },
        ),
        const SizedBox(height: 8),
        custom.EditableText(
          text: deck.description ?? '',
          style: context.theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: context.theme.colorScheme.onSurface,
          ),
          placeholder: 'Add description',
          onTextChanged: (value) async {
            var newDeck = deck.copyWith(description: value);
            try {
              final category = await context.cloudFunctions.deckCategory(
                deck.name,
                value,
              );
              newDeck = newDeck.copyWith(category: category);
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
            await context.cardRepository.saveDeck(newDeck);
            context.showInfoSnackbar(context.l10n.deckDescriptionSavedMessage);
          },
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RepositoryLoader(
                fetcher: (repository) => repository.getCardCount(deck.id!),
                builder: (context, totalCards, _) {
                  return Text(
                    "${context.l10n.cards}: $totalCards",
                    style: context.theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: context.theme.colorScheme.onSurface,
                    ),
                  );
                },
              ),
              if (deck.category != null && !context.isMobile) ...[
                const SizedBox(width: 16),
                Chip(label: Text(deck.category?.name ?? '')),
              ],
              const Spacer(),
              RepositoryLoader(
                fetcher: (repository) => repository.getCardCount(deck.id!),
                builder: (context, totalCards, _) {
                  if (totalCards == 0) return const SizedBox.shrink();
                  return RepositoryLoader(
                    fetcher: (repository) =>
                        repository.cardsToReviewCount(deckId: deck.id!),
                    builder: (context, countStat, _) {
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
                                        color: context
                                            .theme
                                            .colorScheme
                                            .onErrorContainer,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        context.l10n.errorLoadingCards,
                                        style: TextStyle(
                                          color: context
                                              .theme
                                              .colorScheme
                                              .onErrorContainer,
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
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
