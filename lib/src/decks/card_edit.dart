import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/model/repository.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../model/cards.dart' as model;

class CardEdit extends StatefulWidget {
  final model.Card? card;

  final String deckId;

  const CardEdit({this.card, required this.deckId, super.key});

  @override
  State<CardEdit> createState() => _CardEditState(card, deckId);
}

class _CardEditState extends State<CardEdit> {
  final GlobalKey<FormState> formKey = GlobalKey();

  final cardQuestionTextController = TextEditingController();
  final cardAnswerTextController = TextEditingController();
  final cardHintTextController = TextEditingController();

  String? question;
  String? hint;

  final model.Card? card;
  final String deckId;

  _CardEditState(this.card, this.deckId);

  @override
  void initState() {
    super.initState();
    cardQuestionTextController.addListener(() {
      question = cardQuestionTextController.text;
      setState(() {});
    });
    cardHintTextController.addListener(() {
      hint = cardHintTextController.text;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: cardQuestionTextController,
                    validator: _validateQuestion,
                    maxLines: 5,
                    decoration: InputDecoration(
                        hintText: 'Question',
                        labelText: 'Question',
                        border: OutlineInputBorder()),
                  ),
                ),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TexMarkdown(question ?? ''),
                ))
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: cardAnswerTextController,
                    decoration: InputDecoration(
                        hintText: 'Answer',
                        labelText: 'Answer',
                        border: OutlineInputBorder()),
                  ),
                ),
                Spacer()
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: cardHintTextController,
                    maxLines: 5,
                    decoration: InputDecoration(
                        hintText: 'Hint',
                        labelText: 'Hint',
                        border: OutlineInputBorder()),
                  ),
                ),
                Expanded(
                  child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: TexMarkdown(hint ?? '')),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FilledButton(
                onPressed: () async => _saveCard(context),
                child: Text('Submit')),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    cardQuestionTextController.dispose();
    cardAnswerTextController.dispose();
    super.dispose();
  }

  String? _validateQuestion(String? value) {
    return null;
  }

  _saveCard(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      final cardToSave = model.Card(
          id: card?.id,
          deckId: deckId,
          question: model.Content.basic(cardQuestionTextController.text),
          answer: cardAnswerTextController.text,
          explanation: model.Content.basic(cardHintTextController.text));

      await Provider.of<CardsRepository>(context, listen: false)
          .saveCard(cardToSave)
          .then((value) => _showSnackbar(context, 'Card saved!', false),
              onError: (e) =>
                  _showSnackbar(context, "Error saving card", true));
    }
  }

  void _showSnackbar(BuildContext context, String text, bool isError) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(text),
          backgroundColor: isError ? Colors.red : Colors.green,
        ));
    }
  }
}
