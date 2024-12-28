import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_flashcards/src/model/firebase/mapper.dart';
import 'package:flutter_flashcards/src/model/user.dart';
import 'package:logger/logger.dart';

import '../cards.dart';
import '../repository.dart';

class FirebaseCardsRepository extends CardsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var _log = Logger();
  final _user = FirebaseAuth.instance.currentUser; // Get current user

  Future<Deck> _addDeck(Deck deck) async {
    _log.i("Saving new deck ${deck.name}");
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
    if (_user == null) {
      _log.w(
          'User not logged in while attempting to load decks.'); // Log warning
      return []; // Or throw an exception, depending on your error handling
    } else {
      _log.d('User UID: ${_user.uid}'); // Log user UID if authenticated
    }
    try {
      final snapshot = await _firestore
          .collection('decks')
          .where('userId', isEqualTo: _user.uid)
          .get();
      final serializer = DeckSerializer();
      return await Future.wait(snapshot.docs
          .map((doc) async => await serializer.fromSnapshot(doc))
          .toList());
    } on Exception catch (e) {
      _log.w('Error loading decks: $e', error: e);
      rethrow;
    }
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
          .collection('cards')
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

    await batch.commit().whenComplete(() => notifyDeckChanged());
  }

  @override
  Future<void> deleteCard(String cardId) async {
    final batch = _firestore.batch();
    batch.delete(_firestore.collection('cards').doc(cardId));
    final cardStatsSnapshot = await _firestore
        .collection('cards')
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
    return await batch.commit().whenComplete(() => notifyCardChanged());
  }

  @override
  Future<List<Card>> loadCards(String deckId) async {
    if (_user == null) {
      _log.w(
          'User not logged in while attempting to load decks.'); // Log warning
      return [];
    }

    final snapshot = await _firestore
        .collection('cards')
        .where('deckId', isEqualTo: deckId)
        .where('userId', isEqualTo: _user.uid)
        .get();
    final serializer = CardSerializer();
    return Future.wait(
            snapshot.docs.map((doc) => serializer.fromSnapshot(doc)).toList())
        .then((value) => value,
            onError: (e) => print("Error loading cards: $e"));
  }

  @override
  Future<Card> saveCard(Card card) async {
    if (card.id == null) {
      return await _addCard(card).whenComplete(() => notifyCardChanged());
    } else {
      return await _updateCard(card).whenComplete(() => notifyCardChanged());
    }
  }

  @override
  Future<Deck> saveDeck(Deck deck) async {
    if (deck.id == null) {
      return await _addDeck(deck).whenComplete(() => notifyDeckChanged());
    } else {
      return await _updateDeck(deck).whenComplete(() => notifyDeckChanged());
    }
  }

  @override
  Future<CardStats> loadCardStats(String cardId) async {
    final docRef = _firestore.collection('cards').doc(cardId);

    final serializer = CardStatsSerializer();
    final snapshot = await docRef.get();
    if (snapshot.exists) {
      return await serializer.fromSnapshot(snapshot).then((value) => value,
          onError: (e) => print("Error loading card stats: $e"));
    }
    return CardStats(cardId: cardId);
  }

  Future<List<Card>> _cardIdsToReview(String deckId) async {
    if (_user == null) {
      _log.w(
          'User not logged in while attempting to load decks.'); // Log warning
      return [];
    }

    try {
      final snapshot = await _firestore
          .collection('cards')
          .where('deckId', isEqualTo: deckId)
          .where('userId', isEqualTo: _user.uid)
          .get();
      if (snapshot.docs.isEmpty) {
        _log.d('deck $deckId is empty');
        return [];
      }
      final cardIds = snapshot.docs.map((doc) => doc.id).toList();
      _log.d('deck $deckId has ${cardIds.length} cards');
      final statsSerializer = CardStatsSerializer();
      _log.d('Loading stats for cards');
      final stats = await Future.wait(
          snapshot.docs.map((doc) => statsSerializer.fromSnapshot(doc)));
      final cardsIdsToReview = stats
          .where((c) =>
              c.nextReviewDate == null ||
              c.nextReviewDate!.isBefore(DateTime.now()))
          .map((c) => c.cardId)
          .toSet();
      final serializer = CardSerializer();
      return await Future.wait(snapshot.docs
          .where((doc) => cardsIdsToReview.contains(doc.id))
          .map((doc) => serializer.fromSnapshot(doc))
          .toList());
    } on Exception catch (e) {
      _log.w('Error querying cards to review: $e');
      rethrow;
    }
  }

  @override
  Future<List<Card>> loadCardToReview(String deckId) async {
    return await _cardIdsToReview(deckId);
  }

  @override
  Future<void> saveCardStats(CardStats stats) async {
    final docRef = _firestore.collection('cards').doc(stats.cardId);
    final serializer = CardStatsSerializer();
    await serializer.toSnapshot(stats, docRef).then(
        (value) => print("Review answer successfully recorded!"),
        onError: (e) => print("Error recording review answer: $e"));
  }

  @override
  Future<int> getCardCount(String deckId) async {
    if (_user == null) {
      _log.w(
          'User not logged in while attempting to load decks.'); // Log warning
      return 0;
    }

    final snapshot = await _firestore
        .collection('cards')
        .where('deckId', isEqualTo: deckId)
        .where('userId', isEqualTo: _user.uid)
        .count()
        .get()
        .onError<Exception>((e, stackTrace) {
      _log.w("Error loading cards: $e");
      throw e;
    });

    return snapshot.count ?? 0;
  }

  @override
  Future<int> getCardToReviewCount(String deckId) async {
    final ids = await _cardIdsToReview(deckId);
    return ids.length;
  }

  @override
  Future<List<CardAnswer>> loadAnswers(
      DateTime dayStart, DateTime dayEnd) async {
    _log.i('Loading answers for $dayStart to $dayEnd');
    final serializer = CardAnswerSerializer();
    try {
      final snapshot = await _firestore
          .collection('cardAnswers')
          .where('userId', isEqualTo: _user!.uid)
          .where('reviewStart', isGreaterThanOrEqualTo: dayStart)
          .where('reviewStart', isLessThanOrEqualTo: dayEnd)
          .get();
      final answers = await Future.wait(snapshot.docs
          .map((doc) async => await serializer.fromSnapshot(doc))
          .toList());
      _log.d('Loaded ${answers.length} answers');
      return answers;
    } on Exception catch (e) {
      _log.w('Failed loading answers', error: e);
      rethrow;
    }
  }

  @override
  Future<void> recordCardAnswer(CardAnswer answer) async {
    _log.i("Recording answer for card ${answer.cardId}");
    final serializer = CardAnswerSerializer();
    final docRef = _firestore.collection('cardAnswers').doc();
    await serializer.toSnapshot(answer, docRef).then(
        (value) => _log.d("Answer saved"),
        onError: (e) => _log.e("Error saving answer: $e"));
  }

  @override
  Future<Deck> loadDeck(String deckId) async {
    _log.i('Loading deck $deckId');
    final serializer = DeckSerializer();
    return await _firestore
        .collection('decks')
        .doc(deckId)
        .get()
        .then((snapshot) async => await serializer.fromSnapshot(snapshot));
  }

  @override
  Future<void> saveUser(UserProfile user) async {
    if (FirebaseAuth.instance.currentUser == null) {
      throw Exception("User not logged in");
    }
    final docRef = _firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);
    final serializer = UserSerializer();
    await serializer.toSnapshot(user, docRef);
    _log.i('Saved user profile ${user.id}');
  }

  @override
  Future<UserProfile?> loadUser(String userId) async {
    final serializer = UserSerializer();
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return await serializer.fromSnapshot(doc);
    }
    return null;
  }
}
