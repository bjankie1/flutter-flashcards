import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/model/cards.dart' as model;

import '../model/repository.dart';

class DeckListWidget extends StatelessWidget {
  final CardsRepository repository;

  const DeckListWidget({Key? key, required this.repository}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<model.Deck>>(
      future: repository.loadDecks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final decks = snapshot.data!;
          return ListView.builder(
            itemCount: decks.length,
            itemBuilder: (context, index) {
              final deck = decks[index];
              return ListTile(
                title: Text(deck.name),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    // Pokaż dialog potwierdzenia
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Potwierdzenie"),
                        content: Text(
                            "Czy na pewno chcesz usunąć talię '${deck.name}'?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Anuluj"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text("Usuń"),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      await repository.deleteDeck(deck.name);
                      // Odśwież listę po usunięciu
                      // Możesz to zrobić, np. używając setState w StatefulWidget,
                      // jeśli ten widget jest częścią StatefulWidget.
                      // Alternatywnie, możesz użyć providera lub innego mechanizmu
                      // zarządzania stanem, aby powiadomić o zmianie danych.
                    }
                  },
                ),
              );
            },
          );
        } else {
          return const Center(child: Text('No decks found.'));
        }
      },
    );
  }
}
