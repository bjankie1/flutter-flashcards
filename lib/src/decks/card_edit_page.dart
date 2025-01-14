import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/app.dart';
import 'package:flutter_flashcards/src/base_layout.dart';
import 'package:flutter_flashcards/src/decks/card_edit.dart';
import 'package:flutter_flashcards/src/widgets.dart';
import '../model/cards.dart' as model;

class CardEditPage extends StatelessWidget {
  final model.Card? card;

  final String deckId;

  const CardEditPage({this.card, required this.deckId, super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryLoader(
      fetcher: (repository) => repository.loadDeck(deckId),
      builder: (context, deck, _) => BaseLayout(
        title: card == null
            ? context.l10n.createCardTitle(deck?.name ?? '')
            : context.l10n.editCardTitle(deck?.name ?? ''),
        currentPage: PageIndex.cards,
        child: deck != null
            ? CardEdit(
                card: card,
                deckId: deckId,
              )
            : Text('Deck not found'),
      ),
    );
  }
}
