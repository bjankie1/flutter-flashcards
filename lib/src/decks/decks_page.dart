import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/app.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'decks_list.dart';
import '../base_layout.dart';
import '../model/cards.dart' as model;
import '../model/repository.dart';

class DecksPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      title: 'Flashcard decks',
      currentPage: PageIndex.cards,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => {
          _showAddDeckDialog(context, null),
        },
        label: Text(context.l10n.addDeck),
        icon: const Icon(Icons.add),
      ),
      child: DeckListWidget(),
    );
  }

  _showAddDeckDialog(BuildContext context, model.Deck? deck) async {
    String deckName = deck?.name ?? '';
    final repository = Provider.of<CardsRepository>(context, listen: false);

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text(deck == null ? context.l10n.addDeck : context.l10n.editDeck),
          content: TextFormField(
            initialValue: deckName,
            onChanged: (value) {
              deckName = value;
            },
            decoration: InputDecoration(labelText: context.l10n.deckName),
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
              child: Text(context.ml10n.cancelButtonLabel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: Text(deck == null
                  ? context.l10n.add
                  : context.ml10n.saveButtonLabel),
              onPressed: () async {
                if (deckName.isNotEmpty) {
                  await repository.saveDeck(model.Deck(name: deckName));
                  // setState(() {});
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(
                          SnackBar(content: Text(context.l10n.deckSaved)));
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
