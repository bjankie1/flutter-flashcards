import 'dart:math';

import 'package:clock/clock.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    show AuthCredential, GoogleAuthProvider, User;
import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/dates.dart';
import 'package:flutter_flashcards/src/model/users_collaboration.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_flashcards/src/model/cards.dart' as model;
import 'package:flutter_flashcards/src/model/firebase/firebase_repository.dart';

const loggedInUserId = 'logged_in_user_id';
const loggedInUserEmail = 'bob@somedomain.com';

Future<User?> mockSignIn(String id, String email) async {
  final googleSignIn = MockGoogleSignIn();
  final signinAccount = await googleSignIn.signIn();
  final googleAuth = await signinAccount?.authentication;
  final AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );
  final user = MockUser(
    isAnonymous: false,
    uid: id,
    email: email,
    displayName: 'Bob',
  );
  final auth = MockFirebaseAuth(mockUser: user);
  final result = await auth.signInWithCredential(credential);
  return result.user;
}

void main() {
  final firestore = FakeFirebaseFirestore();

  late FirebaseCardsRepository repository;
  setUp(() async {
    User? user = await mockSignIn(loggedInUserId, loggedInUserEmail);

    // TestWidgetsFlutterBinding.ensureInitialized();
    repository = FirebaseCardsRepository(firestore, user);
  });

  group('Decks management', () {
    tearDown(() async {
      await firestore.clearPersistence();
    });

    test('Save and load deck', () async {
      final deck = model.Deck(name: 'Test Deck');
      await repository.saveDeck(deck);

      final loadedDecks = await repository.loadDecks();
      expect(loadedDecks.length, 1);
      expect(loadedDecks.first.name, 'Test Deck');
    });

    test('Delete deck and associated cards', () async {
      final deck = model.Deck(name: 'Test Deck 2');
      final savedDeck = await repository.saveDeck(deck);
      final deckId = savedDeck.id!;

      await repository.saveCard(model.Card(
        deckId: deckId,
        question: 'Question 1',
        answer: "Answer 1",
      ));

      await repository.deleteDeck(deckId);

      final loadedDecks = await repository.loadDecks();
      expect(loadedDecks.isEmpty, true);
      final cards = await repository.loadCards(deckId);
      expect(cards.isEmpty, true);
    });

    test('Add, delete and update card', () async {
      final card = model.Card(
        deckId: 'deck1',
        question: 'Question',
        answer: 'Answer',
      );
      final addedCard = await repository.saveCard(card);

      var loadedCards = await repository.loadCards('deck1');
      expect(loadedCards.length, 1);

      await repository.deleteCard(addedCard.id!);
      final loadedCardsAfterDelete = await repository.loadCard(addedCard.id!);
      expect(loadedCardsAfterDelete, null);

      final savedCard3 =
          await repository.saveCard(card.copyWith(answer: 'New answer'));
      final loadedCardsAfterUpdate = await repository.loadCard(savedCard3.id!);
      expect(loadedCardsAfterUpdate?.answer, 'New answer');
    });
  });

  group('Card reviews', () {
    tearDown(() async {
      await firestore.clearPersistence();
    });

    test('Save and load card stats', () async {
      final deck = model.Deck(name: 'Test Deck 3');
      await repository.saveDeck(deck);

      final card = model.Card(
        id: 'card1',
        deckId: 'deck1',
        question: 'Question 1',
        answer: 'Answer 1',
      );
      await repository.saveCard(card);

      final frontStats = await repository.loadCardStats(
          card.id!, model.CardReviewVariant.front);
      expect(frontStats.cardId, card.id);
      expect(frontStats.variant, model.CardReviewVariant.front);
      expect(frontStats.state, model.State.newState);
      expect(frontStats.nextReviewDate, null);
      expect(frontStats.stability, 0);
      await expectLater(
          repository.loadCardStats(card.id!, model.CardReviewVariant.back),
          throwsA(isA<Exception>()));
    });

    test('recorded answer reflected ins tats', () async {
      final deck = model.Deck(name: 'Test Deck 3');
      await repository.saveDeck(deck);

      final card = model.Card(
        id: 'card1',
        deckId: 'deck1',
        question: 'Question 1',
        answer: 'Answer 1',
      );
      final duration = Duration(seconds: 15);
      final reviewTime = clock.agoBy(duration);
      await repository.saveCard(card);
      repository.recordAnswer(card.id!, model.CardReviewVariant.front,
          model.Rating.good, reviewTime, duration);

      final stats = await repository.loadCardStats(
          card.id!, model.CardReviewVariant.front);
      final answers = await repository.loadAnswers(reviewTime, reviewTime);
      expect(stats.difficulty, 0);
      expect(answers.length, 1);
      expect(answers.first.rating, model.Rating.good);
      // TODO: evaluate stats and answers
    });
  });

  group('Collaboration Invitations', () {
    final userLogged = UserProfile(
        id: loggedInUserId,
        email: loggedInUserEmail,
        name: 'john',
        theme: ThemeMode.system,
        locale: Locale('pl'),
        photoUrl: '');
    final user1 = UserProfile(
        id: 'id1',
        email: 'user1@example.com',
        name: 'john',
        theme: ThemeMode.system,
        locale: Locale('pl'),
        photoUrl: '');
    final user2 = UserProfile(
        id: 'id2',
        email: 'user2@example.com',
        name: 'john',
        theme: ThemeMode.system,
        locale: Locale('pl'),
        photoUrl: '');

    setUp(() async {
      await repository.saveUser(userLogged);
      await firestore.collection('users').doc(user1.id).set(user1.toJson());
      await firestore.collection('users').doc(user2.id).set(user2.toJson());
    });

    tearDown(() async {
      await firestore.clearPersistence();
    });

    Future<void> changeLogin(UserProfile newUser) async {
      User? newUserLogged = await mockSignIn(newUser.id, newUser.email);
      repository = FirebaseCardsRepository(firestore, newUserLogged);
    }

    test('saveCollaborationInvitation saves invitation successfully', () async {
      await repository.saveCollaborationInvitation(user1.email);

      final invitations = await repository.pendingInvitations();
      expect(invitations.length, 0);
      final invitationsSent = await repository.pendingInvitations(sent: true);
      expect(invitationsSent.length, 1);
      expect(invitationsSent.first.initiatorUserId, loggedInUserId);
      expect(invitationsSent.first.receivingUserId, isNull);
      expect(invitationsSent.first.status, InvitationStatus.pending);
    });

    test('saveCollaborationInvitation throws exception if user not found',
        () async {
      // the test would have fail if the mock supported security rules
      await expectLater(
          repository.saveCollaborationInvitation('nonexistent@example.com'),
          throwsA(isA<Exception>()));
    });

    test('pendingInvitations retrieves received invitations', () async {
      withClock(Clock.fixed(DateTime(2021)), () async {
        await repository.saveCollaborationInvitation(user2.email);

        final collaborators = await repository.loadCollaborators();
        expect(collaborators.length, 0);

        // Log as user2
        await changeLogin(user2);

        final invitations = await repository.pendingInvitations();

        expect(invitations.length, 1);
        expect(invitations.first.receivingUserId, user2.id);
        expect(invitations.first.initiatorUserId, userLogged.id);
        expect(invitations.first.sentTimestamp,
            currentClockDateTime.toTimestamp());

        final collaborators2 = await repository.loadCollaborators();
        expect(collaborators2.length, 0);
      });
    });

    test(
        'changeInvitationStatus updates invitation status both users start collaboration',
        () async {
      await repository.saveUser(userLogged);
      await repository.saveUser(user1);
      await repository.saveCollaborationInvitation(user1.email);
      await repository.saveCollaborationInvitation(user2.email);

      await changeLogin(user1);
      final invitations = await repository.pendingInvitations();
      expect(invitations.length, 1);
      expect(invitations.first.status, InvitationStatus.pending);
      await repository.changeInvitationStatus(
          invitations.first.id, InvitationStatus.accepted);
      final invitationsAgain = await repository.pendingInvitations();
      expect(invitationsAgain.length, 0);
      final collaborators1 = await repository.loadCollaborators();
      expect(collaborators1.length, 1);
      expect(collaborators1, contains(userLogged.id));
      await expectLater(
          firestore
              .collection('users')
              .doc(user1.id)
              .collection('collaborators')
              .doc(userLogged.id)
              .get()
              .then((doc) => doc.exists),
          completion(isTrue));
      await expectLater(
          firestore
              .collection('users')
              .doc(loggedInUserId)
              .collection('collaborators')
              .doc(user1.id)
              .get()
              .then((doc) => doc.exists),
          completion(isTrue));

      // log in back the original user
      await changeLogin(userLogged);
      final sentInvitations = await repository.pendingInvitations(sent: true);
      expect(sentInvitations.length, 1);
      final collaborators = await repository.loadCollaborators();
      expect(collaborators.length, 1);
      expect(collaborators, contains(user1.id));
    });

    test('changeInvitationStatus throws exception if invitation not found',
        () async {
      expectLater(
          () => repository.changeInvitationStatus(
              'nonexistent_id', InvitationStatus.accepted),
          throwsA(isA<Exception>()));
    });

    test(
        'send the same invitation for the second time should throw an exception',
        () async {
      await repository.saveCollaborationInvitation(user1.email);
      await expectLater(repository.saveCollaborationInvitation(user1.email),
          throwsA(isA<Exception>()));
    });
  });
}
