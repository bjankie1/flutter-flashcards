import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'decks_controller.dart';

part 'deck_info_controller.g.dart';

/// Controller for managing deck info data (card count)
@riverpod
class DeckInfoController extends _$DeckInfoController {
  final Logger _log = Logger();
  late String _deckId;

  @override
  AsyncValue<int> build(String deckId) {
    _deckId = deckId;
    _loadCardCount();
    return const AsyncValue.loading();
  }

  /// Loads card count for a specific deck
  Future<void> _loadCardCount() async {
    try {
      _log.d('Loading card count for deck: $_deckId');
      state = const AsyncValue.loading();
      final repository = ref.read(cardsRepositoryProvider);
      final cardCount = await repository.getCardCount(_deckId);
      state = AsyncValue.data(cardCount);
      _log.d(
        'Successfully loaded card count for deck: $_deckId - $cardCount cards',
      );
    } catch (error, stackTrace) {
      _log.e(
        'Error loading card count for deck: $_deckId',
        error: error,
        stackTrace: stackTrace,
      );
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Refreshes the card count for the deck
  Future<void> refresh() async {
    await _loadCardCount();
  }

  /// Gets the current card count
  int getCardCount() {
    return state.value ?? 0;
  }
}
