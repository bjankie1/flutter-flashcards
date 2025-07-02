import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/snackbar_messaging.dart';
import 'package:flutter_flashcards/src/model/repository.dart';

import '../../model/cards.dart' as model;

/// A widget that displays a list of deck groups for selection.
///
/// This widget allows users to view and select deck groups for a specific deck.
/// It shows which groups the deck currently belongs to and allows toggling
/// membership in groups.
class DeckGroupSelectionList extends StatefulWidget {
  /// The ID of the deck for which groups are being selected.
  final String deckId;

  /// Optional callback function that is called when a group is selected.
  /// The callback receives the ID of the selected group.
  final Function(String groupId)? onGroupSelected;

  DeckGroupSelectionList({required this.deckId, this.onGroupSelected});

  @override
  State<DeckGroupSelectionList> createState() => _DeckGroupSelectionListState();
}

class _DeckGroupSelectionListState extends State<DeckGroupSelectionList> {
  final List<model.DeckGroupId> selectedGroups = List.empty(growable: true);
  List<model.DeckGroup> groups = List.empty(growable: true);

  Future<List<model.DeckGroup>> _loadDeckGroups(
    CardsRepository repository,
  ) async {
    final groups = await repository.loadDeckGroups();
    final groupsList = groups.toList();
    groupsList.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
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
    return ListView(
      children: [
        ...groups.map(
          (group) => ListTile(
            leading: Visibility(
              visible:
                  group.decks != null && group.decks!.contains(widget.deckId),
              child: Icon(Icons.check),
            ),
            title: Text(group.name),
            onTap: () {
              _toggleDeckInGroup(context, group);
            },
          ),
        ),
        AddNewDeckGroup(
          deckId: widget.deckId,
          onGroupAdded: (group) {
            setState(() {
              groups.add(group);
            });
          },
        ),
      ],
    );
  }

  Future<void> _toggleDeckInGroup(
    BuildContext context,
    model.DeckGroup group,
  ) async {
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
            : {...group.decks!, widget.deckId},
      );
    } else {
      await context.cardRepository.removeDeckFromGroup(widget.deckId, group.id);
      groupWithDeck = group.copyWith(
        decks: group.decks!.difference({widget.deckId}),
      );
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
    final group = await context.cardRepository.createDeckGroup(
      _controller.text,
      '',
    );
    await context.cardRepository.addDeckToGroup(deckId, group.id);
    context.showInfoSnackbar(context.l10n.newDeckGroupAddedMessage);
    _controller.clear();
    onGroupAdded(group);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _controller,
      builder: (context, value, _) => ListTile(
        title: TextFormField(
          controller: _controller,
          decoration: InputDecoration(
            label: Text(context.l10n.newDeckGroupName),
            helperText: context.l10n.newDeckGroupHelper,
          ),
          autofocus: true,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: value.text.isEmpty
              ? null
              : (_) => _addGroup(context),
        ),
        trailing: FilledButton(
          onPressed: value.text.isEmpty ? null : () => _addGroup(context),
          child: Text(context.l10n.add),
        ),
      ),
    );
  }
}
