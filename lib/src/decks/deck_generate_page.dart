import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/assets.dart';
import 'package:flutter_flashcards/src/common/language_selector.dart';
import 'package:flutter_flashcards/src/common/snackbar_messaging.dart';
import 'package:flutter_flashcards/src/common/themes.dart';
import 'package:flutter_flashcards/src/model/cards.dart' as model;
import 'package:flutter_flashcards/src/model/repository.dart';
import 'package:flutter_flashcards/src/widgets.dart';
import 'package:gpt_markdown/gpt_markdown.dart';

import "../common/build_context_extensions.dart";
import '../genkit/functions.dart';
import '../layout/base_layout.dart';

class DeckGeneratePage extends StatelessWidget {
  final model.DeckId? deckId;

  const DeckGeneratePage({super.key, this.deckId});

  @override
  Widget build(BuildContext context) {
    return RepositoryLoader(
      fetcher: (repository) =>
          deckId == null ? Future.value(null) : repository.loadDeck(deckId!),
      builder: (context, deck, _) => BaseLayout(
        title: GptMarkdown(
          deck == null
              ? context.l10n.deckGeneration
              : context.l10n.generateCardsForDeck(deck.name),
        ),
        child: GenerationControllerWidget(deckId: deckId),
      ),
    );
  }
}

class GenerationControllerWidget extends StatefulWidget {
  final model.DeckId? deckId;

  const GenerationControllerWidget({super.key, this.deckId});

  @override
  State<GenerationControllerWidget> createState() =>
      _GenerationControllerWidgetState();
}

class _GenerationControllerWidgetState
    extends State<GenerationControllerWidget> {
  String backLanguage = '';

  String frontLanguage = '';

  final textController = TextEditingController();

  bool isLoading = false;

  Iterable<FrontBack> proposals = Iterable.empty();

  @override
  void dispose() {
    super.dispose();
    textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return proposals.isNotEmpty
        ? GeneratedCardsSelectWidget(
            cardProposals: proposals,
            deckId: widget.deckId,
          )
        : Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FocusTraversalGroup(
                policy: OrderedTraversalPolicy(),
                child: Column(
                  children: [
                    LanguageAutocompletePicker(
                      onLanguageSelected: (lang) => {
                        frontLanguage = lang['name']!,
                      },
                      label: context.l10n.backCardLabel,
                    ),
                    LanguageAutocompletePicker(
                      onLanguageSelected: (lang) => {
                        backLanguage = lang['name']!,
                      },
                      label: context.l10n.frontCardLabel,
                    ),
                    TextFormField(
                      controller: textController,
                      maxLines: 20,
                      minLines: 20,
                      decoration: InputDecoration(
                        label: Text(context.l10n.inputText),
                        border: OutlineInputBorder(),
                        helperText: context.l10n.inputTextForGenerator,
                      ),
                    ),
                    isLoading
                        ? Center(child: CircularProgressIndicator())
                        : FilledButton(
                            onPressed: () async => processText(context),
                            child: IntrinsicWidth(
                              child: Row(
                                children: [
                                  ImageIcon(gemini),
                                  const SizedBox(width: 8.0),
                                  Text(context.l10n.generateCards),
                                ],
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          );
  }

  Future<void> processText(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    try {
      final result = await context.cloudFunctions.generateCardsForText(
        frontLanguage,
        backLanguage,
        textController.text,
      );
      setState(() {
        proposals = result;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}

class GeneratedCardsSelectWidget extends StatefulWidget {
  final Iterable<FrontBack> cardProposals;

  final model.DeckId? deckId;

  bool get newDeck => deckId == null;

  GeneratedCardsSelectWidget({
    super.key,
    required this.cardProposals,
    this.deckId,
  });

  @override
  State<GeneratedCardsSelectWidget> createState() =>
      _GeneratedCardsSelectWidgetState();
}

class _GeneratedCardsSelectWidgetState
    extends State<GeneratedCardsSelectWidget> {
  final Set<int> singleSided = {};
  final Set<int> skipped = {};

  @override
  Widget build(BuildContext context) {
    final sortedProposals = widget.cardProposals.toList()
      ..sort((a, b) => a.front.compareTo(b.front));
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Card(
            child: Row(
              spacing: 8.0,
              children: [
                IconButton(
                  isSelected: skipped.isEmpty,
                  onPressed: toggleAllSelected,
                  icon: Icon(Icons.check),
                  selectedIcon: Icon(Icons.check_outlined),
                ),
                IconButton(
                  isSelected: singleSided.isEmpty,
                  onPressed: toggleAllDoubleSided,
                  icon: Icon(Icons.swap_vert),
                  selectedIcon: Icon(Icons.swap_vert_circle),
                ),
                Expanded(
                  child: Text(
                    context.l10n.questionLabel,
                    style: context.textTheme.headlineSmall,
                  ),
                ),
                Expanded(
                  child: Text(
                    context.l10n.answerLabel,
                    style: context.textTheme.headlineSmall,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: sortedProposals.length,
            padding: const EdgeInsets.all(8.0),
            itemBuilder: (context, index) {
              final card = sortedProposals.elementAt(index);
              return Card(
                child: Row(
                  spacing: 8.0,
                  children: [
                    IconButton(
                      isSelected: !skipped.contains(index),
                      onPressed: () => toggleSkipCard(index),
                      icon: Icon(Icons.cancel, color: Colors.red),
                      selectedIcon: Icon(Icons.check, color: Colors.green),
                    ),
                    IconButton(
                      isSelected: !singleSided.contains(index),
                      onPressed: () => changeCardMode(index),
                      icon: Icon(Icons.swap_vert),
                      selectedIcon: Icon(Icons.swap_vert_circle),
                    ),
                    Expanded(child: Text(card.front)),
                    Expanded(child: Text(card.back)),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: widget.newDeck
              ? CreateNewDeckWidget(
                  onCreateNewDeck: (name, description) =>
                      createNewDeck(name, description, sortedProposals),
                )
              : FilledButton(
                  onPressed: () =>
                      addToExistingDeck(widget.deckId!, sortedProposals),
                  child: Text(context.l10n.addCardsToDeck),
                ),
        ),
      ],
    );
  }

  void changeCardMode(int index) {
    final isSingleSided = singleSided.contains(index);
    setState(() {
      if (isSingleSided) {
        singleSided.remove(index);
      } else {
        singleSided.add(index);
      }
    });
  }

  void toggleAllDoubleSided() {
    setState(() {
      if (singleSided.isEmpty) {
        singleSided.addAll(
          List.generate(widget.cardProposals.length, (index) => index),
        );
      } else {
        singleSided.clear();
      }
    });
  }

  void toggleSkipCard(int index) {
    setState(() {
      if (skipped.contains(index)) {
        skipped.remove(index);
      } else {
        skipped.add(index);
      }
    });
  }

  void toggleAllSelected() {}

  Future<void> createNewDeck(
    String name,
    String description,
    List<FrontBack> proposals,
  ) async {
    if (proposals.length == skipped.length) return;
    final repo = context.cardRepository;
    final deck = model.Deck(
      id: repo.nextDeckId(),
      name: name,
      description: description,
    );
    await repo.saveDeck(deck);
    await addToExistingDeck(deck.id!, proposals);
  }

  Future<void> addToExistingDeck(
    model.DeckId deckId,
    List<FrontBack> proposals,
  ) async {
    final repo = context.cardRepository;
    int index = 0;
    await Future.wait(
      proposals.map((proposal) async {
        final isSkipped = skipped.contains(index);
        if (!isSkipped) {
          final isSingleSided = singleSided.contains(index);
          final cardId = repo.nextCardId();
          final deckCard = model.Card(
            deckId: deckId,
            question: proposal.front,
            answer: proposal.back,
            options: model.CardOptions(learnBothSides: !isSingleSided),
            id: cardId,
          );
          await context.cardRepository.saveCard(deckCard);
        }
        index++;
      }),
    ).then(
      (_) {
        context.showInfoSnackbar('Cards saved');
        Navigator.pop(context);
      },
      onError: (_) {
        context.showErrorSnackbar('Error saving cards');
      },
    );
  }
}

class CreateNewDeckWidget extends StatelessWidget {
  final deckNameController = TextEditingController();

  final deckDescriptionController = TextEditingController();

  final Function(String name, String description) onCreateNewDeck;

  CreateNewDeckWidget({super.key, required this.onCreateNewDeck});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8.0,
      children: [
        TextFormField(
          controller: deckNameController,
          decoration: InputDecoration(
            label: Text(context.l10n.deckName),
            border: OutlineInputBorder(),
          ),
        ),
        TextFormField(
          controller: deckDescriptionController,
          decoration: InputDecoration(
            label: Text(context.l10n.deckDescription),
            border: OutlineInputBorder(),
          ),
        ),
        FilledButton(
          onPressed: () => onCreateNewDeck(
            deckNameController.text,
            deckDescriptionController.text,
          ),
          child: Text('Create deck'),
        ),
      ],
    );
  }
}
