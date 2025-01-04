import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/app.dart';
import 'package:flutter_flashcards/src/common/snackbar_messaging.dart';
import 'package:go_router/go_router.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import '../model/repository.dart';
import '../model/cards.dart' as model;

class CardEdit extends StatefulWidget {
  final model.Card? card;

  final String deckId;

  const CardEdit({this.card, required this.deckId, super.key});

  @override
  State<CardEdit> createState() => _CardEditState();
}

class _CardEditState extends State<CardEdit> {
  final GlobalKey<FormState> formKey = GlobalKey();

  final cardQuestionTextController = TextEditingController();
  final cardAnswerTextController = TextEditingController();
  final cardHintTextController = TextEditingController();

  bool preview = false;

  void reset() {
    cardQuestionTextController.text = '';
    cardAnswerTextController.text = '';
    cardHintTextController.text = '';
  }

  @override
  void initState() {
    super.initState();
    cardQuestionTextController.text = widget.card?.question.text ?? '';
    cardAnswerTextController.text = widget.card?.answer ?? '';
    cardHintTextController.text = widget.card?.explanation?.text ?? '';

    cardQuestionTextController.addListener(() {
      setState(() {});
    });
    cardHintTextController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    OutlinedButton(
                        onPressed: () {
                          setState(() {
                            preview = !preview;
                          });
                        },
                        child: Text('Preview')),
                  ],
                ),
              ),
              Form(
                key: formKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    spacing: 8.0,
                    children: [
                      SizedBox(
                        height: 200,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: TextFormField(
                                expands: true,
                                maxLines: null,
                                minLines: null,
                                textAlignVertical: TextAlignVertical.top,
                                controller: cardQuestionTextController,
                                validator: _validateQuestion,
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
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    padding: EdgeInsets.all(8.0),
                                    child: GptMarkdown(
                                        cardQuestionTextController.text)))
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
                        child: SizedBox(
                          height: 200,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: TextFormField(
                                  expands: true,
                                  maxLines: null,
                                  minLines: null,
                                  textAlignVertical: TextAlignVertical.top,
                                  controller: cardHintTextController,
                                  decoration: InputDecoration(
                                      hintText: context.l10n.hintPrompt,
                                      labelText: context.l10n.hintLabel,
                                      border: OutlineInputBorder()),
                                ),
                              ),
                              SizedBox(width: 8.0),
                              Expanded(
                                child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    padding: EdgeInsets.all(8.0),
                                    child: GptMarkdown(
                                        cardHintTextController.text)),
                              )
                            ],
                          ),
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
                          Visibility(
                            visible: widget.card?.id == null,
                            child: FilledButton(
                                onPressed: () async =>
                                    _saveCard(context, addNew: true),
                                child: Text(context.l10n.saveAndNext)),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
          id: widget.card?.id,
          deckId: widget.deckId,
          question: model.Content.basic(cardQuestionTextController.text),
          answer: cardAnswerTextController.text,
          explanation: model.Content.basic(cardHintTextController.text));

      await context.cardRepository.saveCard(cardToSave).then(
          (value) => context.showInfoSnackbar('Card saved!'),
          onError: (e) => context.showErrorSnackbar('Error saving card'));
      if (addNew) {
        reset();
      } else {
        context.pop();
      }
    }
  }
}
