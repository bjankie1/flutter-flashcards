import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter_flashcards/src/common/crypto.dart';
import 'package:flutter_flashcards/src/common/dates.dart';
import 'package:flutter_flashcards/src/common/iterable_extensions.dart';
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

  CollectionReference<DeckGroup> get withDeckGroupsConverter =>
      withConverter<DeckGroup>(
          fromFirestore: (doc, _) => DeckGroup.fromJson(doc.id, doc.data()!),
          toFirestore: (deckGroup, _) => deckGroup.toJson());

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
const deckGroupsCollectionName = 'deckGroups';

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

  CollectionReference<DeckGroup> get _deckGroupsCollection =>
      _collection(deckGroupsCollectionName).withDeckGroupsConverter;

  CollectionReference<UserProfile> get _usersCollection =>
      _firestore.collection(usersCollectionName).withConverter<UserProfile>(
          fromFirestore: (doc, _) => UserProfile.fromJson(doc.id, doc.data()!),
          toFirestore: (user, _) => user.toJson());

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

  Future<void> _updateCard(Card card) async {
    _log.d('Updating card');
    final docRef = _cardsCollection.doc(card.id);
    final stats = CardStats.statsForCard(card);
    final statsDocs = await Future.wait(stats.map((s) async =>
            await _cardStatsCollection
                .doc(s.idValue)
                .get()
                .then((snapshot) => (s, snapshot.reference, snapshot.exists))))
        .logError('Error loading stats for card ${card.id}');
    await docRef.set(card);
    for (final record in statsDocs) {
      if (!record.$3) {
        _log.d('Creating stats for card ${card.id} ${record.$1.variant}');
        await record.$2.set(record.$1);
      }
    }
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
  Future<Iterable<Card>> loadCards(String deckId) async {
    _log.d('Loading cards for deck $deckId');
    return await _loadCards({deckId}, {});
  }

  void _validateUser() {
    if (_user == null) {
      _log.w('User not logged in while attempting to load decks.');
      throw Exception('User not logged in');
    }
  }

  @override
  Future<Card> saveCard(Card card) async {
    await _updateCard(card)
        .whenComplete(() => notifyCardChanged())
        .logError('Error saving card');
    return card;
  }

  @override
  Future<Deck> saveDeck(Deck deck) async {
    if (deck.name.trim().isEmpty) throw 'Deck name cannot be empty';
    final docRef = _decksCollection.doc(deck.id);
    final savedDeck = deck.id == null ? deck.copyWith(id: docRef.id) : deck;
    await docRef.set(savedDeck, SetOptions(merge: true)).then(
        (value) => _log.d("Deck successfully updated!"),
        onError: (e) => _log.e("Error updating deck: $e"));
    notifyDeckChanged();
    return savedDeck;
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

  Future<Iterable<String>> _deckCardsIds(DeckId deckId) async {
    final snapshots =
        await _cardsCollection.where('deckId', isEqualTo: deckId).get();
    return snapshots.docs.map((doc) => doc.id);
  }

  Future<Iterable<String>> _deckGroupCardsIds(DeckGroupId deckGroupId) async {
    final deckGroup = await loadDeckGroup(deckGroupId);
    if (deckGroup == null ||
        deckGroup.decks == null ||
        deckGroup.decks!.isEmpty) {
      return [];
    }
    final deckIds = deckGroup.decks;
    final cardIds = await Future.wait(deckIds!.map((deckId) async {
      final result =
          await _cardsCollection.where('deckId', isEqualTo: deckId).get();
      return result.docs.map((doc) => doc.id);
    }));
    return cardIds.expand((element) => element);
  }

  /// Loads identifiers and review variants of cards to review based on `nextReviewDate`
  @override
  Future<Map<State, int>> cardsToReviewCount(
      {DeckId? deckId, DeckGroupId? deckGroupId}) async {
    _log.d('Loading cards to review count');
    // Cards ready for review
    final baseQuery = _cardStatsCollection.where(Filter.or(
        Filter('nextReviewDate', isLessThanOrEqualTo: currentClockDateTime),
        Filter('nextReviewDate', isNull: true)));

    Future<Iterable<Iterable<String>>?> batchCardIds() async {
      if (deckId != null || deckGroupId != null) {
        final cardIds = deckId != null
            ? await _deckCardsIds(deckId)
            : await _deckGroupCardsIds(deckGroupId!);
        return cardIds.splitIterable(15);
      }
      // null indicates no deck specific card filtering
      return null;
    }

    final cardIds = await batchCardIds();

    if (cardIds != null && cardIds.isEmpty) {
      return {
        State.newState: 0,
        State.learning: 0,
        State.relearning: 0,
        State.review: 0
      };
    }

    countState(State state) async {
      var query = baseQuery.where('state', isEqualTo: state.name);
      final results = await Future.wait((cardIds ?? [[]]).map((batch) async {
        if (batch.isNotEmpty) {
          query = query.where('cardId', whereIn: batch);
        }
        var countQuery = query.count();
        final result = await countQuery.get().then((value) {
          _log.d('Loaded ${value.count} $state cards');
          return value;
        }).logError('Error counting cards to review');
        return result.count ?? 0;
      }));
      return results.fold(0, (agg, next) => agg + next);
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
      _log.d('Identified ${toReview.length} to review');

      // New cards
      final statsSnapshotNew = await _cardStatsCollection
          .where('nextReviewDate', isNull: true)
          .limit(newLimit ?? 200)
          .get()
          .logError('Error querying new cards to review');
      final newCards = statsSnapshotNew.docs.map((doc) => doc.data()).toList();
      _log.d('New cards to review: ${newCards.length}');

      final allCards = [...toReview, ...newCards];
      _log.d('All cards to review: ${allCards.length}');

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
  Future<Iterable<Card>> loadCardToReview(
      {DeckId? deckId, DeckGroupId? deckGroupId}) async {
    // First step:
    // load cards to review IDs and corresponding card review variant.
    final cardIdsWithVariants =
        await _cardIdsToReview().logError('Error identifying cards to review');
    _log.d('Cards to review: ${cardIdsWithVariants.length}');
    // Load corresponding cards for each card ID from the tuple
    final cardIds =
        cardIdsWithVariants.map((t) => t.$1).toSet(); // unique card Ids
    if (cardIds.isEmpty) return Iterable.empty();

    // Second step:
    // Identify decks IDs from a deck group the cards should be loaded for.
    // The cards can be also loaded for a single deck if provided or all decks.
    // The deck IDs set can be empty which means all cards should be loaded.
    final deckIds = List<String>.empty(growable: true);
    if (deckId != null) {
      deckIds.add(deckId);
    } else if (deckGroupId != null) {
      final deckGroup = await loadDeckGroup(deckGroupId);
      if (deckGroup != null && deckGroup.decks != null) {
        deckIds.addAll(deckGroup.decks!);
      }
    }

    // Load the cards for given decks.
    Iterable<Card> cards = await _loadCards(deckIds.toSet(), cardIds);

    // Third step:
    // Combine cards data with cards IDs identified for review. This operation
    // should also filter only the cards that were identified for review in
    // the first step.
    final cardsMappedToId =
        Map.fromEntries(cards.map((card) => MapEntry(card.id, card)));
    final result = cardIdsWithVariants
        .where((pair) => cardsMappedToId.containsKey(pair.$1))
        .map((pair) => cardsMappedToId[pair.$1]!);
    return result;
  }

  /// Executes query by splitting ids into batches. The method does not verify
  /// if the query includes other criteria that would impact the firebase OR
  /// size limitation of 30.
  Future<Iterable<T>> _batchQuery<T>(
      {required Query<T> query,
      required String field,
      required Iterable<String> ids,
      int batchSize = 30}) async {
    final batches = ids.splitIterable(batchSize);
    final result = await Future.wait(
        batches.map((batch) => query.where(field, whereIn: batch).get()));
    return result.expand((element) => element.docs.map((doc) => doc.data()));
  }

  /// Loads cards for given decks or card IDs. If decks are empty, it is
  /// expected that cardIds are not empty. If deckIds are not empty the cardIds
  /// are ignored.
  /// The method batches the query to overcome firebase limit on OR queries by
  /// splitting deckIds or cardIds into batches of 30.
  /// The method overcomes firebase limit on OR queries
  /// https://firebase.google.com/docs/firestore/query-data/queries#limits_on_or_queries
  Future<Iterable<Card>> _loadCards(
      Set<String> deckIds, Set<String> cardIds) async {
    final collectionGroup = _firestore
        .collectionGroup(userPrefix(cardsCollectionName))
        .withCardsConverter;
    final result = deckIds.isNotEmpty
        ? _batchQuery(query: collectionGroup, field: 'deckId', ids: deckIds)
        : _batchQuery(query: collectionGroup, field: 'cardId', ids: cardIds);
    final cards = await result.logError('Error loading cards to review');
    _log.d('Loaded ${cards.length} cards to review');
    return cards;
  }

  @override
  Future<void> saveCardStats(CardStats stats) async {
    _log.d(
        'Saving card stats ${stats.cardId}::${stats.variant.name} with next review on ${stats.nextReviewDate}');
    final docRef = _cardStatsCollection.doc(stats.idValue);
    await docRef.set(stats).then(
        (value) => _log.d('Review answer successfully recorded!'),
        onError: (e) => _log.w('Error recording review answer: $e'));
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
    _log.d('Loading answers for $dayStart to $dayEnd for user $uid');

    final collection = uid != null
        ? _firestore
            .collection(cardAnswersCollectionName)
            .doc(uid)
            .collection(userPrefix(cardAnswersCollectionName))
            .withCardAnswerConverter
        : _cardAnswersCollection;
    final snapshot = await collection
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
    final snapshot = await _firestore
        .collectionGroup(userPrefix(decksCollectionName))
        .withDecksConverter
        .where('deckId', isEqualTo: deckId)
        .get()
        .logError('Error loading deck $deckId');
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
  Future<Iterable<Card>> loadCardsByIds(Iterable<String> cardIds) async =>
      await _loadCards({}, cardIds.toSet());

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
  Future<Set<String>> listCollaborators() async {
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

  /// List users who have granted access to stats
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
    final userIds = statsGrantReferences
        .map((doc) => doc.reference.parent.parent!.parent.parent!.id);
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
        .collection('sharing')
        .doc(userId)
        .collection('sharedStats')
        .doc('stats')
        .collection('grantedTo')
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
  Future<Map<UserId, Iterable<Deck>>> listSharedDecks() async {
    _log.d('Loading shared decks');
    final deckIds =
        await getSharedDeckIds().logError('Error loading shared decks');
    if (deckIds.isEmpty) {
      _log.d('No shared decks');
      return {};
    }
    _log.d('Loaded ${deckIds.length} shared decks');
    final Map<UserId, Iterable<DeckId>> groupedDecks =
        deckIds.fold({}, (map, next) {
      if (map.containsKey(next.$1)) {
        map[next.$1] = [...map[next.$1]!, next.$2];
      } else {
        map[next.$1] = [next.$2];
      }
      return map;
    });
    final entries = await Future.wait(groupedDecks.entries.map((entry) async {
      final ownerId = entry.key;
      final deckIds = entry.value;
      _log.d('Loading decks for user $ownerId with IDs $deckIds');
      final decksSnapshot = await _firestore
          .collection(decksCollectionName)
          .doc(ownerId)
          .collection(userPrefix(decksCollectionName))
          .where(FieldPath.documentId, whereIn: deckIds)
          .withDecksConverter
          .get()
          .logError('Failed loading shared decks from $ownerId');
      return MapEntry(ownerId, decksSnapshot.docs.map((s) => s.data()));
    }));
    return Map.fromEntries(entries);
  }

  @override
  Future<void> incorporateSharedDeck(String deckId) async {
    final cards = await _firestore
        .collectionGroup(userPrefix(cardsCollectionName))
        .where('deckId', isEqualTo: deckId)
        .withCardsConverter
        .get();
    _log.d('There are ${cards.size} to incorporate from $deckId');
    for (final card in cards.docs) {
      final stats = CardStats.statsForCard(card.data());
      final statsDocs = await Future.wait(stats.map((s) async =>
          await _cardStatsCollection
              .doc(s.idValue)
              .get()
              .then((snapshot) => (s, snapshot.reference, snapshot.exists))));
      for (final record in statsDocs) {
        if (!record.$3) {
          _log.d('Added card ${record.$1.idValue} to review stats');
          await record.$2.set(record.$1);
        }
      }
    }
  }

  @override
  Future<void> addDeckToGroup(String deckId, String groupId) async {
    _log.d('Adding deck $deckId to group $groupId');
    final doc = _deckGroupsCollection.doc(groupId);
    final data = await doc.get().then((snapshot) => snapshot.data());
    if (data == null) {
      _log.d('Group $groupId not found');
      throw 'Group $groupId not found';
    }
    if (data.decks!.contains(deckId)) {
      _log.d('Deck $deckId already in group $groupId');
      return;
    }
    final List<DeckId> deckIds = [...data.decks ?? [], deckId];

    await doc.update({'decks': deckIds});
    notifyDeckGroupChanged();
  }

  @override
  Future<DeckGroup> createDeckGroup(String name, String? description) async {
    if (name.trim().isEmpty) {
      throw 'Group name cannot be empty and needs to contain non-whitespace characters';
    }
    _log.d('Creating deck group $name');
    final existing = await _deckGroupsCollection.get();
    if (existing.docs
        .where((doc) => doc.data().name.toLowerCase() == name.toLowerCase())
        .isNotEmpty) {
      throw 'Group of name $name already exists';
    }
    final docRef = _deckGroupsCollection.doc();
    final group =
        DeckGroup(id: docRef.id, name: name, description: description);
    await docRef.set(group).logError('Error creating deck group');
    return group;
  }

  @override
  Future<void> deleteDeckGroup(String groupId) async {
    _log.d('Deleting deck group $groupId');
    await _deckGroupsCollection
        .doc(groupId)
        .delete()
        .logError('Error deleting deck group');
  }

  @override
  Future<DeckGroup?> loadDeckGroup(DeckGroupId deckGroupId) async {
    _log.d('Loading deck group $deckGroupId');
    return await _deckGroupsCollection
        .doc(deckGroupId)
        .get()
        .then((snapshot) => snapshot.data())
        .logError('Error loading deck group');
  }

  @override
  Future<Iterable<DeckGroup>> loadDeckGroups() async {
    _log.d('Loading deck groups');
    return await _deckGroupsCollection
        .get()
        .then((snapshot) => snapshot.docs.map((doc) => doc.data()))
        .logError('Error loading deck groups');
  }

  @override
  Future<void> removeDeckFromGroup(String deckId, String groupId) async {
    _log.d('Removing deck $deckId from group $groupId');
    final doc = _deckGroupsCollection.doc(groupId);
    final group = await doc.get().then((snapshot) => snapshot.data());
    if (group == null) {
      _log.d('Group $groupId not found');
      return;
    }
    if (group.decks == null) {
      _log.d('Group $groupId has no decks');
      return;
    }
    final deckIds = [...group.decks!]..remove(deckId);
    await doc.update({'decks': deckIds}).logError(
        'Error removing deck $deckId from group $groupId');
    notifyDeckGroupChanged();
  }
}