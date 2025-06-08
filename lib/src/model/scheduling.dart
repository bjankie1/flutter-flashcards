import 'dart:convert';

import 'package:flutter_flashcards/src/model/card_stats.dart';
import 'package:flutter_flashcards/src/model/enums.dart';

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

class SchedulingInfo {
  late CardStats card;
  late ReviewLog reviewLog;

  SchedulingInfo(this.card, this.reviewLog);
}

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