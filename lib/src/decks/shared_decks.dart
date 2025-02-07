import 'package:flutter/material.dart';

import '../common/build_context_extensions.dart';
import '../model/cards.dart' as model;
import '../widgets.dart';

class SharedDeckListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RepositoryLoader<Iterable<model.Deck>>(
      fetcher: (repository) => repository.listSharedDecks(),
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
                return Center(child: Text(context.l10n.noCardsMessage));
              }
              final deck = decks[index];
              return SharedDeckItem(deck: deck);
            },
          ),
        );
      },
    );
  }
}

class SharedDeckItem extends StatelessWidget {
  final model.Deck deck;

  const SharedDeckItem({super.key, required this.deck});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(deck.name),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.push_pin),
            label: Text('Select deck'),
          )
        ],
      ),
    );
  }
}