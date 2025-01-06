import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/app.dart';
import 'package:flutter_flashcards/src/common/snackbar_messaging.dart';
import 'package:flutter_flashcards/src/model/firebase/firebase_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_for_web/image_picker_for_web.dart';
import 'package:provider/provider.dart';
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

  late String cardId;

  late bool questionImageAttached;
  late bool hintImageAttached;

  void reset() {
    cardQuestionTextController.text = '';
    cardAnswerTextController.text = '';
    cardHintTextController.text = '';
    cardId = '';
  }

  @override
  void initState() {
    super.initState();
    cardQuestionTextController.text = widget.card?.question ?? '';
    cardAnswerTextController.text = widget.card?.answer ?? '';
    cardHintTextController.text = widget.card?.explanation ?? '';
    questionImageAttached = widget.card?.questionImageAttached ?? false;
    hintImageAttached = widget.card?.explanationImageAttached ?? false;

    cardId = widget.card?.id ?? context.read<CardsRepository>().nextCardId();

    // cardQuestionTextController.addListener(() {
    //   setState(() {});
    // });
    // cardHintTextController.addListener(() {
    //   setState(() {});
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Input widgets
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    spacing: 8.0,
                    children: [
                      _questionInput(context),
                      _answerInput(context),
                      _hintInput(context),
                    ],
                  ),
                ),
              ),
              // Preview widgets
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 8.0,
                    children: [
                      _markdownPreview(cardQuestionTextController.text),
                      _questionImagePreview(height: 200),
                      Divider(),
                      _markdownPreview(cardHintTextController.text),
                    ],
                  ),
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _actions(context),
          )
        ],
      ),
    );
  }

  Widget _actions(BuildContext context) {
    return Row(
      spacing: 8.0,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutlinedButton(
            onPressed: () => context.pop(),
            child: Text(context.ml10n.cancelButtonLabel)),
        FilledButton(
            onPressed: () async => _saveCard(context),
            child: Text(context.ml10n.saveButtonLabel)),
        Visibility(
          visible: widget.card?.id == null,
          child: FilledButton(
              onPressed: () async => _saveCard(context, addNew: true),
              child: Text(context.l10n.saveAndNext)),
        ),
      ],
    );
  }

  Widget _markdownPreview(String text) {
    return GptMarkdown(text);
  }

  Widget _hintInput(BuildContext context) {
    return SizedBox(
      height: 200,
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
    );
  }

  Widget _answerInput(BuildContext context) {
    return TextFormField(
      controller: cardAnswerTextController,
      decoration: InputDecoration(
          hintText: context.l10n.answerHint,
          labelText: context.l10n.answerLabel,
          border: OutlineInputBorder()),
    );
  }

  Widget _questionImagePreview({double height = 200.0}) {
    return Visibility(
        visible: questionImageAttached,
        child: CardImage(
          cardId: cardId,
          placement: ImagePlacement.question,
          height: height,
        ));
  }

  Widget _questionInput(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          TextFormField(
            expands: true,
            maxLines: null,
            minLines: null,
            textAlignVertical: TextAlignVertical.top,
            controller: cardQuestionTextController,
            validator: _validateQuestion,
            decoration: InputDecoration(
                hintText: context.l10n.questionHint,
                labelText: context.l10n.questionLabel,
                border: OutlineInputBorder()),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: IconButton.filled(
              onPressed: () => _uploadImage(ImagePlacement.question),
              icon: Icon(Icons.image),
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
    final cardToSave = model.Card(
        id: cardId,
        deckId: widget.deckId,
        question: cardQuestionTextController.text,
        answer: cardAnswerTextController.text,
        explanation: cardHintTextController.text,
        questionImageAttached: questionImageAttached,
        explanationImageAttached: hintImageAttached);

    await context.cardRepository.saveCard(cardToSave).then(
        (value) => context.showInfoSnackbar('Card saved!'),
        onError: (e) => context.showErrorSnackbar('Error saving card'));
    if (addNew) {
      reset();
    } else {
      context.pop();
    }
  }

  void _uploadImage(ImagePlacement placement) async {
    final ImagePickerPlugin picker = ImagePickerPlugin();
    // Pick an image from the gallery
    final XFile? image =
        await picker.getImageFromSource(source: ImageSource.gallery);
    final service = context.read<StorageService>();
    if (image != null) {
      await context.read<StorageService>().uploadImage(
            image,
            cardId,
            placement.name,
            onSuccess: () async {
              context.showInfoSnackbar('Image recorded');
              // final url = await service.imageUrl(cardId, placement.name);
              setState(() {
                switch (placement) {
                  case ImagePlacement.question:
                    questionImageAttached = true;
                  case ImagePlacement.hint:
                    hintImageAttached = true;
                }
              });
            },
            onError: () => context.showErrorSnackbar('Error uploading image'),
          );
    }
  }
}

class CardImage extends StatelessWidget {
  const CardImage(
      {super.key,
      required this.cardId,
      required this.placement,
      this.height = 200});

  final String cardId;

  final ImagePlacement placement;

  final double height;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: context.read<StorageService>().imageUrl(cardId, placement.name),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Text('error: ${snapshot.error}');
          }
          if (!snapshot.hasData) {
            return Center(child: Text('No data'));
          }
          final url = snapshot.data;
          if (url == null) {
            return Center(child: Text('No image data'));
          }
          return Image.network(
            url,
            height: height,
          );
        });
  }
}

enum ImagePlacement { question, hint }
