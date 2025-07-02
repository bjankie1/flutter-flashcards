import 'package:flutter_flashcards/src/model/enums.dart';
import 'package:flutter_flashcards/src/model/firebase_serializable.dart';

typedef DeckId = String;
typedef DeckGroupId = String;

class Deck implements FirebaseSerializable {
  final DeckId? id;
  final String name;
  final String? description;
  final String? parentDeckId;
  final DeckOptions? deckOptions;
  final DeckCategory? category;

  const Deck({
    this.id,
    required this.name,
    this.description,
    this.parentDeckId,
    this.deckOptions,
    this.category = DeckCategory.other,
  });

  Deck withId({required String id}) {
    return Deck(
      id: id,
      name: name,
      description: description,
      parentDeckId: parentDeckId,
      deckOptions: deckOptions,
    );
  }

  @override
  int get hashCode => Object.hash(id, name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Deck &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          id == other.id;

  Deck copyWith({
    String? id,
    String? name,
    String? description,
    String? parentDeckId,
    DeckOptions? deckOptions,
    DeckCategory? category,
  }) {
    return Deck(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      parentDeckId: parentDeckId ?? this.parentDeckId,
      deckOptions: deckOptions ?? this.deckOptions,
      category: category ?? this.category,
    );
  }

  factory Deck.fromJson(String id, Map<String, dynamic> json) => Deck(
    id: id,
    name: json['name'] as String,
    description: json['description'] as String?,
    parentDeckId: json['parentDeckId'] as String?,
    deckOptions: json['deckOptions'] != null
        ? _deckOptionsFromJson(json['deckOptions'] as Map<String, dynamic>)
        : null,
    category: json['category'] != null
        ? DeckCategory.fromName(json['category'])
        : null,
  );

  @override
  Map<String, dynamic> toJson() => {
    'name': name,
    'deckId': id,
    'description': description,
    'parentDeckId': parentDeckId,
    'deckOptions': deckOptions != null
        ? _deckOptionsToJson(deckOptions!)
        : null,
    'category': category?.name,
  };

  static DeckOptions _deckOptionsFromJson(Map<String, dynamic> json) =>
      DeckOptions(
        cardsDaily: json['cardsDaily'] as int,
        newCardsDailyLimit: json['newCardsDailyLimit'] as int,
        maxInterval: Duration(
          milliseconds: json['maxInterval'] as int,
        ), // Parse from milliseconds
      );

  Map<String, dynamic> _deckOptionsToJson(DeckOptions deckOptions) => {
    'cardsDaily': deckOptions.cardsDaily,
    'newCardsDailyLimit': deckOptions.newCardsDailyLimit,
    'maxInterval':
        deckOptions.maxInterval.inMilliseconds, // Store as milliseconds
  };

  @override
  String get idValue => id!;
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
