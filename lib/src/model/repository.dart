import 'cards.dart' as model;

abstract class CardsRepository {
  Future<void> saveDeck(model.Deck deck);
  Future<List<model.Deck>> loadDecks();
  Future<void> deleteDeck(String deckId);
  Future<void> addCard(model.Card card);
  Future<void> deleteCard(String cardId);
  Future<void> updateCard(model.Card card);
}

class InMemoryCardsRepository implements CardsRepository {
  final Map<String, model.Deck> _decks = {};
  final Map<String, model.Card> _cards = {};

  @override
  Future<void> saveDeck(model.Deck deck) async {
    _decks[deck.name] = deck;
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
  Future<void> addCard(model.Card card) async {
    _cards[card.question.text] = card;
  }

  @override
  Future<void> deleteCard(String cardId) async {
    _cards.remove(cardId);
  }

  @override
  Future<void> updateCard(model.Card card) async {
    _cards[card.question.text] = card;
  }
}
