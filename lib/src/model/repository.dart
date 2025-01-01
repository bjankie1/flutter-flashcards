import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_flashcards/src/model/user.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../fsrs/fsrs.dart';
import 'cards.dart' as model;

abstract class CardsRepository extends ChangeNotifier {
  final _log = Logger();

  final ValueNotifier<bool> _cardsUpdated = ValueNotifier<bool>(false);
  ValueListenable<bool> get cardsUpdated => _cardsUpdated;
  final ValueNotifier<bool> _decksUpdated = ValueNotifier<bool>(false);
  ValueListenable<bool> get decksUpdated => _decksUpdated;

  Future<void> saveDeck(model.Deck deck);
  Future<Iterable<model.Deck>> loadDecks();
  Future<model.Deck?> loadDeck(String deckId);
  Future<void> deleteDeck(String deckId);

  Future<Iterable<model.Card>> loadCards(String deckId);
  Future<void> saveCard(model.Card card);
  Future<void> deleteCard(String cardId);

  Future<Iterable<model.Card>> loadCardToReview({String? deckId});
  Future<Map<model.State, int>> cardsToReviewCount({String? deckId});
  Future<model.CardStats> loadCardStats(
      String cardId, model.CardReviewVariant variant);
  Future<int> getCardCount(String deckId);

  Future<void> recordCardAnswer(model.CardAnswer answer);
  Future<Iterable<model.CardAnswer>> loadAnswers(
      DateTime dayStart, DateTime dayEnd);

  @protected
  Future<void> saveCardStats(model.CardStats stats);

  Future<UserProfile?> loadUser(String userId);
  Future<void> saveUser(UserProfile user);

  Future<void> updateAllStats();

  @protected
  void notifyCardChanged() {
    _cardsUpdated.value = !_cardsUpdated.value;
    notifyListeners();
  }

  @protected
  void notifyDeckChanged() {
    _decksUpdated.value = !_decksUpdated.value;
    notifyListeners();
  }

  /// Record an answer if it hasn't been responded today.
  /// Ignores the information if it has.
  /// Calculates next review date based on FSRS algorithm
  Future<void> recordAnswer(String cardId, model.CardReviewVariant variant,
      model.Rating rating) async {
    _log.d('Recording answer for card $cardId with variant $variant');
    final stats = await loadCardStats(cardId, variant);
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
}

class InMemoryCardsRepository extends CardsRepository {
  var logger = Logger();
  final Map<String, model.Deck> _decks = {};
  final Map<String, model.Card> _cards = {};
  var _uuid = Uuid();

  @override
  Future<void> saveDeck(model.Deck deck) async {
    if (deck.id == null) {
      var deckId = deck.id!;
      deckId = _uuid.v4();
      var deckWithId = deck.withId(id: deckId);
      _decks[deckId] = deckWithId;
      return deckWithId;
    }
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
  Future<void> saveCard(model.Card card) async {
    if (card.id == null) {
      final cardId = _uuid.v4(); // Generate a UUID
      final cardWithId = card.withId(id: cardId); // Assign the UUID to the card
      _cards[cardId] = cardWithId; // Store the card using the UUID as the key
      return cardWithId;
    }
    _cards[card.id!] = card;
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
  Future<model.CardStats> loadCardStats(
      String cardId, model.CardReviewVariant variant) {
    // TODO: implement loadCardStats
    throw UnimplementedError();
  }

  @override
  Future<List<model.Card>> loadCardToReview({String? deckId}) {
    // TODO: implement loadCardToReview
    throw UnimplementedError();
  }

  @override
  Future<int> getCardCount(String deckId) {
    // TODO: implement loadCardCount
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

  @override
  Future<model.Deck> loadDeck(String deckId) {
    // TODO: implement loadDeck
    throw UnimplementedError();
  }

  @override
  Future<void> saveUser(UserProfile user) {
    // TODO: implement saveUser
    throw UnimplementedError();
  }

  @override
  Future<UserProfile?> loadUser(String userId) {
    // TODO: implement loadUser
    throw UnimplementedError();
  }

  @override
  Future<Map<model.State, int>> cardsToReviewCount({String? deckId}) {
    // TODO: implement cardCardsToReviewCount
    throw UnimplementedError();
  }

  @override
  Future<void> updateAllStats() {
    // TODO: implement updateAllStats
    throw UnimplementedError();
  }
}

extension CardRepositoryProvider on BuildContext {
  CardsRepository get cardRepository =>
      Provider.of<CardsRepository>(this, listen: false);
}
