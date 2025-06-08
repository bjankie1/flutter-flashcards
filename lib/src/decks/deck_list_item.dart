import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/assets.dart';
import 'package:flutter_flashcards/src/decks/deck_sharing.dart';
import 'package:go_router/go_router.dart';

import '../common/build_context_extensions.dart';
import '../model/cards.dart' as model;
import '../widgets.dart';
import 'deck_group_selection.dart';
import 'decks_list.dart';

class DeckListItem extends StatelessWidget {
  const DeckListItem({super.key, required this.deck});

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
        overflow: TextOverflow.clip,
        softWrap: false,
      ),
      subtitle: Row(
        children: [
          DeckCardsNumber(deck: deck),
          DeckCardsToReview(deck: deck),
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
          value: 'addCard',
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: const Icon(Icons.add),
              ),
              Text(context.l10n.addCard),
            ],
          ),
          onTap: () async {
            _addCard(context, deck);
          },
        ),

        PopupMenuItem<String>(
          value: 'addToGroup',
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: const Icon(Icons.folder),
              ),
              Text(context.l10n.addDeckToGroup),
            ],
          ),
          onTap: () {
            _showAddDeckToGroupDialog(context, deck.id!);
          },
        ),
        PopupMenuItem<String>(
          value: 'generateWithAI',
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ImageIcon(gemini),
              ),
              Text(context.l10n.generateCards),
            ],
          ),
          onTap: () {
            context.pushNamed(
              'generateCards',
              queryParameters: {'deckId': deck.id},
            );
          },
        ),
        PopupMenuItem(
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(Icons.share),
              ),
              Text(context.l10n.shareDeck),
            ],
          ),
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => DeckSharing(deck: deck),
            );
          },
        ),
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
        // Add more menu items as needed
      ],
    );
  }

  Future<void> deleteDeck(BuildContext context, model.Deck deck) async =>
      DeckList().deleteDeck(context, deck);

  _showAddDeckToGroupDialog(BuildContext context, model.DeckId deckId) {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.only(
            top: 18,
            bottom: 20,
            left: 8,
            right: 8,
          ),
          child: DeckGroupSelectionList(deckId: deckId),
        );
      },
    );
  }

  Future<void> _addCard(BuildContext context, model.Deck deck) async {
    await context.pushNamed('addCard', pathParameters: {'deckId': deck.id!});
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
        return TextButton(
          style: TextButton.styleFrom(padding: EdgeInsets.only(right: 8)),
          onPressed: () async => {
            await context.pushNamed(
              'addCard',
              pathParameters: {'deckId': deck.id!},
            ),
          },
          child: Text(
            "${context.l10n.cards}: $cardCount",
            overflow: TextOverflow.clip,
            softWrap: false,
          ),
        );
      },
    );
  }
}

class DeckCardsToReview extends StatelessWidget {
  final model.Deck deck;

  DeckCardsToReview({required this.deck});

  @override
  Widget build(BuildContext context) {
    return RepositoryLoader(
      fetcher: (repository) => repository.cardsToReviewCount(deckId: deck.id!),
      builder: (context, data, _) {
        final cardCount = data.values.reduce((agg, next) => agg + next);
        return Visibility(
          visible: cardCount > 0,
          child: TextButton(
            style: ButtonStyle(visualDensity: VisualDensity.compact),
            onPressed: () {
              startLearning(context, deck);
            },
            child: Text(
              context.l10n.cardsToReview(cardCount),
              overflow: TextOverflow.clip,
              softWrap: false,
            ),
          ),
        );
      },
    );
  }

  void startLearning(BuildContext context, model.Deck deck) async {
    try {
      await context.push('/learn?deckId=${deck.id}');
    } on Exception {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          content: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
              const SizedBox(width: 8),
              Text(
                'Error loading cards',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}

class TagText extends StatelessWidget {
  const TagText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(8.0), // Rounded corners
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest, // Use theme color
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(text),
        ),
      ),
    );
  }
}
