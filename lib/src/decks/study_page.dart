import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/model/repository.dart';
import 'package:provider/provider.dart';
import '../base_layout.dart';
import 'package:gpt_markdown/gpt_markdown.dart';

import '../model/cards.dart' as model;

class StudyCardsPage extends StatefulWidget {
  final List<model.Card> cards;

  const StudyCardsPage({super.key, required this.cards});

  @override
  State<StatefulWidget> createState() => _StudyCardsPageState();
}

class _StudyCardsPageState extends State<StudyCardsPage> {
  int _currentCardIndex = 0;

  bool _answered = false;

  model.Rating? _reviewRate;

  @override
  Widget build(BuildContext context) {
    final repository = Provider.of<CardsRepository>(context, listen: false);
    final card = currentCard();
    if (card == null) {
      return BaseLayout(
        title: 'No cards to learn',
        currentPage: PageIndex.learning,
        child: Text('No cards to learn'),
      );
    }
    return BaseLayout(
      title: 'Learning card $_currentCardIndex of ${widget.cards.length}',
      currentPage: PageIndex.learning,
      child: Card(
        child: Column(
          children: [
            Expanded(
              child: SizedBox(
                width: 800,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TexMarkdown(card.question.text),
                ),
              ),
            ),
            Divider(),
            if (!_answered)
              ElevatedButton(
                child: Text("Show answer"),
                onPressed: () => setState(() => _answered = true),
              ),
            if (_answered)
              Expanded(
                child: SizedBox(
                  width: 800,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TexMarkdown(card.answer),
                  ),
                ),
              ),
            if (_answered)
              SegmentedButton<model.Rating>(
                emptySelectionAllowed: true,
                segments: [
                  ButtonSegment<model.Rating>(
                      value: model.Rating.again, label: Text('No idea')),
                  ButtonSegment<model.Rating>(
                      value: model.Rating.hard, label: Text('Hard')),
                  ButtonSegment<model.Rating>(
                      value: model.Rating.good, label: Text('Good')),
                  ButtonSegment<model.Rating>(
                      value: model.Rating.easy, label: Text('Easy')),
                ],
                selected: _reviewRate != null ? {_reviewRate!} : {},
                onSelectionChanged: (value) async {
                  setState(() => _reviewRate = value.first);
                  await updateStats(repository, _reviewRate!, card);
                  nextCard();
                },
              ),
          ],
        ),
      ),
    );
  }

  model.Card? currentCard() {
    if (widget.cards.isEmpty) return null;
    return widget.cards[_currentCardIndex];
  }

  void nextCard() {
    setState(() {
      _answered = false;
      _reviewRate = null;
      _currentCardIndex = (_currentCardIndex + 1) % widget.cards.length;
    });
  }

  updateStats(
      CardsRepository repository, model.Rating rating, model.Card card) async {
    try {
      await repository.recordAnswer(card.id!, rating);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Answer recorded')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Text('Error recording answer'),
            ],
          )));
    }
  }
}
