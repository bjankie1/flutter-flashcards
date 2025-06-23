import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common/build_context_extensions.dart';
import '../../model/repository.dart';
import '../../model/cards.dart' as model;
import 'cards_list_controller.dart';
import 'cards_list_widgets.dart';

class CardsList extends StatelessWidget {
  final model.Deck deck;

  const CardsList({super.key, required this.deck});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CardsListController(
        deckId: deck.id!,
        repository: context.read<CardsRepository>(),
      ),
      child: _CardsListView(deck: deck),
    );
  }
}

class _CardsListView extends StatelessWidget {
  final model.Deck deck;
  const _CardsListView({required this.deck});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CardsListController>();
    final filteredCards = controller.filteredCards;
    final hasCards = controller.cards.isNotEmpty;
    if (controller.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.error) {
      return Center(child: Text(context.l10n.errorLoadingCards));
    }
    return Column(
      children: [
        if (hasCards) ...[
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                hintText: context.l10n.cardsSearchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: controller.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          controller.searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
              ),
            ),
          ),
        ],
        Expanded(
          child: hasCards
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: filteredCards.length,
                  itemBuilder: (context, index) {
                    final card = filteredCards[index];
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: CardTile(
                            deck: deck,
                            card: card,
                            cardStats: controller.cardStats[card.id] ?? [],
                            onDelete: () => controller.deleteCard(card),
                          ),
                        ),
                        if (index < filteredCards.length - 1) const Divider(),
                      ],
                    );
                  },
                )
              : Center(child: Text(context.l10n.noCardsMessage)),
        ),
      ],
    );
  }
}
