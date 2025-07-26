import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/snackbar_messaging.dart';
import 'package:flutter_flashcards/src/decks/deck_groups/deck_groups_controller.dart';
import 'package:flutter_flashcards/src/model/cards.dart' as model;

class DeckGroupSelectionList extends ConsumerStatefulWidget {
  final String deckId;

  const DeckGroupSelectionList({super.key, required this.deckId});

  @override
  ConsumerState<DeckGroupSelectionList> createState() =>
      _DeckGroupSelectionListState();
}

class _DeckGroupSelectionListState
    extends ConsumerState<DeckGroupSelectionList> {
  @override
  Widget build(BuildContext context) {
    final groupsAsync = ref.watch(deckGroupsControllerProvider);

    return groupsAsync.when(
      data: (groups) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                context.l10n.addDeckToGroup,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ...groups.map(
              (group) => ListTile(
                leading: Icon(
                  group.decks?.contains(widget.deckId) == true
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
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
                  // The state will be refreshed by the controller
                });
              },
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) =>
          Center(child: Text('Error loading deck groups: $error')),
    );
  }

  Future<void> _toggleDeckInGroup(
    BuildContext context,
    model.DeckGroup group,
  ) async {
    try {
      if (group.decks == null || !group.decks!.contains(widget.deckId)) {
        await ref
            .read(deckGroupsControllerProvider.notifier)
            .addDeckToGroup(deckId: widget.deckId, groupId: group.id);
        context.showInfoSnackbar('Deck added to group');
      } else {
        await ref
            .read(deckGroupsControllerProvider.notifier)
            .removeDeckFromGroup(deckId: widget.deckId, groupId: group.id);
        context.showInfoSnackbar('Deck removed from group');
      }
    } catch (error) {
      context.showErrorSnackbar('Error updating deck group: $error');
    }
  }
}

class AddNewDeckGroup extends ConsumerWidget {
  final String deckId;
  final Function(model.DeckGroup) onGroupAdded;

  AddNewDeckGroup({
    super.key,
    required this.deckId,
    required this.onGroupAdded,
  });

  final TextEditingController _controller = TextEditingController();

  Future<void> _addGroup(BuildContext context, WidgetRef ref) async {
    if (_controller.text.isEmpty) {
      return;
    }
    try {
      await ref
          .read(deckGroupsControllerProvider.notifier)
          .createDeckGroup(_controller.text, '');
      await ref
          .read(deckGroupsControllerProvider.notifier)
          .addDeckToGroup(
            deckId: deckId,
            groupId: '', // This will be set by the controller
          );
      context.showInfoSnackbar(context.l10n.newDeckGroupAddedMessage);
      _controller.clear();
      onGroupAdded(model.DeckGroup(id: '', name: _controller.text));
    } catch (error) {
      context.showErrorSnackbar('Error creating deck group: $error');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              : (_) => _addGroup(context, ref),
        ),
        trailing: FilledButton(
          onPressed: value.text.isEmpty ? null : () => _addGroup(context, ref),
          child: Text(context.l10n.add),
        ),
      ),
    );
  }
}
