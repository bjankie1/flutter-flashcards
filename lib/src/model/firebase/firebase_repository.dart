import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_flashcards/src/model/firebase/mapper.dart';
import 'package:logger/logger.dart';

import '../cards.dart';
import '../repository.dart';

class FirebaseCardsRepository extends CardsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var _log = Logger();

  Future<Deck> _addDeck(Deck deck) async {
    final serializer = DeckSerializer();
    final docRef = _firestore.collection('decks').doc(); // new doc ref
    await serializer.toSnapshot(deck, docRef).then(
        (value) => _log.i("Deck successfully added!"),
        onError: (e) => _log.e("Error adding deck: $e"));
    final newDeck = deck.withId(id: docRef.id);
    return newDeck;
  }

  Future<Deck> _updateDeck(Deck deck) async {
    final docRef = _firestore.collection('decks').doc(deck.id);
    await DeckSerializer().toSnapshot(deck, docRef).then(
        (value) => print("Deck successfully updated!"),
        onError: (e) => print("Error updating deck $e"));
    return deck;
  }

  @override
  Future<List<Deck>> loadDecks() async {
    _log.i('Loading decks');
    // Check authentication state
    final user = FirebaseAuth.instance.currentUser; // Get current user
    if (user == null) {
      _log.w(
          'User not logged in while attempting to load decks.'); // Log warning
      return []; // Or throw an exception, depending on your error handling
    } else {
      _log.d('User UID: ${user.uid}'); // Log user UID if authenticated
    }
    final snapshot = await _firestore.collection('decks').get();
    final serializer = DeckSerializer();
    return Future.wait(snapshot.docs
        .map((doc) async => await serializer.fromSnapshot(doc))
        .toList());
  }

  Future<Card> _addCard(Card card) async {
    _log.i('Adding card');
    final serializer = CardSerializer();
    var docRef = _firestore.collection('cards').doc();
    return serializer.toSnapshot(card, docRef).then(
        (value) => card.withId(id: docRef.id),
        onError: (e) => print("Error adding card: $e"));
  }

  Future<Card> _updateCard(Card card) async {
    final docRef = _firestore.collection('cards').doc(card.id);
    final serializer = CardSerializer();
    await serializer.toSnapshot(card, docRef).then(
        (value) => print("Card successfully updated!"),
        onError: (e) => print("Error updating card $e"));
    return card;
  }

  @override
  Future<void> deleteDeck(String deckId) async {
    _log.i('Deleting deck: $deckId');
    final batch = _firestore.batch();
    batch.delete(_firestore.collection('decks').doc(deckId));
    final cardsSnapshot = await _firestore
        .collection('cards')
        .where('deckId', isEqualTo: deckId)
        .get();
    for (final doc in cardsSnapshot.docs) {
      batch.delete(doc.reference);
      final cardStatsSnapshot = await _firestore
          .collection('cardStats')
          .where('cardId', isEqualTo: doc.id)
          .get();
      for (final statDoc in cardStatsSnapshot.docs) {
        batch.delete(statDoc.reference);
      }
      final cardAnswerSnapshot = await _firestore
          .collection('cardAnswers')
          .where('cardId', isEqualTo: doc.id)
          .get();
      for (final answerDoc in cardAnswerSnapshot.docs) {
        batch.delete(answerDoc.reference);
      }
    }

    await batch.commit();
  }

  @override
  Future<void> deleteCard(String cardId) async {
    final batch = _firestore.batch();
    batch.delete(_firestore.collection('cards').doc(cardId));
    final cardStatsSnapshot = await _firestore
        .collection('cardStats')
        .where('cardId', isEqualTo: cardId)
        .get();
    for (final doc in cardStatsSnapshot.docs) {
      batch.delete(doc.reference);
    }
    final cardAnswerSnapshot = await _firestore
        .collection('cardAnswers')
        .where('cardId', isEqualTo: cardId)
        .get();
    for (final doc in cardAnswerSnapshot.docs) {
      batch.delete(doc.reference);
    }
    return batch.commit();
  }

  @override
  Future<List<Card>> loadCards(String deckId) async {
    final snapshot = await _firestore
        .collection('cards')
        .where('deckId', isEqualTo: deckId)
        .get();
    final serializer = CardSerializer();
    return Future.wait(
            snapshot.docs.map((doc) => serializer.fromSnapshot(doc)).toList())
        .then((value) => value,
            onError: (e) => print("Error loading cards: $e"));
  }

  @override
  Future<Card> saveCard(Card card) {
    if (card.id == null) {
      return _addCard(card);
    } else {
      return _updateCard(card);
    }
  }

  @override
  Future<Deck> saveDeck(Deck deck) {
    if (deck.id == null) {
      return _addDeck(deck);
    } else {
      return _updateDeck(deck);
    }
  }

  @override
  Future<CardStats> loadCardStats(String cardId) async {
    final docRef = _firestore.collection('cards_stats').doc(cardId);

    final serializer = CardStatsSerializer();
    final snapshot = await docRef.get();
    if (snapshot.exists) {
      return await serializer.fromSnapshot(snapshot).then((value) => value,
          onError: (e) => print("Error loading card stats: $e"));
    }
    return CardStats(cardId: cardId);
  }

  @override
  Future<void> loadCardToReview(String deckId) async {
    final snapshot = await _firestore
        .collection('cards')
        .where('deckId', isEqualTo: deckId)
        .where('nextReviewDate', isLessThanOrEqualTo: DateTime.now())
        .get();
    final serializer = CardSerializer();
    return Future.wait(
            snapshot.docs.map((doc) => serializer.fromSnapshot(doc)).toList())
        .then((value) => value,
            onError: (e) => print("Error loading cards: $e"));
  }

  @override
  Future<void> saveCardStats(CardStats stats) async {
    final docRef = _firestore.collection('cards_stats').doc(stats.cardId);
    final serializer = CardStatsSerializer();
    await serializer.toSnapshot(stats, docRef).then(
        (value) => print("Review answer successfully recorded!"),
        onError: (e) => print("Error recording review answer: $e"));
  }
}
