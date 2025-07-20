import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/decks/cards_list/cards_list.dart';
import 'package:flutter_flashcards/src/decks/cards_list/deck_details.dart';
import 'package:flutter_flashcards/src/decks/cards_list/deck_details_page_controller.dart';
import 'package:flutter_flashcards/src/layout/base_layout.dart';

import '../../model/cards.dart' as model;

class DeckDetailsPage extends ConsumerWidget {
  final model.Deck deck;

  const DeckDetailsPage({required this.deck});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseLayout(
      title: Text(deck.name),
      currentPage: PageIndex.cards,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ref
            .read(deckDetailsPageControllerProvider.notifier)
            .navigateToAddCard(context, deck.id!),
        label: Text(context.l10n.addCard),
        icon: const Icon(Icons.add),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              children: [
                DeckDetails(deck: deck),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: CardsList(deck: deck),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
