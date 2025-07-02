import 'package:clock/clock.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_flashcards/src/model/cards.dart' as model;
import 'package:flutter_flashcards/src/model/study_session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../mocks/mock_cards_repository.dart';

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
    final cards = [
      (
        model.CardStats(cardId: '1', variant: model.CardReviewVariant.front),
        MockCard(),
      ),
      (
        model.CardStats(cardId: '2', variant: model.CardReviewVariant.front),
        MockCard(),
      ),
      (
        model.CardStats(cardId: '3', variant: model.CardReviewVariant.front),
        MockCard(),
      ),
    ];
    when(
      () => mockRepository.loadCardsWithStatsToReview(deckId: null),
    ).thenAnswer((_) async => cards);

    await studySession.startStudySession();

    verify(
      () => mockRepository.loadCardsWithStatsToReview(deckId: null),
    ).called(1);
    expect(studySession.remainingCards, 3);
    expect(studySession.currentCard, isNotNull);
  });

  test(
    'startStudySession with deckId loads and shuffles cards from specific deck',
    () async {
      final cards = [
        (
          model.CardStats(cardId: '1', variant: model.CardReviewVariant.front),
          MockCard(),
        ),
        (
          model.CardStats(cardId: '2', variant: model.CardReviewVariant.front),
          MockCard(),
        ),
        (
          model.CardStats(cardId: '3', variant: model.CardReviewVariant.front),
          MockCard(),
        ),
      ];
      when(
        () => mockRepository.loadCardsWithStatsToReview(deckId: 'testDeckId'),
      ).thenAnswer((_) async => cards);

      final deckIdStudySession = StudySession(
        repository: mockRepository,
        deckId: 'testDeckId',
      );
      await deckIdStudySession.startStudySession();

      verify(
        () => mockRepository.loadCardsWithStatsToReview(deckId: 'testDeckId'),
      ).called(1);
      expect(deckIdStudySession.remainingCards, 3);
      expect(deckIdStudySession.currentCard, isNotNull);
    },
  );

  test('startStudySession handles empty card list', () async {
    final studySession = StudySession(repository: mockRepository);
    when(
      () => mockRepository.loadCardsWithStatsToReview(deckId: null),
    ).thenAnswer((_) async => []);

    await studySession.startStudySession();

    verify(
      () => mockRepository.loadCardsWithStatsToReview(deckId: null),
    ).called(1);
    expect(studySession.remainingCards, 0);
    expect(studySession.currentCard, isNull);
  });

  test('rateAnswer records answer and removes card', () async {
    final studySession = StudySession(repository: mockRepository);
    final card = MockCard.withId('cardId');
    when(
      () => mockRepository.loadCardsWithStatsToReview(deckId: null),
    ).thenAnswer(
      (_) async => [
        (
          model.CardStats(
            cardId: 'cardId',
            variant: model.CardReviewVariant.back,
          ),
          card,
        ),
      ],
    );
    when(
      () => mockRepository.recordAnswer(any(), any(), any(), any(), any()),
    ).thenAnswer((_) async {});

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

    verify(
      () => mockRepository.recordAnswer(
        card.id,
        model.CardReviewVariant.front,
        model.Rating.good,
        startTime,
        answerDuration,
      ),
    ).called(1);
    expect(studySession.remainingCards, 0);
  });

  test('rateAnswer records answer and keeps card if rated again', () async {
    final studySession = StudySession(repository: mockRepository);
    final card = MockCard.withId('cardId');
    when(
      () => mockRepository.loadCardsWithStatsToReview(deckId: null),
    ).thenAnswer(
      (_) async => [
        (
          model.CardStats(
            cardId: 'cardId',
            variant: model.CardReviewVariant.front,
          ),
          card,
        ),
      ],
    );

    when(
      () => mockRepository.recordAnswer(any(), any(), any(), any(), any()),
    ).thenAnswer((_) async {});

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
    verify(
      () => mockRepository.recordAnswer(
        card.id,
        model.CardReviewVariant.front,
        model.Rating.again,
        responseTime,
        answerDuration,
      ),
    ).called(1);
    expect(studySession.remainingCards, 1); // Card should not be removed
  });

  test(
    'rating only one card as `again` leaves only this card in the list',
    () async {
      final studySession = StudySession(repository: mockRepository);
      final cards = [
        (
          model.CardStats(cardId: 'c1', variant: model.CardReviewVariant.front),
          MockCard.withId('c1'),
        ),
        (
          model.CardStats(cardId: 'c2', variant: model.CardReviewVariant.back),
          MockCard.withId('c2'),
        ),
        (
          model.CardStats(cardId: 'c3', variant: model.CardReviewVariant.front),
          MockCard.withId('c3'),
        ),
      ];
      when(
        () => mockRepository.loadCardsWithStatsToReview(deckId: null),
      ).thenAnswer((_) async => cards);
      when(
        () => mockRepository.recordAnswer(any(), any(), any(), any(), any()),
      ).thenAnswer((_) async {});

      await studySession.startStudySession();
      final againCard = studySession.currentCard!;
      await studySession.rateAnswer(model.Rating.again);
      await studySession.rateAnswer(model.Rating.hard);
      await studySession.rateAnswer(model.Rating.good);

      expect(studySession.remainingCards, 1);
      expect(studySession.currentCard?.$2.id, againCard.$2.id);
    },
  );

  test('card should be shuffled after reviewing all of them', () async {
    final studySession = StudySession(repository: mockRepository);
    final cards = [
      (
        model.CardStats(cardId: 'c1', variant: model.CardReviewVariant.back),
        MockCard.withId('c1'),
      ),
      (
        model.CardStats(cardId: 'c2', variant: model.CardReviewVariant.front),
        MockCard.withId('c2'),
      ),
      (
        model.CardStats(cardId: 'c3', variant: model.CardReviewVariant.back),
        MockCard.withId('c3'),
      ),
    ];
    when(
      () => mockRepository.loadCardsWithStatsToReview(deckId: null),
    ).thenAnswer((_) async => cards);
    when(
      () => mockRepository.recordAnswer(any(), any(), any(), any(), any()),
    ).thenAnswer((_) async {});

    await studySession.startStudySession();
    // loop 100 times answering again expecting that the order of cards
    // may change. As there is no guarantee it's assumed that chance of
    // no change at all in 100 tries is negligible.
    final initialOrder = [];
    initialOrder.add(studySession.currentCard?.$2.id);
    await studySession.rateAnswer(model.Rating.again);
    initialOrder.add(studySession.currentCard?.$2.id);
    await studySession.rateAnswer(model.Rating.again);
    initialOrder.add(studySession.currentCard?.$2.id);
    await studySession.rateAnswer(model.Rating.again);
    final newOrder = [];
    for (var i = 0; i < 100; i++) {
      newOrder.add(studySession.currentCard?.$2.id);
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
    when(
      () => mockRepository.loadCardsWithStatsToReview(deckId: null),
    ).thenAnswer((_) async => []);

    await studySession.startStudySession();

    expect(studySession.currentCard, isNull);
    expect(studySession.remainingCards, 0);
    expect(
      () => studySession.rateAnswer(model.Rating.good),
      throwsA(isA<String>()),
    );
  });
}
