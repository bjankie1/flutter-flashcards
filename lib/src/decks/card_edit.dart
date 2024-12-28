import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/app.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import '../model/repository.dart';
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
    return Card(
      child: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            spacing: 8.0,
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    SizedBox(width: 8.0),
                    Expanded(
                        child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: EdgeInsets.all(8.0),
                            child: TexMarkdown(question ?? '')))
                  ],
                ),
              ),
              Row(
                spacing: 8.0,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: cardAnswerTextController,
                          decoration: InputDecoration(
                              hintText: 'Answer',
                              labelText: 'Answer',
                              border: OutlineInputBorder()),
                        ),
                        ListView(shrinkWrap: true, children: [])
                      ],
                    ),
                  ),
                  Spacer()
                ],
              ),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    SizedBox(width: 8.0),
                    Expanded(
                      child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TexMarkdown(hint ?? ''),
                          )),
                    )
                  ],
                ),
              ),
              Row(
                spacing: 8.0,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(context.ml10n.cancelButtonLabel)),
                  FilledButton(
                      onPressed: () async => _saveCard(context),
                      child: Text(context.ml10n.saveButtonLabel)),
                  if (card?.id == null)
                    FilledButton(
                        onPressed: () async => _saveCard(context, addNew: true),
                        child: Text(context.l10n.saveAndNext)),
                ],
              )
            ],
          ),
        ),
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

      await context.cardRepository.saveCard(cardToSave).then(
          (value) => _showSnackbar(context, 'Card saved!', false),
          onError: (e) => _showSnackbar(context, "Error saving card", true));
      if (addNew) {
        reset();
      } else {
        Navigator.pop(context);
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
