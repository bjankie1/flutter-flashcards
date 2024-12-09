import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_flashcards/src/model/cards.dart' as model;
import 'package:flutter_flashcards/src/model/firebase/firebase_repository.dart';

void main() {
  void main() {
    late FirebaseCardsRepository repository;
    late FakeFirebaseFirestore firestore;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();
      FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
      repository = FirebaseCardsRepository();
      firestore = FakeFirebaseFirestore();
    });

    test('Save and load deck', () async {
      final deck = model.Deck(name: 'Test Deck');
      await repository.saveDeck(deck);

      final loadedDecks = await repository.loadDecks();
      expect(loadedDecks.length, 1);
      expect(loadedDecks[0].name, 'Test Deck');
    });

    test('Delete deck and associated cards', () async {
      final deck = model.Deck(name: 'Test Deck 2');
      await repository.saveDeck(deck);
      await repository.saveCard(model.Card(
        deckId: deck.name,
        question: model.Content(text: "Question 1"),
        answer: "Answer 1",
      ));

      await repository.deleteDeck(deck.name);

      final loadedDecks = await repository.loadDecks();
      expect(loadedDecks.isEmpty, true);

      final cardsSnapshot = await firestore.collection('cards').get();
      expect(cardsSnapshot.docs.isEmpty, true);
    });

    test('Add, delete and update card', () async {
      final card = model.Card(
        deckId: 'deck1',
        question: model.Content(text: 'Question'),
        answer: 'Answer',
      );
      await repository.saveCard(card);

      var loadedCards = await firestore.collection('cards').get();
      expect(loadedCards.docs.length, 1);

      await repository.deleteCard(card.question.text);
      loadedCards = await firestore.collection('cards').get();
      expect(loadedCards.docs.length, 0);

      await repository.saveCard(card);
      await repository.saveCard(card.copyWith(answer: 'New answer'));
      loadedCards = await firestore.collection('cards').get();
      final updatedCard = model.Card.fromJson(loadedCards.docs.first.data());
      expect(updatedCard.answer, 'New answer');
    });
  }
}
