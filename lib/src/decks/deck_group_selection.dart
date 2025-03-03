import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/snackbar_messaging.dart';
import 'package:flutter_flashcards/src/model/repository.dart';

import '../model/cards.dart' as model;

class DeckGroupSelectionList extends StatefulWidget {
  final String deckId;
  final Function(String groupId)? onGroupSelected;

  DeckGroupSelectionList({
    required this.deckId,
    this.onGroupSelected,
  });

  @override
  State<DeckGroupSelectionList> createState() => _DeckGroupSelectionListState();
}

class _DeckGroupSelectionListState extends State<DeckGroupSelectionList> {
  final List<model.DeckGroupId> selectedGroups = List.empty(growable: true);
  List<model.DeckGroup> groups = List.empty(growable: true);

  Future<List<model.DeckGroup>> _loadDeckGroups(
      CardsRepository repository) async {
    final groups = await repository.loadDeckGroups();
    final groupsList = groups.toList();
    groupsList
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return groupsList;
  }

  void _loadState() async {
    final groups = await _loadDeckGroups(context.cardRepository);
    setState(() {
      this.groups = groups;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AddNewDeckGroup(
          deckId: widget.deckId,
          onGroupAdded: (group) {
            setState(() {
              groups.add(group);
            });
          },
        ),
        Expanded(
          child: ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return ListTile(
                leading: Visibility(
                  visible: group.decks != null &&
                      group.decks!.contains(widget.deckId),
                  child: Icon(Icons.check),
                ),
                title: Text(group.name),
                onTap: () {
                  _toggleDeckInGroup(context, group);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _toggleDeckInGroup(
      BuildContext context, model.DeckGroup group) async {
    final groupIndex = groups.indexOf(group);
    if (groupIndex == -1) {
      context.showErrorSnackbar('Internal error: group not found');
      return;
    }
    model.DeckGroup groupWithDeck;
    if (group.decks == null || !group.decks!.contains(widget.deckId)) {
      await context.cardRepository.addDeckToGroup(widget.deckId, group.id);
      groupWithDeck = group.copyWith(
          decks: group.decks == null
              ? {widget.deckId}
              : {...group.decks!, widget.deckId});
    } else {
      await context.cardRepository.removeDeckFromGroup(widget.deckId, group.id);
      groupWithDeck =
          group.copyWith(decks: group.decks!.difference({widget.deckId}));
    }
    setState(() {
      groups[groupIndex] = groupWithDeck;
    });
  }
}

class AddNewDeckGroup extends StatelessWidget {
  final String deckId;

  final Function(model.DeckGroup) onGroupAdded;

  AddNewDeckGroup({
    super.key,
    required this.deckId,
    required this.onGroupAdded,
  });

  final TextEditingController _controller = TextEditingController();

  Future<void> _addGroup(BuildContext context) async {
    if (_controller.text.isEmpty) {
      return;
    }
    final group =
        await context.cardRepository.createDeckGroup(_controller.text, '');
    await context.cardRepository.addDeckToGroup(deckId, group.id);
    context.showInfoSnackbar(context.l10n.newDeckGroupAddedMessage);
    _controller.clear();
    onGroupAdded(group);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: TextFormField(
            controller: _controller,
            decoration: InputDecoration(
                label: Text(context.l10n.newDeckGroupName),
                border: OutlineInputBorder(),
                helperText: context.l10n.newDeckGroupHelper),
          ),
        ),
        IconButton(
          iconSize: 40,
          color: Colors.green,
          onPressed: () => _addGroup(context),
          icon: Icon(Icons.check),
        )
      ],
    );
  }
}