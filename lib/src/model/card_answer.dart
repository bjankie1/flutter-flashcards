import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_flashcards/src/model/enums.dart';
import 'package:flutter_flashcards/src/model/firebase_serializable.dart';

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
