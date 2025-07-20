import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'deck_list_item.dart';
import 'package:go_router/go_router.dart';

import '../../model/cards.dart' as model;
import 'decks_controller.dart';

/// A widget that displays a list of decks with loading, error, and empty states.
///
/// This widget uses Riverpod to manage state and automatically handles:
/// - Loading state with a circular progress indicator
/// - Error state with retry functionality
/// - Empty state with a message when no decks exist
/// - Data state displaying the list of decks
class DeckList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the sorted decks provider which automatically handles loading, error, and data states
    final sortedDecksAsync = ref.watch(sortedDecksProvider);

    return sortedDecksAsync.when(
      data: (decks) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: decks.isEmpty ? 1 : decks.length,
            itemBuilder: (context, index) {
              if (decks.isEmpty) {
                return Center(child: Text(context.l10n.noDecksMessage));
              }
              final deck = decks[index];
              return DeckListItem(deck: deck);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error loading decks: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Refresh the data by invalidating the provider
                ref.invalidate(sortedDecksProvider);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> deleteDeck(
    BuildContext context,
    WidgetRef ref,
    model.Deck deck,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.deleteDeck(deck.name)),
        content: Text(context.l10n.deleteDeckConfirmation),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(context.ml10n.cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () async {
              try {
                // Use the Riverpod controller to delete the deck
                await ref
                    .read(decksControllerProvider.notifier)
                    .deleteDeck(deck.id!);
                context.pop();
              } catch (e) {
                // Handle error - you might want to show a snackbar here
                context.pop();
              }
            },
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
  }
}
