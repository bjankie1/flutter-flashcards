import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/base_layout.dart';
import 'package:flutter_flashcards/src/decks/cards_list.dart';

import '../model/cards.dart' as model;
import 'card_edit_page.dart';

class CardsPage extends StatelessWidget {
  final model.Deck deck;

  const CardsPage({required this.deck});

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      title: 'Cards for ${deck.name}',
      currentPage: PageIndex.cards,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addCard(context, null),
        label: const Text('Add card'),
        icon: const Icon(Icons.add),
      ),
      child: CardsList(deck: deck),
    );
  }

  _addCard(BuildContext context, model.Card? card) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CardEditPage(
          deckId: deck.id!,
          card: card,
        ),
      ),
    );
  }
}
