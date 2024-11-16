import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'cards.freezed.dart';
part 'cards.g.dart';

@freezed
class Deck with _$Deck {
  const factory Deck({
    required String name,
    String? description,
    String? parentDeckId,
    DeckOptions? deckOptions,
  }) = _Deck;

  factory Deck.fromJson(Map<String, dynamic> json) => _$DeckFromJson(json);
}

@freezed
class DeckOptions with _$DeckOptions {
  const factory DeckOptions({
    required int cardsDaily,
    required int newCardsDailyLimit,
    required Duration maxInterval,
  }) = _DeckOptions;

  factory DeckOptions.fromJson(Map<String, dynamic> json) =>
      _$DeckOptionsFromJson(json);
}

@freezed
class Tag with _$Tag {
  const factory Tag({
    required String name,
  }) = _Tag;

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);
}

@freezed
class Content with _$Content {
  const factory Content({
    required String text,
    List<String>?
        attachments, // Assuming attachments are represented by strings (e.g., URLs)
  }) = _Content;

  factory Content.fromJson(Map<String, dynamic> json) =>
      _$ContentFromJson(json);
}

@freezed
class CardOptions with _$CardOptions {
  const factory CardOptions({
    required String deckId,
    required bool reverse,
    required bool inputRequire,
  }) = _CardOptions;

  factory CardOptions.fromJson(Map<String, dynamic> json) =>
      _$CardOptionsFromJson(json);
}

@freezed
class Card with _$Card {
  const factory Card({
    required String deckId,
    required Content question,
    required String answer,
    CardOptions? options,
    List<Tag>? tags,
    List<String>? alternativeAnswers,
    Content? explanation,
  }) = _Card;

  factory Card.fromJson(Map<String, dynamic> json) => _$CardFromJson(json);
}

@freezed
class CardStats with _$CardStats {
  const factory CardStats({
    required String cardId,
    required double stability,
    required double difficulty,
    required double lastAnswerRate,
    required DateTime lastAnswerDate,
    required int numberOfAnswers,
    required DateTime dateAdded,
  }) = _CardStats;

  factory CardStats.fromJson(Map<String, dynamic> json) =>
      _$CardStatsFromJson(json);
}

@freezed
class CardAnswer with _$CardAnswer {
  const factory CardAnswer({
    required String cardId,
    required DateTime date,
    required double answerRate,
    required Duration timeSpent,
  }) = _CardAnswer;

  factory CardAnswer.fromJson(Map<String, dynamic> json) =>
      _$CardAnswerFromJson(json);
}
