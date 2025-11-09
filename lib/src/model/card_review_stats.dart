import 'package:flutter_flashcards/src/model/enums.dart';

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
