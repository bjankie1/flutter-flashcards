import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/crypto.dart';
import 'package:flutter_flashcards/src/model/repository.dart';

class ProvisionaryCardAdd extends StatefulWidget {
  @override
  State<ProvisionaryCardAdd> createState() => _ProvisionaryCardAddState();
}

class _ProvisionaryCardAddState extends State<ProvisionaryCardAdd> {
  final TextEditingController cardQuestionController = TextEditingController();

  final List<String> addedCards = [];

  late FocusNode cardQuestionFocusNode;

  @override
  void initState() {
    super.initState();
    cardQuestionFocusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(cardQuestionFocusNode);
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
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: context.l10n.provisionaryCardText,
              ),
              autovalidateMode: AutovalidateMode.always,
              keyboardType: TextInputType.text,
              onFieldSubmitted: (value) async {
                if (value.isEmpty) return;
                _addProvisionaryCard(context, value);
              }),
          ValueListenableBuilder(
            valueListenable: cardQuestionController,
            builder: (BuildContext context, TextEditingValue value, _) {
              return FilledButton(
                  onPressed: value.text.isEmpty
                      ? null
                      : () async {
                          await _addProvisionaryCard(
                              context, cardQuestionController.text);
                        },
                  child: Text(context.l10n.add));
            },
          ),
          const Divider(),
          Expanded(
            child: ListView(
              children: addedCards
                  .map((text) => ListTile(
                        title: Text(text),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await _removeProvisionaryCard(text, context);
                          },
                        ),
                      ))
                  .toList(),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _removeProvisionaryCard(
      String text, BuildContext context) async {
    await context.cardRepository
        .finalizeProvisionaryCard(text.trim().sha256Digest, null);
    setState(() {
      addedCards.remove(text);
    });
  }

  Future<void> _addProvisionaryCard(BuildContext context, String text) async {
    await context.cardRepository.addProvisionaryCard(text);
    setState(() {
      addedCards.add(text);
      cardQuestionController.clear();
      FocusScope.of(context).requestFocus(cardQuestionFocusNode);
    });
  }
}