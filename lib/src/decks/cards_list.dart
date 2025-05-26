import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/snackbar_messaging.dart';
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
            flashcards.sort((card1, card2) => card1.question
                .toLowerCase()
                .compareTo(card2.question.toLowerCase()));
            return data.isEmpty
                ? Text('No Cards')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: flashcards.length,
                    itemBuilder: (context, index) {
                      final card = flashcards[index];
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: CardTile(
                            deck: deck,
                            card: card,
                            onDelete: () => _deleteCard(context, card)),
                      );
                    },
                  );
          },
        );
      },
    );
  }

  _deleteCard(BuildContext context, model.Card card) async {
    final repository = context.read<CardsRepository>();
    await repository
        .deleteCard(card.id)
        .then((_) => context.showInfoSnackbar(context.l10n.cardDeletedMessage),
            onError: (e, stackTrace) {
      context.showErrorSnackbar(context.l10n.cardDeletionErrorMessage);
    });
  }
}

class CardTile extends StatelessWidget {
  final model.Deck deck;
  final model.Card card;
  final Function onDelete;

  CardTile({
    super.key,
    required this.deck,
    required this.card,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {
        await context.push('/decks/${deck.id}/cards/${card.id}');
      },
      tileColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      title: GptMarkdown(
        card.question,
        maxLines: 5,
      ),
      subtitle: Row(
        children: [
          if (card.options?.learnBothSides ?? false)
            Icon(
              Icons.swap_vert,
              color: Colors.green,
            ),
          if (card.explanation != null && card.explanation!.isNotEmpty)
            Icon(
              Icons.info,
              color: Colors.blue,
            ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () {
          onDelete();
        },
      ),
    );
  }
}