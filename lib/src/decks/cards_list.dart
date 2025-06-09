import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/snackbar_messaging.dart';
import 'package:flutter_flashcards/src/model/repository.dart';
import 'package:flutter_flashcards/src/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:provider/provider.dart';

import '../model/cards.dart' as model;

class CardsList extends StatefulWidget {
  final model.Deck deck;

  const CardsList({super.key, required this.deck});

  @override
  State<CardsList> createState() => _CardsListState();
}

class _CardsListState extends State<CardsList> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesSearch(model.Card card) {
    if (_searchQuery.isEmpty) return true;
    return card.question.toLowerCase().contains(_searchQuery) ||
        card.answer.toLowerCase().contains(_searchQuery) ||
        (card.explanation?.toLowerCase().contains(_searchQuery) ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: context.l10n.cards,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
            ),
          ),
        ),
        Expanded(
          child: ValueListenableBuilder<bool>(
            valueListenable: context.watch<CardsRepository>().cardsUpdated,
            builder: (context, updated, _) {
              return RepositoryLoader<Iterable<model.Card>>(
                fetcher: (repository) => repository.loadCards(widget.deck.id!),
                noDataWidget: Center(
                  child: Text(context.l10n.deckEmptyMessage),
                ),
                builder: (context, data, _) {
                  final flashcards = data.toList();
                  flashcards.sort(
                    (card1, card2) => card1.question.toLowerCase().compareTo(
                      card2.question.toLowerCase(),
                    ),
                  );
                  final filteredCards = flashcards
                      .where(_matchesSearch)
                      .toList();
                  return filteredCards.isEmpty
                      ? Center(child: Text(context.l10n.noCardsMessage))
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: filteredCards.length,
                          itemBuilder: (context, index) {
                            final card = filteredCards[index];
                            return Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 4),
                                  child: CardTile(
                                    deck: widget.deck,
                                    card: card,
                                    onDelete: () => _deleteCard(context, card),
                                  ),
                                ),
                                if (index < filteredCards.length - 1) Divider(),
                              ],
                            );
                          },
                        );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  _deleteCard(BuildContext context, model.Card card) async {
    final repository = context.read<CardsRepository>();
    await repository
        .deleteCard(card.id)
        .then(
          (_) => context.showInfoSnackbar(context.l10n.cardDeletedMessage),
          onError: (e, stackTrace) {
            context.showErrorSnackbar(context.l10n.cardDeletionErrorMessage);
          },
        );
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
      isThreeLine: true,
      onTap: () async {
        await context.push('/decks/${deck.id}/cards/${card.id}');
      },
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TrimmedTextWithLabel(
            label: context.l10n.cardQuestionDisplay,
            text: card.question,
            maxWidth: 500,
          ),
          SizedBox(height: 4),
          _TrimmedTextWithLabel(
            label: context.l10n.cardAnswerDisplay,
            text: card.answer,
            maxWidth: 500,
          ),
        ],
      ),
      subtitle: Row(
        children: [
          if (card.options?.learnBothSides ?? false)
            Tooltip(
              message: context.l10n.cardOptionDoubleSided,
              child: Icon(Icons.swap_vert, color: Colors.green),
            ),
          if (card.explanation != null && card.explanation!.isNotEmpty)
            Tooltip(
              message: context.l10n.hintLabel,
              child: Icon(Icons.info, color: Colors.blue),
            ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, size: 32),
        onPressed: () {
          onDelete();
        },
      ),
    );
  }
}

class _TrimmedTextWithLabel extends StatelessWidget {
  final String label;
  final String text;
  final double maxWidth;

  const _TrimmedTextWithLabel({
    required this.label,
    required this.text,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label ', style: const TextStyle(fontWeight: FontWeight.bold)),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
