import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/language_selector.dart';
import 'package:flutter_flashcards/src/common/snackbar_messaging.dart';
import 'package:flutter_flashcards/src/common/themes.dart';
import 'package:flutter_flashcards/src/model/cards.dart' as model;
import 'package:flutter_flashcards/src/model/repository.dart';
import 'package:flutter_flashcards/src/widgets.dart';

import "../common/build_context_extensions.dart";
import '../genkit/functions.dart';
import '../layout/base_layout.dart';

class DeckGeneratePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseLayout(
        title: Text(context.l10n.deckGeneration),
        child: GenerationControllerWidget());
  }
}

class GenerationControllerWidget extends StatefulWidget {
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
        ? GeneratedCardsSelectWidget(cardProposals: proposals)
        : Card(
            child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FocusTraversalGroup(
              policy: OrderedTraversalPolicy(),
              child: Column(
                children: [
                  LanguageAutocompletePicker(
                    onLanguageSelected: (lang) =>
                        {frontLanguage = lang['name']!},
                    label: context.l10n.backCardLabel,
                  ),
                  LanguageAutocompletePicker(
                    onLanguageSelected: (lang) =>
                        {backLanguage = lang['name']!},
                    label: context.l10n.frontCardLabel,
                  ),
                  TextFormField(
                    controller: textController,
                    maxLines: 20,
                    minLines: 20,
                    decoration: InputDecoration(
                        label: Text(context.l10n.inputText),
                        border: OutlineInputBorder(),
                        helperText: context.l10n.inputTextForGenerator),
                  ),
                  isLoading
                      ? Center(child: CircularProgressIndicator())
                      : FilledButton(
                          onPressed: () async => processText(context),
                          child: Text(context.l10n.generateCards))
                ],
              ),
            ),
          ));
  }

  Future<void> processText(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    try {
      final result = await context.cloudFunctions.generateCardsForText(
          frontLanguage, backLanguage, textController.text);
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

  GeneratedCardsSelectWidget({super.key, required this.cardProposals});

  @override
  State<GeneratedCardsSelectWidget> createState() =>
      _GeneratedCardsSelectWidgetState();
}

class _GeneratedCardsSelectWidgetState
    extends State<GeneratedCardsSelectWidget> {
  final Set<int> singleSided = {};
  final Set<int> skipped = {};
  bool newDeck = true;

  @override
  Widget build(BuildContext context) {
    final sortedProposals = widget.cardProposals.toList()
      ..sort((a, b) => a.front.compareTo(b.front));
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Card(
            child: Row(spacing: 8.0, children: [
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
                  child: Text(context.l10n.questionLabel,
                      style: context.textTheme.headlineSmall)),
              Expanded(
                  child: Text(context.l10n.answerLabel,
                      style: context.textTheme.headlineSmall)),
            ]),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: sortedProposals.length,
            padding: const EdgeInsets.all(8.0),
            itemBuilder: (context, index) {
              final card = sortedProposals.elementAt(index);
              return Card(
                child: Row(spacing: 8.0, children: [
                  IconButton(
                    isSelected: !skipped.contains(index),
                    onPressed: () => toggleSkipCard(index),
                    icon: Icon(
                      Icons.cancel,
                      color: Colors.red,
                    ),
                    selectedIcon: Icon(
                      Icons.check,
                      color: Colors.green,
                    ),
                  ),
                  IconButton(
                    isSelected: !singleSided.contains(index),
                    onPressed: () => changeCardMode(index),
                    icon: Icon(Icons.swap_vert),
                    selectedIcon: Icon(Icons.swap_vert_circle),
                  ),
                  Expanded(child: Text(card.front)),
                  Expanded(child: Text(card.back)),
                ]),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: RadioListTile(
                        title: Text(context.l10n.createNewDeck),
                        value: true,
                        groupValue: newDeck,
                        onChanged: toggleNewVsExisting),
                  ),
                  Expanded(
                    child: RadioListTile(
                        title: Text(context.l10n.addToExistingDeck),
                        value: false,
                        groupValue: newDeck,
                        onChanged: toggleNewVsExisting),
                  ),
                ],
              ),
              newDeck
                  ? CreateNewDeckWidget(
                      onCreateNewDeck: (name, description) =>
                          createNewDeck(name, description, sortedProposals),
                    )
                  : RepositoryLoader(
                      fetcher: (repository) => repository.loadDecks(),
                      builder: (context, decks, _) {
                        return AddGeneratedCardsToExistingDeckWidget(
                          onAddToExistingDeck: (deckId) =>
                              addToExistingDeck(deckId, sortedProposals),
                          decks: decks,
                        );
                      }),
            ],
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
            List.generate(widget.cardProposals.length, (index) => index));
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

  createNewDeck(
      String name, String description, List<FrontBack> proposals) async {
    if (proposals.length == skipped.length) return;
    final repo = context.cardRepository;
    final deck =
        model.Deck(id: repo.nextDeckId(), name: name, description: description);
    await repo.saveDeck(deck);
    await addToExistingDeck(deck.id!, proposals);
  }

  addToExistingDeck(model.DeckId deckId, List<FrontBack> proposals) async {
    final repo = context.cardRepository;
    int index = 0;
    await Future.wait(proposals.map((proposal) async {
      final isSkipped = skipped.contains(index);
      if (!isSkipped) {
        final isSingleSided = singleSided.contains(index);
        final cardId = repo.nextCardId();
        final deckCard = model.Card(
            deckId: deckId,
            question: proposal.front,
            answer: proposal.back,
            options: model.CardOptions(learnBothSides: !isSingleSided),
            id: cardId);
        await context.cardRepository.saveCard(deckCard);
      }
      index++;
    })).then((_) {
      context.showInfoSnackbar('Cards saved');
      Navigator.pop(context);
    }, onError: (_) {
      context.showErrorSnackbar('Error saving cards');
    });
  }

  void toggleAllSelected() {}

  void toggleNewVsExisting(bool? value) {
    setState(() {
      newDeck = !newDeck;
    });
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
              label: Text(context.l10n.deckName), border: OutlineInputBorder()),
        ),
        TextFormField(
          controller: deckDescriptionController,
          decoration: InputDecoration(
              label: Text(context.l10n.deckDescription),
              border: OutlineInputBorder()),
        ),
        FilledButton(
            onPressed: () => onCreateNewDeck(
                deckNameController.text, deckDescriptionController.text),
            child: Text('Create deck')),
      ],
    );
  }
}

class AddGeneratedCardsToExistingDeckWidget extends StatefulWidget {
  final Function(model.DeckId deckId) onAddToExistingDeck;
  final Iterable<model.Deck> decks;

  AddGeneratedCardsToExistingDeckWidget(
      {super.key, required this.onAddToExistingDeck, required this.decks});

  @override
  State<AddGeneratedCardsToExistingDeckWidget> createState() =>
      _AddGeneratedCardsToExistingDeckWidgetState();
}

class _AddGeneratedCardsToExistingDeckWidgetState
    extends State<AddGeneratedCardsToExistingDeckWidget> {
  model.DeckId? selectedDeck;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8.0,
      children: [
        Autocomplete(
          optionsBuilder: (textEditingValue) {
            if (textEditingValue.text == '') {
              return const Iterable<model.Deck>.empty();
            }
            return widget.decks.where((model.Deck deck) {
              return deck.name
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
            });
          },
          onSelected: (model.Deck selection) {
            setState(() {
              selectedDeck = selection.id!;
            });
          },
          displayStringForOption: (deck) => deck.name,
          fieldViewBuilder: (BuildContext context,
                  TextEditingController textEditingController,
                  FocusNode focusNode,
                  VoidCallback onFieldSubmitted) =>
              TextFormField(
            controller: textEditingController,
            focusNode: focusNode,
            decoration: InputDecoration(labelText: context.l10n.deckSelect),
            onFieldSubmitted: (value) {
              onFieldSubmitted();
            },
          ),
          optionsViewBuilder: (BuildContext context,
                  AutocompleteOnSelected<model.Deck> onSelected,
                  Iterable<model.Deck> options) =>
              Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4.0,
              child: SizedBox(
                height: 200.0,
                child: ListView.builder(
                  padding: EdgeInsets.all(8.0),
                  itemCount: options.length,
                  itemBuilder: (BuildContext context, int index) {
                    final model.Deck option = options.elementAt(index);
                    return GestureDetector(
                      onTap: () {
                        onSelected(option);
                      },
                      child: ListTile(
                        title: Text(option.name),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        FilledButton(
          onPressed: () => selectedDeck != null
              ? widget.onAddToExistingDeck(selectedDeck!)
              : null,
          child: Text(context.l10n.addToDeck),
        ),
      ],
    );
  }
}