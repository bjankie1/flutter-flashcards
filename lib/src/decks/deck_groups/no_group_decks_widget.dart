import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/decks/deck_groups/deck_groups_controller.dart';
import 'package:flutter_flashcards/src/decks/deck_groups/deck_group_widget.dart';

class NoGroupDecksWidget extends ConsumerWidget {
  const NoGroupDecksWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unassignedDecksAsync = ref.watch(unassignedDecksProvider);
    final logger = Logger();

    return unassignedDecksAsync.when(
      data: (deckIds) {
        logger.d('NoGroupDecksWidget: ${deckIds.length} unassigned decks');

        if (deckIds.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            // Header
            Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 8.0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      context.l10n.decksWithoutGroupHeader,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Decks list
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    for (int i = 0; i < deckIds.length; i++) ...[
                      if (i > 0) const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        child: DeckListItemById(deckId: deckIds[i]),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) {
        logger.e(
          'Error loading unassigned decks',
          error: error,
          stackTrace: stackTrace,
        );
        return Center(child: Text('Error loading unassigned decks: $error'));
      },
    );
  }
}
