import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/decks/card_edit_page.dart';
import 'package:flutter_flashcards/src/widgets.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../model/cards.dart' as model;
import '../model/repository.dart';

class CardsList extends StatelessWidget {
  final model.Deck deck;
  final Logger _log = Logger();

  CardsList({super.key, required this.deck});

  @override
  Widget build(BuildContext context) {
    final repository = Provider.of<CardsRepository>(context, listen: false);
    return FutureBuilder<List<model.Card>>(
      future: repository.loadCards(deck.id!),
      builder: (context, snapshot) {
        _log.i('Building cards list' + snapshot.hasError.toString());
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final flashcards = snapshot.data ?? [];
          return Column(
            children: [
              Header('Cards for ${deck.name}'),
              SizedBox(
                width: 500,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: flashcards.length,
                  itemBuilder: (context, index) {
                    final card = flashcards[index];
                    return ListTile(
                      title: InkWell(child: Text(card.question.text)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await _deleteCard(context, card);
                        },
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
        } else {
          return const Center(child: Text('No flashcards found.'));
        }
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
