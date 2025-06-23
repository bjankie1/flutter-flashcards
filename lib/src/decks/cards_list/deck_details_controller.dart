import 'package:flutter/material.dart';
import '../../model/cards.dart' as model;
import '../../model/repository.dart';
import 'package:logger/logger.dart';
import 'package:flutter_flashcards/src/genkit/functions.dart';

class DeckDetailsController extends ChangeNotifier {
  final Logger _log = Logger();
  final CardsRepository repository;
  final String deckId;
  final CloudFunctions cloudFunctions;

  model.Deck? _deck;
  int _cardCount = 0;
  model.DeckCategory? _category;
  bool _loading = true;
  bool _error = false;

  DeckDetailsController({
    required this.repository,
    required this.deckId,
    required this.cloudFunctions,
  }) {
    _loadDeck();
    _loadCardCount();
  }

  model.Deck? get deck => _deck;
  int get cardCount => _cardCount;
  model.DeckCategory? get category => _category;
  bool get loading => _loading;
  bool get error => _error;

  Future<void> _loadDeck() async {
    try {
      _loading = true;
      notifyListeners();
      final loadedDeck = await repository.loadDeck(deckId);
      _deck = loadedDeck;
      _category = loadedDeck?.category;
      _loading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _log.e('Error loading deck', error: e, stackTrace: stackTrace);
      _loading = false;
      _error = true;
      notifyListeners();
    }
  }

  Future<void> _loadCardCount() async {
    try {
      final count = await repository.getCardCount(deckId);
      _cardCount = count;
      notifyListeners();
    } catch (e, stackTrace) {
      _log.e('Error loading card count', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> updateDeckName(String name) async {
    if (_deck == null) return;
    var newDeck = _deck!.copyWith(name: name);
    try {
      final category = await cloudFunctions.deckCategory(
        name,
        newDeck.description ?? '',
      );
      newDeck = newDeck.copyWith(category: category);
      _category = category;
    } catch (e, stackTrace) {
      _log.e('Error saving deck name', error: e, stackTrace: stackTrace);
    }
    await repository.saveDeck(newDeck);
    _deck = newDeck;
    notifyListeners();
  }

  Future<void> updateDeckDescription(String description) async {
    if (_deck == null) return;
    var newDeck = _deck!.copyWith(description: description);
    try {
      final category = await cloudFunctions.deckCategory(
        newDeck.name,
        description,
      );
      newDeck = newDeck.copyWith(category: category);
      _category = category;
    } catch (e, stackTrace) {
      _log.e('Error saving deck description', error: e, stackTrace: stackTrace);
    }
    await repository.saveDeck(newDeck);
    _deck = newDeck;
    notifyListeners();
  }
}
