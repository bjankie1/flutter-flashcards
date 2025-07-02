import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../common/build_context_extensions.dart';
import '../../common/themes.dart';
import '../../model/cards.dart' as model;
import 'deck_cards_to_review_controller.dart';

class DeckCardsToReviewWidget extends ConsumerWidget {
  final model.Deck deck;

  const DeckCardsToReviewWidget({super.key, required this.deck});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsToReviewAsync = ref.watch(
      deckCardsToReviewControllerProvider(deck.id!),
    );

    return cardsToReviewAsync.when(
      data: (cardsToReviewByState) {
        final cardCount = cardsToReviewByState.values.reduce(
          (agg, next) => agg + next,
        );
        return Visibility(
          visible: cardCount > 0,
          child: ElevatedButton.icon(
            onPressed: () {
              startLearning(context, deck);
            },
            icon: const Icon(Icons.play_circle_fill, size: 18),
            label: Text(
              context.l10n.cardsToReview(cardCount),
              overflow: TextOverflow.clip,
              softWrap: false,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(80, 32),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
              textStyle: Theme.of(context).textTheme.labelMedium,
              elevation: 1,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }

  void startLearning(BuildContext context, model.Deck deck) async {
    try {
      await context.push('/learn?deckId=${deck.id}');
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
  }
}
