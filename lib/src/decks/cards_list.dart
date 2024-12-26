import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/app.dart';
import 'package:flutter_flashcards/src/app_state.dart';
import 'package:flutter_flashcards/src/decks/card_edit_page.dart';
import 'package:flutter_flashcards/src/model/repository.dart';
import 'package:flutter_flashcards/src/widgets.dart';
import 'package:provider/provider.dart';
import '../model/cards.dart' as model;

class CardsList extends StatelessWidget {
  final model.Deck deck;

  CardsList({super.key, required this.deck});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable:
          Provider.of<CardsRepository>(context, listen: true).cardsUpdated,
      builder: (context, updated, _) {
        return RepositoryLoader<List<model.Card>>(
          fetcher: (repository) => repository.loadCards(deck.id!),
          noDataWidget: Center(child: Text(context.l10n.deckEmptyMessage)),
          builder: (context, data, _) {
            final flashcards = data;
            return Column(
              children: [
                Header(context.l10n.deckHeader(deck.name)),
                SizedBox(
                  width: 500,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: flashcards.length,
                    itemBuilder: (context, index) {
                      final card = flashcards[index];
                      return Card(
                        child: ListTile(
                          title: InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CardEditPage(
                                      card: card,
                                      deckId: card.deckId,
                                    ),
                                  ));
                              Provider.of<AppState>(context, listen: false)
                                  .setTitle(context.l10n.editCard);
                            },
                            child: Text(card.question.text),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              await _deleteCard(context, card);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  // Now always visible
                  padding: const EdgeInsets.all(8.0),
                  child: FilledButton(
                    onPressed: () {
                      _editCard(context, null);
                    },
                    child: const Text('Add Card'),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  _deleteCard(BuildContext context, model.Card card) async {}

  void _editCard(BuildContext context, model.Card? card) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CardEditPage(
          card: card,
          deckId: deck.id!,
        ),
      ),
    );
  }
}
