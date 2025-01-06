import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_flashcards/src/model/cards.dart' as model;
import 'package:flutter_flashcards/src/model/firebase/firebase_repository.dart';
import 'package:logger/logger.dart';

void main() {
  final log = Logger();
  late FirebaseCardsRepository repository;
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    log.i('Initialized binding');
    await Firebase.initializeApp();
    log.i('Initialized Firebase app');
    FirebaseFirestore.instance.settings = const Settings(
      host: 'localhost:8080',
      sslEnabled: false,
      persistenceEnabled: false,
    );
    FirebaseFirestore.instance.useFirestoreEmulator('127.0.0.1', 8080);

    // [Authentication | localhost:9099]
    log.i('Connected to emulator');
    repository = FirebaseCardsRepository();
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
