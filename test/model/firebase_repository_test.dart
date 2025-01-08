import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    show AuthCredential, GoogleAuthProvider, User;
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

import 'package:flutter_flashcards/src/model/cards.dart' as model;
import 'package:flutter_flashcards/src/model/firebase/firebase_repository.dart';

Future<User?> mockSignIn() async {
  final googleSignIn = MockGoogleSignIn();
  final signinAccount = await googleSignIn.signIn();
  final googleAuth = await signinAccount?.authentication;
  final AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );
  final user = MockUser(
    isAnonymous: false,
    uid: 'someuid',
    email: 'bob@somedomain.com',
    displayName: 'Bob',
  );
  final auth = MockFirebaseAuth(mockUser: user);
  final result = await auth.signInWithCredential(credential);
  return result.user;
}

void main() {
  late FirebaseCardsRepository repository;
  setUp(() async {
    final firestore = FakeFirebaseFirestore();
    User? user = await mockSignIn();

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

    await repository.deleteDeck(deck.name);

    final loadedDecks = await repository.loadDecks();
    expect(loadedDecks.isEmpty, true);
    final cards = await repository.loadCards(deckId);
    expect(cards.isEmpty, true);
  });

  //   test('Add, delete and update card', () async {
  //     final card = model.Card(
  //       deckId: 'deck1',
  //       question: model.Content(text: 'Question'),
  //       answer: 'Answer',
  //     );
  //     await repository.saveCard(card);

  //     var loadedCards = await firestore.collection('cards').get();
  //     expect(loadedCards.docs.length, 1);

  //     await repository.deleteCard(card.question.text);
  //     loadedCards = await firestore.collection('cards').get();
  //     expect(loadedCards.docs.length, 0);

  //     await repository.saveCard(card);
  //     await repository.saveCard(card.copyWith(answer: 'New answer'));
  //     loadedCards = await firestore.collection('cards').get();
  //     final updatedCard = model.Card.fromJson(loadedCards.docs.first.data());
  //     expect(updatedCard.answer, 'New answer');
  //   });
}
