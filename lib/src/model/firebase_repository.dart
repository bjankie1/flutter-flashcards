import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

import 'cards.dart';
import 'repository.dart';

class FirebaseCardsRepository implements CardsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var logger = Logger();

  @override
  Future<Deck> addDeck(Deck deck) async {
    final docRef = await _firestore.collection('decks').add(deck.toJson());
    final newDeck = deck.copyWith(id: docRef.id);
    return newDeck;
  }

  @override
  Future<void> updateDeck(Deck deck) async {
    await _firestore.collection('decks').doc(deck.id).update(deck.toJson());
  }

  @override
  Future<List<Deck>> loadDecks() async {
    logger.i('Loading decks');
    // Check authentication state
    final user = FirebaseAuth.instance.currentUser; // Get current user
    if (user == null) {
      logger.w(
          'User not logged in while attempting to load decks.'); // Log warning
      return []; // Or throw an exception, depending on your error handling
    } else {
      logger.d('User UID: ${user.uid}'); // Log user UID if authenticated
    }
    final snapshot = await _firestore.collection('decks').get();
    return snapshot.docs.map((doc) => Deck.fromJson(doc.data())).toList();
  }

  @override
  Future<Card> addCard(Card card) async {
    logger.i('Adding card');
    var docRef = await _firestore.collection('cards').add(card.toJson());
    final newCard = card.copyWith(id: docRef.id);
    return newCard;
  }

  @override
  Future<void> deleteDeck(String deckId) async {
    logger.i('Deleting deck: $deckId');
    final batch = _firestore.batch();

    // 1. Remove deck
    batch.delete(_firestore.collection('decks').doc(deckId));

    // 2. Usuń powiązane karty
    final cardsSnapshot = await _firestore
        .collection('cards')
        .where('deckId', isEqualTo: deckId)
        .get();
    for (final doc in cardsSnapshot.docs) {
      batch.delete(doc.reference);

      // 3. Usuń powiązane CardStats
      final cardStatsSnapshot = await _firestore
          .collection('cardStats')
          .where('cardId', isEqualTo: doc.id)
          .get();
      for (final statDoc in cardStatsSnapshot.docs) {
        batch.delete(statDoc.reference);
      }

      // 4. Usuń powiązane CardAnswer
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

    // 1. Usuń kartę
    batch.delete(_firestore.collection('cards').doc(cardId));

    // 2. Usuń powiązane CardStats
    final cardStatsSnapshot = await _firestore
        .collection('cardStats')
        .where('cardId', isEqualTo: cardId)
        .get();
    for (final doc in cardStatsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // 3. Usuń powiązane CardAnswer
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
  Future<void> updateCard(Card card) async {
    await _firestore
        .collection('cards')
        .doc(card.question.text)
        .update(card.toJson());
  }
}
