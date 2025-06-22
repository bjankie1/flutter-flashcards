import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/containers.dart';
import 'package:flutter_flashcards/src/decks/deck_list/deck_list_item.dart';

import '../model/cards.dart' as model;

class DeckGroupHorizontalList extends StatelessWidget {
  final List<model.Deck> decks;

  // Is this carousel presenting shared decks
  final bool sharedDecks;

  const DeckGroupHorizontalList({
    super.key,
    required this.decks,
    this.sharedDecks = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: decks
          .map(
            (deck) => CardsContainer(
              secondary: true,
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 80, maxWidth: 330),
                child: DeckListItem(deck: deck),
              ),
            ),
          )
          .toList(),
    );
  }
}
