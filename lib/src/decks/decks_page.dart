import 'package:flutter/material.dart';
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

class DecksPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, appState, _) {
      return BaseLayout(
        title: Text(context.l10n.decksTitle),
        currentPage: PageIndex.cards,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => {
            _showAddDeckDialog(context, null),
          },
          label: Text(context.l10n.addDeck),
          icon: const Icon(Icons.add),
        ),
        child: Column(
          children: [
            Row(children: [
              FilledButton.icon(
                  onPressed: () => _quickAddCard(context),
                  icon: Icon(Icons.add),
                  label: Text(context.l10n.quickAddCard)),
              FilledButton.icon(
                  onPressed: () async {
                    await context.pushNamed('quickCards');
                  },
                  icon: Icon(Icons.reviews),
                  label: Text(context.l10n.provisionaryCardsReviewButton)),
            ]),
            Expanded(
              child: ListenableBuilder(
                  listenable: context.appState.cardRepository.decksUpdated,
                  builder: (context, _) => DeckGroups()),
            ),
          ],
        ),
      );
    });
  }

  _showAddDeckDialog(BuildContext context, model.Deck? deck) async {
    final TextEditingController deckNameController =
        TextEditingController(text: deck?.name ?? '');

    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(spacing: 20, children: [
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
                        child: Text(deck == null
                            ? context.l10n.add
                            : context.ml10n.saveButtonLabel),
                        onPressed: deckNameController.text.trim().isEmpty
                            ? null
                            : () async {
                                if (deckNameController.text.isNotEmpty) {
                                  await context.cardRepository.saveDeck(
                                      model.Deck(
                                          name:
                                              deckNameController.text.trim()));
                                  context
                                      .showInfoSnackbar(context.l10n.deckSaved);
                                  context.pop();
                                }
                              },
                      );
                    }),
              ],
            )
          ]),
        );
      },
    );
  }

  void _quickAddCard(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return ProvisionaryCardAdd();
        });
  }
}