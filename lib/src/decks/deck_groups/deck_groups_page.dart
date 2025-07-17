import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_flashcards/src/app_router.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/snackbar_messaging.dart';
import 'package:flutter_flashcards/src/common/themes.dart';
import 'package:flutter_flashcards/src/decks/deck_groups/deck_groups_widget.dart';
import 'package:flutter_flashcards/src/decks/deck_list/decks_controller.dart';
import 'package:flutter_flashcards/src/decks/provisionary_cards/provisionary_cards_add.dart';
import 'package:go_router/go_router.dart';

import '../../layout/base_layout.dart';
import '../../model/cards.dart' as model;

class DeckGroupsPage extends ConsumerWidget {
  const DeckGroupsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseLayout(
      title: Text(context.l10n.decksTitle),
      currentPage: PageIndex.cards,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDeckDialog(context, ref, null),
        label: Text(context.l10n.addDeck),
        icon: const Icon(Icons.add),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final fontSize = constraints.maxWidth > 600
                    ? context.textTheme.titleLarge?.fontSize
                    : context.textTheme.titleMedium?.fontSize;
                return Consumer(
                  builder: (context, ref, _) {
                    final reviewCountsAsync = ref.watch(sortedDecksProvider);
                    return reviewCountsAsync.when(
                      data: (decks) {
                        final totalToReview = decks.length;
                        final isNarrowScreen = constraints.maxWidth < 600;

                        return _DeckActionsRow(
                          totalToReview: totalToReview,
                          isNarrowScreen: isNarrowScreen,
                          fontSize: fontSize,
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stackTrace) =>
                          Center(child: Text('Error loading decks: $error')),
                    );
                  },
                );
              },
            ),
          ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: DeckGroupsWidget(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddDeckDialog(
    BuildContext context,
    WidgetRef ref,
    model.Deck? deck,
  ) async {
    final TextEditingController deckNameController = TextEditingController(
      text: deck?.name ?? '',
    );

    return await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            spacing: 20,
            children: [
              Text(
                deck == null ? context.l10n.addDeck : context.l10n.editDeck,
                style: context.textTheme.titleLarge,
              ),
              TextFormField(
                controller: deckNameController,
                decoration: InputDecoration(labelText: context.l10n.deckName),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return context.l10n.deckNamePrompt;
                  }
                  return null;
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 20,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: context.theme.textTheme.labelLarge,
                    ),
                    child: Text(context.ml10n.cancelButtonLabel),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  ValueListenableBuilder(
                    valueListenable: deckNameController,
                    builder: (context, value, _) {
                      return FilledButton(
                        style: TextButton.styleFrom(
                          textStyle: context.textTheme.labelLarge,
                        ),
                        onPressed: deckNameController.text.trim().isEmpty
                            ? null
                            : () async {
                                if (deckNameController.text.isNotEmpty) {
                                  try {
                                    await ref
                                        .read(decksControllerProvider.notifier)
                                        .saveDeck(
                                          model.Deck(
                                            name: deckNameController.text
                                                .trim(),
                                          ),
                                        );
                                    context.showInfoSnackbar(
                                      context.l10n.deckSaved,
                                    );
                                    context.pop();
                                  } catch (error) {
                                    context.showErrorSnackbar(
                                      'Error saving deck: $error',
                                    );
                                  }
                                }
                              },
                        child: Text(
                          deck == null
                              ? context.l10n.add
                              : context.ml10n.saveButtonLabel,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DeckActionsRow extends StatelessWidget {
  const _DeckActionsRow({
    required this.totalToReview,
    required this.isNarrowScreen,
    required this.fontSize,
  });

  final int totalToReview;
  final bool isNarrowScreen;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 8,
      children: [
        if (isNarrowScreen) ...[
          FloatingActionButton(
            heroTag: 'learn',
            backgroundColor: context.theme.colorScheme.primary,
            foregroundColor: context.theme.colorScheme.onPrimary,
            onPressed: totalToReview > 0
                ? () async {
                    await context.pushNamed('learn');
                  }
                : null,
            tooltip: "${context.l10n.learnEverything} ($totalToReview)",
            child: const Icon(Icons.school),
          ),
          FloatingActionButton(
            heroTag: 'quickAdd',
            backgroundColor: context.theme.colorScheme.secondary,
            foregroundColor: context.theme.colorScheme.onSecondary,
            onPressed: () => _quickAddCard(context),
            tooltip: context.l10n.quickAddCard,
            child: const Icon(Icons.add_box),
          ),
          FloatingActionButton(
            heroTag: 'review',
            backgroundColor: context.theme.colorScheme.secondary,
            foregroundColor: context.theme.colorScheme.onSecondary,
            onPressed: () async {
              await context.pushNamed(NamedRoute.quickCards.name);
            },
            tooltip: context.l10n.provisionaryCardsReviewButton,
            child: const Icon(Icons.reviews),
          ),
        ] else ...[
          ElevatedButton.icon(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(
                context.theme.colorScheme.primary,
              ),
              foregroundColor: WidgetStateProperty.all<Color>(
                context.theme.colorScheme.onPrimary,
              ),
              padding: WidgetStateProperty.all<EdgeInsets>(
                const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              ),
            ),
            onPressed: totalToReview > 0
                ? () async {
                    await context.pushNamed('learn');
                  }
                : null,
            icon: const Icon(Icons.school, size: 24),
            label: Text(
              "${context.l10n.learnEverything} ($totalToReview)",
              style: TextStyle(fontSize: fontSize),
            ),
          ),
          ElevatedButton.icon(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(
                context.theme.colorScheme.secondary,
              ),
              foregroundColor: WidgetStateProperty.all<Color>(
                context.theme.colorScheme.onSecondary,
              ),
              padding: WidgetStateProperty.all<EdgeInsets>(
                const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              ),
            ),
            onPressed: () => _quickAddCard(context),
            icon: const Icon(Icons.add_box, size: 24),
            label: Text(
              context.l10n.quickAddCard,
              style: TextStyle(fontSize: fontSize),
            ),
          ),
          ElevatedButton.icon(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(
                context.theme.colorScheme.secondary,
              ),
              foregroundColor: WidgetStateProperty.all<Color>(
                context.theme.colorScheme.onSecondary,
              ),
              padding: WidgetStateProperty.all<EdgeInsets>(
                const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              ),
            ),
            onPressed: () async {
              await context.pushNamed(NamedRoute.quickCards.name);
            },
            icon: const Icon(Icons.reviews, size: 24),
            label: Text(
              context.l10n.provisionaryCardsReviewButton,
              style: TextStyle(fontSize: fontSize),
            ),
          ),
        ],
      ],
    );
  }

  void _quickAddCard(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ProvisionaryCardAdd();
      },
    );
  }
}
