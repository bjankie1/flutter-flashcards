import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/base_layout.dart';
import 'package:flutter_flashcards/src/decks/card_edit.dart';
import '../model/cards.dart' as model;

class CardEditPage extends StatelessWidget {
  final model.Card? card;

  final String deckId;

  const CardEditPage({this.card, required this.deckId, super.key});

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
        title: 'Card edit',
        child: CardEdit(
          card: card,
          deckId: deckId,
        ));
  }
}
