import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/containers.dart';
import 'package:flutter_flashcards/src/common/themes.dart';
import 'package:flutter_flashcards/src/decks/deck_group.dart';
import 'package:flutter_flashcards/src/model/cards.dart';
import 'package:flutter_flashcards/src/model/repository.dart';
import 'package:flutter_flashcards/src/widgets.dart';
import 'package:go_router/go_router.dart';

class DeckGroups extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: context.cardRepository.decksGroupUpdated,
      builder: (context, _, __) => RepositoryLoader(
        fetcher: (repository) => repository.loadDecksInGroups(),
        builder: (context, groups, _) => Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ListView(
            children: _groupsWidgets(context, groups),
          ),
        ),
      ),
    );
  }

  _groupsWidgets(BuildContext context, List<(DeckGroup?, List<Deck>)> groups) {
    return [
      ...groups.map((t) {
        final (group, decks) = t;
        return [
          CardsContainer(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                Row(
                  spacing: 10,
                  children: [
                    Text(
                      group == null
                          ? context.l10n.decksWithoutGroupHeader
                          : group.name,
                      style: context.textTheme.headlineMedium,
                    ),
                    if (group != null)
                      DeckGroupReviewButton(
                        deckGroup: group,
                      )
                  ],
                ),
                ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 200),
                    child: DeckGroupHorizontalList(decks: decks))
              ],
            ),
          ),
        ];
      }).expand((l) => l),
      Text(
        context.l10n.sharedDecksHeader,
        style: context.textTheme.headlineMedium,
      ),
      RepositoryLoader(
          fetcher: (repository) => repository.listSharedDecks(),
          builder: (context, sharedDecks, _) {
            return ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 200),
              child: DeckGroupHorizontalList(
                  decks: sharedDecks.values.expand((d) => d).toList()),
            );
          })
    ];
  }
}

class DeckGroupReviewButton extends StatelessWidget {
  final DeckGroup deckGroup;

  const DeckGroupReviewButton({super.key, required this.deckGroup});

  @override
  Widget build(BuildContext context) {
    return RepositoryLoader(
        fetcher: (repository) =>
            repository.cardsToReviewCount(deckGroupId: deckGroup.id),
        builder: (context, countStat, _) {
          final count = countStat.values.fold(0, (p, c) => p + c);
          return FilledButton(
              onPressed: () async => await context
                  .push('/study/learn?deckGroupId=${deckGroup.id}'),
              child: Text(context.l10n.cardsToReview(count)));
        });
  }
}