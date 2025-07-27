import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../common/build_context_extensions.dart';
import '../../model/cards.dart' as model;
import 'cards_list_controller.dart';
import 'cards_list_widgets.dart';

/// Widget for displaying the cards list
class CardsList extends ConsumerWidget {
  final model.Deck deck;

  const CardsList({super.key, required this.deck});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controllerState = ref.watch(cardsListControllerProvider(deck.id!));
    final controller = ref.read(cardsListControllerProvider(deck.id!).notifier);

    return controllerState.when(
      loading: () => const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => SliverToBoxAdapter(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(context.l10n.errorLoadingCards),
              ...[
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => controller.refresh(),
                child: Text(context.l10n.retry),
              ),
            ],
          ),
        ),
      ),
      data: (data) {
        final filteredCards = data.filteredCards;
        final hasCards = filteredCards.isNotEmpty;

        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            if (hasCards) {
              // Card item
              final card = filteredCards[index];
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: CardTile(
                      deck: deck,
                      card: card,
                      cardStats: data.cardStats[card.id] ?? [],
                      onDelete: () => controller.deleteCard(card),
                    ),
                  ),
                  if (index < filteredCards.length - 1) const Divider(),
                ],
              );
            } else {
              // No cards message
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(context.l10n.noCardsMessage),
                ),
              );
            }
          }, childCount: hasCards ? filteredCards.length : 1),
        );
      },
    );
  }
}
