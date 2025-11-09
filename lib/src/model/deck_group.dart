import 'package:flutter_flashcards/src/model/deck.dart';

class DeckGroup {
  final DeckGroupId id;
  final String name;
  final String? description;
  final Set<DeckId>? decks;

  const DeckGroup({
    required this.id,
    required this.name,
    this.description,
    this.decks = const {},
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeckGroup && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  DeckGroup copyWith({
    String? id,
    String? name,
    String? description,
    Set<DeckId>? decks,
  }) {
    return DeckGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      decks: decks ?? this.decks,
    );
  }

  factory DeckGroup.fromJson(String id, Map<String, dynamic> json) => DeckGroup(
    id: id,
    name: json['name'] as String,
    description: json['description'] as String?,
    decks: (json['decks'] as List<dynamic>).map((id) => id.toString()).toSet(),
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'name__lowercase': name.toLowerCase(),
    'description': description,
    'decks': decks == null ? [] : decks!.toList(),
  };
}
