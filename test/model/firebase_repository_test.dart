import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    show AuthCredential, GoogleAuthProvider, User;
import 'package:flutter/material.dart';
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

final firestore = FakeFirebaseFirestore();

void main() {
  late FirebaseCardsRepository repository;
  setUp(() async {
    User? user = await mockSignIn(loggedInUserId, loggedInUserEmail);

    // TestWidgetsFlutterBinding.ensureInitialized();
    repository = FirebaseCardsRepository(firestore, user);
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

    Future<void> changeLogin(UserProfile newUser) async {
      User? newUserLogged = await mockSignIn(newUser.id, newUser.email);
      repository = FirebaseCardsRepository(firestore, newUserLogged);
    }

    test('saveCollaborationInvitation saves invitation successfully', () async {
      await repository.saveCollaborationInvitation(user1.email);

      final invitations = await repository.pendingInvitations();
      expect(invitations.length, 0);
      final invitationsSent = await repository.pendingInvitations(sent: true);
      expect(invitationsSent.first.initiatorUserId, loggedInUserId);
      expect(invitationsSent.first.receivingUserId, user1.id);
      expect(invitationsSent.first.status, InvitationStatus.pending);
    });

    test('saveCollaborationInvitation throws exception if user not found',
        () async {
      await expectLater(
          repository.saveCollaborationInvitation('nonexistent@example.com'),
          throwsA(isA<Exception>()));
    });

    test('pendingInvitations retrieves received invitations', () async {
      final now = Timestamp.now();
      await repository.saveCollaborationInvitation(user2.email);

      // Log as user2
      await changeLogin(user2);

      final invitations = await repository.pendingInvitations();

      expect(invitations.length, 1);
      expect(invitations.first.receivingUserId, user2.id);
      expect(invitations.first.initiatorUserId, userLogged.id);
      expect(
          invitations.first.sentTimestamp.millisecondsSinceEpoch,
          closeTo(now.millisecondsSinceEpoch,
              10000)); // 10 second proximity should be enough
    });

    test('changeInvitationStatus updates invitation status', () async {
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
  });
}
