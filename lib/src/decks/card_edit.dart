import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/model/repository.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
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

  _CardEditState(this.card, this.deckId) {
    cardQuestionTextController.text = card?.question.text ?? '';
    cardAnswerTextController.text = card?.answer ?? '';
    cardHintTextController.text = card?.explanation?.text ?? '';
  }

  void reset() {
    cardQuestionTextController.text = '';
    cardAnswerTextController.text = '';
    cardHintTextController.text = '';
    question = null;
    hint = null;
  }

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
            child: Row(
              spacing: 8.0,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancel')),
                FilledButton(
                    onPressed: () async => _saveCard(context),
                    child: Text('Save')),
                if (card?.id == null)
                  FilledButton(
                      onPressed: () async => _saveCard(context, addNew: true),
                      child: Text('Add next')),
              ],
            ),
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

  _saveCard(BuildContext context, {bool addNew = false}) async {
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
      if (addNew) {
        reset();
      } else {
        Navigator.of(context).pop();
      }
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
