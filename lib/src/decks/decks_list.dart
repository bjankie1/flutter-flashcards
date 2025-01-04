import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/app.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../model/cards.dart' as model;
import '../model/repository.dart';
import '../widgets.dart';

class DeckListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RepositoryLoader<Iterable<model.Deck>>(
      fetcher: (repository) => repository.loadDecks(),
      builder: (context, decksIterable, repository) {
        final decks = decksIterable.toList();
        decks.sort((deck1, deck2) => deck1.name.compareTo(deck2.name));
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: SizedBox(
            height: 500,
            width: 500,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: decks.isEmpty ? 1 : decks.length,
              itemBuilder: (context, index) {
                if (decks.isEmpty) {
                  return Center(child: Text(context.l10n.noCardsMessage));
                } else {
                  final deck = decks[index];
                  return ListTile(
                    title: InkWell(
                        onTap: () async {
                          await context.push('/decks/${deck.id}');
                        },
                        child: Text(
                          deck.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        )),
                    subtitle: Row(
                      children: [
                        DeckCardsNumber(deck),
                        DeckCardsToReview(deck),
                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment
                                .end, // Align buttons to the right
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  await deleteDeck(context, deck);
                                },
                              ),
                              ElevatedButton(
                                onPressed: () async =>
                                    startLearning(context, deck),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primary, // Use primary color from the theme
                                  foregroundColor: Theme.of(context)
                                      .colorScheme
                                      .onPrimary, // Use appropriate contrast color
                                ),
                                child: Text(context.l10n.learn),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> deleteDeck(BuildContext context, model.Deck deck) async {
    final repository = Provider.of<CardsRepository>(context, listen: false);
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(context.l10n.deleteDeck(deck.name)),
              content: Text(context.l10n.deleteDeckConfirmation),
              actions: [
                TextButton(
                  onPressed: () => context.pop(),
                  child: Text(context.ml10n.cancelButtonLabel),
                ),
                FilledButton(
                  onPressed: () async {
                    await repository.deleteDeck(deck.id!);
                    context.pop();
                  },
                  child: Text(context.l10n.delete),
                ),
              ],
            ));
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

class DeckCardsNumber extends RepositoryLoader<int> {
  DeckCardsNumber(model.Deck deck)
      : super(
            fetcher: (repository) => repository.getCardCount(deck.id!),
            builder: (context, data, _) {
              final cardCount = data;
              return TagText("${context.l10n.cards}: $cardCount");
            });
}

class DeckCardsToReview extends RepositoryLoader<Map<model.State, int>> {
  DeckCardsToReview(model.Deck deck)
      : super(
            fetcher: (repository) =>
                repository.cardsToReviewCount(deckId: deck.id!),
            builder: (context, data, _) {
              final cardCount = data.values.reduce((agg, next) => agg + next);
              return TagText(context.l10n.cardsToReview(cardCount));
            });
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
