import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/containers.dart';
import 'package:flutter_flashcards/src/common/themes.dart';
import 'package:flutter_flashcards/src/decks/deck_group.dart';
import 'package:flutter_flashcards/src/decks/deck_list_item.dart';
import 'package:flutter_flashcards/src/model/cards.dart' show Deck, DeckGroup;
import 'package:flutter_flashcards/src/model/repository.dart';
import 'package:flutter_flashcards/src/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_flashcards/src/decks/editable_text.dart' as custom;

class DeckGroups extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: context.cardRepository.decksGroupUpdated,
      builder: (context, _, __) => RepositoryLoader(
        fetcher: (repository) => repository.loadDecksInGroups(),
        builder: (context, groups, _) => Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 800),
            child: CustomScrollView(
              slivers: [
                for (final (group, decks) in groups) ...[
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _DeckGroupHeaderDelegate(
                      child: Container(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 8.0,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: group == null
                                  ? Text(
                                      context.l10n.decksWithoutGroupHeader,
                                      style: context.textTheme.headlineSmall,
                                    )
                                  : custom.EditableText(
                                      text: group.name,
                                      style: context.textTheme.headlineSmall,
                                      onTextChanged: (value) {
                                        context.cardRepository.updateDeckGroup(
                                          group.copyWith(name: value),
                                        );
                                      },
                                    ),
                            ),
                            if (group != null)
                              DeckGroupReviewButton(deckGroup: group),
                          ],
                        ),
                      ),
                      height: 56,
                    ),
                  ),
                  if (decks.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 0,
                        ),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              for (int i = 0; i < decks.length; i++) ...[
                                if (i > 0) Divider(height: 1),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                    vertical: 4.0,
                                  ),
                                  child: DeckListItem(deck: decks[i]),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
                SliverToBoxAdapter(
                  child: RepositoryLoader(
                    fetcher: (repository) => repository.listSharedDecks(),
                    builder: (context, sharedDecks, _) {
                      if (sharedDecks.isEmpty) return SizedBox.shrink();
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Text(
                              context.l10n.sharedDecksHeader,
                              style: context.textTheme.headlineSmall,
                            ),
                          ),
                          ...sharedDecks.values
                              .expand((d) => d)
                              .map(
                                (deck) => CardsContainer(
                                  secondary: true,
                                  margin: EdgeInsets.symmetric(vertical: 8.0),
                                  child: DeckListItem(deck: deck),
                                ),
                              ),
                        ],
                      );
                    },
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DeckGroupHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _DeckGroupHeaderDelegate({required this.child, this.height = 56});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _DeckGroupHeaderDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.height != height;
  }
}

class DeckGroupWidget extends StatelessWidget {
  final DeckGroup? group;

  final List<Deck> decks;

  const DeckGroupWidget({super.key, this.group, required this.decks});

  @override
  Widget build(BuildContext context) {
    return CardsContainer(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Row(
            spacing: 10,
            children: [
              group == null
                  ? Text(
                      context.l10n.decksWithoutGroupHeader,
                      style: context.textTheme.headlineMedium,
                    )
                  : custom.EditableText(
                      text: group!.name,
                      style: context.textTheme.headlineMedium,
                      onTextChanged: (value) {
                        context.cardRepository.updateDeckGroup(
                          group!.copyWith(name: value),
                        );
                      },
                    ),
              if (group != null) DeckGroupReviewButton(deckGroup: group!),
            ],
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 120),
            child: DeckGroupHorizontalList(decks: decks),
          ),
        ],
      ),
    );
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
        return Visibility(
          visible: count > 0,
          child: ElevatedButton.icon(
            onPressed: () async =>
                await context.push('/learn?deckGroupId=${deckGroup.id}'),
            icon: Icon(Icons.play_circle_fill),
            label: Text(context.l10n.cardsToReview(count)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              textStyle: context.textTheme.labelLarge,
            ),
          ),
        );
      },
    );
  }
}
