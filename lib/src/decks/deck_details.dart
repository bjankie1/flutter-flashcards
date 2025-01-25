import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/snackbar_messaging.dart';
import 'package:flutter_flashcards/src/model/repository.dart';
import 'package:logger/logger.dart';

import '../model/cards.dart' as model;

/// Shows Deck metadata information enabling user to edit those details.
final class DeckInformation extends StatelessWidget {
  final model.Deck deck;

  DeckInformation({super.key, required this.deck});

  final _log = Logger();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _DeckNameWidget(
                deckName: deck.name,
                onNameChanged: (name) async {
                  await _saveDeckName(context, name).onError((e, stackTrace) {
                    _log.w('Error saving new name',
                        error: e, stackTrace: stackTrace);
                    // show error in snackbar
                    context.showErrorSnackbar('Error saving deck');
                  });
                }),
            const SizedBox(height: 8),
            _DeckDescriptionWidget(
                deckDescription: deck.description ?? '',
                onDescriptionChanged: (description) {
                  _saveDeckDescription(context, description)
                      .onError((e, stackTrace) {
                    _log.w('Error saving new description',
                        error: e, stackTrace: stackTrace);
                    // show error in snackbar
                    context.showErrorSnackbar('Error saving deck');
                  });
                }),
          ],
        ),
      ),
    );
  }

  Future<void> _saveDeckName(BuildContext context, String name) async {
    _log.d('Name changed to $name');
    final newDeck = deck.copyWith(name: name);
    await context.cardRepository.saveDeck(newDeck);
    context.showInfoSnackbar(context.l10n.deckNameSavedMessage);
  }

  Future<void> _saveDeckDescription(
      BuildContext context, String description) async {
    _log.d('Description changed to $description');
    final newDeck = deck.copyWith(description: description);
    await context.cardRepository.saveDeck(newDeck);
    context.showInfoSnackbar(context.l10n.deckDescriptionSavedMessage);
  }
}

class _DeckNameWidget extends StatefulWidget {
  @override
  State<_DeckNameWidget> createState() => _DeckNameWidgetState();

  final String deckName;

  final Function(String) onNameChanged;

  _DeckNameWidget({required this.deckName, required this.onNameChanged});
}

class _DeckNameWidgetState extends State<_DeckNameWidget> {
  var _log = Logger();

  bool isEditingName = false;
  bool isEditingDescription = false;

  final nameController = TextEditingController();

  @override
  void initState() {
    nameController.text = widget.deckName;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IntrinsicWidth(
          child: TextFormField(
            controller: nameController,
            readOnly: !isEditingName,
            style: Theme.of(context).textTheme.headlineMedium,
            maxLines: 1,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderSide: isEditingName
                        ? const BorderSide() // Default border when editing
                        : BorderSide.none)),
          ),
        ),
        Visibility(
          visible: isEditingName,
          child: IconButton(
            icon: Icon(Icons.cancel),
            onPressed: () async {
              setState(() {
                isEditingName = false;
                nameController.text = widget.deckName;
              });
            },
          ),
        ),
        IconButton(
          icon: Icon(isEditingName ? Icons.save : Icons.edit),
          onPressed: () async {
            if (isEditingName) {
              // Save the name here
              String newName = nameController.text.trim();
              if (newName.isNotEmpty && newName != widget.deckName) {
                widget.onNameChanged(newName);
              }
            }
            setState(() {
              isEditingName = !isEditingName; // Toggle editing state
            });
          },
        ),
      ],
    );
  }
}

class _DeckDescriptionWidget extends StatefulWidget {
  final String deckDescription;

  final Function(String) onDescriptionChanged;

  _DeckDescriptionWidget(
      {required this.deckDescription, required this.onDescriptionChanged});

  @override
  State<_DeckDescriptionWidget> createState() => _DeckDescriptionWidgetState();
}

class _DeckDescriptionWidgetState extends State<_DeckDescriptionWidget> {
  bool isEditingDescription = false;

  final descriptionController = TextEditingController();

  @override
  void initState() {
    descriptionController.text = widget.deckDescription;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: descriptionController,
            readOnly: !isEditingDescription,
            minLines: 1,
            maxLines: 5,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderSide: isEditingDescription
                        ? const BorderSide() // Default border when editing
                        : BorderSide.none)),
          ),
        ),
        Visibility(
          visible: isEditingDescription,
          child: IconButton(
            icon: Icon(Icons.cancel),
            onPressed: () {
              setState(() {
                isEditingDescription = false;
                descriptionController.text = widget.deckDescription;
              });
            },
          ),
        ),
        IconButton(
          icon: Icon(isEditingDescription ? Icons.save : Icons.edit),
          onPressed: () {
            if (isEditingDescription) {
              // Save the description here
              String newDescription = descriptionController.text.trim();
              if (newDescription != widget.deckDescription) {
                widget.onDescriptionChanged(newDescription);
              }
            }
            setState(() {
              isEditingDescription =
                  !isEditingDescription; // Toggle editing state
            });
          },
        ),
      ],
    );
  }
}
