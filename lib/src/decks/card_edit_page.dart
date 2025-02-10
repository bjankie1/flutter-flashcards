import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/decks/card_edit.dart';
import 'package:flutter_flashcards/src/layout/base_layout.dart';
import 'package:flutter_flashcards/src/widgets.dart';
import 'package:gpt_markdown/gpt_markdown.dart';

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
            ? GptMarkdown(context.l10n.createCardTitle(deck?.name ?? ''))
            : GptMarkdown(context.l10n.editCardTitle(deck?.name ?? '')),
        currentPage: PageIndex.cards,
        child: deck != null
            ? CardEdit(
                card: card,
                deck: deck,
              )
            : Text(context.l10n.deckNotFoundMessage),
      ),
    );
  }
}