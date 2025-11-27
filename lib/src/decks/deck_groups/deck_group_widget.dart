import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/themes.dart';
import 'package:flutter_flashcards/src/decks/deck_groups/deck_groups_controller.dart';
import 'package:flutter_flashcards/src/decks/deck_list/deck_list_item.dart';
import 'package:flutter_flashcards/src/decks/deck_list/decks_controller.dart';
import 'package:flutter_flashcards/src/model/cards.dart' as model;
import 'package:go_router/go_router.dart';
import 'package:flutter_flashcards/src/common/editable_text.dart' as custom;

class DeckGroupWidget extends ConsumerWidget {
  final model.DeckGroup deckGroup;

  const DeckGroupWidget({super.key, required this.deckGroup});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logger = Logger();
    logger.d('DeckGroupWidget rebuilt for group: ${deckGroup.name}');

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: custom.EditableText(
              text: deckGroup.name,
              style: context.textTheme.headlineSmall,
              onTextChanged: (value) {
                ref
                    .read(deckGroupsControllerProvider.notifier)
                    .updateDeckGroup(deckGroup.copyWith(name: value));
              },
            ),
          ),
          DeckGroupReviewButton(deckGroup: deckGroup),
        ],
      ),
    );
  }
}

class DeckListItemById extends ConsumerWidget {
  final model.DeckId deckId;

  const DeckListItemById({super.key, required this.deckId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deckAsync = ref.watch(deckProvider(deckId));

    return deckAsync.when(
      data: (deck) {
        if (deck == null) {
          return const SizedBox.shrink();
        }
        return DeckListItem(deck: deck);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) =>
          Center(child: Text('Error loading deck: $error')),
    );
  }
}

class DeckGroupReviewButton extends ConsumerWidget {
  final model.DeckGroup deckGroup;

  const DeckGroupReviewButton({super.key, required this.deckGroup});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countAsync = ref.watch(
      cardsToReviewCountByGroupProvider(deckGroup.id),
    );

    return countAsync.when(
      data: (countStat) {
        final count = countStat.values.fold(0, (p, c) => p + c);
        return Visibility(
          visible: count > 0,
          child: ElevatedButton.icon(
            onPressed: () async =>
                await context.push('/learn?deckGroupId=${deckGroup.id}'),
            icon: const Icon(Icons.play_circle_fill),
            label: Text(context.l10n.cardsToReview(count)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              textStyle: context.textTheme.labelLarge,
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }
}
