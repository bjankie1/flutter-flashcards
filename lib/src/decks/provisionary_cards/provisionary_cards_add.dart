import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/crypto.dart';
import 'package:flutter_flashcards/src/decks/provisionary_cards/provisionary_cards_review_controller.dart';
import 'package:flutter_flashcards/src/decks/deck_list/decks_controller.dart';

class ProvisionaryCardAdd extends ConsumerStatefulWidget {
  @override
  ConsumerState<ProvisionaryCardAdd> createState() =>
      _ProvisionaryCardAddState();
}

class _ProvisionaryCardAddState extends ConsumerState<ProvisionaryCardAdd> {
  final TextEditingController cardQuestionController = TextEditingController();

  final List<String> addedCards = [];

  late FocusNode cardQuestionFocusNode;

  @override
  void initState() {
    super.initState();
    cardQuestionFocusNode = FocusNode();
    // Request focus after the widget is built to ensure keyboard shows
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusScope.of(context).requestFocus(cardQuestionFocusNode);
      }
    });
  }

  @override
  void dispose() {
    cardQuestionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: 20,
        children: [
          TextFormField(
            controller: cardQuestionController,
            focusNode: cardQuestionFocusNode,
            autofocus: true, // Automatically focus the field
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: context.l10n.provisionaryCardText,
            ),
            autovalidateMode: AutovalidateMode.always,
            keyboardType: TextInputType.text,
            textInputAction:
                TextInputAction.done, // Show done button on keyboard
            onFieldSubmitted: (value) async {
              if (value.isEmpty) return;
              await _addProvisionaryCard(context, value);
            },
          ),
          ValueListenableBuilder(
            valueListenable: cardQuestionController,
            builder: (BuildContext context, TextEditingValue value, _) {
              return FilledButton(
                onPressed: value.text.isEmpty
                    ? null
                    : () async {
                        await _addProvisionaryCard(
                          context,
                          cardQuestionController.text,
                        );
                      },
                child: Text(context.l10n.add),
              );
            },
          ),
          const Divider(),
          Expanded(
            child: ListView(
              children: addedCards
                  .map(
                    (text) => ListTile(
                      title: Text(text),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await _removeProvisionaryCard(text, context);
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _removeProvisionaryCard(
    String text,
    BuildContext context,
  ) async {
    final repository = ref.read(cardsRepositoryProvider);
    await repository.finalizeProvisionaryCard(text.trim().sha256Digest, null);
    setState(() {
      addedCards.remove(text);
    });

    // Refresh the provisionary cards review controller to update the badge
    await ref
        .read(provisionaryCardsReviewControllerProvider.notifier)
        .refresh();
  }

  Future<void> _addProvisionaryCard(BuildContext context, String text) async {
    final repository = ref.read(cardsRepositoryProvider);
    await repository.addProvisionaryCard(text);
    setState(() {
      addedCards.add(text);
      cardQuestionController.clear();
    });

    // Refresh the provisionary cards review controller to update the badge
    await ref
        .read(provisionaryCardsReviewControllerProvider.notifier)
        .refresh();

    // Ensure focus is maintained and keyboard stays visible after submission
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusScope.of(context).requestFocus(cardQuestionFocusNode);
      }
    });
  }
}
