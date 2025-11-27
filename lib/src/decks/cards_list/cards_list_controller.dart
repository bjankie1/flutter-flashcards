import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';
import '../../model/cards.dart' as model;
import '../../common/sorting_utils.dart';
import '../deck_list/decks_controller.dart';

part 'cards_list_controller.g.dart';

class CardsListData {
  final List<model.Card> cards;
  final Map<String, List<model.CardStats>> cardStats;
  final String searchQuery;

  CardsListData({
    required this.cards,
    required this.cardStats,
    this.searchQuery = '',
  });

  List<model.Card> get filteredCards {
    if (searchQuery.isEmpty) return cards;
    final query = searchQuery.toLowerCase();
    return cards
        .where(
          (card) =>
              SortingUtils.containsWithDiacritics(card.question, query) ||
              SortingUtils.containsWithDiacritics(card.answer, query),
        )
        .toList();
  }

  CardsListData copyWith({
    List<model.Card>? cards,
    Map<String, List<model.CardStats>>? cardStats,
    String? searchQuery,
  }) {
    return CardsListData(
      cards: cards ?? this.cards,
      cardStats: cardStats ?? this.cardStats,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Controller for managing cards list operations
@riverpod
class CardsListController extends _$CardsListController {
  final Logger _log = Logger();
  late String _deckId;

  @override
  AsyncValue<CardsListData> build(String deckId) {
    _log.d(
      'CardsListController build called for deckId: \x1B[32m$deckId\x1B[0m',
    );
    _deckId = deckId;
    _loadCards();
    return const AsyncValue.loading();
  }

  /// Loads cards for the deck
  Future<void> _loadCards() async {
    _log.d(
      '[_loadCards] Start loading cards for deck: \x1B[32m$_deckId\x1B[0m',
    );
    try {
      final repository = ref.read(cardsRepositoryProvider);
      _log.d('[_loadCards] Got repository, loading cards...');
      final cards = await repository.loadCards(_deckId);
      _log.d('[_loadCards] Loaded cards: count=[33m${cards.length}[0m');
      final cardIds = cards.map((c) => c.id).toList();
      final allStats = await repository.loadCardStatsForCardIds(cardIds);
      _log.d('[_loadCards] Loaded card stats: count=${allStats.length}');
      final cardStats = <String, List<model.CardStats>>{};
      for (final card in cards) {
        final statsForCard = allStats
            .where((s) => s.cardId == card.id)
            .toList();
        statsForCard.sort((a, b) => a.variant.index.compareTo(b.variant.index));
        cardStats[card.id] = statsForCard;
      }

      final sortedCards = cards.toList()
        ..sort(
          (a, b) => SortingUtils.compareWithDiacritics(a.question, b.question),
        );
      state = AsyncValue.data(
        CardsListData(cards: sortedCards, cardStats: cardStats),
      );
      _log.d(
        '[_loadCards] State updated: cards=${sortedCards.length}, isLoading=false',
      );
    } catch (error, stackTrace) {
      _log.e(
        '[_loadCards] Error loading cards for deck: $_deckId',
        error: error,
        stackTrace: stackTrace,
      );
      state = AsyncValue.error(error, stackTrace);
      _log.d(
        '[_loadCards] State updated: hasError=true, errorMessage=${error.toString()}',
      );
    }
  }

  /// Updates the search query
  void updateSearchQuery(String query) {
    state = state.whenData((data) => data.copyWith(searchQuery: query));
  }

  /// Deletes a card
  Future<void> deleteCard(model.Card card) async {
    try {
      _log.d('Deleting card: ${card.id} from deck: $_deckId');
      final repository = ref.read(cardsRepositoryProvider);
      await repository.deleteCard(card.id);
      await _loadCards();
      _log.d('Successfully deleted card: ${card.id}');
    } catch (error, stackTrace) {
      _log.e(
        'Error deleting card: ${card.id}',
        error: error,
        stackTrace: stackTrace,
      );
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Refreshes the cards data
  Future<void> refresh() async {
    await _loadCards();
  }
}
