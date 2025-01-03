import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/app.dart';
import 'package:flutter_flashcards/src/model/repository.dart';
import 'package:flutter_flashcards/src/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:provider/provider.dart';
import '../model/cards.dart' as model;

class CardsList extends StatelessWidget {
  final model.Deck deck;

  CardsList({super.key, required this.deck});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: context.watch<CardsRepository>().cardsUpdated,
      builder: (context, updated, _) {
        return RepositoryLoader<Iterable<model.Card>>(
          fetcher: (repository) => repository.loadCards(deck.id!),
          noDataWidget: Center(child: Text(context.l10n.deckEmptyMessage)),
          builder: (context, data, _) {
            final flashcards = data.toList();
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: flashcards.length,
                    itemBuilder: (context, index) {
                      final card = flashcards[index];
                      return Card(
                        child: ListTile(
                          title: InkWell(
                            onTap: () async {
                              await context
                                  .push('/decks/${deck.id}/cards/${card.id}');
                            },
                            child: GptMarkdown(
                              card.question.text,
                              maxLines: 5,
                            ),
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
                  Padding(
                    // Now always visible
                    padding: const EdgeInsets.all(8.0),
                    child: FilledButton(
                      onPressed: () async {
                        await context.pushNamed('addCard', pathParameters: {
                          'deckId': deck.id!,
                        });
                      },
                      child: Text(context.l10n.addCard),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  _deleteCard(BuildContext context, model.Card card) async {}
}
