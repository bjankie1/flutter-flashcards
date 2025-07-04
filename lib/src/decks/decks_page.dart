import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/app_router.dart';
import 'package:flutter_flashcards/src/app_state.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/snackbar_messaging.dart';
import 'package:flutter_flashcards/src/common/themes.dart';
import 'package:flutter_flashcards/src/decks/deck_groups.dart';
import 'package:flutter_flashcards/src/decks/provisionary_cards_add.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../layout/base_layout.dart';
import '../model/cards.dart' as model;
import '../model/repository.dart';
import '../widgets.dart';

class DecksPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return BaseLayout(
          title: Text(context.l10n.decksTitle),
          currentPage: PageIndex.cards,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => {_showAddDeckDialog(context, null)},
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
                    return RepositoryLoader<Map<model.State, int>>(
                      fetcher: (repository) => repository.cardsToReviewCount(),
                      builder: (context, reviewCounts, repository) {
                        final totalToReview = reviewCounts.values.fold(
                          0,
                          (a, b) => a + b,
                        );
                        final isNarrowScreen = constraints.maxWidth < 600;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 8,
                          children: [
                            if (isNarrowScreen) ...[
                              FloatingActionButton(
                                heroTag: 'learn',
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.onPrimary,
                                onPressed: totalToReview > 0
                                    ? () async {
                                        await context.pushNamed('learn');
                                      }
                                    : null,
                                tooltip:
                                    "${context.l10n.learnEverything} ($totalToReview)",
                                child: Icon(Icons.school),
                              ),
                              FloatingActionButton(
                                heroTag: 'quickAdd',
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.secondary,
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.onSecondary,
                                onPressed: () => _quickAddCard(context),
                                tooltip: context.l10n.quickAddCard,
                                child: Icon(Icons.add_box),
                              ),
                              FloatingActionButton(
                                heroTag: 'review',
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.secondary,
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.onSecondary,
                                onPressed: () async {
                                  await context.pushNamed(
                                    NamedRoute.quickCards.name,
                                  );
                                },
                                tooltip:
                                    context.l10n.provisionaryCardsReviewButton,
                                child: Icon(Icons.reviews),
                              ),
                            ] else ...[
                              ElevatedButton.icon(
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all<Color>(
                                        Theme.of(context).colorScheme.primary,
                                      ),
                                  foregroundColor:
                                      WidgetStateProperty.all<Color>(
                                        Theme.of(context).colorScheme.onPrimary,
                                      ),
                                  padding: WidgetStateProperty.all<EdgeInsets>(
                                    EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 20,
                                    ),
                                  ),
                                ),
                                onPressed: totalToReview > 0
                                    ? () async {
                                        await context.pushNamed('learn');
                                      }
                                    : null,
                                icon: Icon(Icons.school, size: 24),
                                label: Text(
                                  "${context.l10n.learnEverything} (${totalToReview})",
                                  style: TextStyle(fontSize: fontSize),
                                ),
                              ),
                              ElevatedButton.icon(
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all<Color>(
                                        Theme.of(context).colorScheme.secondary,
                                      ),
                                  foregroundColor:
                                      WidgetStateProperty.all<Color>(
                                        Theme.of(
                                          context,
                                        ).colorScheme.onSecondary,
                                      ),
                                  padding: WidgetStateProperty.all<EdgeInsets>(
                                    EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 20,
                                    ),
                                  ),
                                ),
                                onPressed: () => _quickAddCard(context),
                                icon: Icon(Icons.add_box, size: 24),
                                label: Text(
                                  context.l10n.quickAddCard,
                                  style: TextStyle(fontSize: fontSize),
                                ),
                              ),
                              ElevatedButton.icon(
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all<Color>(
                                        Theme.of(context).colorScheme.secondary,
                                      ),
                                  foregroundColor:
                                      WidgetStateProperty.all<Color>(
                                        Theme.of(
                                          context,
                                        ).colorScheme.onSecondary,
                                      ),
                                  padding: WidgetStateProperty.all<EdgeInsets>(
                                    EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 20,
                                    ),
                                  ),
                                ),
                                onPressed: () async {
                                  await context.pushNamed(
                                    NamedRoute.quickCards.name,
                                  );
                                },
                                icon: Icon(Icons.reviews, size: 24),
                                label: Text(
                                  context.l10n.provisionaryCardsReviewButton,
                                  style: TextStyle(fontSize: fontSize),
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              Expanded(
                child: ListenableBuilder(
                  listenable: context.appState.cardRepository.decksUpdated,
                  builder: (context, _) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: DeckGroups(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  _showAddDeckDialog(BuildContext context, model.Deck? deck) async {
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
                      textStyle: Theme.of(context).textTheme.labelLarge,
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
                          textStyle: Theme.of(context).textTheme.labelLarge,
                        ),
                        onPressed: deckNameController.text.trim().isEmpty
                            ? null
                            : () async {
                                if (deckNameController.text.isNotEmpty) {
                                  await context.cardRepository.saveDeck(
                                    model.Deck(
                                      name: deckNameController.text.trim(),
                                    ),
                                  );
                                  context.showInfoSnackbar(
                                    context.l10n.deckSaved,
                                  );
                                  context.pop();
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

  void _quickAddCard(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ProvisionaryCardAdd();
      },
    );
  }
}
