import 'dart:math';
import 'dart:core';

import '../model/cards.dart' as model;

class FSRS {
  late model.Parameters p;
  late double decay;
  late double factor;

  FSRS() {
    p = model.Parameters();
    decay = -0.5;
    factor = pow(0.9, 1 / decay) - 1;
  }

  Map<model.Rating, model.SchedulingInfo> repeat(
      model.CardStats card, DateTime now) {
    var reviewedCard = card.copyWith(lastReview: now).addReview();
    final s = model.SchedulingCards(reviewedCard);
    s.updateState(card.state);

    switch (card.state) {
      case model.State.newState:
        _initDS(s);

        s.again = s.again.nextReview(now.add(Duration(minutes: 1)));
        s.again = s.again.withInterval(_nextInterval(s.again.stability));
        s.hard = s.hard.nextReview(now.add(Duration(minutes: 5)));
        s.hard = s.hard.withInterval(_nextInterval(s.hard.stability));
        s.good = s.good.nextReview(now.add(Duration(minutes: 10)));
        s.good = s.good.withInterval(_nextInterval(s.good.stability));
        s.easy = s.easy.withInterval(_nextInterval(s.easy.stability));
        s.easy = s.easy.nextReview(now.add(Duration(days: s.easy.interval)));
      case model.State.learning:
      case model.State.relearning:
        final hardInterval = 0;
        final goodInterval = _nextInterval(s.good.stability);
        final easyInterval =
            max(_nextInterval(s.easy.stability), goodInterval + 1);

        s.schedule(now, hardInterval.toDouble(), goodInterval.toDouble(),
            easyInterval.toDouble());
      case model.State.review:
        final interval = card.elapsedDays();
        final lastD = card.difficulty;
        final lastS = card.stability;
        final retrievability = _forgettingCurve(interval, lastS);
        _nextDS(s, lastD, lastS, retrievability);

        var hardInterval = _nextInterval(s.hard.stability);
        var goodInterval = _nextInterval(s.good.stability);
        hardInterval = min(hardInterval, goodInterval);
        goodInterval = max(goodInterval, hardInterval + 1);
        final easyInterval =
            max(_nextInterval(s.easy.stability), goodInterval + 1);
        s.schedule(now, hardInterval.toDouble(), goodInterval.toDouble(),
            easyInterval.toDouble());
    }

    return s.recordLog(card, now);
  }

  void _initDS(model.SchedulingCards s) {
    s.again = s.again.copyWith(
        difficulty: _initDifficulty(model.Rating.again.val),
        stability: _initStability(model.Rating.again.val));
    s.hard = s.hard.copyWith(
        difficulty: _initDifficulty(model.Rating.hard.val),
        stability: _initStability(model.Rating.hard.val));
    s.good = s.good.copyWith(
        difficulty: _initDifficulty(model.Rating.good.val),
        stability: _initStability(model.Rating.good.val));
    s.easy = s.easy.copyWith(
        difficulty: _initDifficulty(model.Rating.easy.val),
        stability: _initStability(model.Rating.easy.val));
  }

  double _initStability(int r) {
    return max(p.w[r - 1], 0.1);
  }

  double _initDifficulty(int r) {
    return min(max(p.w[4] - p.w[5] * (r - 3), 1), 10);
  }

  double _forgettingCurve(int elapsedDays, double stability) {
    return pow(1 + factor * elapsedDays / stability, decay).toDouble();
  }

  int _nextInterval(double s) {
    final newInterval = s / factor * (pow(p.requestRetention, 1 / decay) - 1);
    return min(max(newInterval.round(), 1), p.maximumInterval);
  }

  double _nextDifficulty(double d, int r) {
    final nextD = d - p.w[6] * (r - 3);
    return min(max(_meanReversion(p.w[4], nextD), 1), 10);
  }

  double _meanReversion(double init, double current) {
    return p.w[7] * init + (1 - p.w[7]) * current;
  }

  double _nextRecallStability(
      double d, double s, double r, model.Rating rating) {
    final hardPenalty = (rating == model.Rating.hard) ? p.w[15] : 1;
    final easyBonus = (rating == model.Rating.easy) ? p.w[16] : 1;
    return s *
        (1 +
            exp(p.w[8]) *
                (11 - d) *
                pow(s, -p.w[9]) *
                (exp((1 - r) * p.w[10]) - 1) *
                hardPenalty *
                easyBonus);
  }

  double _nextForgetStability(double d, double s, double r) {
    return p.w[11] *
        pow(d, -p.w[12]) *
        (pow(s + 1, p.w[13]) - 1) *
        exp((1 - r) * p.w[14]);
  }

  void _nextDS(model.SchedulingCards s, double lastD, double lastS,
      double retrievability) {
    s.again = s.again.copyWith(
        difficulty: _nextDifficulty(lastD, model.Rating.again.val),
        stability: _nextForgetStability(lastD, lastS, retrievability));
    s.hard = s.hard.copyWith(
        difficulty: _nextDifficulty(lastD, model.Rating.hard.val),
        stability: _nextRecallStability(
            lastD, lastS, retrievability, model.Rating.hard));
    s.good = s.good.copyWith(
        difficulty: _nextDifficulty(lastD, model.Rating.good.val),
        stability: _nextRecallStability(
            lastD, lastS, retrievability, model.Rating.good));
    s.easy = s.easy.copyWith(
        difficulty: _nextDifficulty(lastD, model.Rating.easy.val),
        stability: _nextRecallStability(
            lastD, lastS, retrievability, model.Rating.easy));
  }
}
