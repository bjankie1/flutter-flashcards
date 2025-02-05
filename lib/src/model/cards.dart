import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_flashcards/src/common/dates.dart';

enum ImagePlacement { question, explanation }

abstract class FirebaseSerializable<T> {
  Map<String, dynamic> toJson();

  String? get idValue;
}

enum State {
  newState(0),
  learning(1),
  review(2),
  relearning(3);

  const State(this.val);

  final int val;

  factory State.fromName(String name) =>
      State.values.firstWhere((element) => element.name == name);
}

enum Rating {
  again(1),
  hard(2),
  good(3),
  easy(4);

  const Rating(this.val);

  final int val;
}

enum DeckCategory {
  language,
  history,
  science,
  other;

  factory DeckCategory.fromName(String name) =>
      DeckCategory.values.firstWhere((element) => element.name == name);
}

typedef DeckId = String;

class Deck implements FirebaseSerializable {
  final DeckId? id;
  final String name;
  final String? description;
  final String? parentDeckId;
  final DeckOptions? deckOptions;
  final DeckCategory? category;

  const Deck({
    this.id,
    required this.name,
    this.description,
    this.parentDeckId,
    this.deckOptions,
    this.category = DeckCategory.other,
  });

  withId({required String id}) {
    return Deck(
      id: id,
      name: name,
      description: description,
      parentDeckId: parentDeckId,
      deckOptions: deckOptions,
    );
  }

  @override
  int get hashCode => Object.hash(id, name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Deck &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          id == other.id;

  Deck copyWith({
    String? id,
    String? name,
    String? description,
    String? parentDeckId,
    DeckOptions? deckOptions,
    DeckCategory? category,
  }) {
    return Deck(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      parentDeckId: parentDeckId ?? this.parentDeckId,
      deckOptions: deckOptions ?? this.deckOptions,
      category: category ?? this.category,
    );
  }

  factory Deck.fromJson(String id, Map<String, dynamic> json) => Deck(
        id: id,
        name: json['name'] as String,
        description: json['description'] as String?,
        parentDeckId: json['parentDeckId'] as String?,
        deckOptions: json['deckOptions'] != null
            ? _deckOptionsFromJson(json['deckOptions'] as Map<String, dynamic>)
            : null,
        category: json['category'] != null
            ? DeckCategory.fromName(json['category'])
            : null,
      );

  @override
  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'parentDeckId': parentDeckId,
        'deckOptions':
            deckOptions != null ? _deckOptionsToJson(deckOptions!) : null,
        'category': category?.name,
      };

  static DeckOptions _deckOptionsFromJson(Map<String, dynamic> json) =>
      DeckOptions(
        cardsDaily: json['cardsDaily'] as int,
        newCardsDailyLimit: json['newCardsDailyLimit'] as int,
        maxInterval: Duration(
            milliseconds:
                json['maxInterval'] as int), // Parse from milliseconds
      );

  Map<String, dynamic> _deckOptionsToJson(DeckOptions deckOptions) => {
        'cardsDaily': deckOptions.cardsDaily,
        'newCardsDailyLimit': deckOptions.newCardsDailyLimit,
        'maxInterval':
            deckOptions.maxInterval.inMilliseconds, // Store as milliseconds
      };

  @override
  String get idValue => id!;
}

class DeckOptions {
  final int cardsDaily;
  final int newCardsDailyLimit;
  final Duration maxInterval;

  const DeckOptions({
    required this.cardsDaily,
    required this.newCardsDailyLimit,
    required this.maxInterval,
  });
}

class Tag {
  final String name;

  const Tag({
    required this.name,
  });

  @override
  int get hashCode => name.hashCode;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Tag && runtimeType == other.runtimeType && name == other.name;
  }
}

class Attachment {
  final String id;
  final String url;

  const Attachment({required this.id, required this.url});

  toJson() => {"id": id, "url": url};
}

class CardOptions {
  final bool learnBothSides;
  final bool inputRequired;

  CardOptions({
    required this.learnBothSides,
    required this.inputRequired,
  });

  Map<String, dynamic> toJson() => {
        'learnBothSides': learnBothSides,
        'inputRequired': inputRequired,
      };

  factory CardOptions.fromJson(Map<String, dynamic> json) => CardOptions(
        learnBothSides: (json['learnBothSides'] ?? false) as bool,
        inputRequired: (json['inputRequire'] ?? false) as bool,
      );
}

List<Tag> _tagsFromJson(List<String> data) =>
    data.map((tag) => Tag(name: tag)).toList();

class Card implements FirebaseSerializable {
  final String? id;
  final String deckId;
  final String question;
  final bool questionImageAttached;
  final String answer;
  final CardOptions? options;
  final List<Tag>? tags;
  final List<String>? alternativeAnswers;
  final String? explanation;
  final bool explanationImageAttached;

  const Card({
    this.id,
    required this.deckId,
    required this.question,
    required this.answer,
    this.options,
    this.tags,
    this.alternativeAnswers,
    this.explanation,
    this.questionImageAttached = false,
    this.explanationImageAttached = false,
  });

  withId({required String id}) {
    return Card(
      id: id,
      deckId: deckId,
      question: question,
      answer: answer,
      options: options,
      tags: tags,
      alternativeAnswers: alternativeAnswers,
      explanation: explanation,
      questionImageAttached: questionImageAttached,
      explanationImageAttached: explanationImageAttached,
    );
  }

  Card copyWith({
    String? id,
    String? deckId,
    String? question,
    String? answer,
    CardOptions? options,
    List<Tag>? tags,
    List<String>? alternativeAnswers,
    String? explanation,
    bool? questionImageAttached,
    bool? explanationImageAttached,
  }) =>
      Card(
        id: id ?? this.id,
        deckId: deckId ?? this.deckId,
        question: question ?? this.question,
        answer: answer ?? this.answer,
        options: options ?? this.options,
        tags: tags ?? this.tags,
        alternativeAnswers: alternativeAnswers ?? this.alternativeAnswers,
        explanation: explanation ?? this.explanation,
        questionImageAttached:
            questionImageAttached ?? this.questionImageAttached,
        explanationImageAttached:
            explanationImageAttached ?? this.explanationImageAttached,
      );

  @override
  int get hashCode => Object.hash(id, deckId, question);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Card &&
            runtimeType == other.runtimeType &&
            deckId == other.deckId &&
            question == other.question &&
            answer == other.answer &&
            id == other.id;
  }

  @override
  String get idValue => id!;

  @override
  Map<String, dynamic> toJson() => {
        'deckId': deckId,
        'question': question,
        'answer': answer,
        'options': options?.toJson(),
        'tags': tags?.map((tag) => tag.name).toSet(),
        'alternativeAnswers': alternativeAnswers,
        'explanation': explanation ?? '',
        'questionImageAttached': questionImageAttached,
        'explanationImageAttached': explanationImageAttached,
      };

  static String? _contentValue(dynamic value) {
    if (value case String result) {
      return result;
    }

    if (value case Map content) {
      return content['text'];
    }
    return null;
  }

  factory Card.fromJson(String id, Map<String, dynamic> data) => Card(
      id: id,
      deckId: data['deckId'],
      question: _contentValue(data['question']) ?? '',
      explanation: _contentValue(data['explanation']),
      answer: data['answer'],
      options: data['options'] != null
          ? CardOptions.fromJson(data['options'])
          : null,
      tags: _tagsFromJson(data['tags'] ?? []),
      alternativeAnswers: data['alternativeAnswers'] ?? [],
      questionImageAttached: data['questionImageAttached'] ?? false,
      explanationImageAttached: data['explanationImageAttached'] ?? false);
}

/// Cards can have more than one variant to review. For instance a card can be configured to
/// review it both based on question as well as for the answer (reversed).
enum CardReviewVariant {
  front,
  back;

  factory CardReviewVariant.fromString(String name) {
    switch (name) {
      case 'front':
        return CardReviewVariant.front;
      case 'back':
        return CardReviewVariant.back;
      default:
        return CardReviewVariant.front;
    }
  }
}

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

  CardStats(
      {required this.cardId,
      this.variant = CardReviewVariant.front,
      this.interval = 0,
      this.lastReview,
      this.nextReviewDate,
      this.stability = 0,
      this.difficulty = 0,
      this.numberOfReviews = 0,
      this.numberOfLapses = 0,
      this.dateAdded,
      this.state = State.newState}) {
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
        CardStats(cardId: card.id!, variant: CardReviewVariant.front),
        CardStats(cardId: card.id!, variant: CardReviewVariant.back)
      ];
    }
    return [CardStats(cardId: card.id!, variant: CardReviewVariant.front)];
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
        dateAdded:
            (data['dateAdded'] as Timestamp? ?? currentClockTimestamp).toDate(),
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

class CardAnswer implements FirebaseSerializable {
  final String cardId;
  final CardReviewVariant variant;
  final DateTime reviewStart;
  final Duration timeSpent;
  final Rating rating;

  const CardAnswer({
    required this.cardId,
    required this.variant,
    required this.reviewStart,
    required this.timeSpent,
    required this.rating,
  });

  factory CardAnswer.fromJson(String id, Map<String, dynamic> json) =>
      CardAnswer(
        cardId: json['cardId'] as String,
        variant: CardReviewVariant.fromString(json['variant']),
        reviewStart: (json['reviewStart'] as Timestamp).toDate(),
        rating: Rating.values[json['answerRate'] as int],
        timeSpent: Duration(milliseconds: json['timeSpent'] as int),
      );

  @override
  Map<String, dynamic> toJson() => {
        'cardId': cardId,
        'variant': variant.name,
        'reviewStart': reviewStart,
        'answerRate': rating.index,
        'timeSpent': timeSpent.inMilliseconds,
      };

  @override
  String get idValue => '$cardId::${variant.name}';

  @override
  int get hashCode => Object.hash(cardId, variant, reviewStart);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CardAnswer &&
            runtimeType == other.runtimeType &&
            cardId == other.cardId &&
            variant == other.variant &&
            reviewStart == other.reviewStart;
  }
}

class CardReviewStats {
  final DateTime day;
  final int cardsReviewed;
  final int totalAnswers; // single card can be reviewed multiple times
  final Duration timeSpent;
  final Duration p90TimeOnCard;
  final Duration p95TimeOnCard;
  final Map<Rating, int> ratings;
  final Map<int, int> reviewTimeOfDay; // hour of day is the key

  CardReviewStats({
    required this.day,
    required this.cardsReviewed,
    required this.totalAnswers,
    required this.timeSpent,
    required this.p90TimeOnCard,
    required this.p95TimeOnCard,
    required this.ratings,
    required this.reviewTimeOfDay,
  });
}

// Copied from https://github.com/open-spaced-repetition/dart-fsrs/
class ReviewLog {
  Rating rating;
  int scheduledDays;
  int elapsedDays;
  DateTime review;
  State state;

  ReviewLog(this.rating, this.scheduledDays, this.elapsedDays, this.review,
      this.state);

  @override
  String toString() {
    return jsonEncode({
      "rating": rating.toString(),
      "scheduledDays": scheduledDays,
      "elapsedDays": elapsedDays,
      "review": review.toString(),
      "state": state.toString(),
    });
  }
}

/// Store card and review log info
class SchedulingInfo {
  late CardStats card;
  late ReviewLog reviewLog;

  SchedulingInfo(this.card, this.reviewLog);
}

/// Calculate next review
class SchedulingCards {
  late CardStats again;
  late CardStats hard;
  late CardStats good;
  late CardStats easy;

  SchedulingCards(CardStats card) {
    again = card.copyWith();
    hard = card.copyWith();
    good = card.copyWith();
    easy = card.copyWith();
  }

  void updateState(State state) {
    switch (state) {
      case State.newState:
        again = again.withState(State.learning);
        hard = hard.withState(State.learning);
        good = good.withState(State.learning);
        easy = easy.withState(State.review);
      case State.learning:
      case State.relearning:
        again = again.withState(state);
        hard = hard.withState(state);
        good = good.withState(State.review);
        easy = easy.withState(State.review);
      case State.review:
        again = again.withState(State.relearning);
        hard = hard.withState(State.review);
        good = good.withState(State.review);
        easy = easy.withState(State.review);
        again = again.addReview();
    }
  }

  void schedule(
    DateTime now,
    double hardInterval,
    double goodInterval,
    double easyInterval,
  ) {
    again = again.withInterval(0);
    hard = hard.withInterval(hardInterval.toInt());
    good = good.withInterval(goodInterval.toInt());
    easy = easy.withInterval(easyInterval.toInt());
    again = again.nextReview(now.add(Duration(minutes: 5)));
    hard = hard.nextReview((hardInterval > 0)
        ? now.add(Duration(days: hardInterval.toInt()))
        : now.add(Duration(minutes: 10)));
    good = good.nextReview(now.add(Duration(days: goodInterval.toInt())));
    easy = easy.nextReview(now.add(Duration(days: easyInterval.toInt())));
  }

  Map<Rating, SchedulingInfo> recordLog(CardStats card, DateTime now) {
    final elapsedDays = card.elapsedDays();
    return {
      Rating.again: SchedulingInfo(
          again,
          ReviewLog(
              Rating.again, again.interval, elapsedDays, now, card.state)),
      Rating.hard: SchedulingInfo(hard,
          ReviewLog(Rating.hard, hard.interval, elapsedDays, now, card.state)),
      Rating.good: SchedulingInfo(good,
          ReviewLog(Rating.good, good.interval, elapsedDays, now, card.state)),
      Rating.easy: SchedulingInfo(easy,
          ReviewLog(Rating.easy, easy.interval, elapsedDays, now, card.state)),
    };
  }
}

class Parameters {
  double requestRetention = 0.9;
  int maximumInterval = 36500;
  List<double> w = [
    0.4,
    0.6,
    2.4,
    5.8,
    4.93,
    0.94,
    0.86,
    0.01,
    1.49,
    0.14,
    0.94,
    2.18,
    0.05,
    0.34,
    1.26,
    0.29,
    2.61
  ];
}