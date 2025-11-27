import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/snackbar_messaging.dart';
import 'package:flutter_flashcards/src/common/themes.dart';
import 'package:flutter_flashcards/src/decks/deck_groups/deck_groups_widget.dart';
import 'package:flutter_flashcards/src/decks/deck_list/decks_controller.dart';
import 'package:flutter_flashcards/src/model/cards.dart' as model;
import 'package:go_router/go_router.dart';

import '../../layout/base_layout.dart';

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
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: DeckGroupsWidget(),
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
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (value) async {
                  final trimmed = value.trim();
                  if (trimmed.isNotEmpty) {
                    try {
                      await ref
                          .read(decksControllerProvider.notifier)
                          .saveDeck(model.Deck(name: trimmed));
                      context.showInfoSnackbar(context.l10n.deckSaved);
                      context.pop();
                    } catch (error) {
                      context.showErrorSnackbar('Error saving deck: $error');
                    }
                  }
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
