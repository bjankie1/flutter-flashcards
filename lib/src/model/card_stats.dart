import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_flashcards/src/common/dates.dart';
import 'package:flutter_flashcards/src/model/card.dart';
import 'package:flutter_flashcards/src/model/enums.dart';
import 'package:flutter_flashcards/src/model/firebase_serializable.dart';

class CardStats implements FirebaseSerializable {
  final String cardId;
  final CardReviewVariant variant;
  final double stability; // Represents how well the card is learned
  final double difficulty;
  final DateTime? lastReview;
  final int numberOfReviews;
  late DateTime? dateAdded;
  final int interval; // Time until next review (in days)
  final DateTime? nextReviewDate;
  final State state;
  final int numberOfLapses;

  CardStats({
    required this.cardId,
    this.variant = CardReviewVariant.front,
    this.interval = 0,
    this.lastReview,
    this.nextReviewDate,
    this.stability = 0,
    this.difficulty = 0,
    this.numberOfReviews = 0,
    this.numberOfLapses = 0,
    this.dateAdded,
    this.state = State.newState,
  }) {
    dateAdded ??= currentClockDateTime;
  }

  double? getRetrievability(DateTime now) {
    const decay = -0.5;
    final factor = pow(0.9, 1 / decay) - 1;

    if (state == State.review && lastReview != null) {
      final elapsedDays = (now.difference(lastReview!).inDays)
          .clamp(0, double.infinity)
          .toInt();
      return pow(1 + factor * elapsedDays / stability, decay).toDouble();
    } else {
      return null;
    }
  }

  CardStats copyWith({
    String? cardId,
    CardReviewVariant? variant,
    double? stability,
    double? difficulty,
    DateTime? lastReview,
    DateTime? lastAnswerDate,
    int? numberOfReviews,
    int? numberOfLapses,
    DateTime? dateAdded,
    int? interval,
    DateTime? nextReviewDate,
    State? state,
  }) {
    return CardStats(
      cardId: cardId ?? this.cardId,
      variant: variant ?? this.variant,
      stability: stability ?? this.stability,
      difficulty: difficulty ?? this.difficulty,
      lastReview: lastReview ?? this.lastReview,
      numberOfReviews: numberOfReviews ?? this.numberOfReviews,
      dateAdded: dateAdded ?? this.dateAdded,
      interval: interval ?? this.interval,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      state: state ?? this.state,
      numberOfLapses: numberOfLapses ?? this.numberOfLapses,
    );
  }

  CardStats withState(State state) => copyWith(state: state);

  CardStats addReview() => copyWith(numberOfReviews: numberOfReviews + 1);

  CardStats withInterval(int interval) => copyWith(interval: interval);

  CardStats nextReview(DateTime date) => copyWith(nextReviewDate: date);

  int elapsedDays() => state == State.newState || lastReview == null
      ? 0
      : currentClockDateTime.difference(lastReview!).inDays;

  static Iterable<CardStats> statsForCard(Card card) {
    if (card.options?.learnBothSides == true) {
      return [
        CardStats(cardId: card.id, variant: CardReviewVariant.front),
        CardStats(cardId: card.id, variant: CardReviewVariant.back),
      ];
    }
    return [CardStats(cardId: card.id, variant: CardReviewVariant.front)];
  }

  factory CardStats.fromJson(String id, Map<String, dynamic> data) {
    if (id.split(r'::') case [final cardId, final variant]) {
      return CardStats(
        cardId: cardId,
        variant: CardReviewVariant.fromString(variant),
        stability: data['stability'] as double? ?? 0,
        difficulty: data['difficulty'] as double? ?? 0,
        lastReview: (data['lastReview'] as Timestamp? ?? currentClockTimestamp)
            .toDate(),
        numberOfReviews: data['numberOfReviews'] as int? ?? 0,
        numberOfLapses: data['numberOfLapses'] as int? ?? 0,
        dateAdded: (data['dateAdded'] as Timestamp? ?? currentClockTimestamp)
            .toDate(),
        interval: (data['interval'] ?? 0) as int? ?? 0,
        nextReviewDate: (data['nextReviewDate'] as Timestamp?)?.toDate(),
        state: data['state'] == null
            ? State.newState
            : State.fromName(data['state']),
      );
    }
    throw Exception('Invalid id format');
  }

  @override
  Map<String, dynamic> toJson() => {
    'cardId': cardId,
    'variant': variant.name,
    'stability': stability,
    'difficulty': difficulty,
    'lastReview': lastReview,
    'numberOfReviews': numberOfReviews,
    'numberOfLapses': numberOfLapses,
    'dateAdded': dateAdded,
    'interval': interval,
    'nextReviewDate': nextReviewDate,
    'state': state.name,
  };

  @override
  String get idValue => '$cardId::${variant.name}';
}
