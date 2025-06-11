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
  final cardQuestionTextController = TextEditingController();
  final cardAnswerTextController = TextEditingController();
  final cardHintTextController = TextEditingController();

  late Listenable textChangeNotifier;

  late String cardId;

  bool questionImageAttached = false;
  bool explanationImageAttached = false;

  bool learnBothSides = false;

  void reset() {
    setState(() {
      cardQuestionTextController.text = '';
      cardAnswerTextController.text = '';
      cardHintTextController.text = '';
      cardId = context.cardRepository.nextCardId();
      questionImageAttached = false;
      explanationImageAttached = false;
      // `learnBothSides` is not being reverted as it is common that subsequent
      // cards will have the same option.
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
    learnBothSides = widget.card?.options?.learnBothSides ?? false;
    cardId = widget.card?.id ?? context.cardRepository.nextCardId();
    textChangeNotifier = Listenable.merge([
      cardQuestionTextController,
      cardAnswerTextController,
      cardHintTextController,
    ]);
  }

  @override
  void dispose() {
    cardQuestionTextController.dispose();
    cardAnswerTextController.dispose();
    cardHintTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.5,
        child: FocusTraversalGroup(
          policy: OrderedTraversalPolicy(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CardOptions(
                  value: learnBothSides,
                  onChanged: (value) {
                    setState(() {
                      learnBothSides = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    MarkdownWithImageInput(
                      controller: cardQuestionTextController,
                      focusOrder: 1,
                      hintText: context.l10n.questionHint,
                      labelText: context.l10n.questionLabel,
                      imagePlacement: model.ImagePlacement.question,
                      onImageUpload: _uploadImage,
                    ),
                    const SizedBox(height: 16),
                    ValueListenableBuilder(
                      valueListenable: cardQuestionTextController,
                      builder: (context, value, _) {
                        return _GenerateAnswerButton(
                          deck: widget.deck,
                          question: value.text,
                          onAnswer: (answer, hint) {
                            cardAnswerTextController.text = answer;
                            cardHintTextController.text = hint;
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _answerInput(),
                    const SizedBox(height: 16),
                    MarkdownWithImageInput(
                      controller: cardHintTextController,
                      focusOrder: 3,
                      hintText: context.l10n.hintPrompt,
                      labelText: context.l10n.hintLabel,
                      imagePlacement: model.ImagePlacement.explanation,
                      onImageUpload: _uploadImage,
                    ),
                  ],
                ),
              ),
              CardEditActions(
                onSave: () async => _saveCard(context),
                onSaveAndAddNext: () async => _saveCard(context, addNew: true),
                isNewCard: widget.card?.id == null,
              ),
              const SizedBox(height: 24),
              Padding(
                padding: EdgeInsets.only(top: 8, bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.visibility, size: 20, color: Colors.grey),
                    SizedBox(width: 8),
                    Text(
                      'Preview',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ListenableBuilder(
                listenable: textChangeNotifier,
                builder: (context, value) => Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 0,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CardPreview(
                      cardQuestion: cardQuestionTextController.text,
                      cardAnswer: cardAnswerTextController.text,
                      cardHint: cardHintTextController.text,
                      questionImageAttached: questionImageAttached,
                      explanationImageAttached: explanationImageAttached,
                      cardId: cardId,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _answerInput() {
    return FocusTraversalOrder(
      order: const NumericFocusOrder(2),
      child: TextFormField(
        minLines: 1,
        maxLines: 4,
        controller: cardAnswerTextController,
        decoration: InputDecoration(
          hintText: context.l10n.answerHint,
          labelText: context.l10n.answerLabel,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  void _saveCard(BuildContext context, {bool addNew = false}) async {
    final cardToSave = model.Card(
      id: cardId,
      deckId: widget.deck.id!,
      question: cardQuestionTextController.text,
      answer: cardAnswerTextController.text,
      explanation: cardHintTextController.text,
      questionImageAttached: questionImageAttached,
      explanationImageAttached: explanationImageAttached,
      options: model.CardOptions(learnBothSides: learnBothSides),
    );

    await context.cardRepository
        .saveCard(cardToSave)
        .then(
          (value) => context.showInfoSnackbar(context.l10n.cardSavedMessage),
          onError: (e) =>
              context.showErrorSnackbar(context.l10n.cardSavingErrorMessage),
        );
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
      // final ImagePicker picker = ImagePicker();
      // final XFile? pickedFile =
      //     await picker.pickImage(source: ImageSource.gallery);
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
  }
}

class MarkdownWithImageInput extends StatelessWidget {
  final TextEditingController controller;
  final double focusOrder;
  final String hintText;
  final String labelText;
  final model.ImagePlacement imagePlacement;

  final Function(model.ImagePlacement) onImageUpload;

  MarkdownWithImageInput({
    required this.controller,
    required this.focusOrder,
    required this.hintText,
    required this.labelText,
    required this.imagePlacement,
    required this.onImageUpload,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        FocusTraversalOrder(
          order: NumericFocusOrder(focusOrder),
          child: TextFormField(
            maxLines: null,
            minLines: 1,
            textAlignVertical: TextAlignVertical.top,
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              labelText: labelText,
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: IconButton.filledTonal(
            onPressed: () => onImageUpload(imagePlacement),
            icon: Icon(Icons.image, size: 18),
            iconSize: 20,
            padding: EdgeInsets.all(4),
          ),
        ),
      ],
    );
  }
}

class CardEditActions extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onSaveAndAddNext;
  final bool isNewCard;

  const CardEditActions({
    super.key,
    required this.onSave,
    required this.onSaveAndAddNext,
    required this.isNewCard,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        spacing: 8.0,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OutlinedButton(
            onPressed: () => context.pop(),
            child: Text(context.ml10n.cancelButtonLabel),
          ),
          FilledButton(
            onPressed: onSave,
            child: Text(context.ml10n.saveButtonLabel),
          ),
          Visibility(
            visible: isNewCard,
            child: FilledButton(
              onPressed: onSaveAndAddNext,
              child: Text(context.l10n.saveAndNext),
            ),
          ),
        ],
      ),
    );
  }
}

class CardOptions extends StatelessWidget {
  final ValueChanged<bool> onChanged;
  final bool value;

  const CardOptions({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text(context.l10n.cardOptionDoubleSided),
          FocusTraversalOrder(
            order: const NumericFocusOrder(0),
            child: Switch(value: value, onChanged: onChanged),
          ),
        ],
      ),
    );
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
  String? _loadingType; // 'answer', 'answerHint', or null

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            onPressed: _loadingType != null
                ? null
                : () => processLoading(includeHint: false),
            icon: _loadingType == 'answer'
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.generating_tokens),
            label: Text(
              _loadingType == 'answer' ? 'Generating...' : 'Generate Answer',
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _loadingType != null
                ? null
                : () => processLoading(includeHint: true),
            icon: _loadingType == 'answerHint'
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.generating_tokens),
            label: Text(
              _loadingType == 'answerHint'
                  ? 'Generating...'
                  : 'Generate Answer & Hint',
            ),
          ),
        ],
      ),
    );
  }

  loadAnswer() async {
    final category =
        widget.deck.category ??
        await context.cloudFunctions.deckCategory(
          widget.deck.name,
          widget.deck.description ?? '',
        );
    // persist the category in case it wasn't attached to deck earlier
    if (widget.deck.category == null) {
      await context.cardRepository.saveDeck(
        widget.deck.copyWith(category: category),
      );
    }
    return await context.cloudFunctions.generateCardAnswer(
      category,
      widget.deck.name,
      widget.deck.description ?? '',
      widget.question,
    );
  }

  void processLoading({required bool includeHint}) async {
    setState(() {
      _loadingType = includeHint ? 'answerHint' : 'answer';
    });
    try {
      await loadAnswer().then(
        (result) {
          widget.onAnswer(result.answer, includeHint ? result.explanation : '');
        },
        onError: (e) {
          context.showErrorSnackbar('Error generating answer: $e');
        },
      );
    } finally {
      setState(() {
        _loadingType = null;
      });
    }
  }
}

class MarkdownPreview extends StatelessWidget {
  final TextEditingController controller;

  const MarkdownPreview(this.controller);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, _) {
        return GptMarkdown(value.text);
      },
    );
  }
}

class ImagePreview extends StatelessWidget {
  final double height;

  final model.ImagePlacement imagePlacement;

  final bool questionImageAttached;
  final bool explanationImageAttached;

  final String cardId;

  const ImagePreview({
    this.height = 200.0,
    required this.imagePlacement,
    required this.questionImageAttached,
    required this.explanationImageAttached,
    required this.cardId,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible:
          imagePlacement == model.ImagePlacement.question &&
              questionImageAttached ||
          imagePlacement == model.ImagePlacement.explanation &&
              explanationImageAttached,
      child: CardImage(
        cardId: cardId,
        placement: imagePlacement,
        height: height,
      ),
    );
  }
}

class CardPreview extends StatelessWidget {
  final String cardQuestion;
  final String cardAnswer;
  final String cardHint;
  final bool questionImageAttached;
  final bool explanationImageAttached;
  final String cardId;

  const CardPreview({
    super.key,
    required this.cardQuestion,
    required this.cardAnswer,
    required this.cardHint,
    required this.questionImageAttached,
    required this.explanationImageAttached,
    required this.cardId,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GptMarkdown(cardQuestion),
          ImagePreview(
            imagePlacement: model.ImagePlacement.question,
            questionImageAttached: questionImageAttached,
            explanationImageAttached: explanationImageAttached,
            cardId: cardId,
          ),
          const SizedBox(height: 8),
          Divider(),
          GptMarkdown(cardAnswer),
          const SizedBox(height: 8),
          if (cardHint.trim().isNotEmpty) ...[
            Divider(),
            Text(cardHint, style: Theme.of(context).textTheme.bodySmall),
            ImagePreview(
              imagePlacement: model.ImagePlacement.explanation,
              questionImageAttached: questionImageAttached,
              explanationImageAttached: explanationImageAttached,
              cardId: cardId,
            ),
          ],
        ],
      ),
    );
  }
}
