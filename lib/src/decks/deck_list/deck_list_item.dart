import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_flashcards/src/common/assets.dart';
import 'package:flutter_flashcards/src/decks/deck_sharing.dart';
import 'package:go_router/go_router.dart';

import '../../common/build_context_extensions.dart';
import '../../model/cards.dart' as model;
import '../../model/card_mastery.dart';
import '../../widgets.dart';
import '../deck_groups/deck_group_selection_list.dart';
import 'decks_list.dart';

class DeckListItem extends StatelessWidget {
  const DeckListItem({super.key, required this.deck});

  final model.Deck deck;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    if (isWide) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: DeckMasteryProgress(deck: deck, isWide: true),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ListTile(
                dense: true,
                isThreeLine: true,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  deck.name,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.clip,
                  softWrap: false,
                ),
                subtitle: Row(children: [DeckInfoWidget(deck: deck)]),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(child: DeckCardsToReview(deck: deck)),
                    const SizedBox(width: 8),
                    DeckContextMenu(deck: deck),
                  ],
                ),
                onTap: () async {
                  await context.push('/decks/${deck.id}');
                },
              ),
            ),
          ],
        ),
      );
    } else {
      final tile = ListTile(
        dense: true,
        isThreeLine: true,
        title: Text(
          deck.name,
          style: Theme.of(context).textTheme.titleMedium,
          overflow: TextOverflow.clip,
          softWrap: false,
        ),
        subtitle: Row(children: [DeckInfoWidget(deck: deck)]),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(child: DeckCardsToReview(deck: deck)),
            const SizedBox(width: 8),
            DeckContextMenu(deck: deck),
          ],
        ),
        onTap: () async {
          await context.push('/decks/${deck.id}');
        },
      );
      return Stack(
        children: [
          tile,
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: DeckMasteryProgress(deck: deck, isWide: false),
          ),
        ],
      );
    }
  }
}

class DeckContextMenu extends ConsumerWidget {
  final model.Deck deck;

  const DeckContextMenu({super.key, required this.deck});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton(
      icon: Icon(Icons.more_vert),
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'addCard',
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: const Icon(Icons.add),
              ),
              Text(context.l10n.addCard),
            ],
          ),
          onTap: () async {
            _addCard(context, deck);
          },
        ),

        PopupMenuItem<String>(
          value: 'addToGroup',
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: const Icon(Icons.folder),
              ),
              Text(context.l10n.addDeckToGroup),
            ],
          ),
          onTap: () {
            _showAddDeckToGroupDialog(context, deck.id!);
          },
        ),
        PopupMenuItem<String>(
          value: 'generateWithAI',
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ImageIcon(gemini),
              ),
              Text(context.l10n.generateCards),
            ],
          ),
          onTap: () {
            context.pushNamed(
              'generateCards',
              queryParameters: {'deckId': deck.id},
            );
          },
        ),
        PopupMenuItem<String>(
          value: 'generateFromGoogleDoc',
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: const Icon(Icons.description),
              ),
              Text(context.l10n.generateFromGoogleDoc),
            ],
          ),
          onTap: () {
            context.pushNamed(
              'generateFromGoogleDoc',
              queryParameters: {'deckId': deck.id},
            );
          },
        ),
        PopupMenuItem(
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(Icons.share),
              ),
              Text(context.l10n.shareDeck),
            ],
          ),
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => DeckSharing(deck: deck),
            );
          },
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: const Icon(Icons.delete),
              ),
              Text(context.l10n.delete),
            ],
          ),
          onTap: () {
            deleteDeck(context, ref, deck);
          },
        ),
        // Add more menu items as needed
      ],
    );
  }

  Future<void> deleteDeck(
    BuildContext context,
    WidgetRef ref,
    model.Deck deck,
  ) async => DeckList().deleteDeck(context, ref, deck);

  _showAddDeckToGroupDialog(BuildContext context, model.DeckId deckId) {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.only(
            top: 18,
            bottom: 20,
            left: 8,
            right: 8,
          ),
          child: DeckGroupSelectionList(deckId: deckId),
        );
      },
    );
  }

  Future<void> _addCard(BuildContext context, model.Deck deck) async {
    await context.pushNamed('addCard', pathParameters: {'deckId': deck.id!});
  }
}

class DeckInfoWidget extends StatelessWidget {
  final model.Deck deck;

  const DeckInfoWidget({super.key, required this.deck});

  @override
  Widget build(BuildContext context) {
    return RepositoryLoader(
      fetcher: (repository) => repository.getCardCount(deck.id!),
      builder: (context, data, _) {
        final cardCount = data;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Tooltip(
              message: context.l10n.cards,
              child: Icon(
                Icons.style,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              cardCount.toString(),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.add, size: 18),
              onPressed: () async {
                await context.pushNamed(
                  'addCard',
                  pathParameters: {'deckId': deck.id!},
                );
              },
              tooltip: context.l10n.addCard,
              style: IconButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size(24, 24),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        );
      },
    );
  }
}

class DeckCardsToReview extends StatelessWidget {
  final model.Deck deck;

  DeckCardsToReview({required this.deck});

  @override
  Widget build(BuildContext context) {
    return RepositoryLoader(
      fetcher: (repository) => repository.cardsToReviewCount(deckId: deck.id!),
      builder: (context, data, _) {
        final cardCount = data.values.reduce((agg, next) => agg + next);
        return Visibility(
          visible: cardCount > 0,
          child: ElevatedButton.icon(
            onPressed: () {
              startLearning(context, deck);
            },
            icon: Icon(Icons.play_circle_fill, size: 18),
            label: Text(
              context.l10n.cardsToReview(cardCount),
              overflow: TextOverflow.clip,
              softWrap: false,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(80, 32),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
              textStyle: Theme.of(context).textTheme.labelMedium,
              elevation: 1,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
        );
      },
    );
  }

  void startLearning(BuildContext context, model.Deck deck) async {
    try {
      await context.push('/learn?deckId=${deck.id}');
    } on Exception {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          content: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
              const SizedBox(width: 8),
              Text(
                context.l10n.errorLoadingCards,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}

class TagText extends StatelessWidget {
  const TagText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(8.0), // Rounded corners
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest, // Use theme color
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(text),
        ),
      ),
    );
  }
}

class DeckMasteryProgress extends StatelessWidget {
  final model.Deck deck;
  final bool isWide;

  const DeckMasteryProgress({
    super.key,
    required this.deck,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    return RepositoryLoader(
      fetcher: (repository) => repository.getMasteryBreakdown(deckId: deck.id!),
      builder: (context, data, _) {
        final total = data.values.fold(0, (a, b) => a + b);
        final mastered =
            (data[CardMastery.young] ?? 0) + (data[CardMastery.mature] ?? 0);
        final progress = total == 0 ? 0.0 : mastered / total;

        void showReport() {
          showDialog(
            context: context,
            builder: (context) => DeckMasteryReportDialog(
              deckName: deck.name,
              breakdown: data,
              progress: progress,
            ),
          );
        }

        if (isWide) {
          // Circular progress for wide screens
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: _HoverableCircularProgress(
              progress: progress,
              onTap: showReport,
              label: '${(progress * 100).round()}%',
            ),
          );
        } else {
          // Linear progress for narrow screens
          return GestureDetector(
            onTap: showReport,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
                minHeight: 8, // Thicker bar
              ),
            ),
          );
        }
      },
    );
  }
}

class DeckMasteryReportDialog extends StatelessWidget {
  final String deckName;
  final Map<CardMastery, int> breakdown;
  final double progress;

  const DeckMasteryReportDialog({
    super.key,
    required this.deckName,
    required this.breakdown,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final total = breakdown.values.fold(0, (a, b) => a + b);
    final percent = (progress * 100).round();
    final textTheme = Theme.of(context).textTheme;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: SizedBox(
        width: 320, // Make the dialog more narrow than the list
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.deckProgress(deckName),
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '$percent%',
                style: textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _MasteryBar(
                label: context.l10n.masteryNew,
                value: breakdown[CardMastery.new_] ?? 0,
                total: total,
              ),
              const SizedBox(height: 8),
              _MasteryBar(
                label: context.l10n.masteryLearning,
                value: breakdown[CardMastery.learning] ?? 0,
                total: total,
              ),
              const SizedBox(height: 8),
              _MasteryBar(
                label: context.l10n.masteryYoung,
                value: breakdown[CardMastery.young] ?? 0,
                total: total,
              ),
              const SizedBox(height: 8),
              _MasteryBar(
                label: context.l10n.masteryMature,
                value: breakdown[CardMastery.mature] ?? 0,
                total: total,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MasteryBar extends StatelessWidget {
  final String label;
  final int value;
  final int total;

  const _MasteryBar({
    required this.label,
    required this.value,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0.0 : value / total;
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 16,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: percent,
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.outline,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(
            value.toString(),
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _HoverableCircularProgress extends StatefulWidget {
  final double progress;
  final VoidCallback onTap;
  final String label;

  const _HoverableCircularProgress({
    required this.progress,
    required this.onTap,
    required this.label,
  });

  @override
  State<_HoverableCircularProgress> createState() =>
      _HoverableCircularProgressState();
}

class _HoverableCircularProgressState
    extends State<_HoverableCircularProgress> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.primary;
    final hsl = HSLColor.fromColor(baseColor);
    final hoverColor = hsl
        .withSaturation((hsl.saturation * 1.3).clamp(0.0, 1.0))
        .toColor();
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: 40,
        height: 40,
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovering = true),
          onExit: (_) => setState(() => _hovering = false),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: widget.progress,
                strokeWidth: 6,
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _hovering ? hoverColor : baseColor,
                ),
              ),
              Text(widget.label, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}
