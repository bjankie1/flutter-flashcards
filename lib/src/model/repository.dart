import 'package:uuid/uuid.dart';

import 'cards.dart' as model;

abstract class CardsRepository {
  Future<model.Deck> addDeck(model.Deck deck);
  Future<void> updateDeck(model.Deck deck);
  Future<List<model.Deck>> loadDecks();
  Future<void> deleteDeck(String deckId);
  Future<model.Card> addCard(model.Card card);
  Future<void> deleteCard(String cardId);
  Future<void> updateCard(model.Card card);
}

class InMemoryCardsRepository implements CardsRepository {
  final Map<String, model.Deck> _decks = {};
  final Map<String, model.Card> _cards = {};
  var _uuid = Uuid();

  @override
  Future<model.Deck> addDeck(model.Deck deck) async {
    var deckWithId = deck.copyWith(id: _uuid.v4());
    _decks[deckWithId.id] = deckWithId;
    return deckWithId;
  }

  @override
  Future<List<model.Deck>> loadDecks() async {
    return _decks.values.toList();
  }

  @override
  Future<void> deleteDeck(String deckId) async {
    _decks.remove(deckId);
    _cards.removeWhere((key, value) => value.deckId == deckId);
  }

  @override
  Future<model.Card> addCard(model.Card card) async {
    final cardId = _uuid.v4(); // Generate a UUID
    final cardWithId = card.copyWith(id: cardId); // Assign the UUID to the card
    _cards[cardId] = cardWithId; // Store the card using the UUID as the key
    return cardWithId;
  }

  @override
  Future<void> deleteCard(String cardId) async {
    _cards.remove(cardId);
  }

  @override
  Future<void> updateCard(model.Card card) async {
    _cards[card.question.text] = card;
  }

  @override
  Future<void> updateDeck(model.Deck deck) {
    _decks[deck.name] = deck;
    return Future.value();
  }
}
