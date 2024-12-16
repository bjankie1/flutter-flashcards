import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/decks/study_page.dart';
import 'package:flutter_flashcards/src/model/cards.dart' as model;
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../model/repository.dart';
import '../widgets.dart';
import 'cards_page.dart';

class DeckListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final repository = Provider.of<CardsRepository>(context, listen: false);
    return buildDecksList(repository);
  }

  Widget buildDecksList(CardsRepository repository) {
    return FutureBuilder<List<model.Deck>>(
      future: repository.loadDecks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final decks = snapshot.data ?? []; // Use an empty list if no data
          return Column(
            children: [
              Header('Decks'),
              SizedBox(
                width: 700,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: decks.isEmpty ? 1 : decks.length,
                  itemBuilder: (context, index) {
                    if (decks.isEmpty) {
                      return const Center(child: Text('No decks found :().'));
                    } else {
                      final deck = decks[index];
                      return Card(
                        child: Column(
                          children: [
                            ListTile(
                              title: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CardsPage(
                                          deck: deck,
                                        ),
                                      ),
                                    );
                                    Provider.of<AppState>(context,
                                            listen: false)
                                        .setTitle('Cards for ${deck.name}');
                                  },
                                  child: Text(
                                    deck.name,
                                  )),
                              subtitle: Row(
                                children: [
                                  DeckCardsNumber(repository, deck),
                                  DeckCardsToReview(repository, deck)
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
                                    onPressed: () async => startLearning(
                                        context, repository, deck),
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
        } else {
          return const Center(child: Header('No decks found :().'));
        }
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

  void startLearning(
      BuildContext context, CardsRepository repository, model.Deck deck) async {
    try {
      final cards = await repository.loadCardToReview(deck.id!);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StudyCards(
            cards: cards,
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

class DeckCardsNumber extends FutureBuilder<int> {
  DeckCardsNumber(CardsRepository repository, model.Deck deck)
      : super(
            future: repository.getCardCount(deck.id!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                final cardCount = snapshot.data;
                return TagText("Cards: $cardCount");
              }
            });
}

class DeckCardsToReview extends FutureBuilder<int> {
  DeckCardsToReview(CardsRepository repository, model.Deck deck)
      : super(
            future: repository.getCardToReviewCount(deck.id!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                final cardCount = snapshot.data;
                return TagText("To review: $cardCount");
              }
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
