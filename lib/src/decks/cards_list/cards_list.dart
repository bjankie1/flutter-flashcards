import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../common/build_context_extensions.dart';
import '../../model/cards.dart' as model;
import 'cards_list_controller.dart';
import 'cards_list_widgets.dart';

class CardsList extends ConsumerWidget {
  final model.Deck deck;

  const CardsList({super.key, required this.deck});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controllerState = ref.watch(cardsListControllerProvider(deck.id!));
    final controller = ref.read(cardsListControllerProvider(deck.id!).notifier);

    return _CardsListView(
      deck: deck,
      controllerState: controllerState,
      controller: controller,
    );
  }
}

class _CardsListView extends StatefulWidget {
  final model.Deck deck;
  final AsyncValue<CardsListData> controllerState;
  final CardsListController controller;

  const _CardsListView({
    required this.deck,
    required this.controllerState,
    required this.controller,
  });

  @override
  State<_CardsListView> createState() => _CardsListViewState();
}

class _CardsListViewState extends State<_CardsListView> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    widget.controller.updateSearchQuery(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return widget.controllerState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
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
              onPressed: () => widget.controller.refresh(),
              child: Text(context.l10n.retry),
            ),
          ],
        ),
      ),
      data: (data) {
        final filteredCards = data.filteredCards;
        final hasCards = data.cards.isNotEmpty;
        return Column(
          children: [
            if (hasCards) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: context.l10n.cardsSearchHint,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: data.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
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
                                deck: widget.deck,
                                card: card,
                                cardStats: data.cardStats[card.id] ?? [],
                                onDelete: () =>
                                    widget.controller.deleteCard(card),
                              ),
                            ),
                            if (index < filteredCards.length - 1)
                              const Divider(),
                          ],
                        );
                      },
                    )
                  : Center(child: Text(context.l10n.noCardsMessage)),
            ),
          ],
        );
      },
    );
  }
}
