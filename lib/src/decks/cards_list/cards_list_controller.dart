import 'package:flutter/material.dart';
import '../../model/cards.dart' as model;
import '../../model/repository.dart';

class CardsListController extends ChangeNotifier {
  final String deckId;
  final CardsRepository repository;
  final TextEditingController searchController = TextEditingController();

  List<model.Card> _cards = [];
  Map<String, List<model.CardStats>> _cardStats = {};
  String _searchQuery = '';
  bool _loading = false;
  bool _error = false;

  CardsListController({required this.deckId, required this.repository}) {
    searchController.addListener(_onSearchChanged);
    loadCards();
  }

  List<model.Card> get cards => _cards;
  Map<String, List<model.CardStats>> get cardStats => _cardStats;
  String get searchQuery => _searchQuery;
  bool get loading => _loading;
  bool get error => _error;

  List<model.Card> get filteredCards {
    if (_searchQuery.isEmpty) return _cards;
    final query = _searchQuery.toLowerCase();
    return _cards
        .where(
          (card) =>
              card.question.toLowerCase().contains(query) ||
              card.answer.toLowerCase().contains(query),
        )
        .toList();
  }

  void _onSearchChanged() {
    _searchQuery = searchController.text;
    notifyListeners();
  }

  Future<void> loadCards() async {
    _loading = true;
    _error = false;
    notifyListeners();
    try {
      final cards = await repository.loadCards(deckId);
      final cardIds = cards.map((c) => c.id).toList();
      final allStats = await repository.loadCardStatsForCardIds(cardIds);
      _cardStats = {};
      for (final card in cards) {
        final statsForCard = allStats
            .where((s) => s.cardId == card.id)
            .toList();
        statsForCard.sort((a, b) => a.variant.index.compareTo(b.variant.index));
        _cardStats[card.id] = statsForCard;
      }
      _cards = cards.toList();
      _cards.sort(
        (a, b) => a.question.toLowerCase().compareTo(b.question.toLowerCase()),
      );
      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = true;
      notifyListeners();
    }
  }

  Future<void> deleteCard(model.Card card) async {
    try {
      await repository.deleteCard(card.id);
      await loadCards();
    } catch (e) {
      // error handling can be improved as needed
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
