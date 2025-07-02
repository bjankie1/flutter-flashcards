import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/themes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_flashcards/src/common/assets.dart';
import 'package:flutter_flashcards/src/decks/deck_sharing.dart';
import 'package:go_router/go_router.dart';

import '../../common/build_context_extensions.dart';
import '../../model/cards.dart' as model;
import '../deck_groups/deck_group_selection_list.dart';
import 'decks_list.dart';
import 'deck_mastery_progress.dart';
import 'deck_info_widget.dart';
import 'deck_cards_to_review_widget.dart';

class DeckListItem extends StatelessWidget {
  const DeckListItem({super.key, required this.deck});

  final model.Deck deck;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;

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
                      style: context.theme.textTheme.titleMedium,
                      overflow: TextOverflow.clip,
                      softWrap: false,
                    ),
                    subtitle: Row(children: [DeckInfoWidget(deck: deck)]),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FittedBox(child: DeckCardsToReviewWidget(deck: deck)),
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
              style: context.theme.textTheme.titleMedium,
              overflow: TextOverflow.clip,
              softWrap: false,
            ),
            subtitle: Row(children: [DeckInfoWidget(deck: deck)]),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(child: DeckCardsToReviewWidget(deck: deck)),
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
      },
    );
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

  Future _showAddDeckToGroupDialog(BuildContext context, model.DeckId deckId) {
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
