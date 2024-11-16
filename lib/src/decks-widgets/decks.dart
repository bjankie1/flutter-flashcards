import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/model/cards.dart' as model;

import '../model/repository.dart';
import '../widgets.dart';

class DeckListWidget extends StatefulWidget {
  final CardsRepository repository;

  const DeckListWidget({super.key, required this.repository});

  @override
  State<DeckListWidget> createState() => _DeckListWidgetState();
}

class _DeckListWidgetState extends State<DeckListWidget> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<model.Deck>>(
      future: widget.repository.loadDecks(),
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
              Expanded(
                // Takes up remaining space even if the list is empty
                child: ListView.builder(
                  itemCount: decks.length,
                  itemBuilder: (context, index) {
                    final deck = decks[index];
                    return ListTile(
                      title: Text(deck.name),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await deleteDeck(context, deck);
                          setState(() {});
                        },
                      ),
                    );
                  },
                ),
              ),
              Padding(
                // Now always visible
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    _showAddDeckDialog(context, null);
                  },
                  child: const Text('Add Deck'),
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
    // ... (Existing deleteDeck function remains unchanged)
  }

  Future<void> _showAddDeckDialog(
      BuildContext context, model.Deck? deck) async {
    String deckName = deck?.name ?? "";

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
                  if (deck == null) {
                    await widget.repository.addDeck(model.Deck(name: deckName));
                  } else {
                    await widget.repository
                        .updateDeck(deck.copyWith(name: deckName));
                  }
                  setState(() {});
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
