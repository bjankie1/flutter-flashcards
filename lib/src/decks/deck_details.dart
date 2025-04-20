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

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: _DeckNameWidget(deck: deck),
      subtitle: _DeckDescriptionWidget(deck: deck),
      trailing: deck.category != null && !context.isMobile
          ? Chip(label: Text(deck.category?.name ?? ''))
          : null,
      dense: true,
    );
  }
}

class _DeckNameWidget extends StatefulWidget {
  @override
  State<_DeckNameWidget> createState() => _DeckNameWidgetState();

  final model.Deck deck;

  _DeckNameWidget({required this.deck});
}

class _DeckNameWidgetState extends State<_DeckNameWidget> {
  var _log = Logger();

  bool isEditing = false;
  bool isSaving = false;

  final nameController = TextEditingController();

  @override
  void initState() {
    nameController.text = widget.deck.name;
    super.initState();
  }

  Future<void> _saveDeckName(BuildContext context, String name) async {
    _log.d('Name changed to $name');
    var newDeck = widget.deck.copyWith(name: name);
    try {
      final category = await context.cloudFunctions
          .deckCategory(name, widget.deck.description ?? '');
      newDeck = newDeck.copyWith(category: category);
    } on Exception catch (e, stackTrace) {
      _log.w('Failed categorizing the deck', error: e, stackTrace: stackTrace);
    }
    await context.cardRepository.saveDeck(newDeck);
    context.showInfoSnackbar(context.l10n.deckNameSavedMessage);
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 1000, maxHeight: 65),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: nameController,
                    readOnly: !isEditing,
                    style: Theme.of(context).textTheme.headlineSmall,
                    maxLines: 1,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderSide: isEditing
                                ? const BorderSide() // Default border when editing
                                : BorderSide.none)),
                  ),
                ),
                SizedBox(
                  height: 5,
                  child: Visibility(
                      visible: isSaving, child: LinearProgressIndicator()),
                )
              ],
            ),
          ),
          Visibility(
            visible: isEditing,
            child: IconButton(
              icon: Icon(Icons.cancel),
              onPressed: () async {
                setState(() {
                  isEditing = false;
                  nameController.text = widget.deck.name;
                });
              },
            ),
          ),
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            onPressed: () async {
              if (isEditing && !isSaving) {
                String newText = nameController.text.trim();
                if (newText == widget.deck.name) {
                  setState(() {
                    isEditing = false;
                    isSaving = false;
                  });
                  return;
                }
                // Save the description here
                setState(() {
                  isSaving = true;
                });
                await _saveDeckName(context, newText).then((_) {
                  nameController.text = newText;
                }, onError: (e) {
                  nameController.text = widget.deck.name;
                }).whenComplete(() {
                  setState(() {
                    isEditing = false;
                    isSaving = false;
                  });
                });
              } else if (!isSaving) {
                setState(() {
                  isEditing = true;
                  isSaving = false;
                });
              }
            },
          ),
        ],
      ),
    );
  }
}

class _DeckDescriptionWidget extends StatefulWidget {
  final model.Deck deck;

  _DeckDescriptionWidget({required this.deck});

  @override
  State<_DeckDescriptionWidget> createState() => _DeckDescriptionWidgetState();
}

class _DeckDescriptionWidgetState extends State<_DeckDescriptionWidget> {
  bool isEditing = false;
  bool isSaving = false;

  final _log = Logger();

  final inputTextController = TextEditingController();

  @override
  void initState() {
    inputTextController.text = widget.deck.description ?? '';
    super.initState();
  }

  Future<void> _saveDeckDescription(
      BuildContext context, String description) async {
    _log.d('Description changed to $description');
    var newDeck = widget.deck.copyWith(description: description);
    try {
      final category = await context.cloudFunctions
          .deckCategory(widget.deck.name, description);
      newDeck = newDeck.copyWith(category: category);
    } on Exception catch (e, stackTrace) {
      _log.w('Failed categorizing the deck', error: e, stackTrace: stackTrace);
    }
    await context.cardRepository.saveDeck(newDeck);
    context.showInfoSnackbar(context.l10n.deckDescriptionSavedMessage);
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 1000),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                TextFormField(
                  controller: inputTextController,
                  readOnly: !isEditing,
                  minLines: 1,
                  maxLines: 5,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: isEditing
                              ? const BorderSide() // Default border when editing
                              : BorderSide.none)),
                ),
                SizedBox(
                  height: 5,
                  child: Visibility(
                      visible: isSaving, child: LinearProgressIndicator()),
                )
              ],
            ),
          ),
          Visibility(
            visible: isEditing,
            child: IconButton(
              icon: Icon(Icons.cancel),
              onPressed: () {
                setState(() {
                  isEditing = false;
                  inputTextController.text = widget.deck.description ?? '';
                });
              },
            ),
          ),
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            onPressed: () async {
              if (isEditing && !isSaving) {
                String newDescription = inputTextController.text.trim();
                if (newDescription == widget.deck.description) {
                  setState(() {
                    isEditing = false;
                    isSaving = false;
                  });
                  return;
                }
                // Save the description here
                setState(() {
                  isSaving = true;
                });
                await _saveDeckDescription(context, newDescription).then((_) {
                  inputTextController.text = newDescription;
                }, onError: (e) {
                  inputTextController.text = widget.deck.description ?? '';
                }).whenComplete(() {
                  setState(() {
                    isEditing = false;
                    isSaving = false;
                  });
                });
              } else if (!isSaving) {
                setState(() {
                  isEditing = true;
                  isSaving = false;
                });
              }
            },
          ),
        ],
      ),
    );
  }
}