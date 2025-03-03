import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/layout/base_layout.dart';
import 'package:flutter_flashcards/src/decks/cards_list.dart';
import 'package:flutter_flashcards/src/decks/deck_details.dart';
import 'package:flutter_flashcards/src/model/repository.dart';
import 'package:flutter_flashcards/src/widgets.dart';
import 'package:provider/provider.dart';

import '../model/cards.dart' as model;
import 'card_edit_page.dart';

class DeckDetailsPage extends StatelessWidget {
  final model.Deck deck;

  const DeckDetailsPage({required this.deck});

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      title: Text(deck.name),
      currentPage: PageIndex.cards,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addCard(context, null),
        label: Text(context.l10n.addCard),
        icon: const Icon(Icons.add),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          children: [
            ValueListenableBuilder(
                valueListenable: context.watch<CardsRepository>().decksUpdated,
                builder: (context, deckChange, _) => RepositoryLoader(
                    fetcher: (repository) => repository.loadDeck(deck.id!),
                    builder: (context, deck, _) =>
                        DeckInformation(deck: deck!))),
            CardsList(deck: deck),
          ],
        ),
      ),
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