import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/themes.dart';
import 'package:flutter_flashcards/src/layout/base_layout.dart';
import 'package:flutter_flashcards/src/model/cards.dart' as model;
import 'package:flutter_flashcards/src/model/firebase/firebase_repository.dart';
import 'package:flutter_flashcards/src/model/repository.dart';
import 'package:flutter_flashcards/src/widgets.dart';
import 'package:go_router/go_router.dart';

class ReviewsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RepositoryLoader(
        fetcher: (repository) => repository.loadCardsToReview().logError(
            'Error loading cards to review'), // Loading all cards to review
        builder: (context, cards, repository) {
          return RepositoryLoader(
            fetcher: (repository) => groupedByDeck(cards, repository),
            builder: (context, cardsByDeck, _) => BaseLayout(
                title: Text(context.l10n.learning),
                currentPage: PageIndex.learning,
                child: ReviewsBreakdown(cardsByDeck)),
          );
        });
  }

  Future<Map<model.Deck, List<(model.CardReviewVariant, model.Card)>>>
      groupedByDeck(Iterable<(model.CardReviewVariant, model.Card)> cards,
          CardsRepository repository) async {
    final deckGroups =
        <model.Deck, List<(model.CardReviewVariant, model.Card)>>{};
    final deckIds = cards.map((card) => card.$2.deckId).toSet();
    final decks =
        await Future.wait(deckIds.map((id) => repository.loadDeck(id)));
    final decksMap =
        Map.fromEntries(decks.nonNulls.map((deck) => MapEntry(deck.id, deck)));
    for (final tuple in cards) {
      var deck = decksMap[tuple.$2.deckId];
      if (deck == null) {
        print('No Deck for ${tuple.$2.id}');
        continue;
      }
      deckGroups.putIfAbsent(deck, () => []).add(tuple);
    }
    return deckGroups;
  }
}

class ReviewsBreakdown extends StatelessWidget {
  final Map<model.Deck, List<(model.CardReviewVariant, model.Card)>>
      cardsByDeck;

  ReviewsBreakdown(this.cardsByDeck);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 800,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...cardsByDeck.keys.map(
              (deck) => FilledButton(
                style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color?>(
                        context.theme.primaryColorLight)),
                onPressed: () async => await learn(context, deck.id),
                child: Text("${deck.name}: ${cardsByDeck[deck]!.length}"),
              ),
            ),
            Visibility(
              visible: cardsByDeck.isNotEmpty,
              child: FilledButton(
                onPressed: () async => await learnEverything(context),
                style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color?>(
                        context.theme.primaryColorDark)),
                child: Text(
                  context.l10n.learnEverything,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Visibility(
              visible: cardsByDeck.isEmpty,
              child: Text(
                context.l10n.noCardsToLearn,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            )
          ],
        ),
      ),
    );
  }

  learn(BuildContext context, String? id) async {
    await context.pushNamed('learn', queryParameters: {'deckId': id});
  }

  learnEverything(BuildContext context) async {
    // Navigate to `StudyCardsPage`
    await context.pushNamed('learn');
  }
}