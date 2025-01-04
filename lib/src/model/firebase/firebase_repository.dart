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
  get _user => FirebaseAuth.instance.currentUser;

  String get userId {
    _validateUser();
    return _user!.uid;
  }

  Query<Map<String, dynamic>> _collection(String name) =>
      _firestore.collection(name).where('userId', isEqualTo: userId);

  Query<Card> get _cardsCollection => _collection('cards').withConverter<Card>(
      fromFirestore: (doc, _) => Card.fromJson(doc.id, doc.data()!),
      toFirestore: (card, _) => card.toJson());

  Query<CardStats> get _cardStatsCollection =>
      _collection('cardStats').withConverter<CardStats>(
          fromFirestore: (doc, _) => CardStats.fromJson(doc.id, doc.data()!),
          toFirestore: (stats, _) => stats.toJson());

  Query<CardAnswer> get _cardAnswersCollection =>
      _collection('reviewLog').withConverter<CardAnswer>(
          fromFirestore: (doc, _) => CardAnswer.fromJson(doc.id, doc.data()!),
          toFirestore: (answer, _) => answer.toJson());

  Query<Deck> get _decksCollection => _collection('decks').withConverter<Deck>(
      fromFirestore: (doc, _) => Deck.fromJson(doc.id, doc.data()!),
      toFirestore: (deck, _) => deck.toJson());

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
  Future<Iterable<Deck>> loadDecks() async {
    _log.i('Loading decks');
    // Check authentication state
    _validateUser();
    try {
      final snapshot = await _firestore
          .collection('decks')
          .where('userId', isEqualTo: userId)
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

  Future<void> _addCard(Card card) async {
    _log.i('Adding card');
    await _firestore.runTransaction((transaction) async {
      final docRef = _firestore.collection('cards').doc();
      transaction.update(docRef, {'userId': userId, ...card.toJson()});
      for (final s in CardStats.statsForCard(card)) {
        final sDoc = _firestore.collection('cardStats').doc(s.idValue);
        transaction.set(sDoc, {'userId': userId, ...s.toJson()});
      }
    });
  }

  Future<void> _updateCard(Card card) async {
    _log.i('Updating card');
    await _firestore.runTransaction((transaction) async {
      // Firestore transactions require all reads to be executed before all writes.
      final docRef = _firestore.collection('cards').doc(card.id);
      final stats = CardStats.statsForCard(card);
      final statsDocs = await Future.wait(stats.map((s) async =>
          await _firestore
              .collection('cardStats')
              .doc(s.idValue)
              .get()
              .then((snapshot) => (s, snapshot.reference, snapshot.exists))));
      transaction.set(docRef, {'userId': userId, ...card.toJson()});
      for (final record in statsDocs) {
        try {
          if (!record.$3) {
            transaction
                .set(record.$2, {'userId': userId, ...record.$1.toJson()});
          }
        } on Exception catch (e) {
          _log.e('Error updating card stats: $e');
          rethrow;
        }
      }
    });
  }

  @override
  Future<void> updateAllStats() async {
    _log.i('Updating card');
    final cardsSnapshot = await _cardsCollection.get();

    for (final snapshot in cardsSnapshot.docs) {
      final stats = CardStats.statsForCard(snapshot.data());
      final statsDocs = await Future.wait(stats.map((s) async =>
          await _firestore
              .collection('cardStats')
              .doc(s.idValue)
              .get()
              .then((snapshot) => (s, snapshot.reference, snapshot.exists))));
      for (final record in statsDocs) {
        if (!record.$3) {
          await record.$2.set({'userId': userId, ...record.$1.toJson()});
        }
      }
    }
  }

  @override
  Future<void> deleteDeck(String deckId) async {
    _log.i('Deleting deck: $deckId');
    final batch = _firestore.batch();
    batch.delete(_firestore.collection('decks').doc(deckId));
    final cardsSnapshot =
        await _collection('cards').where('deckId', isEqualTo: deckId).get();
    for (final doc in cardsSnapshot.docs) {
      batch.delete(doc.reference);
      final cardStatsSnapshot =
          await _collection('cards').where('cardId', isEqualTo: doc.id).get();
      for (final statDoc in cardStatsSnapshot.docs) {
        batch.delete(statDoc.reference);
      }
      final cardAnswerSnapshot = await _collection('cardAnswers')
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
    final cardStatsSnapshot =
        await _collection('cards').where('cardId', isEqualTo: cardId).get();
    for (final doc in cardStatsSnapshot.docs) {
      batch.delete(doc.reference);
    }
    final cardAnswerSnapshot =
        await _cardAnswersCollection.where('cardId', isEqualTo: cardId).get();
    for (final doc in cardAnswerSnapshot.docs) {
      batch.delete(doc.reference);
    }
    return await batch.commit().whenComplete(() => notifyCardChanged());
  }

  @override
  Future<List<Card>> loadCards(String deckId) async {
    final snapshot =
        await _cardsCollection.where('deckId', isEqualTo: deckId).get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  void _validateUser() {
    if (_user == null) {
      _log.w('User not logged in while attempting to load decks.');
      throw Exception('User not logged in');
    }
  }

  @override
  Future<void> saveCard(Card card) async {
    if (card.id == null) {
      return await _addCard(card)
          .whenComplete(() => notifyCardChanged())
          .onError((e, stackTrace) {
        _log.w("Error adding card", error: e, stackTrace: stackTrace);
        throw e as Error;
      });
    } else {
      return await _updateCard(card)
          .whenComplete(() => notifyCardChanged())
          .onError((e, stackTrace) {
        _log.w("Error updating card", error: e, stackTrace: stackTrace);
        throw e as Error;
      });
    }
  }

  @override
  Future<Deck> saveDeck(Deck deck) async {
    if (deck.id == null) {
      final result =
          await _addDeck(deck).whenComplete(() => notifyDeckChanged());
      notifyDeckChanged();
      return result;
    } else {
      final result =
          await _updateDeck(deck).whenComplete(() => notifyDeckChanged());
      notifyDeckChanged();
      return result;
    }
  }

  @override
  Future<CardStats> loadCardStats(
      String cardId, CardReviewVariant variant) async {
    final snapshot = await _firestore
        .collection('cardStats')
        .doc('$cardId::${variant.name}')
        .get();
    if (snapshot.exists) {
      return CardStats.fromJson(snapshot.id, snapshot.data()!);
    }
    throw Exception('No card stats for $cardId and variant $variant');
  }

  Future<Iterable<String>> _deckCardsIds(String deckId) async {
    final snapshots =
        await _collection('cards').where('deckId', isEqualTo: deckId).get();
    return snapshots.docs.map((doc) => doc.id);
  }

  /// Loads identifiers and review variants of cards to review based on `nextReviewDate`
  @override
  Future<Map<State, int>> cardsToReviewCount({String? deckId}) async {
    try {
      // Cards ready for review
      var baseQuery = _collection('cardStats').where(Filter.or(
          Filter('nextReviewDate', isLessThanOrEqualTo: DateTime.now()),
          Filter('nextReviewDate', isNull: true)));
      if (deckId != null) {
        final cardIds = await _deckCardsIds(deckId);
        if (cardIds.isEmpty) {
          return {
            State.newState: 0,
            State.learning: 0,
            State.relearning: 0,
            State.review: 0
          };
        }
        baseQuery = baseQuery.where('cardId', whereIn: cardIds);
      }

      countState(State state) async {
        final result =
            await baseQuery.where('state', isEqualTo: state.name).count().get();
        return result.count ?? 0;
      }

      final newState = await countState(State.newState);
      final learningState = await countState(State.learning);
      final relearningState = await countState(State.relearning);
      final reviewState = await countState(State.review);

      _log.d('''
Successfully loaded cards to review count. 
New: $newState, Learning: $learningState, Relearning: $relearningState, Review: $reviewState''');

      return {
        State.newState: newState,
        State.learning: learningState,
        State.relearning: relearningState,
        State.review: reviewState
      };
    } on Exception catch (e) {
      _log.w('Error querying cards to review: $e');
      rethrow;
    }
  }

  /// Loads identifiers and review variants of cards to review based on `nextReviewDate`
  Future<Iterable<(String, CardReviewVariant)>> _cardIdsToReview(
      {int? reviewLimit = 200, int? newLimit = 200}) async {
    try {
      // Cards ready for review
      final statsSnapshot = await _cardStatsCollection
          .where('nextReviewDate', isLessThanOrEqualTo: DateTime.now())
          .limit(reviewLimit ?? 200)
          .get();
      final toReview = statsSnapshot.docs.map((doc) => doc.data()).toList();
      _log.d('Cards to review: ${toReview.length}');

      // New cards
      final statsSnapshotNew = await _cardStatsCollection
          .where('nextReviewDate', isNull: true)
          .limit(newLimit ?? 200)
          .get();
      final newCards = statsSnapshotNew.docs.map((doc) => doc.data()).toList();
      _log.d('New cards to review: ${newCards.length}');

      final allCards = [...toReview, ...newCards];
      _log.d('All cards to review: ${statsSnapshot.docs.length}');

      _log.d('Loading cards to review');
      // Load cards to review
      final cardsIdsToReview = allCards.map((cs) => (cs.cardId, cs.variant));
      return cardsIdsToReview;
    } on Exception catch (e) {
      _log.w('Error querying cards to review: $e');
      rethrow;
    }
  }

  @override
  Future<Iterable<Card>> loadCardToReview({String? deckId}) async {
    // Load cards to review IDs and corresponding card review variant.
    final cardIdsWithVariants = await _cardIdsToReview();
    _log.d('Cards to review: ${cardIdsWithVariants.length}');
    // Load corresponding cards for each card ID from the tuple
    final cardIds =
        cardIdsWithVariants.map((t) => t.$1).toSet(); // unique card Ids
    final cardsQuery = deckId != null
        ? _cardsCollection.where(Filter.and(
            Filter(FieldPath.documentId, whereIn: cardIds),
            Filter('deckId', isEqualTo: deckId)))
        : _cardsCollection.where(FieldPath.documentId, whereIn: cardIds);
    final cardsSnapshot = await cardsQuery.get();
    final cards = cardsSnapshot.docs.map((doc) => doc.data());
    final cardsMappedToId =
        Map.fromEntries(cards.map((card) => MapEntry(card.id, card)));
    final result = cardIdsWithVariants
        .where((pair) => cardsMappedToId.containsKey(pair.$1))
        .map((pair) => cardsMappedToId[pair.$1]!);
    return result;
  }

  @override
  Future<void> saveCardStats(CardStats stats) async {
    _log.d('Saving card stats ${stats.cardId}::${stats.variant}');
    final docRef = _firestore.collection('cardStats').doc(stats.idValue);
    await docRef.set({'userId': userId, ...stats.toJson()}).then(
        (value) => print("Review answer successfully recorded!"),
        onError: (e) => print("Error recording review answer: $e"));
  }

  @override
  Future<int> getCardCount(String deckId) async {
    final snapshot = await _cardsCollection
        .where('deckId', isEqualTo: deckId)
        .count()
        .get()
        .onError<Exception>((e, stackTrace) {
      _log.w("Error loading cards: $e");
      throw e;
    });

    return snapshot.count ?? 0;
  }

  @override
  Future<Iterable<CardAnswer>> loadAnswers(
      DateTime dayStart, DateTime dayEnd) async {
    _log.i('Loading answers for $dayStart to $dayEnd');
    try {
      final snapshot = await _cardAnswersCollection
          .where(Filter.and(
              Filter('reviewStart', isGreaterThanOrEqualTo: dayStart),
              Filter('reviewStart', isLessThanOrEqualTo: dayEnd)))
          .get();
      _log.d('Loaded ${snapshot.docs.length} answers');
      return snapshot.docs.map((doc) => doc.data());
    } on Exception catch (e) {
      _log.w('Failed loading answers', error: e);
      rethrow;
    }
  }

  @override
  Future<void> recordCardAnswer(CardAnswer answer) async {
    _log.i("Recording answer for card ${answer.cardId}");
    final collection = _firestore.collection('reviewLog');
    collection.add({'userId': userId, ...answer.toJson()}).then(
        (value) => _log.d("Answer saved"),
        onError: (e) => _log.e("Error saving answer: $e"));
  }

  @override
  Future<Deck?> loadDeck(String deckId) async {
    _log.i('Loading deck $deckId');
    final snapshot = await _decksCollection
        .where(FieldPath.documentId, isEqualTo: deckId)
        .get();
    return snapshot.docs.firstOrNull?.data();
  }

  @override
  Future<void> saveUser(UserProfile user) async {
    final docRef = _firestore.collection('users').doc(userId);
    final serializer = UserSerializer();
    await serializer.toSnapshot(user, docRef);
    _log.i('Saved user profile ${user.id}');
  }

  @override
  Future<UserProfile?> loadUser(String userId) async {
    final serializer = UserSerializer();
    _log.d('Loading user $userId');
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return await serializer.fromSnapshot(doc);
    }
    return null;
  }

  @override
  Future<Card?> loadCard(String cardId) async {
    _log.i('Loading card $cardId');
    final snapshot = await _cardsCollection
        .where(FieldPath.documentId, isEqualTo: cardId)
        .get();
    return snapshot.docs.firstOrNull?.data();
  }

  @override
  Future<Iterable<Card>> loadCardsByIds(Iterable<String> cardIds) async {
    final snapshot = await _cardsCollection
        .where(FieldPath.documentId, whereIn: cardIds)
        .get();
    return snapshot.docs.map((e) => e.data());
  }

  @override
  Future<Iterable<Deck>> loadDecksByIds(Iterable<String> deckIds) async {
    final snapshot = await _decksCollection
        .where(FieldPath.documentId, whereIn: deckIds)
        .get();
    return snapshot.docs.map((e) => e.data());
  }
}
