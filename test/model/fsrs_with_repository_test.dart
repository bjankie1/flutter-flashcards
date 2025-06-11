import 'package:clock/clock.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_flashcards/src/common/dates.dart';
import 'package:flutter_flashcards/src/model/cards.dart' as model;
import 'package:flutter_flashcards/src/model/firebase/firebase_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../matchers.dart';
import 'firebase_repository_test.dart';

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

    /// Test Scenario 1: Basic Functionality
    /// Day 1:
    /// Add Card 1.
    /// Review Card 1, score "Hard".
    /// Assert:
    /// Card 1 scheduled for review on Day 2.
    /// No cards available for review on Day 1 after the initial review.
    /// Day 2:
    /// Review Card 1, score "Good".
    /// Assert:
    /// Card 1 scheduled for review on Day 4 (or later, depending on your FSRS parameters).
    /// 1 card available for review on Day 2.
    /// Day 3:
    /// Assert:
    /// No cards available for review on Day 3.
    /// Day 4:
    /// Assert:
    /// 1 card available for review on Day 4.
    test('Test Scenario 1: Basic Functionality', () async {
      final deck = await repository.saveDeck(model.Deck(name: 'Test Deck'));
      final card = model.Card(
        id: 'card1',
        deckId: deck.id!,
        question: 'Question 1',
        answer: 'Answer 1',
      );
      await repository.saveCard(card);
      // Day 1:
      // Add Card 1.
      // Review Card 1, score "Hard".
      // Assert:
      // Card 1 scheduled for review on Day 2.
      // No cards available for review on Day 1 after the initial review.
      final day1 = DateTime(2000);
      await withClock(Clock.fixed(day1), () async {
        final cardsToReviewDay1 = await repository.loadCardsWithStatsToReview();
        expect(cardsToReviewDay1.length, 1);
        expect(cardsToReviewDay1.first.$2, card);
        final reviewTime1 = currentClockDateTime;
        await repository.recordAnswer(
          card.id,
          model.CardReviewVariant.front,
          model.Rating.hard,
          reviewTime1,
          Duration(minutes: 1),
        );
        final stats = await repository.loadCardStats(
          card.id,
          model.CardReviewVariant.front,
        );
        expect(stats, isNotNull);
        expect(stats.nextReviewDate, isNotNull);
      });

      // Day 2:
      // Review Card 1, score "Good".
      // Assert:
      // Card 1 scheduled for review on Day 4 (or later, depending on your FSRS parameters).
      // 1 card available for review on Day 2.
      final day2 = day1.add(Duration(days: 1));
      await withClock(Clock.fixed(day2), () async {
        final cardsToReviewDay2 = await repository.loadCardsWithStatsToReview();
        expect(cardsToReviewDay2.length, 1);
        expect(cardsToReviewDay2.first.$2.id, card.id);

        final stats1 = await repository.loadCardStats(
          card.id,
          model.CardReviewVariant.front,
        );
        expect(stats1.nextReviewDate, isNotNull);
        expect(stats1.nextReviewDate!, isAfter(day1));
        expect(await repository.cardsToReviewCount(), {
          model.State.newState: 0,
          model.State.learning: 1,
          model.State.relearning: 0,
          model.State.review: 0,
        });
        await repository.recordAnswer(
          card.id,
          model.CardReviewVariant.front,
          model.Rating.good,
          day2,
          Duration(minutes: 1),
        );
      });

      // Day 3:
      // Assert:
      // No cards available for review on Day 3.
      // Day 4:
      // Assert:
      // 1 card available for review on Day 4.
      final day3 = day2.add(Duration(days: 1));
      await withClock(Clock.fixed(day3), () async {
        final stats2 = await repository.loadCardStats(
          card.id,
          model.CardReviewVariant.front,
        );
        expect(stats2.nextReviewDate, isNotNull);
        expect(stats2.nextReviewDate, isNot(isBefore(day3)));
        expect(await repository.cardsToReviewCount(), {
          model.State.newState: 0,
          model.State.learning: 0,
          model.State.relearning: 0,
          model.State.review: 1,
        });

        expect(await repository.cardsToReviewCount(deckId: deck.id!), {
          model.State.newState: 0,
          model.State.learning: 0,
          model.State.relearning: 0,
          model.State.review: 1,
        });
      });
    });
  });

  /// Day 3:
  /// Assert:
  /// 1 card (Card 2) available for review on Day 3.
  /// Day 5 (or later, depending on Card 1's scheduling):
  /// Assert:
  /// 1 card (Card 1) available for review.
  test('Test Scenario 2: Multiple Cards and Different Intervals', () async {
    // Day 1:
    // Add Card 1.
    // Add Card 2.
    final day1 = DateTime(2000);
    final deck = await repository.saveDeck(model.Deck(name: 'Test Deck'));
    final card1 = model.Card(
      id: 'card1',
      deckId: deck.id!,
      question: 'Question 1',
      answer: 'Answer 1',
    );
    await repository.saveCard(card1);
    final card2 = model.Card(
      id: 'card2',
      deckId: deck.id!,
      question: 'Question 2',
      answer: 'Answer 2',
    );
    await repository.saveCard(card2);

    // Day 2:
    // Review Card 1, score "Good".
    // Review Card 2, score "Easy".
    // Assert:
    // Card 2 scheduled for review later than Card 1.
    // 1 cards available for review on Day 2.
    final day2 = day1.add(Duration(days: 1));
    await withClock(Clock.fixed(day2), () async {
      final cardsToReviewDay2 = await repository.loadCardsWithStatsToReview();
      expect(cardsToReviewDay2.length, 2);
      await repository.recordAnswer(
        card1.id,
        model.CardReviewVariant.front,
        model.Rating.good,
        day2,
        Duration(minutes: 1),
      );
      await repository.recordAnswer(
        card2.id,
        model.CardReviewVariant.front,
        model.Rating.easy,
        day2,
        Duration(minutes: 1),
      );
      final statsCard1 = await repository.loadCardStats(
        card1.id,
        model.CardReviewVariant.front,
      );
      final statsCard2 = await repository.loadCardStats(
        card2.id,
        model.CardReviewVariant.front,
      );
      expect(statsCard1.nextReviewDate, isNotNull);
      expect(statsCard2.nextReviewDate, isNotNull);
      expect(statsCard2.nextReviewDate!, isAfter(statsCard1.nextReviewDate!));
    });

    // Day 3:
    // Assert:
    // 1 card (Card 1) available for review on Day 3.
    final day3 = day2.add(Duration(days: 1));
    await withClock(Clock.fixed(day3), () async {
      final cardsToReviewDay3 = await repository.loadCardsWithStatsToReview();
      expect(cardsToReviewDay3.length, 1);
      expect(cardsToReviewDay3.first.$2.id, card1.id);
    });

    // Day 5 (or later, depending on Card 1's scheduling):
    // Assert:
    // 1 card (Card 1) available for review.
    final day5 = day3.add(Duration(days: 2));
    await withClock(Clock.fixed(day5), () async {
      final cardsToReviewDay5 = await repository.loadCardsWithStatsToReview();
      expect(cardsToReviewDay5.length, 1);
      expect(cardsToReviewDay5.first.$2.id, card1.id);
    });

    // Day 10 (or later, depending on scheduling):
    // Assert:
    // 2 cards available for review.
    final day10 = day3.add(Duration(days: 6));
    await withClock(Clock.fixed(day10), () async {
      final cardsToReviewDay5 = await repository.loadCardsWithStatsToReview();
      expect(cardsToReviewDay5.length, 2);
    });
  });

  test('Test Scenario 3: Lapses and Relearning', () async {
    // Day 1:
    // Add Card 1.
    final day1 = DateTime(2000);
    final deck = await repository.saveDeck(model.Deck(name: 'Test Deck'));
    final card1 = model.Card(
      id: 'card1',
      deckId: deck.id!,
      question: 'Question 1',
      answer: 'Answer 1',
    );

    // Day 2:
    // Review Card 1, score "Good".
    final day2 = day1.add(Duration(days: 1));
    await withClock(Clock.fixed(day2), () async {
      final cardsToReview = await repository.loadCardsWithStatsToReview();
      expect(cardsToReview.length, 1);
      expect(cardsToReview.first.$2.id, card1.id);
      await repository.recordAnswer(
        card1.id,
        model.CardReviewVariant.front,
        model.Rating.good,
        day2,
        Duration(minutes: 1),
      );
    });

    // Day 5:
    // Review Card 1, score "Again" (lapse).
    // Assert:
    // Card 1's stability is reduced.
    // Card 1 is scheduled for review sooner than it would have been if scored "Good" (likely within the next day or two).
    final day5 = day1.add(Duration(days: 4));
    await withClock(Clock.fixed(day5), () async {
      final cardsToReview = await repository.loadCardsWithStatsToReview();
      final statsBefore = await repository.loadCardStats(
        card1.id,
        model.CardReviewVariant.front,
      );
      expect(cardsToReview.length, 1);
      expect(cardsToReview.first.$2.id, card1.id);
      await repository.recordAnswer(
        card1.id,
        model.CardReviewVariant.front,
        model.Rating.again,
        day2,
        Duration(minutes: 1),
      );
      final statsAfter = await repository.loadCardStats(
        card1.id,
        model.CardReviewVariant.front,
      );
      expect(statsBefore.stability, greaterThan(statsAfter.stability));
      expect(statsAfter.nextReviewDate, isNotNull);
      expect(statsAfter.nextReviewDate!, isAfter(day5));
      expect(statsAfter.nextReviewDate!, isBefore(day5.add(Duration(days: 2))));
    });
  });
}
