import 'package:cloud_firestore/cloud_firestore.dart';

import 'cards.dart';
import 'repository.dart';

class FirebaseCardsRepository implements CardsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> saveDeck(Deck deck) async {
    await _firestore.collection('decks').doc(deck.name).set(deck.toJson());
  }

  @override
  Future<List<Deck>> loadDecks() async {
    final snapshot = await _firestore.collection('decks').get();
    return snapshot.docs.map((doc) => Deck.fromJson(doc.data())).toList();
  }

  @override
  Future<void> addCard(Card card) async {
    // Generuj unikalne ID dla karty, jeśli nie jest już zdefiniowane
    final cardId = card.question.text;

    await _firestore.collection('cards').doc(cardId).set(card.toJson());
  }

  @override
  Future<void> deleteDeck(String deckId) async {
    final batch = _firestore.batch();

    // 1. Usuń talię
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
