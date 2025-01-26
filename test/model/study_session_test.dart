import 'package:clock/clock.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_flashcards/src/model/cards.dart' as model;
import 'package:flutter_flashcards/src/model/repository.dart';
import 'package:flutter_flashcards/src/model/study_session.dart';
import 'package:mocktail/mocktail.dart';

class MockCardsRepository extends Mock implements CardsRepository {}

class MockCard extends Mock implements model.Card {
  MockCard();

  factory MockCard.withId(String id) {
    final card = MockCard();
    when(() => card.id).thenReturn(id);
    return card;
  }
}

void main() {
  late MockCardsRepository mockRepository;

  setUp(() {
    mockRepository = MockCardsRepository();
  });

  setUpAll(() {
    registerFallbackValue(model.CardReviewVariant.front);
    registerFallbackValue(model.Rating.good);
    registerFallbackValue(Duration(days: 1));
  });

  test('startStudySession loads and shuffles cards', () async {
    final studySession = StudySession(repository: mockRepository);
    final cards = [MockCard(), MockCard(), MockCard()];
    when(() => mockRepository.loadCardToReview(deckId: null))
        .thenAnswer((_) async => cards);

    await studySession.startStudySession();

    verify(() => mockRepository.loadCardToReview(deckId: null)).called(1);
    expect(studySession.remainingCards, 3);
    expect(studySession.currentCard, isNotNull);
  });

  test(
      'startStudySession with deckId loads and shuffles cards from specific deck',
      () async {
    final cards = [MockCard(), MockCard(), MockCard()];
    when(() => mockRepository.loadCardToReview(deckId: 'testDeckId'))
        .thenAnswer((_) async => cards);

    final deckIdStudySession =
        StudySession(repository: mockRepository, deckId: 'testDeckId');
    await deckIdStudySession.startStudySession();

    verify(() => mockRepository.loadCardToReview(deckId: 'testDeckId'))
        .called(1);
    expect(deckIdStudySession.remainingCards, 3);
    expect(deckIdStudySession.currentCard, isNotNull);
  });

  test('startStudySession handles empty card list', () async {
    final studySession = StudySession(repository: mockRepository);
    when(() => mockRepository.loadCardToReview(deckId: null))
        .thenAnswer((_) async => []);

    await studySession.startStudySession();

    verify(() => mockRepository.loadCardToReview(deckId: null)).called(1);
    expect(studySession.remainingCards, 0);
    expect(studySession.currentCard, isNull);
  });

  test('rateAnswer records answer and removes card', () async {
    final studySession = StudySession(repository: mockRepository);
    final card = MockCard.withId('cardId');
    when(() => mockRepository.loadCardToReview(deckId: null))
        .thenAnswer((_) async => [card]);
    when(() => mockRepository.recordAnswer(any(), any(), any(), any(), any()))
        .thenAnswer((_) async {});

    final startTime = DateTime(2024);
    final answerDuration = Duration(minutes: 1);
    final responseTime = startTime.add(answerDuration);

    await withClock(Clock.fixed(startTime), () async {
      // Start studying fixes start date and time based on the clock
      await studySession.startStudySession();
    });
    await withClock(Clock.fixed(responseTime), () async {
      await studySession.rateAnswer(model.Rating.good);
    });

    verify(() => mockRepository.recordAnswer(
        card.id!,
        model.CardReviewVariant.front,
        model.Rating.good,
        startTime,
        answerDuration)).called(1);
    expect(studySession.remainingCards, 0);
  });

  test('rateAnswer records answer and keeps card if rated again', () async {
    final studySession = StudySession(repository: mockRepository);
    final card = MockCard.withId('cardId');
    when(() => mockRepository.loadCardToReview(deckId: null))
        .thenAnswer((_) async => [card]);

    when(() => mockRepository.recordAnswer(any(), any(), any(), any(), any()))
        .thenAnswer((_) async {});

    final startTime = DateTime(2024);
    final answerDuration = Duration(minutes: 1);
    final responseTime = startTime.add(answerDuration);

    await withClock(Clock.fixed(startTime), () async {
      // Start studying fixes start date and time based on the clock
      await studySession.startStudySession();
    });
    await withClock(Clock.fixed(responseTime), () async {
      await studySession.rateAnswer(model.Rating.again);
    });
    verify(() => mockRepository.recordAnswer(
        card.id!,
        model.CardReviewVariant.front,
        model.Rating.again,
        responseTime,
        answerDuration)).called(1);
    expect(studySession.remainingCards, 1); // Card should not be removed
  });

  test('rating only one card as `again` leaves only this card in the list',
      () async {
    final studySession = StudySession(repository: mockRepository);
    final cards = [
      MockCard.withId('c1'),
      MockCard.withId('c2'),
      MockCard.withId('c3')
    ];
    when(() => mockRepository.loadCardToReview(deckId: null))
        .thenAnswer((_) async => cards);
    when(() => mockRepository.recordAnswer(any(), any(), any(), any(), any()))
        .thenAnswer((_) async {});

    await studySession.startStudySession();
    await studySession.rateAnswer(model.Rating.again);
    await studySession.rateAnswer(model.Rating.hard);
    await studySession.rateAnswer(model.Rating.good);

    expect(studySession.remainingCards, 1);
    expect(studySession.currentCard?.id, 'c1');
  });

  test('card should be shuffled after reviewing all of them', () async {
    final studySession = StudySession(repository: mockRepository);
    final cards = [
      MockCard.withId('c1'),
      MockCard.withId('c2'),
      MockCard.withId('c3')
    ];
    when(() => mockRepository.loadCardToReview(deckId: null))
        .thenAnswer((_) async => cards);
    when(() => mockRepository.recordAnswer(any(), any(), any(), any(), any()))
        .thenAnswer((_) async {});

    await studySession.startStudySession();
    // loop 100 times answering again expecting that the order of cards
    // may change. As there is no guarantee it's assumed that chance of
    // no change at all in 100 tries is negligible.
    final initialOrder = [];
    initialOrder.add(studySession.currentCard?.id!);
    await studySession.rateAnswer(model.Rating.again);
    initialOrder.add(studySession.currentCard?.id!);
    await studySession.rateAnswer(model.Rating.again);
    initialOrder.add(studySession.currentCard?.id!);
    await studySession.rateAnswer(model.Rating.again);
    final newOrder = [];
    for (var i = 0; i < 100; i++) {
      newOrder.add(studySession.currentCard?.id!);
      await studySession.rateAnswer(model.Rating.again);
      if (newOrder.length == initialOrder.length) {
        if (ListEquality().equals(newOrder, initialOrder)) {
          newOrder.clear();
        } else {
          expect(newOrder, isNot(initialOrder));
          break;
        }
      }
    }
  });

  test('progressToNextCard handles empty card list', () async {
    final studySession = StudySession(repository: mockRepository);
    when(() => mockRepository.loadCardToReview(deckId: null))
        .thenAnswer((_) async => []);

    await studySession.startStudySession();

    expect(studySession.currentCard, isNull);
    expect(studySession.remainingCards, 0);
    expect(() => studySession.rateAnswer(model.Rating.good),
        throwsA(isA<String>()));
  });
}
