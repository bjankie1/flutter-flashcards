import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/decks/deck_list_item.dart';

import '../model/cards.dart' as model;

class DeckGroupHorizontalList extends StatelessWidget {
  final List<model.Deck> decks;

  // Is this carousel presenting shared decks
  final bool sharedDecks;

  const DeckGroupHorizontalList(
      {super.key, required this.decks, this.sharedDecks = false});

  @override
  Widget build(BuildContext context) {
    return ListView(
        scrollDirection: Axis.horizontal,
        children: decks
            .map((deck) =>
                // ColoredBox(color: Colors.green, child: Text(deck.name)))
                // sharedDecks
                //     ? SharedDeckItem(
                //         deck: deck,
                //         avatar: Avatar(
                //           size: 20,
                //           userId: 'TODO',
                //         ))
                //     :
                ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 100, maxWidth: 300),
                    child: DeckListItem(deck: deck)))
            .toList());
  }
}