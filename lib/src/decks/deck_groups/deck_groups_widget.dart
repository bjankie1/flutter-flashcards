import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/containers.dart';
import 'package:flutter_flashcards/src/common/themes.dart';
import 'package:flutter_flashcards/src/decks/deck_groups/deck_groups_controller.dart';
import 'package:flutter_flashcards/src/decks/deck_list/deck_list_item.dart';
import 'package:flutter_flashcards/src/model/cards.dart' as model;
import 'package:go_router/go_router.dart';
import 'package:flutter_flashcards/src/common/editable_text.dart' as custom;

class DeckGroupsWidget extends ConsumerWidget {
  const DeckGroupsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deckGroupsAsync = ref.watch(deckGroupsControllerProvider);

    // Diagnostic log
    print('DeckGroupsWidget rebuilt: ${deckGroupsAsync.toString()}');
    if (deckGroupsAsync.hasValue) {
      print(
        'DeckGroupsWidget data: ${deckGroupsAsync.value?.length ?? 0} groups',
      );
      deckGroupsAsync.value?.forEach((group) {
        print(
          '  Group: ${group.$1?.name ?? 'null'}, Decks: ${group.$2.length}',
        );
      });
    }

    return deckGroupsAsync.when(
      data: (groups) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
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
                                      ref
                                          .read(
                                            deckGroupsControllerProvider
                                                .notifier,
                                          )
                                          .updateDeckGroup(
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
                              if (i > 0) const Divider(height: 1),
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
                child: Consumer(
                  builder: (context, ref, _) {
                    final sharedDecksAsync = ref.watch(sharedDecksProvider);
                    return sharedDecksAsync.when(
                      data: (sharedDecks) {
                        if (sharedDecks.isEmpty) return const SizedBox.shrink();
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                              ),
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
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                    ),
                                    child: DeckListItem(deck: deck),
                                  ),
                                ),
                          ],
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stackTrace) => Center(
                        child: Text('Error loading shared decks: $error'),
                      ),
                    );
                  },
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error loading deck groups: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(deckGroupsControllerProvider);
              },
              child: const Text('Retry'),
            ),
          ],
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

class DeckGroupReviewButton extends ConsumerWidget {
  final model.DeckGroup deckGroup;

  const DeckGroupReviewButton({super.key, required this.deckGroup});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countAsync = ref.watch(
      cardsToReviewCountByGroupProvider(deckGroup.id),
    );

    return countAsync.when(
      data: (countStat) {
        final count = countStat.values.fold(0, (p, c) => p + c);
        return Visibility(
          visible: count > 0,
          child: ElevatedButton.icon(
            onPressed: () async =>
                await context.push('/learn?deckGroupId=${deckGroup.id}'),
            icon: const Icon(Icons.play_circle_fill),
            label: Text(context.l10n.cardsToReview(count)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              textStyle: context.textTheme.labelLarge,
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }
}
