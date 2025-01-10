import 'package:clock/clock.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_flashcards/src/common/dates.dart';
import 'package:flutter_flashcards/src/model/firebase/firebase_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'firebase_repository_test.dart';
import 'package:flutter_flashcards/src/model/cards.dart' as model;

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
    test('Basic card review scenario', () async {
      final deck = await repository.saveDeck(model.Deck(name: 'Test Deck'));
      final card = model.Card(
          id: 'card1',
          deckId: deck.id!,
          question: 'Question 1',
          answer: 'Answer 1');
      await repository.saveCard(card);
      // Day 1:
      // Add Card 1.
      // Review Card 1, score "Hard".
      // Assert:
      // Card 1 scheduled for review on Day 2.
      // No cards available for review on Day 1 after the initial review.
      final day1 = DateTime(2000);
      await withClock(Clock.fixed(day1), () async {
        final cardsToReviewDay1 = await repository.loadCardToReview();
        expect(cardsToReviewDay1.length, 1);
        expect(cardsToReviewDay1.first, card);
        final reviewTime1 = currentClockDateTime;
        repository.recordAnswer(card.id!, model.CardReviewVariant.front,
            model.Rating.hard, reviewTime1, Duration(minutes: 1));
      });

      // Day 2:
      // Review Card 1, score "Good".
      // Assert:
      // Card 1 scheduled for review on Day 4 (or later, depending on your FSRS parameters).
      // 1 card available for review on Day 2.
      final day2 = day1.add(Duration(days: 1));
      await withClock(Clock.fixed(day2), () async {
        final cardsToReviewDay2 = await repository.loadCardToReview();
        expect(cardsToReviewDay2.length, 1);
        expect(cardsToReviewDay2.first.id, card.id!);

        final stats1 = await repository.loadCardStats(
            card.id!, model.CardReviewVariant.front);
        expect(stats1.nextReviewDate, isNotNull);
        expect(stats1.nextReviewDate!.isAfter(day1), isTrue);
        expect(await repository.cardsToReviewCount(), {
          model.State.newState: 0,
          model.State.learning: 1,
          model.State.relearning: 0,
          model.State.review: 0
        });
        repository.recordAnswer(card.id!, model.CardReviewVariant.front,
            model.Rating.good, day2, Duration(minutes: 1));
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
            card.id!, model.CardReviewVariant.front);
        expect(stats2.nextReviewDate, isNotNull);
        expect(stats2.nextReviewDate!.isAfter(day3), isTrue);
        expect(await repository.cardsToReviewCount(), {
          model.State.newState: 0,
          model.State.learning: 0,
          model.State.relearning: 0,
          model.State.review: 1
        });

        expect(await repository.cardsToReviewCount(deckId: deck.id!), {
          model.State.newState: 0,
          model.State.learning: 0,
          model.State.relearning: 0,
          model.State.review: 1
        });
      });
    });
  });

  /// Test Scenario 2: Multiple Cards and Different Intervals
  /// Day 1:
  /// Add Card 1.
  /// Add Card 2.
  /// Day 2:
  /// Review Card 1, score "Good".
  /// Review Card 2, score "Easy".
  /// Assert:
  /// Card 1 scheduled for review later than Card 2.
  /// 2 cards available for review on Day 2.
  /// Day 3:
  /// Assert:
  /// 1 card (Card 2) available for review on Day 3.
  /// Day 5 (or later, depending on Card 1's scheduling):
  /// Assert:
  /// 1 card (Card 1) available for review.
  /// Test Scenario 3: Lapses and Relearning
  ///
  /// Day 1:
  /// Add Card 1.
  /// Day 2:
  /// Review Card 1, score "Good".
  /// Day 5:
  /// Review Card 1, score "Again" (lapse).
  /// Assert:
  /// Card 1's stability is reduced.
// ignore_for_file: dangling_library_doc_comments

  /// Card 1 is scheduled for review sooner than it would have been if scored "Good" (likely within the next day or two).
  test('Advanced cards review scenario', () {});
}
