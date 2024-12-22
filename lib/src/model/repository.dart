import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../fsrs/fsrs.dart';
import 'cards.dart' as model;

abstract class CardsRepository {
  final _log = Logger();

  Future<model.Deck> saveDeck(model.Deck deck);
  Future<List<model.Deck>> loadDecks();
  Future<void> deleteDeck(String deckId);
  Future<List<model.Card>> loadCards(String deckId);
  Future<model.Card> saveCard(model.Card card);
  Future<void> deleteCard(String cardId);
  Future<List<model.Card>> loadCardToReview(String deckId);
  Future<model.CardStats> loadCardStats(String cardId);
  Future<int> getCardCount(String deckId);
  Future<int> getCardToReviewCount(String deckId);

  Future<void> recordCardAnswer(model.CardAnswer answer);
  Future<List<model.CardAnswer>> loadAnswers(
      DateTime dayStart, DateTime dayEnd);

  @protected
  Future<void> saveCardStats(model.CardStats stats);

  /// Record an answer if it hasn't been responded today.
  /// Ignores the information if it has.
  /// Calculates next review date based on FSRS algorithm
  Future<void> recordAnswer(String cardId, model.Rating rating) async {
    final stats = await loadCardStats(cardId);
    if (stats.lastReview != null &&
        stats.lastReview!.difference(DateTime.now()).inDays == 0 &&
        stats.nextReviewDate != null &&
        stats.nextReviewDate!.difference(DateTime.now()).inDays > 0) {
      _log.i('Card $cardId has been already reviewed today');
      return;
    }
    final f = FSRS();
    final scheduled = f.repeat(stats, DateTime.now())[rating]?.card;
    _log.i('Next schedule for card $cardId is ${scheduled?.nextReviewDate}');
    await saveCardStats(scheduled!);
  }

  Future<model.CardReviewStats> loadCardReviewStats(DateTime day) {}

  // var _listeners = <VoidCallback>[];

  // bool _disposed = false;

  // @override
  // void addListener(VoidCallback listener) {
  //   if (_disposed) {
  //     throw StateError('addListener called after dispose');
  //   }
  //   _listeners.add(listener);
  // }

  // @override
  // void dispose() {
  //   super.dispose();
  //   _disposed = true;
  // }

  // @override
  // bool get hasListeners => _listeners.isNotEmpty;

  // @override
  // void notifyListeners() {
  //   for (var element in _listeners) {
  //     element();
  //   }
  // }

  // @override
  // void removeListener(VoidCallback listener) {
  //   _listeners.remove(listener);
  // }
}

class InMemoryCardsRepository extends CardsRepository {
  var logger = Logger();
  final Map<String, model.Deck> _decks = {};
  final Map<String, model.Card> _cards = {};
  var _uuid = Uuid();

  @override
  Future<model.Deck> saveDeck(model.Deck deck) async {
    if (deck.id == null) {
      var deckId = deck.id!;
      deckId = _uuid.v4();
      var deckWithId = deck.withId(id: deckId);
      _decks[deckId] = deckWithId;
      return deckWithId;
    }
    return _decks[deck.id!] = deck;
  }

  @override
  Future<List<model.Deck>> loadDecks() async {
    logger.i('Loading decks from memory');
    return _decks.values.toList();
  }

  @override
  Future<void> deleteDeck(String deckId) async {
    _decks.remove(deckId);
    _cards.removeWhere((key, value) => value.deckId == deckId);
  }

  @override
  Future<model.Card> saveCard(model.Card card) async {
    if (card.id == null) {
      final cardId = _uuid.v4(); // Generate a UUID
      final cardWithId = card.withId(id: cardId); // Assign the UUID to the card
      _cards[cardId] = cardWithId; // Store the card using the UUID as the key
      return cardWithId;
    }
    _cards[card.id!] = card;
    return card;
  }

  @override
  Future<void> deleteCard(String cardId) async {
    _cards.remove(cardId);
  }

  @override
  Future<List<model.Card>> loadCards(String deckId) async {
    return Future.value(
        _cards.values.where((card) => card.deckId == deckId).toList());
  }

  @override
  Future<void> saveCardStats(model.CardStats stats) {
    // TODO: implement _saveCardStats
    throw UnimplementedError();
  }

  @override
  Future<model.CardStats> loadCardStats(String cardId) {
    // TODO: implement loadCardStats
    throw UnimplementedError();
  }

  @override
  Future<List<model.Card>> loadCardToReview(String deckId) {
    // TODO: implement loadCardToReview
    throw UnimplementedError();
  }

  @override
  Future<int> getCardCount(String deckId) {
    // TODO: implement loadCardCount
    throw UnimplementedError();
  }

  @override
  Future<int> getCardToReviewCount(String deckId) {
    // TODO: implement getCardCountToReview
    throw UnimplementedError();
  }

  @override
  Future<List<model.CardAnswer>> loadAnswers(
      DateTime dayStart, DateTime dayEnd) {
    // TODO: implement loadAnswers
    throw UnimplementedError();
  }

  @override
  Future<void> recordCardAnswer(model.CardAnswer answer) {
    // TODO: implement recordCardAnswer
    throw UnimplementedError();
  }
}
