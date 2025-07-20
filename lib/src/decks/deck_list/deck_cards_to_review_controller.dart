import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';

import '../../model/cards.dart' as model;
import 'decks_controller.dart';

part 'deck_cards_to_review_controller.g.dart';

/// Controller for managing cards to review count for a specific deck
@riverpod
class DeckCardsToReviewController extends _$DeckCardsToReviewController {
  final Logger _log = Logger();
  late String _deckId;

  @override
  AsyncValue<Map<model.State, int>> build(String deckId) {
    _deckId = deckId;
    _loadCardsToReviewCount();
    return const AsyncValue.loading();
  }

  /// Loads cards to review count for a specific deck
  Future<void> _loadCardsToReviewCount() async {
    try {
      _log.d('Loading cards to review count for deck: $_deckId');
      state = const AsyncValue.loading();
      final repository = ref.read(cardsRepositoryProvider);
      final cardsCount = await repository.cardsToReviewCount(deckId: _deckId);
      state = AsyncValue.data(cardsCount);
      _log.d(
        'Successfully loaded cards to review count for deck: $_deckId - $cardsCount',
      );
    } catch (error, stackTrace) {
      _log.e(
        'Error loading cards to review count for deck: $_deckId',
        error: error,
        stackTrace: stackTrace,
      );
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Refreshes the cards to review count for the deck
  Future<void> refresh() async {
    await _loadCardsToReviewCount();
  }

  /// Gets the total cards to review count
  int getTotalCardsToReview() {
    final data = state.value;
    if (data == null) return 0;
    return data.values.reduce((agg, next) => agg + next);
  }

  /// Gets the cards to review count by state
  Map<model.State, int> getCardsToReviewByState() {
    return state.value ?? {};
  }
}
