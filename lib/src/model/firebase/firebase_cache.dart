import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_flashcards/src/model/cards.dart';
import 'package:flutter_flashcards/src/model/firebase/firebase_repository.dart';

/// Carts stat cache for the current user. Stores information about cards answers.
class CardsCache {
  final FirebaseFirestore _firestore;

  final User _user;

  // Cache of card stats indexed by (cardId, variant)
  final Map<(String, CardReviewVariant), CardStats> _cardStatsCache = {};

  // Cache of own and shared decks indexed by deck id
  final Map<DeckId, Deck> _decksCache = {};

  // Cache of cards indexed by card id
  final Map<String, Card> _cardsCache = {};

  // Cache of deck groups indexed by group id
  final Map<String, DeckGroup> _decksGroupsCache = {};

  CardsCache(this._firestore, this._user);

  Future<void> init() async {
    await _loadCardStats();
    await _loadDecks();
    await _loadCards();
    await _loadDeckGroups();
  }

  Future<void> _loadCardStats() async {
    final collection = _firestore
        .userCollection(cardStatsCollectionName, _user.uid)
        .withCardStatsConverter;
    final cardStats = await collection
        .get()
        .then((value) => value.docs.map((doc) => doc.data()));
    _cardStatsCache.addAll(Map.fromEntries(cardStats
        .map((stats) => MapEntry((stats.cardId, stats.variant), stats))));
  }

  Future<void> _loadDecks() async {
    final collection = _firestore
        .userCollection(decksCollectionName, _user.uid)
        .withDecksConverter;
    final decks = await collection.get();
    _decksCache.addAll(
        Map.fromEntries(decks.docs.map((doc) => MapEntry(doc.id, doc.data()))));
  }

  Future<void> _loadCards() async {
    final collection = _firestore
        .userCollection(cardsCollectionName, _user.uid)
        .withCardsConverter;
    final cards = await collection.get();
    _cardsCache.addAll(
        Map.fromEntries(cards.docs.map((doc) => MapEntry(doc.id, doc.data()))));
  }

  Future<void> _loadDeckGroups() async {
    final collection = _firestore
        .userCollection(deckGroupsCollectionName, _user.uid)
        .withDeckGroupsConverter;
    final deckGroups = await collection.get();
    _decksGroupsCache.addAll(Map.fromEntries(
        deckGroups.docs.map((doc) => MapEntry(doc.id, doc.data()))));
  }

  Map<State, int> cardsToReviewCount({String? deckGroupId, String? deckId}) {
    final cardsToReview = <State, int>{};

    return cardsToReview;
  }
}