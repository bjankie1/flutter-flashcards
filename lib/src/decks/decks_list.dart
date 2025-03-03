import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/decks/deck_list_item.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../model/cards.dart' as model;
import '../model/repository.dart';
import '../widgets.dart';

class DeckList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: context.cardRepository.decksUpdated,
        builder: (context, value, _) {
          return RepositoryLoader<Iterable<model.Deck>>(
            fetcher: (repository) => repository.loadDecks(),
            builder: (context, decksIterable, repository) {
              final decks = decksIterable.toList();
              decks.sort((deck1, deck2) => deck1.name.compareTo(deck2.name));
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
          );
        });
  }

  Future<void> deleteDeck(BuildContext context, model.Deck deck) async {
    final repository = Provider.of<CardsRepository>(context, listen: false);
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
                    await repository.deleteDeck(deck.id!);
                    context.pop();
                  },
                  child: Text(context.l10n.delete),
                ),
              ],
            ));
  }
}