import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/card_image.dart';
import 'package:flutter_flashcards/src/common/snackbar_messaging.dart';
import 'package:flutter_flashcards/src/model/firebase/firebase_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
// import 'package:image_picker_for_web/image_picker_for_web.dart'
//     if (dart.library.html) 'package:image_picker_for_web/image_picker_for_web.dart';

import 'package:provider/provider.dart';

import '../model/cards.dart' as model;
import '../model/repository.dart';

class CardEdit extends StatefulWidget {
  final model.Card? card;

  final model.Deck deck;

  const CardEdit({this.card, required this.deck, super.key});

  @override
  State<CardEdit> createState() => _CardEditState();
}

class _CardEditState extends State<CardEdit> {
  final _log = Logger();

  final GlobalKey<FormState> formKey = GlobalKey();

  final cardQuestionTextController = TextEditingController();
  final cardAnswerTextController = TextEditingController();
  final cardHintTextController = TextEditingController();

  late String cardId;

  late bool questionImageAttached;
  late bool explanationImageAttached;

  void reset() {
    _log.d('reset() called');

    setState(() {
      cardQuestionTextController.text = '';
      cardAnswerTextController.text = '';
      cardHintTextController.text = '';
      cardId = context.cardRepository.nextCardId();
      questionImageAttached = false;
      explanationImageAttached = false;
    });
    FocusScope.of(context).unfocus();
  }

  @override
  void initState() {
    super.initState();
    cardQuestionTextController.text = widget.card?.question ?? '';
    cardAnswerTextController.text = widget.card?.answer ?? '';
    cardHintTextController.text = widget.card?.explanation ?? '';
    questionImageAttached = widget.card?.questionImageAttached ?? false;
    explanationImageAttached = widget.card?.explanationImageAttached ?? false;

    cardId = widget.card?.id ?? context.cardRepository.nextCardId();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Input widgets
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      spacing: 8.0,
                      children: [
                        _markdownWithImageInput(
                            controller: cardQuestionTextController,
                            hintText: context.l10n.questionHint,
                            labelText: context.l10n.questionLabel,
                            imagePlacement: model.ImagePlacement.question),
                        _answerInput(),
                        _markdownWithImageInput(
                            controller: cardHintTextController,
                            hintText: context.l10n.hintPrompt,
                            labelText: context.l10n.hintLabel,
                            imagePlacement: model.ImagePlacement.explanation),
                      ],
                    ),
                  ),
                ),
                // Preview widgets
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8.0,
                      children: [
                        ConstrainedBox(
                          constraints:
                              BoxConstraints(maxHeight: 300, minHeight: 100),
                          child: Column(
                            children: [
                              _markdownPreview(cardQuestionTextController),
                              _imagePreview(
                                  height: 200,
                                  imagePlacement:
                                      model.ImagePlacement.question),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Divider(),
                        _markdownPreview(cardAnswerTextController),
                        Divider(),
                        SizedBox(
                          height: 10,
                        ),
                        ConstrainedBox(
                          constraints:
                              BoxConstraints(maxHeight: 300, minHeight: 100),
                          child: Column(
                            children: [
                              _markdownPreview(cardHintTextController),
                              _imagePreview(
                                  height: 200,
                                  imagePlacement:
                                      model.ImagePlacement.explanation),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
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

  Widget _markdownPreview(TextEditingController controller) {
    return ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, value, _) {
          return GptMarkdown(value.text);
        });
  }

  Widget _answerInput() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            maxLines: 4,
            controller: cardAnswerTextController,
            decoration: InputDecoration(
                hintText: context.l10n.answerHint,
                labelText: context.l10n.answerLabel,
                border: OutlineInputBorder()),
          ),
        ),
        ValueListenableBuilder(
            valueListenable: cardQuestionTextController,
            builder: (context, value, _) {
              return _GenerateAnswerButton(
                  deck: widget.deck,
                  question: value.text,
                  onAnswer: (answer, hint) {
                    cardAnswerTextController.text = answer;
                    cardHintTextController.text = hint;
                  });
            })
      ],
    );
  }

  Widget _imagePreview(
      {double height = 200.0, required model.ImagePlacement imagePlacement}) {
    return Visibility(
        visible: imagePlacement == model.ImagePlacement.question &&
                questionImageAttached ||
            imagePlacement == model.ImagePlacement.explanation &&
                explanationImageAttached,
        child: CardImage(
          cardId: cardId,
          placement: imagePlacement,
          height: height,
        ));
  }

  Widget _markdownWithImageInput(
      {required TextEditingController controller,
      required String hintText,
      required String labelText,
      required model.ImagePlacement imagePlacement}) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 300, minHeight: 100),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          TextFormField(
            expands: true,
            maxLines: null,
            minLines: null,
            textAlignVertical: TextAlignVertical.top,
            controller: controller,
            decoration: InputDecoration(
                hintText: hintText,
                labelText: labelText,
                border: OutlineInputBorder()),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton.filled(
              onPressed: () => _uploadImage(imagePlacement),
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

  _saveCard(BuildContext context, {bool addNew = false}) async {
    final cardToSave = model.Card(
        id: cardId,
        deckId: widget.deck.id!,
        question: cardQuestionTextController.text,
        answer: cardAnswerTextController.text,
        explanation: cardHintTextController.text,
        questionImageAttached: questionImageAttached,
        explanationImageAttached: explanationImageAttached);

    await context.cardRepository.saveCard(cardToSave).then(
        (value) => context.showInfoSnackbar(context.l10n.cardSavedMessage),
        onError: (e) =>
            context.showErrorSnackbar(context.l10n.cardSavingErrorMessage));
    if (addNew) {
      reset();
    } else {
      context.pop();
    }
  }

  void _uploadImage(model.ImagePlacement placement) async {
    if (kIsWeb) {
      _uploadImageWeb(placement);
    } else {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);
    }
  }

  void _uploadImageWeb(model.ImagePlacement placement) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.count > 0) {
      XFile image = result.files.first.xFile;
      final service = context.read<StorageService>();
      await service.uploadCardIllustration(
        image,
        cardId,
        placement.name,
        onSuccess: () async {
          context.showInfoSnackbar('Image recorded');
          // final url = await service.imageUrl(cardId, placement.name);
          setState(() {
            switch (placement) {
              case model.ImagePlacement.question:
                questionImageAttached = true;
              case model.ImagePlacement.explanation:
                explanationImageAttached = true;
            }
          });
        },
        onError: () => context.showErrorSnackbar('Error uploading image'),
      );
    }

    //   // Pick an image from the gallery
  }
}

class _GenerateAnswerButton extends StatefulWidget {
  const _GenerateAnswerButton({
    required this.deck,
    required this.question,
    required this.onAnswer,
  });

  final model.Deck deck;
  final String question;
  final Function(String, String) onAnswer;

  @override
  State<_GenerateAnswerButton> createState() => _GenerateAnswerButtonState();
}

class _GenerateAnswerButtonState extends State<_GenerateAnswerButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: _isLoading ? null : processLoading,
        icon: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : Icon(Icons.generating_tokens));
  }

  loadAnswer() async {
    final category = widget.deck.category ??
        await context.cloudFunctions.deckCategory(
          widget.deck.name,
          widget.deck.description ?? '',
        );
    // persist the category in case it wasn't attached to deck earlier
    if (widget.deck.category == null) {
      await context.cardRepository
          .saveDeck(widget.deck.copyWith(category: category));
    }
    return await context.cloudFunctions.generateCardAnswer(category,
        widget.deck.name, widget.deck.description ?? '', widget.question);
  }

  void processLoading() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await loadAnswer().then((result) {
        widget.onAnswer(result.answer, result.explanation);
      }, onError: (e) {
        context.showErrorSnackbar('Error generating answer: $e');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}