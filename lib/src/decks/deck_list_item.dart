import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/decks/deck_group_selection.dart';
import 'package:flutter_flashcards/src/decks/deck_sharing.dart';
import 'package:flutter_flashcards/src/decks/decks_list.dart';
import 'package:flutter_flashcards/src/widgets.dart';
import 'package:go_router/go_router.dart';

import '../model/cards.dart' as model;

class DeckListItem extends StatelessWidget {
  const DeckListItem({
    super.key,
    required this.deck,
  });

  final model.Deck deck;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      isThreeLine: true,
      onTap: () async {
        await context.push('/decks/${deck.id}');
      },
      title: Text(
        deck.name,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      subtitle: Column(
        children: [
          Row(
            children: [
              DeckCardsNumber(deck: deck),
              DeckCardsToReview(deck: deck),
            ],
          ),
          DeckSharing(deck),
        ],
      ),
      trailing: DeckContextMenu(deck: deck),
    );
  }
}

class DeckContextMenu extends StatelessWidget {
  final model.Deck deck;

  const DeckContextMenu({super.key, required this.deck});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
        icon: Icon(Icons.more_vert),
        itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: const Icon(Icons.delete),
                    ),
                    Text(context.l10n.delete),
                  ],
                ),
                onTap: () {
                  deleteDeck(context, deck);
                },
              ),
              PopupMenuItem<String>(
                value: 'addToGroup',
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: const Icon(Icons.group),
                    ),
                    Text(context.l10n.addDeckToGroup),
                  ],
                ),
                onTap: () {
                  _showAddDeckToGroupDialog(context, deck.id!);
                },
              ),
              // Add more menu items as needed
            ]);
  }

  Future<void> deleteDeck(BuildContext context, model.Deck deck) async =>
      DeckList().deleteDeck(context, deck);

  _showAddDeckToGroupDialog(BuildContext context, model.DeckId deckId) {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Padding(
            padding:
                const EdgeInsets.only(top: 18, bottom: 20, left: 8, right: 8),
            child: DeckGroupSelectionList(deckId: deckId),
          );
        });
  }
}

class DeckCardsNumber extends StatelessWidget {
  final model.Deck deck;

  const DeckCardsNumber({super.key, required this.deck});

  @override
  Widget build(BuildContext context) {
    return RepositoryLoader(
        fetcher: (repository) => repository.getCardCount(deck.id!),
        builder: (context, data, _) {
          final cardCount = data;
          return TagText("${context.l10n.cards}: $cardCount");
        });
  }
}

class DeckCardsToReview extends StatelessWidget {
  final model.Deck deck;

  DeckCardsToReview({required this.deck});

  @override
  Widget build(BuildContext context) {
    return RepositoryLoader(
        fetcher: (repository) =>
            repository.cardsToReviewCount(deckId: deck.id!),
        builder: (context, data, _) {
          final cardCount = data.values.reduce((agg, next) => agg + next);
          return Visibility(
            visible: cardCount > 0,
            child: FilledButton(
                onPressed: () {
                  startLearning(context, deck);
                },
                child: Text(context.l10n.cardsToReview(cardCount))),
          );
        });
  }

  void startLearning(BuildContext context, model.Deck deck) async {
    try {
      await context.push('/study/learn?deckId=${deck.id}');
    } on Exception {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          content: Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: Theme.of(context).colorScheme.onErrorContainer),
              const SizedBox(width: 8),
              Text('Error loading cards',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer)),
            ],
          )));
    }
  }
}

class TagText extends StatelessWidget {
  const TagText(
    this.text, {
    super.key,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(8.0), // Rounded corners
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest, // Use theme color
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(text),
        ),
      ),
    );
  }
}