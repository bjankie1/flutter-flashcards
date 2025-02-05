import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter_flashcards/src/common/crypto.dart';
import 'package:flutter_flashcards/src/common/dates.dart';
import 'package:flutter_flashcards/src/model/users_collaboration.dart';
import 'package:logger/logger.dart';

import '../cards.dart';
import '../repository.dart';

var _log = Logger();

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

  Future<QuerySnapshot<T>> getForUser(String userId) =>
      where('userId', isEqualTo: userId).get();
}

extension CollectionReferenceExtensions<T> on CollectionReference<T> {
  CollectionReference<Card> get withCardsConverter => withConverter<Card>(
      fromFirestore: (doc, _) => Card.fromJson(doc.id, doc.data()!),
      toFirestore: (card, _) => card.toJson());

  CollectionReference<CardStats> get withCardStatsConverter =>
      withConverter<CardStats>(
          fromFirestore: (doc, _) => CardStats.fromJson(doc.id, doc.data()!),
          toFirestore: (stats, _) => stats.toJson());

  CollectionReference<Deck> get withDecksConverter => withConverter<Deck>(
      fromFirestore: (doc, _) => Deck.fromJson(doc.id, doc.data()!),
      toFirestore: (deck, _) => deck.toJson());

  CollectionReference<CardAnswer> get withCardAnswerConverter =>
      withConverter<CardAnswer>(
          fromFirestore: (doc, _) => CardAnswer.fromJson(doc.id, doc.data()!),
          toFirestore: (cardAnswer, _) => cardAnswer.toJson());
}

extension ErrorReporting<T> on Future<T> {
  Future<T> logError(String message) => onError((e, stackTrace) {
        _log.w('$message: $e', error: e, stackTrace: stackTrace);
        throw e!;
      });
}

const usersCollectionName = 'users';
const cardsCollectionName = 'cards';
const cardStatsCollectionName = 'cardStats';
const cardAnswersCollectionName = 'reviewLog';
const decksCollectionName = 'decks';

class FirebaseCardsRepository extends CardsRepository {
  final FirebaseFirestore _firestore;
  User? _user;

  FirebaseCardsRepository(this._firestore, this._user) : super();

  String get userId {
    _validateUser();
    return _user!.uid;
  }

  String get userEmail {
    _validateUser();
    if (_user!.email == null) {
      throw Exception('User has no email address');
    }
    return _user!.email!;
  }

  set user(User? user) => _user = user;

  /// Add `user` prefix and make first letter of `name` upper case. Eg.
  /// for `decks` returns `userDecks`
  String userPrefix(String name) => 'user${name.capitalize}';

  CollectionReference<Map<String, dynamic>> _collection(String name) =>
      _firestore.collection(name).doc(userId).collection(userPrefix(name));

  CollectionReference<Card> get _cardsCollection =>
      _collection(cardsCollectionName).withCardsConverter;

  CollectionReference<CardStats> get _cardStatsCollection =>
      _collection(cardStatsCollectionName).withCardStatsConverter;

  CollectionReference<CardAnswer> get _cardAnswersCollection =>
      _collection(cardAnswersCollectionName).withCardAnswerConverter;

  CollectionReference<Deck> get _decksCollection =>
      _collection(decksCollectionName).withDecksConverter;

  CollectionReference<UserProfile> get _usersCollection =>
      _firestore.collection(usersCollectionName).withConverter<UserProfile>(
          fromFirestore: (doc, _) => UserProfile.fromJson(doc.id, doc.data()!),
          toFirestore: (user, _) => user.toJson());

  Future<Deck> _addDeck(Deck deck) async {
    _log.d("Saving new deck ${deck.name}");
    final docRef = _decksCollection.doc();
    await docRef.set(deck).then((value) => _log.d("Deck successfully added!"),
        onError: (e) => _log.e("Error adding deck: $e"));
    final newDeck = deck.withId(id: docRef.id);
    return newDeck;
  }

  Future<Deck> _updateDeck(Deck deck) async {
    final docRef = _decksCollection.doc(deck.id);
    await docRef.set(deck, SetOptions(merge: true)).then(
        (value) => _log.d("Deck successfully updated!"),
        onError: (e) => _log.e("Error updating deck: $e"));
    return deck;
  }

  @override
  String nextCardId() => _firestore.collection(cardsCollectionName).doc().id;

  @override
  String nextDeckId() => _firestore.collection(decksCollectionName).doc().id;

  @override
  Future<Iterable<Deck>> loadDecks() async {
    _log.d('Loading decks');
    // Check authentication state
    _validateUser();
    final snapshot =
        await _decksCollection.get().logError('Error loading decks');
    return snapshot.docs.map((s) => s.data());
  }

  Future<Card> _addCard(Card card) async {
    _log.d('Adding card');
    final docRef = _cardsCollection.doc();
    await _firestore.runTransaction((transaction) async {
      transaction.set(docRef, card);
      for (final s in CardStats.statsForCard(card.withId(id: docRef.id))) {
        final sDoc = _cardStatsCollection.doc(s.idValue);
        transaction.set(sDoc, s);
      }
    });
    return card.withId(id: docRef.id);
  }

  Future<void> _updateCard(Card card) async {
    _log.d('Updating card');
    await _firestore.runTransaction((transaction) async {
      // Firestore transactions require all reads to be executed before all writes.
      final docRef = _cardsCollection.doc(card.id);
      final stats = CardStats.statsForCard(card);
      final statsDocs = await Future.wait(stats.map((s) async =>
              await _cardStatsCollection.doc(s.idValue).get().then(
                  (snapshot) => (s, snapshot.reference, snapshot.exists))))
          .logError('Error loading stats for card ${card.id}');
      transaction.set(docRef, card);
      for (final record in statsDocs) {
        if (!record.$3) {
          transaction.set(record.$2, record.$1);
        }
      }
    });
  }

  @override
  Future<void> updateAllStats() async {
    _log.d('Updating card');
    final cardsSnapshot = await _cardsCollection.get();

    for (final snapshot in cardsSnapshot.docs) {
      final stats = CardStats.statsForCard(snapshot.data());
      final statsDocs = await Future.wait(stats.map((s) async =>
          await _cardStatsCollection
              .doc(s.idValue)
              .get()
              .then((snapshot) => (s, snapshot.reference, snapshot.exists))));
      for (final record in statsDocs) {
        if (!record.$3) {
          await record.$2.set(record.$1);
        }
      }
    }
  }

  @override
  Future<void> deleteDeck(String deckId) async {
    _log.d('Deleting deck: $deckId');
    final batch = _firestore.batch();
    batch.delete(_decksCollection.doc(deckId));
    final cardsSnapshot =
        await _cardsCollection.where('deckId', isEqualTo: deckId).get();
    for (final doc in cardsSnapshot.docs) {
      batch.delete(doc.reference);
      final cardStatsSnapshot =
          await _cardStatsCollection.where('cardId', isEqualTo: doc.id).get();
      for (final statDoc in cardStatsSnapshot.docs) {
        batch.delete(statDoc.reference);
      }
      final cardAnswerSnapshot =
          await _cardAnswersCollection.where('cardId', isEqualTo: doc.id).get();
      for (final answerDoc in cardAnswerSnapshot.docs) {
        batch.delete(answerDoc.reference);
      }
    }

    await batch.commit().whenComplete(() => notifyDeckChanged());
  }

  @override
  Future<void> deleteCard(String cardId) async {
    final batch = _firestore.batch();
    batch.delete(_cardsCollection.doc(cardId));
    final cardStatsSnapshot =
        await _cardStatsCollection.where('cardId', isEqualTo: cardId).get();
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
    _log.d('Loading cards');
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
  Future<Card> saveCard(Card card) async {
    if (card.id == null) {
      return await _addCard(card)
          .whenComplete(() => notifyCardChanged())
          .logError('Error adding card');
    } else {
      await _updateCard(card)
          .whenComplete(() => notifyCardChanged())
          .logError('Error saving card');
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
    final statsId = CardStats(cardId: cardId, variant: variant).idValue;
    final snapshot = await _cardStatsCollection.doc(statsId).get();
    if (snapshot.exists) {
      return snapshot.data()!;
    }
    throw Exception('No card stats for $cardId and variant $variant');
  }

  Future<Iterable<String>> _deckCardsIds(String deckId) async {
    final snapshots =
        await _cardsCollection.where('deckId', isEqualTo: deckId).get();
    return snapshots.docs.map((doc) => doc.id);
  }

  /// Loads identifiers and review variants of cards to review based on `nextReviewDate`
  @override
  Future<Map<State, int>> cardsToReviewCount({String? deckId}) async {
    _log.d('Loading cards to review count');
    // Cards ready for review
    var baseQuery = _cardStatsCollection.where(Filter.or(
        Filter('nextReviewDate', isLessThanOrEqualTo: currentClockDateTime),
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
      var countQuery = baseQuery.where('state', isEqualTo: state.name).count();
      final result = await countQuery.get().then((value) {
        _log.d('Loaded ${value.count} $state cards');
        return value;
      }).logError('Error counting cards to review');
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
  }

  /// Loads identifiers and review variants of cards to review based on `nextReviewDate`
  Future<Iterable<(String, CardReviewVariant)>> _cardIdsToReview(
      {int? reviewLimit = 200, int? newLimit = 200}) async {
    try {
      // Cards ready for review
      final statsSnapshot = await _cardStatsCollection
          .where('nextReviewDate', isLessThanOrEqualTo: currentClockDateTime)
          .limit(reviewLimit ?? 200)
          .get()
          .logError('Error querying cards to review');
      final toReview = statsSnapshot.docs.map((doc) => doc.data()).toList();
      _log.d('Cards to review: ${toReview.length}');

      // New cards
      final statsSnapshotNew = await _cardStatsCollection
          .where('nextReviewDate', isNull: true)
          .limit(newLimit ?? 200)
          .get()
          .logError('Error querying new cards to review');
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
    if (cardIds.isEmpty) return Iterable.empty();
    final cardsQuery = deckId != null
        ? _cardsCollection.where(Filter.and(
            Filter(FieldPath.documentId, whereIn: cardIds),
            Filter('deckId', isEqualTo: deckId)))
        : _cardsCollection
            .where(Filter(FieldPath.documentId, whereIn: cardIds));
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
    _log.d(
        'Saving card stats ${stats.cardId}::${stats.variant.name} with next review on ${stats.nextReviewDate}');
    final docRef = _cardStatsCollection.doc(stats.idValue);
    await docRef.set(stats).then(
        (value) => _log.d("Review answer successfully recorded!"),
        onError: (e) => _log.w("Error recording review answer: $e"));
  }

  @override
  Future<int> getCardCount(String deckId) async {
    final snapshot = await _cardsCollection
        .where('deckId', isEqualTo: deckId)
        .count()
        .get()
        .logError('Error loading cards');

    return snapshot.count ?? 0;
  }

  @override
  Future<Iterable<CardAnswer>> loadAnswers(DateTime dayStart, DateTime dayEnd,
      {String? uid}) async {
    _log.d('Loading answers for $dayStart to $dayEnd');

    final snapshot = await _cardAnswersCollection
        .where(Filter.and(
            Filter('reviewStart', isGreaterThanOrEqualTo: dayStart),
            Filter('reviewStart', isLessThanOrEqualTo: dayEnd)))
        .get()
        .logError('Loading reviewLog failed');
    _log.d('Loaded ${snapshot.docs.length} answers');
    return snapshot.docs.map((doc) => doc.data());
  }

  @override
  Future<void> recordCardAnswer(CardAnswer answer) async {
    _log.d("Recording answer for card ${answer.cardId}");
    await _cardAnswersCollection.add(answer).then(
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
    final emailDigest = user.email.sha256Digest;
    final emailToUidDocRef =
        _firestore.collection('emailToUid').doc(emailDigest);

    final batch = _firestore.batch();
    batch.set(docRef, user, SetOptions(merge: true));
    batch.set(emailToUidDocRef, {'uid': userId});
    await batch.commit().logError('Error saving user profile');
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
    final snapshot = await _cardsCollection.doc(cardId).get();
    if (!snapshot.exists) {
      _log.d('Card $cardId not found');
    }
    return snapshot.data();
  }

  @override
  Future<Iterable<Card>> loadCardsByIds(Iterable<String> cardIds) async {
    final snapshot = await _cardsCollection
        .where(FieldPath.documentId, whereIn: cardIds)
        .get()
        .logError('Error loading cards by ID');
    return snapshot.docs.map((e) => e.data());
    // .where((card) => cardIds.contains(card.id));
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
    if (receivingUserEmail == userEmail) {
      throw Exception('Sending invitation to self is not allowed.');
    }
    final snapshot = await _firestore
        .collection('collaborators')
        .where(
          Filter('receivingUserEmail', isEqualTo: receivingUserEmail),
        )
        .count()
        .get()
        .logError('Error loading collaborators');
    if ((snapshot.count ?? 0) > 0) {
      throw Exception('Invitation has been already sent');
    }
    _log.d('Saving collaboration invitation for $receivingUserEmail');
    final docRef = _firestore.collection('collaborators').doc();
    final request = CollaborationInvitation(
        id: docRef.id,
        initiatorUserId: userId,
        receivingUserEmail: receivingUserEmail,
        sentTimestamp: currentClockTimestamp,
        status: InvitationStatus.pending);
    await docRef.set(request.toJson()).logError('Failed saving invitation');
  }

  @override
  Future<Iterable<CollaborationInvitation>> pendingInvitations(
      {bool sent = false}) async {
    final snapshot = await _firestore
        .collection('collaborators')
        .where(Filter('status', isEqualTo: InvitationStatus.pending.name))
        .where(sent
            ? Filter('initiatorUserId', isEqualTo: userId)
            : Filter('receivingUserEmail', isEqualTo: userEmail))
        .get()
        .logError('Error loading invitations');
    _log.d('Loaded ${snapshot.docs.length} invitations');
    final result = snapshot.docs
        .map((doc) => CollaborationInvitation.fromJson(doc.id, doc.data()));
    return result;
  }

  @override
  Future<Set<String>> loadCollaborators() async {
    // Even though accepted invitations should have `receivingUserId` field
    // the filter is applied to `receivingUserEmail` to avoid creating
    // another index
    final snapshot = await _firestore
        .collection('collaborators')
        .where(Filter.and(
          Filter('status', isEqualTo: InvitationStatus.accepted.name),
          Filter.or(Filter('initiatorUserId', isEqualTo: userId),
              Filter('receivingUserEmail', isEqualTo: userEmail)),
        ))
        .get()
        .logError('Error loading collaborators');
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
    await docRef.update(invitation.changeStatus(status, userId).toJson());
    // add collaborator ID to /users/{userId}/collaborators sub-collection
    // when accepted. The record needs to be added both for sending user
    // and receiving with corresponding IDs.
    if (status == InvitationStatus.accepted) {
      final initiatorDocRef = _usersCollection
          .doc(invitation.initiatorUserId)
          .collection('collaborators')
          .doc(userId);
      final receivingDocRef = _usersCollection
          .doc(userId)
          .collection('collaborators')
          .doc(invitation.initiatorUserId);
      final batch = _firestore.batch();
      batch
        ..set(initiatorDocRef, {'acceptedDate': currentClockTimestamp})
        ..set(receivingDocRef, {'acceptedDate': currentClockTimestamp});
      await batch.commit();
    } else {
      // Delete invitation record when rejected
      final initiatorDocRef = _usersCollection
          .doc(invitation.initiatorUserId)
          .collection('collaborators')
          .doc(userId);
      final receivingDocRef = _usersCollection
          .doc(userId)
          .collection('collaborators')
          .doc(invitation.initiatorUserId);
      final batch = _firestore.batch();
      batch.delete(initiatorDocRef);
      batch.delete(receivingDocRef);
      await batch.commit();
    }
  }

  @override
  Future<void> grantStatsAccess(String receivingUserEmail) async {
    final emailDigest = receivingUserEmail.sha256Digest;
    final snapshot =
        await _firestore.collection('emailToUid').doc(emailDigest).get();
    if (!snapshot.exists) {
      throw Exception('Email not registered');
    }
    final receiverUid = snapshot.data()!['uid'];
    final statsGrantDoc = _firestore
        .collection('sharing')
        .doc(userId)
        .collection('sharedStats')
        .doc('stats')
        .collection('grantedTo')
        .doc(receiverUid);
    final userCollaborators = _firestore
        .collection('userCollaborators')
        .doc(userId)
        .collection('collaborators')
        .doc(receiverUid);

    final batch = _firestore.batch();
    batch.set(statsGrantDoc,
        {'createdAt': currentClockTimestamp, 'grantedTo': receiverUid});
    batch.set(
        userCollaborators, {'stats': true, 'createdAt': currentClockTimestamp});
    await batch.commit();
  }

  @override
  Future<void> revokeStatsAccess(String userId) async {
    final grantedAccessDoc = _firestore
        .collection('sharing')
        .doc(userId)
        .collection('sharedStats')
        .doc('stats')
        .collection('grantedTo')
        .doc(userId);
    await grantedAccessDoc.delete();
  }

  @override
  Future<Iterable<UserProfile>> listOwnStatsGrants() async {
    final querySnapshot = await _firestore
        .collectionGroup('grantedTo')
        .where('grantedTo', isEqualTo: userId)
        .get()
        .logError('Error loading granted user IDs');
    final statsGrantReferences = querySnapshot.docs
        .where((doc) => doc.reference.path.contains('sharedStats'));
    if (statsGrantReferences.isEmpty) {
      _log.d('No stats grants available');
      return [];
    }
    final userIds = statsGrantReferences.map((doc) => doc.id);
    final usersSnapshot = await _firestore
        .collection(usersCollectionName)
        .where(FieldPath.documentId, whereIn: userIds)
        .get()
        .logError('Error loading collaborators profiles');
    return usersSnapshot.docs
        .map((snapshot) => UserProfile.fromJson(snapshot.id, snapshot.data()));
  }

  @override
  Future<Iterable<UserProfile>> listGivenStatsGrants() async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('collaborators')
        .get()
        .logError('Error loading collaborator IDs');
    if (snapshot.docs.isEmpty) {
      return [];
    }
    final userIds = snapshot.docs.map((doc) => doc.id);
    final usersSnapshot = await _firestore
        .collection(usersCollectionName)
        .where(FieldPath.documentId, whereIn: userIds)
        .get()
        .logError('Error loading collaborators profiles');
    return usersSnapshot.docs
        .map((snapshot) => UserProfile.fromJson(snapshot.id, snapshot.data()));
  }

  @override
  Future<void> grantAccessToDeck(
      String deckId, String receivingUserEmail) async {
    final emailDigest = receivingUserEmail.sha256Digest;
    final snapshot =
        await _firestore.collection('emailToUid').doc(emailDigest).get();
    if (!snapshot.exists) {
      throw Exception('Email not registered');
    }
    final receiverUid = snapshot.data()!['uid'];
    final batch = _firestore.batch();
    final grantedAccessDoc = _firestore
        .collection('sharing')
        .doc(userId)
        .collection('sharedDecks')
        .doc(deckId)
        .collection('grantedTo')
        .doc(receiverUid);
    final userCollaborators = _firestore
        .collection('userCollaborators')
        .doc(userId)
        .collection('collaborators')
        .doc(receiverUid);
    batch.set(grantedAccessDoc, {
      'createdAt': currentClockTimestamp,
      'ownerId': userId,
      'grantedTo': receiverUid
    });
    batch.set(userCollaborators, {'createdAt': currentClockTimestamp},
        SetOptions(merge: true));
    await batch.commit();
  }

  @override
  Future<void> revokeAccessToDeck(
      String deckId, String receivingUserEmail) async {
    final emailDigest = receivingUserEmail.sha256Digest;
    final snapshot =
        await _firestore.collection('emailToUid').doc(emailDigest).get();
    if (!snapshot.exists) {
      throw Exception('Email not registered');
    }
    final receiverUid = snapshot.data()!['uid'];
    final grantedAccessDoc = _firestore
        .collection('sharing')
        .doc(userId)
        .collection('sharedDecks')
        .doc(deckId)
        .collection('grantedTo')
        .doc(receiverUid);
    await grantedAccessDoc.delete();
  }

  @override
  Future<Iterable<UserProfile>> listGrantedDeckAccess(String deckId) async {
    final snapshot = await _firestore
        .collection('sharing')
        .doc(userId)
        .collection('sharedDecks')
        .doc(deckId)
        .collection('grantedTo')
        .get()
        .logError('Error loading decks collaborators');
    if (snapshot.docs.isEmpty) {
      return [];
    }
    final userIds = snapshot.docs.map((doc) => doc.id);
    final usersSnapshot = await _firestore
        .collection(usersCollectionName)
        .where(FieldPath.documentId, whereIn: userIds)
        .get()
        .logError('Error loading collaborators profiles');
    return usersSnapshot.docs
        .map((snapshot) => UserProfile.fromJson(snapshot.id, snapshot.data()));
  }

  /// List of decks shared with the user
  /// Function returns a collection of tuples of owner and the deck ID
  Future<Iterable<(UserId, DeckId)>> getSharedDeckIds() async {
    final querySnapshot = await _firestore
        .collectionGroup('grantedTo')
        .where('grantedTo', isEqualTo: userId)
        .get();
    final deckReferences = querySnapshot.docs
        .where((doc) => doc.reference.path.contains('sharedDecks'));
    return deckReferences.map((doc) => (
          doc.reference.parent.parent!.parent.parent!.id,
          doc.reference.parent.parent!.id
        ));
  }

  @override
  Future<Iterable<Deck>> listSharedDecks() async {
    final deckIds =
        await getSharedDeckIds().logError('Error loading shared decks');
    if (deckIds.isEmpty) {
      _log.d('No shared decks');
      return [];
    }
    final Map<UserId, Iterable<DeckId>> groupedDecks =
        deckIds.fold({}, (map, next) {
      if (map.containsKey(next.$1)) {
        map[next.$1] = [...map[next.$1]!, next.$2];
      } else {
        map[next.$1] = [next.$2];
      }
      return map;
    });
    final decks = await Future.wait(groupedDecks.entries.map((entry) async {
      final ownerId = entry.key;
      final deckIds = entry.value;
      _log.d('Loading decks for user $ownerId with IDs $deckIds');
      final decksSnapshot = await _firestore
          .collection(decksCollectionName)
          .doc(ownerId)
          .collection(userPrefix(decksCollectionName))
          .where(FieldPath.documentId, whereIn: deckIds)
          .withDecksConverter
          .get();
      return decksSnapshot.docs.map((s) => s.data());
    }));
    final Iterable<Deck> result =
        decks.fold([], (agg, next) => [...agg, ...next]);
    return result;
  }
}