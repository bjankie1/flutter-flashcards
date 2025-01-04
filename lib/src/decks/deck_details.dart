import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/snackbar_messaging.dart';
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
  bool editDescription = false;

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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Visibility(
            visible: !isEditingName,
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: nameController,
                    readOnly: !isEditingName,
                    style: Theme.of(context).textTheme.headlineMedium,
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
          ),
          const SizedBox(height: 8),
          Text(
            widget.deck.description ?? '',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Future<void> _saveDeckName() async {}
}
