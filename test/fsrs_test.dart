import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_flashcards/src/fsrs/fsrs.dart';
import 'package:flutter_flashcards/src/model/cards.dart' as model;

import 'matchers.dart';

void main() {
  group('FSRS', () {
    test('calculateNextReview - first review - again', () {
      final cardId = 'testCardId';
      var f = FSRS();
      var now = DateTime(2022, 11, 29, 12, 30, 0, 0);
      var card = model.CardStats(cardId: cardId);
      var schedulingCards = f.repeat(card, now);
      final stats = schedulingCards[model.Rating.again]!.card;

      expect(stats.cardId, cardId);
      expect(stats.stability, 0.4);
      expect(stats.difficulty, 6.81);
      expect(stats.lastReview, closeToTime(now));
      expect(stats.numberOfReviews, 1);
      expect(stats.dateAdded, closeToTime(DateTime.now()));
      expect(stats.interval, 0);
      expect(stats.nextReviewDate,
          closeToTime(now, tolerance: Duration(hours: 1)));
    });

    test('calculateNextReview - first review - hard', () {
      final now = DateTime.now();
      var f = FSRS();
      final cardId = 'testCardId';
      var card = model.CardStats(cardId: cardId);
      var schedulingCards = f.repeat(card, now);
      final stats = schedulingCards[model.Rating.hard]!.card;

      expect(stats.nextReviewDate,
          closeToTime(now.add(const Duration(minutes: 5))));
    });

    test('calculateNextReview - first review - good', () {
      final now = DateTime.now();
      final cardId = 'testCardId';
      var f = FSRS();
      final card = model.CardStats(cardId: cardId);
      final schedulingCards = f.repeat(card, now);
      final stats = schedulingCards[model.Rating.good]!.card;

      expect(stats.nextReviewDate,
          closeToTime(now.add(const Duration(minutes: 10))));
    });

    test('calculateNextReview - first review - easy', () {
      final now = DateTime.now();
      final cardId = 'testCardId';
      final card = model.CardStats(cardId: cardId);
      var f = FSRS();
      final schedulingCards = f.repeat(card, now);
      final stats = schedulingCards[model.Rating.easy]!.card;

      expect(stats.interval, 6);
      expect(
          stats.nextReviewDate, closeToTime(now.add(const Duration(days: 6))));
    });

    test('calculateNextReview - subsequent review - again', () {
      final now = DateTime.now();
      final cardId = 'testCardId';
      final currentStats = model.CardStats(
          cardId: cardId,
          stability: 2.5,
          difficulty: 2.5,
          lastReview: now.subtract(const Duration(days: 1)),
          numberOfReviews: 1,
          numberOfLapses: 0,
          dateAdded: now.subtract(const Duration(days: 2)),
          interval: 0,
          nextReviewDate: now,
          state: model.State.learning);
      var f = FSRS();
      final schedulingCards = f.repeat(currentStats, now);
      final stats = schedulingCards[model.Rating.again]!.card;

      expect(stats.stability, 2.5);
      expect(stats.numberOfReviews, 2);
      expect(stats.interval, 0);
    });

    //   test('calculateNextReview - subsequent review - hard', () {
    //     final now = DateTime.now();
    //     final cardId = 'testCardId';
    //     final currentStats = model.CardStats(
    //       cardId: cardId,
    //       stability: 2.5,
    //       difficulty: 2.5,
    //       lastReview: 0,
    //       lastAnswerDate: now.subtract(const Duration(days: 1)),
    //       numberOfReviews: 1,
    //       dateAdded: now.subtract(const Duration(days: 2)),
    //       interval: 1,
    //       nextReviewDate: now,
    //     );

    //     final stats = FSRS.calculateNextReview(cardId, ReviewRate.hard,
    //         currentStats: currentStats);

    //     expect(stats.stability, 2.0); // Stability adjusted downwards
    //     expect(stats.numberOfReviews, 2);
    //     expect(stats.interval, 1); // Interval shortened
    //   });

    // Add similar tests for good and easy ratings for subsequent reviews
  });
}
