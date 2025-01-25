import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/snackbar_messaging.dart';
import 'package:flutter_flashcards/src/model/repository.dart';
import 'package:logger/logger.dart';

import '../model/cards.dart' as model;

/// Shows Deck metadata information enabling user to edit those details.
class DeckInformation extends StatefulWidget {
  final model.Deck deck;

  const DeckInformation({super.key, required this.deck});

  @override
  State<DeckInformation> createState() => _DeckInformationState();
}

class _DeckInformationState extends State<DeckInformation> {
  bool isEditingName = false;
  bool isEditingDescription = false;

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  var _log = Logger();

  @override
  void initState() {
    nameController.text = widget.deck.name;
    descriptionController.text = widget.deck.description ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
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
                        nameController.text = widget.deck.name;
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
                      if (newName.isNotEmpty && newName != widget.deck.name) {
                        try {
                          await _saveDeckName();
                        } on Exception catch (e) {
                          _log.w('Error saving new name', error: e);
                          // show error in snackbar
                          context.showErrorSnackbar('Error saving new name');
                        }
                      }
                    }
                    setState(() {
                      isEditingName = !isEditingName; // Toggle editing state
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Visibility(
                  visible: isEditingDescription ||
                      widget.deck.description != null &&
                          widget.deck.description!.isNotEmpty,
                  child: IntrinsicWidth(
                    child: TextFormField(
                      controller: descriptionController,
                      readOnly: !isEditingDescription,
                      style: Theme.of(context).textTheme.bodyMedium,
                      minLines: 1,
                      maxLines: 5,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderSide: isEditingDescription
                                  ? const BorderSide() // Default border when editing
                                  : BorderSide.none)),
                    ),
                  ),
                ),
                Visibility(
                  visible: isEditingDescription,
                  child: IconButton(
                    icon: Icon(Icons.cancel),
                    onPressed: () async {
                      setState(() {
                        isEditingDescription = false;
                        descriptionController.text =
                            widget.deck.description ?? '';
                      });
                    },
                  ),
                ),
                Visibility(
                  visible: (widget.deck.description == null ||
                          widget.deck.description!.isEmpty) &&
                      !isEditingDescription,
                  child: TextButton(
                      onPressed: () {
                        setState(() {
                          isEditingDescription =
                              !isEditingDescription; // Toggle editing state
                        });
                      },
                      child: Text('Add description')),
                ),
                Visibility(
                  visible: isEditingDescription ||
                      (widget.deck.description != null &&
                          widget.deck.description!.isNotEmpty),
                  child: IconButton(
                    icon: Icon(isEditingDescription ? Icons.save : Icons.edit),
                    onPressed: () async {
                      if (isEditingDescription) {
                        // Save the name here
                        String newDeckDescription =
                            descriptionController.text.trim();
                        if (newDeckDescription != widget.deck.description) {
                          try {
                            await _saveDeckDescription();
                          } on Exception catch (e) {
                            _log.w('Error saving description', error: e);
                            // show error in snackbar
                            context.showErrorSnackbar(
                                context.l10n.errorSavingDescriptionMessage);
                          }
                        }
                      }
                      setState(() {
                        isEditingDescription =
                            !isEditingDescription; // Toggle editing state
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveDeckName() async {
    _log.d('Name changed to ${nameController.text}');
    final newDeckName = nameController.text;
    final newDeck = widget.deck.copyWith(name: newDeckName);
    await context.cardRepository.saveDeck(newDeck);
    context.showInfoSnackbar(context.l10n.deckNameSavedMessage);
  }

  Future<void> _saveDeckDescription() async {
    _log.d('Description changed to ${descriptionController.text}');
    final newDeckDescription = descriptionController.text;
    final newDeck = widget.deck.copyWith(description: newDeckDescription);
    await context.cardRepository.saveDeck(newDeck);
    context.showInfoSnackbar(context.l10n.deckDescriptionSavedMessage);
  }
}
