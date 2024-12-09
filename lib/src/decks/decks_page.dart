import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/decks/decks_list.dart';
import 'package:provider/provider.dart';

import '../base_layout.dart';
import '../model/cards.dart' as model;
import '../model/repository.dart';

class DesksPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      title: 'Flashcard decks',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => {
          _showAddDeckDialog(context, null),
        },
        label: Text('Add deck'),
        icon: const Icon(Icons.add),
      ),
      child: DeckListWidget(),
    );
  }

  _showAddDeckDialog(BuildContext context, model.Deck? deck) async {
    String deckName = deck?.name ?? "";
    final repository = Provider.of<CardsRepository>(context, listen: false);

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(deck == null ? 'Add Deck' : 'Edit Deck'),
          content: TextFormField(
            initialValue: deckName,
            onChanged: (value) {
              deckName = value;
            },
            decoration: const InputDecoration(labelText: 'Deck Name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a deck name';
              }
              return null;
            },
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: Text(deck == null ? 'Add' : 'Save'),
              onPressed: () async {
                if (deckName.isNotEmpty) {
                  await repository.saveDeck(model.Deck(name: deckName));
                  // setState(() {});
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(SnackBar(content: Text('Deck saved!')));
                    Navigator.of(context).pop();
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
}
