import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/custom_theme.dart';
import 'package:flutter_flashcards/src/decks/deck_group.dart';
import 'package:flutter_flashcards/src/model/cards.dart';
import 'package:flutter_flashcards/src/model/repository.dart';
import 'package:flutter_flashcards/src/widgets.dart';

class DeckGroups extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: context.cardRepository.decksGroupUpdated,
      builder: (context, _, __) => RepositoryLoader(
        fetcher: (repository) => repository.loadDecksInGroups(),
        builder: (context, groups, _) => ListView(
          children: _groupsWidgets(context, groups),
        ),
      ),
    );
  }

  _groupsWidgets(BuildContext context, List<(DeckGroup?, List<Deck>)> groups) {
    return [
      ...groups.map((t) {
        final (group, decks) = t;
        return [
          Text(
            group == null ? context.l10n.decksWithoutGroupHeader : group.name,
            style: context.textTheme.headlineMedium,
          ),
          ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 200),
              child: DeckGroupHorizontalList(decks: decks))
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