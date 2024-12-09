import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_flashcards/src/model/cards.dart' as model;
import 'package:logger/logger.dart';

abstract class FirebaseSerializer<T> {
  Future<T> fromSnapshot(DocumentSnapshot snapshot);
  Future<void> toSnapshot(T value, DocumentReference docRef);
}

class DeckSerializer implements FirebaseSerializer<model.Deck> {
  @override
  Future<model.Deck> fromSnapshot(DocumentSnapshot snapshot) async {
    final data = snapshot.data() as Map<String, dynamic>;
    return _deckFromJson(data, id: snapshot.id);
  }

  @override
  toSnapshot(model.Deck deck, DocumentReference docRef) async {
    await docRef.set(_deckToJson(deck));
  }

  model.Deck _deckFromJson(Map<String, dynamic> json, {String? id}) =>
      model.Deck(
        id: id,
        name: json['name'] as String,
        description: json['description'] as String?,
        parentDeckId: json['parentDeckId'] as String?,
        deckOptions: json['deckOptions'] != null
            ? _deckOptionsFromJson(json['deckOptions'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> _deckToJson(model.Deck deck) => {
        'name': deck.name,
        'description': deck.description,
        'parentDeckId': deck.parentDeckId,
        'deckOptions': deck.deckOptions != null
            ? _deckOptionsToJson(deck.deckOptions!)
            : null,
      };

  model.DeckOptions _deckOptionsFromJson(Map<String, dynamic> json) =>
      model.DeckOptions(
        cardsDaily: json['cardsDaily'] as int,
        newCardsDailyLimit: json['newCardsDailyLimit'] as int,
        maxInterval: Duration(
            milliseconds:
                json['maxInterval'] as int), // Parse from milliseconds
      );

  Map<String, dynamic> _deckOptionsToJson(model.DeckOptions deckOptions) => {
        'cardsDaily': deckOptions.cardsDaily,
        'newCardsDailyLimit': deckOptions.newCardsDailyLimit,
        'maxInterval':
            deckOptions.maxInterval.inMilliseconds, // Store as milliseconds
      };
}

class TagSerializer implements FirebaseSerializer<model.Tag> {
  @override
  Future<model.Tag> fromSnapshot(DocumentSnapshot snapshot) async {
    final data = snapshot.data() as Map<String, dynamic>;
    return _tagFromJson(data);
  }

  @override
  toSnapshot(model.Tag tag, DocumentReference docRef) async {
    await docRef.set(_tagToJson(tag));
  }

  Map<String, dynamic> _tagToJson(model.Tag tag) => {'name': tag.name};

  model.Tag _tagFromJson(Map<String, dynamic> json) =>
      model.Tag(name: json['name'] as String);
}

class CardSerializer implements FirebaseSerializer<model.Card> {
  @override
  Future<model.Card> fromSnapshot(DocumentSnapshot snapshot) async {
    final data = snapshot.data() as Map<String, dynamic>;
    final card = model.Card(
        id: snapshot.id,
        deckId: data['deckId'],
        question: _contentFromJson(data['question'])!,
        explanation: _contentFromJson(data['explanation']),
        answer: data['answer'],
        options: _cardOptionsFromJson(data['options']),
        tags: _tagsFromJson(data['tags'] ?? []),
        alternativeAnswers: data['alternativeAnswers'] ?? []);

    return card;
  }

  @override
  toSnapshot(model.Card card, DocumentReference docRef) async {
    await docRef.set(_cardToJson(card));
  }

  Map<String, dynamic> _cardToJson(model.Card card) => {
        'deckId': card.deckId,
        'question': _contentToJson(card.question),
        'answer': card.answer,
        'options': _cardOptionsToJson(card.options),
        'tags': card.tags?.map((tag) => tag.name).toSet(),
        'alternativeAnswers': card.alternativeAnswers,
        'explanation':
            card.explanation != null ? _contentToJson(card.explanation!) : null,
      };

  Map<String, dynamic> _cardOptionsToJson(model.CardOptions? cardOptions) => {
        'reverse': cardOptions?.reverse,
        'inputRequired': cardOptions?.inputRequired,
      };

  model.CardOptions _cardOptionsFromJson(Map<String, dynamic> json) =>
      model.CardOptions(
        reverse: (json['reverse'] ?? false) as bool,
        inputRequired: (json['inputRequire'] ?? false) as bool,
      );

  model.Content? _contentFromJson(Map<String, dynamic> json) {
    if (json['text'] == null) {
      return null;
    }
    return model.Content(text: json['text'] as String);
  }

  Map<String, dynamic> _contentToJson(model.Content? content) => {
        'text': content?.text,
      };

  List<model.Tag> _tagsFromJson(List<String> data) =>
      data.map((tag) => model.Tag(name: tag)).toList();
}

class CardStatsSerializer implements FirebaseSerializer<model.CardStats> {
  @override
  Future<model.CardStats> fromSnapshot(DocumentSnapshot snapshot) async {
    final data = snapshot.data() as Map<String, dynamic>;
    return _cardStatsFromJson(data);
  }

  @override
  toSnapshot(model.CardStats value, DocumentReference docRef) async =>
      await docRef
          .set({'stats': _cardStatsToJson(value)}, SetOptions(merge: true));

  model.CardStats _cardStatsFromJson(Map<String, dynamic> json) =>
      model.CardStats(
        cardId: json['cardId'] as String,
        stability: json['stability'] as double,
        difficulty: json['difficulty'] as double,
        lastReview: (json['lastReview'] as Timestamp).toDate(),
        numberOfReviews: json['numberOfReviews'] as int,
        numberOfLapses: json['numberOfLapses'] as int,
        dateAdded: (json['dateAdded'] as Timestamp).toDate(),
        interval: (json['interval'] ?? 0) as int,
        nextReviewDate:
            ((json['nextReviewDate'] ?? Timestamp.now()) as Timestamp).toDate(),
        state: json['state'] == null
            ? model.State.newState
            : model.State.values
                .firstWhere((element) => element.name == json['state']),
      );

  Map<String, dynamic> _cardStatsToJson(model.CardStats cardStats) => {
        'stability': cardStats.stability,
        'difficulty': cardStats.difficulty,
        'lastReview': cardStats.lastReview,
        'numberOfReviews': cardStats.numberOfReviews,
        'numberOfLapses': cardStats.numberOfLapses,
        'dateAdded': cardStats.dateAdded,
        'interval': cardStats.interval,
        'nextReviewDate': cardStats.nextReviewDate,
        'state': cardStats.state.name,
      };
}

class CardAnswerSerializer implements FirebaseSerializer<model.CardAnswer> {
  @override
  Future<model.CardAnswer> fromSnapshot(DocumentSnapshot snapshot) async {
    final data = snapshot.data() as Map<String, dynamic>;
    return _cardAnswerFromJson(data);
  }

  @override
  toSnapshot(model.CardAnswer value, DocumentReference docRef) async =>
      await docRef.set(_cardAnswerToJson(value));

  model.CardAnswer _cardAnswerFromJson(Map<String, dynamic> json) =>
      model.CardAnswer(
        cardId: json['cardId'] as String,
        date: (json['date'] as Timestamp).toDate(),
        answerRate: json['answerRate'] as double,
        timeSpent: Duration(milliseconds: json['timeSpent'] as int),
      );

  Map<String, dynamic> _cardAnswerToJson(model.CardAnswer cardAnswer) => {
        'cardId': cardAnswer.cardId,
        'date': cardAnswer.date,
        'answerRate': cardAnswer.answerRate,
        'timeSpent': cardAnswer.timeSpent.inMilliseconds,
      };
}
