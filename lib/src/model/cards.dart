import 'dart:convert';
import 'dart:math';

enum State {
  newState(0),
  learning(1),
  review(2),
  relearning(3);

  const State(this.val);

  final int val;
}

enum Rating {
  again(1),
  hard(2),
  good(3),
  easy(4);

  const Rating(this.val);

  final int val;
}

class Deck {
  final String? id;
  final String name;
  final String? description;
  final String? parentDeckId;
  final DeckOptions? deckOptions;

  const Deck({
    this.id,
    required this.name,
    this.description,
    this.parentDeckId,
    this.deckOptions,
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
}

class Attachment {
  final String id;
  final String url;

  const Attachment({required this.id, required this.url});
}

// @JsonSerializable(explicitToJson: true)
class Content {
  final String text;
  final List<Attachment>? attachments;

  const Content({
    required this.text,
    this.attachments,
  });

  factory Content.basic(String text) => Content(text: text, attachments: []);
}

class CardOptions {
  final bool reverse;
  final bool inputRequired;

  CardOptions({
    required this.reverse,
    required this.inputRequired,
  });
}

class Card {
  final String? id;
  final String deckId;
  final Content question;
  final String answer;
  final CardOptions? options;
  final List<Tag>? tags;
  final List<String>? alternativeAnswers;
  final Content? explanation;

  const Card({
    this.id,
    required this.deckId,
    required this.question,
    required this.answer,
    this.options,
    this.tags,
    this.alternativeAnswers,
    this.explanation,
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
    );
  }

  Card copyWith({
    String? id,
    String? deckId,
    Content? question,
    String? answer,
    CardOptions? options,
    List<Tag>? tags,
    List<String>? alternativeAnswers,
    Content? explanation,
  }) =>
      Card(
          id: id ?? this.id,
          deckId: deckId ?? this.deckId,
          question: question ?? this.question,
          answer: answer ?? this.answer,
          options: options ?? this.options,
          tags: tags ?? this.tags,
          alternativeAnswers: alternativeAnswers ?? this.alternativeAnswers,
          explanation: explanation ?? this.explanation);
}

class CardStats {
  final String cardId;
  final double stability; // Represents how well the card is learned
  final double difficulty;
  final DateTime? lastReview;
  final int numberOfReviews;
  late DateTime? dateAdded;
  final int interval; // Time until next review (in days)
  final DateTime? nextReviewDate;
  final State state;
  final dynamic numberOfLapses;

  CardStats(
      {required this.cardId,
      this.interval = 0,
      this.lastReview,
      this.nextReviewDate,
      this.stability = 0,
      this.difficulty = 0,
      this.numberOfReviews = 0,
      this.numberOfLapses = 0,
      this.dateAdded,
      this.state = State.newState}) {
    dateAdded ??= DateTime.now();
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
    double? stability,
    double? difficulty,
    DateTime? lastReview,
    DateTime? lastAnswerDate,
    int? numberOfReviews,
    int? numberOfLapses,
    DateTime? dateAdded,
    int? interval,
    DateTime? nextReviewDate,
    dynamic state,
  }) {
    return CardStats(
      cardId: cardId ?? this.cardId,
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
      : DateTime.now().difference(lastReview!).inDays;
}

class CardAnswer {
  final String cardId;
  final DateTime reviewStart;
  final Duration timeSpent;
  final Rating rating;

  const CardAnswer({
    required this.cardId,
    required this.reviewStart,
    required this.timeSpent,
    required this.rating,
  });
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
