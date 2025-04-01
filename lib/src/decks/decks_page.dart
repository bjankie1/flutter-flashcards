import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/app_state.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/decks/deck_groups.dart';
import 'package:provider/provider.dart';

import '../layout/base_layout.dart';
import '../model/cards.dart' as model;
import '../model/repository.dart';

class DecksPage extends StatefulWidget {
  @override
  State<DecksPage> createState() => _DecksPageState();
}

class _DecksPageState extends State<DecksPage> {
  bool _ownDecks = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, appState, _) {
      return BaseLayout(
        title: Text(context.l10n.decksTitle),
        currentPage: PageIndex.cards,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => {
            _showAddDeckDialog(context, null),
          },
          label: Text(context.l10n.addDeck),
          icon: const Icon(Icons.add),
        ),
        child: ListenableBuilder(
            listenable: context.appState.cardRepository.decksUpdated,
            builder: (context, _) => DeckGroups()),
      );
    });
  }

  _showAddDeckDialog(BuildContext context, model.Deck? deck) async {
    String deckName = deck?.name ?? '';

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
                return context.l10n.deckNamePrompt;
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
                Navigator.pop(context);
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
                  await context.cardRepository
                      .saveDeck(model.Deck(name: deckName));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(
                          SnackBar(content: Text(context.l10n.deckSaved)));
                    Navigator.pop(context);
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