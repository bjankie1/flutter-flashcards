import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_flashcards/src/model/cards.dart' as model;
import 'package:logger/logger.dart';

abstract class FirebaseSerializer<T> {
  Future<T> fromSnapshot(DocumentSnapshot snapshot);
  Future<void> toSnapshot(T value, DocumentReference docRef) async {
    await _updateUserId(docRef);
    await docRef.set(_serialize(value), SetOptions(merge: true));
  }

  Map<String, dynamic> _serialize(T value);

  _updateUserId(DocumentReference doc) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await doc.set({'userId': user.uid}, SetOptions(merge: true));
    }
  }
}

class DeckSerializer extends FirebaseSerializer<model.Deck> {
  @override
  Future<model.Deck> fromSnapshot(DocumentSnapshot snapshot) async {
    final data = snapshot.data() as Map<String, dynamic>;
    return _deckFromJson(data, id: snapshot.id);
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

  @override
  Map<String, dynamic> _serialize(model.Deck value) => {
        'name': value.name,
        'description': value.description,
        'parentDeckId': value.parentDeckId,
        'deckOptions': value.deckOptions != null
            ? _deckOptionsToJson(value.deckOptions!)
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

class TagSerializer extends FirebaseSerializer<model.Tag> {
  @override
  Future<model.Tag> fromSnapshot(DocumentSnapshot snapshot) async {
    final data = snapshot.data() as Map<String, dynamic>;
    return _tagFromJson(data);
  }

  @override
  Map<String, dynamic> _serialize(model.Tag tag) => {'name': tag.name};

  model.Tag _tagFromJson(Map<String, dynamic> json) =>
      model.Tag(name: json['name'] as String);
}

class CardSerializer extends FirebaseSerializer<model.Card> {
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
  Map<String, dynamic> _serialize(model.Card value) => {
        'deckId': value.deckId,
        'question': _contentToJson(value.question),
        'answer': value.answer,
        'options': _cardOptionsToJson(value.options),
        'tags': value.tags?.map((tag) => tag.name).toSet(),
        'alternativeAnswers': value.alternativeAnswers,
        'explanation': value.explanation != null
            ? _contentToJson(value.explanation!)
            : null,
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

class CardStatsSerializer extends FirebaseSerializer<model.CardStats> {
  var _log = Logger();

  @override
  Future<model.CardStats> fromSnapshot(DocumentSnapshot snapshot) async {
    try {
      // _log.d('Deserializing stats');
      return _cardStatsFromJson(
          snapshot.id, snapshot.data() as Map<String, dynamic>);
    } on Exception catch (e) {
      _log.w('Error loading card stats: $e');
      rethrow;
    }
  }

  @override
  toSnapshot(model.CardStats value, DocumentReference docRef) async {
    await docRef.set({'stats': _serialize(value)}, SetOptions(merge: true));
    await _updateUserId(docRef);
  }

  model.CardStats _cardStatsFromJson(String id, Map<String, dynamic> json) =>
      model.CardStats(
        cardId: id,
        stability: json['stats']?['stability'] as double? ?? 0,
        difficulty: json['stats']?['difficulty'] as double? ?? 0,
        lastReview:
            (json['stats']?['lastReview'] as Timestamp? ?? Timestamp.now())
                .toDate(),
        numberOfReviews: json['stats']?['numberOfReviews'] as int? ?? 0,
        numberOfLapses: json['stats']?['numberOfLapses'] as int? ?? 0,
        dateAdded:
            (json['stats']?['dateAdded'] as Timestamp? ?? Timestamp.now())
                .toDate(),
        interval: (json['stats']?['interval'] ?? 0) as int? ?? 0,
        nextReviewDate:
            ((json['stats']?['nextReviewDate'] ?? Timestamp.now()) as Timestamp)
                .toDate(),
        state: json['stats']?['state'] == null
            ? model.State.newState
            : model.State.values.firstWhere(
                (element) => element.name == json['stats']['state']),
      );

  @override
  Map<String, dynamic> _serialize(model.CardStats value) => {
        'cardId': value.cardId,
        'stability': value.stability,
        'difficulty': value.difficulty,
        'lastReview': value.lastReview,
        'numberOfReviews': value.numberOfReviews,
        'numberOfLapses': value.numberOfLapses,
        'dateAdded': value.dateAdded,
        'interval': value.interval,
        'nextReviewDate': value.nextReviewDate,
        'state': value.state.name,
      };
}

class CardAnswerSerializer extends FirebaseSerializer<model.CardAnswer> {
  @override
  Future<model.CardAnswer> fromSnapshot(DocumentSnapshot snapshot) async {
    final data = snapshot.data() as Map<String, dynamic>;
    return _cardAnswerFromJson(data);
  }

  model.CardAnswer _cardAnswerFromJson(Map<String, dynamic> json) =>
      model.CardAnswer(
        cardId: json['cardId'] as String,
        date: (json['date'] as Timestamp).toDate(),
        answerRate: json['answerRate'] as double,
        timeSpent: Duration(milliseconds: json['timeSpent'] as int),
      );

  @override
  Map<String, dynamic> _serialize(model.CardAnswer value) => {
        'cardId': value.cardId,
        'date': value.date,
        'answerRate': value.answerRate,
        'timeSpent': value.timeSpent.inMilliseconds,
      };
}
