import 'package:flutter/material.dart';
import 'package:flutter_flashcards/l10n/app_localizations.dart';
import 'package:flutter_flashcards/src/app.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../model/cards.dart' as model;
import '../model/repository.dart';
import '../widgets.dart';
import 'study_page.dart';

class DeckListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RepositoryLoader<List<model.Deck>>(
      fetcher: (repository) => repository.loadDecks(),
      builder: (context, decks, repository) {
        return Column(
          children: [
            Header(AppLocalizations.of(context)!.decks),
            SizedBox(
              width: 700,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: decks.isEmpty ? 1 : decks.length,
                itemBuilder: (context, index) {
                  if (decks.isEmpty) {
                    return Center(child: Text(context.l10n.noCardsMessage));
                  } else {
                    final deck = decks[index];
                    return Card(
                      child: Column(
                        children: [
                          ListTile(
                            title: InkWell(
                                onTap: () {
                                  context.pushNamed('deck',
                                      pathParameters: {'deckId': deck.id!});
                                },
                                child: Text(
                                  deck.name,
                                )),
                            subtitle: Row(
                              children: [
                                DeckCardsNumber(deck),
                                DeckCardsToReview(deck)
                              ],
                            ),
                          ),
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
                                  child: Text('Learn'),
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
          ],
        );
      },
    );
  }

  Future<void> deleteDeck(BuildContext context, model.Deck deck) async {
    final repository = Provider.of<CardsRepository>(context, listen: false);
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Delete ${deck.name}?'),
              content: Text('Are you sure you want to delete this deck?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    await repository.deleteDeck(deck.id!);
                    Navigator.of(context).pop();
                  },
                  child: Text('Delete'),
                ),
              ],
            ));
  }

  void startLearning(BuildContext context, model.Deck deck) async {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RepositoryLoader(
            fetcher: (repository) => repository.loadCardToReview(deck.id!),
            builder: (context, cards, repository) => StudyCardsPage(
              cards: cards,
            ),
          ),
        ),
      );
    } on Exception catch (e) {
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
              return TagText("Cards: $cardCount");
            });
}

class DeckCardsToReview extends RepositoryLoader<int> {
  DeckCardsToReview(model.Deck deck)
      : super(
            fetcher: (repository) => repository.getCardToReviewCount(deck.id!),
            builder: (context, data, _) {
              final cardCount = data;
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
