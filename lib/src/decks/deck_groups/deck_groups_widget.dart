import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/containers.dart';
import 'package:flutter_flashcards/src/common/themes.dart';
import 'package:flutter_flashcards/src/decks/deck_groups/deck_groups_controller.dart';
import 'package:flutter_flashcards/src/decks/deck_groups/deck_group_widget.dart';
import 'package:flutter_flashcards/src/decks/deck_groups/no_group_decks_widget.dart';
import 'package:flutter_flashcards/src/model/cards.dart' as model;

class DeckGroupsWidget extends ConsumerWidget {
  const DeckGroupsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deckGroupsAsync = ref.watch(deckGroupsControllerProvider);
    final logger = Logger();

    return deckGroupsAsync.when(
      data: (deckGroups) {
        logger.d('DeckGroupsWidget rebuilt: ${deckGroups.length} groups');
        for (final group in deckGroups) {
          logger.d('  Group: ${group.name} (id: ${group.id})');
        }

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: CustomScrollView(
              slivers: [
                // Deck groups (only show non-empty groups)
                for (final group in deckGroups) ...[
                  // Group header
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _DeckGroupHeaderDelegate(
                      child: _buildGroupHeader(context, ref, group),
                      height: 64,
                    ),
                  ),
                  // Group decks
                  SliverToBoxAdapter(
                    child: _buildGroupDecks(context, ref, group),
                  ),
                ],
                // Decks without group
                SliverToBoxAdapter(child: NoGroupDecksWidget()),
                // Shared decks
                SliverToBoxAdapter(
                  child: Consumer(
                    builder: (context, ref, _) {
                      final sharedDecksAsync = ref.watch(sharedDecksProvider);
                      return sharedDecksAsync.when(
                        data: (sharedDecks) {
                          if (sharedDecks.isEmpty)
                            return const SizedBox.shrink();
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
                                      child: DeckListItemById(deckId: deck.id!),
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
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) =>
          Center(child: Text('Error loading deck groups: $error')),
    );
  }

  Widget _buildGroupHeader(
    BuildContext context,
    WidgetRef ref,
    model.DeckGroup group,
  ) {
    return DeckGroupWidget(deckGroup: group);
  }

  Widget _buildGroupDecks(
    BuildContext context,
    WidgetRef ref,
    model.DeckGroup group,
  ) {
    final deckIds = group.decks?.toList() ?? [];
    if (deckIds.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            for (int i = 0; i < deckIds.length; i++) ...[
              if (i > 0) const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: DeckListItemById(deckId: deckIds[i]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DeckGroupHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _DeckGroupHeaderDelegate({required this.child, this.height = 64});

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
