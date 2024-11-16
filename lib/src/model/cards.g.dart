// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cards.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DeckImpl _$$DeckImplFromJson(Map<String, dynamic> json) => _$DeckImpl(
      name: json['name'] as String,
      description: json['description'] as String?,
      parentDeckId: json['parentDeckId'] as String?,
      deckOptions: json['deckOptions'] == null
          ? null
          : DeckOptions.fromJson(json['deckOptions'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$DeckImplToJson(_$DeckImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'parentDeckId': instance.parentDeckId,
      'deckOptions': instance.deckOptions,
    };

_$DeckOptionsImpl _$$DeckOptionsImplFromJson(Map<String, dynamic> json) =>
    _$DeckOptionsImpl(
      cardsDaily: (json['cardsDaily'] as num).toInt(),
      newCardsDailyLimit: (json['newCardsDailyLimit'] as num).toInt(),
      maxInterval: Duration(microseconds: (json['maxInterval'] as num).toInt()),
    );

Map<String, dynamic> _$$DeckOptionsImplToJson(_$DeckOptionsImpl instance) =>
    <String, dynamic>{
      'cardsDaily': instance.cardsDaily,
      'newCardsDailyLimit': instance.newCardsDailyLimit,
      'maxInterval': instance.maxInterval.inMicroseconds,
    };

_$TagImpl _$$TagImplFromJson(Map<String, dynamic> json) => _$TagImpl(
      name: json['name'] as String,
    );

Map<String, dynamic> _$$TagImplToJson(_$TagImpl instance) => <String, dynamic>{
      'name': instance.name,
    };

_$ContentImpl _$$ContentImplFromJson(Map<String, dynamic> json) =>
    _$ContentImpl(
      text: json['text'] as String,
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$ContentImplToJson(_$ContentImpl instance) =>
    <String, dynamic>{
      'text': instance.text,
      'attachments': instance.attachments,
    };

_$CardOptionsImpl _$$CardOptionsImplFromJson(Map<String, dynamic> json) =>
    _$CardOptionsImpl(
      deckId: json['deckId'] as String,
      reverse: json['reverse'] as bool,
      inputRequire: json['inputRequire'] as bool,
    );

Map<String, dynamic> _$$CardOptionsImplToJson(_$CardOptionsImpl instance) =>
    <String, dynamic>{
      'deckId': instance.deckId,
      'reverse': instance.reverse,
      'inputRequire': instance.inputRequire,
    };

_$CardImpl _$$CardImplFromJson(Map<String, dynamic> json) => _$CardImpl(
      deckId: json['deckId'] as String,
      question: Content.fromJson(json['question'] as Map<String, dynamic>),
      answer: json['answer'] as String,
      options: json['options'] == null
          ? null
          : CardOptions.fromJson(json['options'] as Map<String, dynamic>),
      tags: (json['tags'] as List<dynamic>?)
          ?.map((e) => Tag.fromJson(e as Map<String, dynamic>))
          .toList(),
      alternativeAnswers: (json['alternativeAnswers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      explanation: json['explanation'] == null
          ? null
          : Content.fromJson(json['explanation'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$CardImplToJson(_$CardImpl instance) =>
    <String, dynamic>{
      'deckId': instance.deckId,
      'question': instance.question,
      'answer': instance.answer,
      'options': instance.options,
      'tags': instance.tags,
      'alternativeAnswers': instance.alternativeAnswers,
      'explanation': instance.explanation,
    };

_$CardStatsImpl _$$CardStatsImplFromJson(Map<String, dynamic> json) =>
    _$CardStatsImpl(
      cardId: json['cardId'] as String,
      stability: (json['stability'] as num).toDouble(),
      difficulty: (json['difficulty'] as num).toDouble(),
      lastAnswerRate: (json['lastAnswerRate'] as num).toDouble(),
      lastAnswerDate: DateTime.parse(json['lastAnswerDate'] as String),
      numberOfAnswers: (json['numberOfAnswers'] as num).toInt(),
      dateAdded: DateTime.parse(json['dateAdded'] as String),
    );

Map<String, dynamic> _$$CardStatsImplToJson(_$CardStatsImpl instance) =>
    <String, dynamic>{
      'cardId': instance.cardId,
      'stability': instance.stability,
      'difficulty': instance.difficulty,
      'lastAnswerRate': instance.lastAnswerRate,
      'lastAnswerDate': instance.lastAnswerDate.toIso8601String(),
      'numberOfAnswers': instance.numberOfAnswers,
      'dateAdded': instance.dateAdded.toIso8601String(),
    };

_$CardAnswerImpl _$$CardAnswerImplFromJson(Map<String, dynamic> json) =>
    _$CardAnswerImpl(
      cardId: json['cardId'] as String,
      date: DateTime.parse(json['date'] as String),
      answerRate: (json['answerRate'] as num).toDouble(),
      timeSpent: Duration(microseconds: (json['timeSpent'] as num).toInt()),
    );

Map<String, dynamic> _$$CardAnswerImplToJson(_$CardAnswerImpl instance) =>
    <String, dynamic>{
      'cardId': instance.cardId,
      'date': instance.date.toIso8601String(),
      'answerRate': instance.answerRate,
      'timeSpent': instance.timeSpent.inMicroseconds,
    };
