import 'package:flutter_flashcards/src/model/firebase_serializable.dart';

class Attachment {
  final String id;
  final String url;

  const Attachment({required this.id, required this.url});

  Map<String, dynamic> toJson() => {"id": id, "url": url};
}

class CardOptions {
  final bool learnBothSides;
  final bool inputRequired;

  CardOptions({this.learnBothSides = false, this.inputRequired = false});

  Map<String, dynamic> toJson() => {
    'learnBothSides': learnBothSides,
    'inputRequired': inputRequired,
  };

  factory CardOptions.fromJson(Map<String, dynamic> json) => CardOptions(
    learnBothSides: (json['learnBothSides'] ?? false) as bool,
    inputRequired: (json['inputRequire'] ?? false) as bool,
  );
}

class Card implements FirebaseSerializable {
  final String id;
  final String deckId;
  final String question;
  final bool questionImageAttached;
  final String answer;
  final CardOptions? options;
  final List<String>? alternativeAnswers;
  final String? explanation;
  final bool explanationImageAttached;

  const Card({
    required this.id,
    required this.deckId,
    required this.question,
    required this.answer,
    this.options,
    this.alternativeAnswers,
    this.explanation,
    this.questionImageAttached = false,
    this.explanationImageAttached = false,
  });

  Card withId({required String id}) {
    return Card(
      id: id,
      deckId: deckId,
      question: question,
      answer: answer,
      options: options,
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
    List<String>? alternativeAnswers,
    String? explanation,
    bool? questionImageAttached,
    bool? explanationImageAttached,
  }) => Card(
    id: id ?? this.id,
    deckId: deckId ?? this.deckId,
    question: question ?? this.question,
    answer: answer ?? this.answer,
    options: options ?? this.options,
    alternativeAnswers: alternativeAnswers ?? this.alternativeAnswers,
    explanation: explanation ?? this.explanation,
    questionImageAttached: questionImageAttached ?? this.questionImageAttached,
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
  String get idValue => id;

  @override
  Map<String, dynamic> toJson() => {
    'deckId': deckId,
    // regrettable redundancy due to limitation of collectionGroup filtering
    'cardId': id,
    'question': question,
    'answer': answer,
    'options': options?.toJson(),
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
    alternativeAnswers: data['alternativeAnswers'] ?? [],
    questionImageAttached: data['questionImageAttached'] ?? false,
    explanationImageAttached: data['explanationImageAttached'] ?? false,
  );
}
