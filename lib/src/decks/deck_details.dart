import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/snackbar_messaging.dart';
import 'package:flutter_flashcards/src/model/repository.dart';

import '../model/cards.dart' as model;
import 'editable_text.dart' as custom;

/// Shows Deck metadata information enabling user to edit those details.
final class DeckInformation extends StatelessWidget {
  final model.Deck deck;

  DeckInformation({super.key, required this.deck});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: custom.EditableText(
        text: deck.name,
        style: Theme.of(context).textTheme.headlineSmall,
        onTextChanged: (value) async {
          var newDeck = deck.copyWith(name: value);
          try {
            final category = await context.cloudFunctions.deckCategory(
              value,
              deck.description ?? '',
            );
            newDeck = newDeck.copyWith(category: category);
          } catch (e, stackTrace) {
            // Optionally log error
          }
          await context.cardRepository.saveDeck(newDeck);
          context.showInfoSnackbar(context.l10n.deckNameSavedMessage);
        },
      ),
      subtitle: custom.EditableText(
        text: deck.description ?? '',
        style: Theme.of(context).textTheme.bodyMedium,
        onTextChanged: (value) async {
          var newDeck = deck.copyWith(description: value);
          try {
            final category = await context.cloudFunctions.deckCategory(
              deck.name,
              value,
            );
            newDeck = newDeck.copyWith(category: category);
          } catch (e, stackTrace) {
            // show error snackbar
            context.showErrorSnackbar(
              context.l10n.deckDescriptionSaveErrorMessage,
            );
          }
          await context.cardRepository.saveDeck(newDeck);
          context.showInfoSnackbar(context.l10n.deckDescriptionSavedMessage);
        },
      ),
      trailing: deck.category != null && !context.isMobile
          ? Chip(label: Text(deck.category?.name ?? ''))
          : null,
      isThreeLine: true,
      dense: true,
    );
  }
}
