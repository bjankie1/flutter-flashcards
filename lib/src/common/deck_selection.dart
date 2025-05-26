import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/widgets.dart';

import '../model/cards.dart' as model;

class DeckSelection extends StatelessWidget {
  final Function(String) onDeckSelected;
  final model.DeckId? initialDeckId;

  const DeckSelection(
      {super.key, required this.onDeckSelected, required this.initialDeckId});

  String _initialDeckName(Iterable<model.Deck> decks) {
    final deck = decks.where((deck) => deck.id == initialDeckId).firstOrNull;
    return deck?.name ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryLoader(
        fetcher: (repository) => repository.loadDecks(),
        builder: (context, decks, _) {
          return Autocomplete(
            initialValue: TextEditingValue(text: _initialDeckName(decks)),
            optionsBuilder: (textEditingValue) {
              if (textEditingValue.text == '') {
                return decks;
              }
              return decks.where((model.Deck deck) {
                return deck.name
                    .toLowerCase()
                    .contains(textEditingValue.text.toLowerCase());
              });
            },
            onSelected: (model.Deck selection) {
              onDeckSelected(selection.id!);
            },
            displayStringForOption: (deck) => deck.name,
            fieldViewBuilder: (BuildContext context,
                    TextEditingController textEditingController,
                    FocusNode focusNode,
                    VoidCallback onFieldSubmitted) =>
                TextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: InputDecoration(labelText: context.l10n.deckSelect),
              onFieldSubmitted: (value) {
                onFieldSubmitted();
              },
            ),
            optionsViewBuilder: (BuildContext context,
                    AutocompleteOnSelected<model.Deck> onSelected,
                    Iterable<model.Deck> options) =>
                Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                child: SizedBox(
                  height: 200.0,
                  child: ListView.builder(
                    padding: EdgeInsets.all(8.0),
                    itemCount: options.length,
                    itemBuilder: (BuildContext context, int index) {
                      final model.Deck option = options.elementAt(index);
                      return GestureDetector(
                        onTap: () {
                          onSelected(option);
                        },
                        child: ListTile(
                          title: Text(option.name),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        });
  }
}