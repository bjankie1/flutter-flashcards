import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_flashcards/src/common/dates.dart';
import 'package:flutter_flashcards/src/model/users_collaboration.dart';
import 'package:logger/logger.dart';

import '../cards.dart';
import '../repository.dart';

extension QueryExtensions<T> on Query<T> {
  Query<Card> get withCardsConverter => withConverter<Card>(
      fromFirestore: (doc, _) => Card.fromJson(doc.id, doc.data()!),
      toFirestore: (card, _) => card.toJson());
  Query<CardStats> get withCardStatsConverter => withConverter<CardStats>(
      fromFirestore: (doc, _) => CardStats.fromJson(doc.id, doc.data()!),
      toFirestore: (stats, _) => stats.toJson());
  Query<Deck> get withDecksConverter => withConverter<Deck>(
      fromFirestore: (doc, _) => Deck.fromJson(doc.id, doc.data()!),
      toFirestore: (deck, _) => deck.toJson());

  Query<T> withUserFilter(String userId) => where('userId', isEqualTo: userId);
  Future<QuerySnapshot<T>> getForUser(String userId) =>
      where('userId', isEqualTo: userId).get();
}

class FirebaseCardsRepository extends CardsRepository {
  var _log = Logger();

  final FirebaseFirestore _firestore;
  User? _user;

  FirebaseCardsRepository(this._firestore, this._user) : super();

  String get userId {
    _validateUser();
    return _user!.uid;
  }

  set user(User? user) => _user = user;

  Query<Map<String, dynamic>> _collection(String name) =>
      _firestore.collection(name).where(Filter('userId', isEqualTo: userId));

  Query<Map<String, dynamic>> get _cardsCollection => _collection('cards');

  Query<Map<String, dynamic>> get _cardStatsCollection =>
      _collection('cardStats');

  Query<CardAnswer> get _cardAnswersCollection =>
      _collection('reviewLog').withConverter<CardAnswer>(
          fromFirestore: (doc, _) => CardAnswer.fromJson(doc.id, doc.data()!),
          toFirestore: (answer, _) => answer.toJson());

  Query<Deck> get _decksCollection => _collection('decks').withConverter<Deck>(
      fromFirestore: (doc, _) => Deck.fromJson(doc.id, doc.data()!),
      toFirestore: (deck, _) => deck.toJson());

  CollectionReference<UserProfile> get _usersCollection =>
      _firestore.collection('users').withConverter<UserProfile>(
          fromFirestore: (doc, _) => UserProfile.fromJson(doc.id, doc.data()!),
          toFirestore: (user, _) => user.toJson());

  Future<Deck> _addDeck(Deck deck) async {
    _log.d("Saving new deck ${deck.name}");
    final docRef = _firestore.collection('decks').doc();
    await docRef.set({'userId': userId, ...deck.toJson()}).then(
        (value) => _log.d("Deck successfully added!"),
        onError: (e) => _log.e("Error adding deck: $e"));
    final newDeck = deck.withId(id: docRef.id);
    return newDeck;
  }

  Future<Deck> _updateDeck(Deck deck) async {
    final docRef = _firestore.collection('decks').doc(deck.id);
    await docRef.update(deck.toJson()).then(
        (value) => _log.d("Deck successfully updated!"),
        onError: (e) => _log.e("Error updating deck: $e"));
    return deck;
  }

  @override
  String nextCardId() => _firestore.collection('cards').doc().id;

  @override
  String nextDeckId() => _firestore.collection('decks').doc().id;

  @override
  Future<Iterable<Deck>> loadDecks() async {
    _log.d('Loading decks');
    // Check authentication state
    _validateUser();
    final snapshot = await _decksCollection.get().onError((e, _) {
      _log.w('Error loading decks: $e', error: e);
      throw e!;
    });
    return snapshot.docs.map((s) => s.data());
  }

  Future<Card> _addCard(Card card) async {
    _log.d('Adding card');
    final docRef = _firestore.collection('cards').doc();
    await _firestore.runTransaction((transaction) async {
      transaction.set(docRef, {'userId': userId, ...card.toJson()});
      for (final s in CardStats.statsForCard(card.withId(id: docRef.id))) {
        final sDoc = _firestore.collection('cardStats').doc(s.idValue);
        transaction.set(sDoc, {'userId': userId, ...s.toJson()});
      }
    });
    return card.withId(id: docRef.id);
  }

  Future<void> _updateCard(Card card) async {
    _log.d('Updating card');
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
    _log.d('Updating card');
    final cardsSnapshot = await _cardsCollection.withCardsConverter.get();

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
    _log.d('Deleting deck: $deckId');
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
    final cardAnswerSnapshot = await _collection('cardAnswers')
        .where(Filter('cardId', isEqualTo: cardId))
        .get();
    for (final doc in cardAnswerSnapshot.docs) {
      batch.delete(doc.reference);
    }
    return await batch.commit().whenComplete(() => notifyCardChanged());
  }

  @override
  Future<List<Card>> loadCards(String deckId) async {
    _log.d('Loading cards');
    final snapshot = await _collection('cards')
        .where(Filter.and(Filter('userId', isEqualTo: userId),
            Filter('deckId', isEqualTo: deckId)))
        .get();
    return snapshot.docs
        .map((doc) => Card.fromJson(doc.id, doc.data()))
        .toList();
  }

  void _validateUser() {
    if (_user == null) {
      _log.w('User not logged in while attempting to load decks.');
      throw Exception('User not logged in');
    }
  }

  @override
  Future<Card> saveCard(Card card) async {
    if (card.id == null) {
      return await _addCard(card)
          .whenComplete(() => notifyCardChanged())
          .onError((e, stackTrace) {
        _log.w("Error adding card", error: e, stackTrace: stackTrace);
        throw e as Error;
      });
    } else {
      await _updateCard(card)
          .whenComplete(() => notifyCardChanged())
          .onError((e, stackTrace) {
        _log.w("Error updating card", error: e, stackTrace: stackTrace);
        throw e as Error;
      });
      return card;
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
    _log.d('Loading cards to review count');

    try {
      // Cards ready for review
      var baseQuery = _firestore
          .collection('cardStats')
          .where(Filter.or(
              Filter('nextReviewDate',
                  isLessThanOrEqualTo: currentClockDateTime),
              Filter('nextReviewDate', isNull: true)))
          .withUserFilter(userId);

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
        var countQuery =
            baseQuery.where('state', isEqualTo: state.name).count();
        final result = await countQuery.get().then((value) {
          _log.d('Loaded ${value.count} $state cards');
          return value;
        });
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
          .where(Filter('nextReviewDate',
              isLessThanOrEqualTo: currentClockDateTime))
          .withCardStatsConverter
          .limit(reviewLimit ?? 200)
          .getForUser(userId);
      final toReview = statsSnapshot.docs.map((doc) => doc.data()).toList();
      _log.d('Cards to review: ${toReview.length}');

      // New cards
      final statsSnapshotNew = await _cardStatsCollection
          .where(Filter('nextReviewDate', isNull: true))
          .withCardStatsConverter
          .limit(newLimit ?? 200)
          .getForUser(userId);
      final newCards = statsSnapshotNew.docs.map((doc) => doc.data()).toList();
      _log.d('New cards to review: ${newCards.length}');

      final allCards = [...toReview, ...newCards];
      _log.d('All cards to review: ${statsSnapshot.docs.length}');

      _log.d('Loading cards to review');
      // Load cards to review
      final cardsIdsToReview = allCards.map((cs) => (cs.cardId, cs.variant));
      return cardsIdsToReview;
    } on Exception catch (e, stackTrace) {
      _log.w('Error querying cards to review: $e', stackTrace: stackTrace);
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
        : _cardsCollection
            .where(Filter(FieldPath.documentId, whereIn: cardIds));
    final cardsSnapshot = await cardsQuery.withCardsConverter.get();
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
    _log.d(
        'Saving card stats ${stats.cardId}::${stats.variant.name} with next review on ${stats.nextReviewDate}');
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
    _log.d('Loading answers for $dayStart to $dayEnd');
    try {
      final snapshot = await _collection('reviewLog')
          .where(Filter.and(
              Filter('reviewStart', isGreaterThanOrEqualTo: dayStart),
              Filter('reviewStart', isLessThanOrEqualTo: dayEnd)))
          .getForUser(userId);
      _log.d('Loaded ${snapshot.docs.length} answers');
      return snapshot.docs
          .map((doc) => CardAnswer.fromJson(doc.id, doc.data()));
    } on Exception catch (e) {
      _log.w('Failed loading answers', error: e);
      rethrow;
    }
  }

  @override
  Future<void> recordCardAnswer(CardAnswer answer) async {
    _log.d("Recording answer for card ${answer.cardId}");
    final collection = _firestore.collection('reviewLog');
    collection.add({'userId': userId, ...answer.toJson()}).then(
        (value) => _log.d("Answer saved"),
        onError: (e) => _log.e("Error saving answer: $e"));
  }

  @override
  Future<Deck?> loadDeck(String deckId) async {
    _log.d('Loading deck $deckId');
    final snapshot = await _decksCollection
        .where(FieldPath.documentId, isEqualTo: deckId)
        .get();
    return snapshot.docs.firstOrNull?.data();
  }

  @override
  Future<void> saveUser(UserProfile user) async {
    final docRef = _usersCollection.doc(userId);
    await docRef.set(user, SetOptions(merge: true)).then(
        (value) => _log.d("User successfully updated!"),
        onError: (e) => _log.e("Error updating user: $e"));
  }

  @override
  Future<UserProfile?> loadUser(String userId) async {
    _log.d('Loading user $userId');
    final doc = await _usersCollection.doc(userId).get();
    return doc.exists ? doc.data() : null;
  }

  @override
  Future<Card?> loadCard(String cardId) async {
    _log.d('Loading card $cardId');
    final snapshot = await _firestore.collection('cards').doc(cardId).get();
    if (!snapshot.exists) {
      return null;
    }
    return Card.fromJson(snapshot.id, snapshot.data()!);
  }

  @override
  Future<Iterable<Card>> loadCardsByIds(Iterable<String> cardIds) async {
    final snapshot = await _cardsCollection
        .where(Filter(FieldPath.documentId, whereIn: cardIds))
        .withCardsConverter
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

  @override
  Future<void> saveCollaborationInvitation(String receivingUserEmail) async {
    _log.d('Saving collaboration invitation for $receivingUserEmail');
    final snapshot = await _usersCollection
        .where('email', isEqualTo: receivingUserEmail)
        .get();
    final receivingUserId = snapshot.docs.firstOrNull?.id;
    if (receivingUserId == null) {
      _log.w('User does not exist $receivingUserEmail');
      throw Exception('No user found with email $receivingUserEmail');
    }
    final docRef = _firestore.collection('collaborators').doc();
    final request = CollaborationInvitation(
        id: docRef.id,
        initiatorUserId: userId,
        receivingUserId: receivingUserId,
        receivingUserEmail: receivingUserEmail,
        sentTimestamp: currentClockTimestamp,
        status: InvitationStatus.pending);
    await docRef.set(request.toJson());
  }

  @override
  Future<Iterable<CollaborationInvitation>> pendingInvitations(
      {bool sent = false}) async {
    final snapshot = await _firestore
        .collection('collaborators')
        .where(Filter.and(
          Filter('status', isEqualTo: InvitationStatus.pending.name),
          sent
              ? Filter('initiatorUserId', isEqualTo: userId)
              : Filter('receivingUserId', isEqualTo: userId),
        ))
        .get()
        .then((value) {
      _log.d('Loaded invitations: ${value.docs.length}');
      return value;
    },
            onError: (e, st) =>
                _log.e('Error loading invitations: $e', stackTrace: st));
    return snapshot.docs
        .map((doc) => CollaborationInvitation.fromJson(doc.id, doc.data()));
  }

  @override
  Future<Set<String>> loadCollaborators() async {
    final snapshot = await _firestore
        .collection('collaborators')
        .where(Filter.and(
          Filter('status', isEqualTo: InvitationStatus.accepted.name),
          Filter.or(Filter('initiatorUserId', isEqualTo: userId),
              Filter('receivingUserId', isEqualTo: userId)),
        ))
        .get()
        .then((value) {
      _log.d('Loaded collaborators: ${value.docs.length}');
      return value;
    },
            onError: (e, st) =>
                _log.e('Error loading collaborators: $e', stackTrace: st));
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return data['receivingUserId'] == userId
          ? data['initiatorUserId'] as String
          : data['receivingUserId'] as String;
    }).toSet();
  }

  @override
  Future<void> changeInvitationStatus(
      String invitationId, InvitationStatus status) async {
    final docRef = _firestore.collection('collaborators').doc(invitationId);
    final snapshot = await docRef.get();
    if (!snapshot.exists) {
      throw Exception('Invitation not found');
    }
    final invitation =
        CollaborationInvitation.fromJson(snapshot.id, snapshot.data()!);
    docRef.update(invitation.changeStatus(status).toJson());
  }
}
