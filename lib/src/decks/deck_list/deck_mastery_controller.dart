import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../model/card_mastery.dart';
import 'decks_controller.dart';

part 'deck_mastery_controller.g.dart';

/// Controller for managing deck mastery data
@riverpod
class DeckMasteryController extends _$DeckMasteryController {
  final Logger _log = Logger();
  late String _deckId;

  @override
  AsyncValue<Map<CardMastery, int>> build(String deckId) {
    _deckId = deckId;
    _loadMasteryData();
    return const AsyncValue.loading();
  }

  /// Loads mastery breakdown for a specific deck
  Future<void> _loadMasteryData() async {
    try {
      _log.d('Loading mastery data for deck: $_deckId');
      state = const AsyncValue.loading();
      final repository = ref.read(cardsRepositoryProvider);
      final masteryData = await repository.getMasteryBreakdown(deckId: _deckId);
      state = AsyncValue.data(masteryData);
      _log.d('Successfully loaded mastery data for deck: $_deckId');
    } catch (error, stackTrace) {
      _log.e(
        'Error loading mastery data for deck: $_deckId',
        error: error,
        stackTrace: stackTrace,
      );
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Refreshes the mastery data for the deck
  Future<void> refresh() async {
    await _loadMasteryData();
  }

  /// Gets the mastery progress percentage
  double getProgressPercentage() {
    final data = state.value;
    if (data == null) return 0.0;

    final total = data.values.fold(0, (a, b) => a + b);
    final mastered =
        (data[CardMastery.young] ?? 0) + (data[CardMastery.mature] ?? 0);
    return total == 0 ? 0.0 : mastered / total;
  }

  /// Gets the total number of cards
  int getTotalCards() {
    final data = state.value;
    if (data == null) return 0;
    return data.values.fold(0, (a, b) => a + b);
  }

  /// Gets the number of mastered cards (young + mature)
  int getMasteredCards() {
    final data = state.value;
    if (data == null) return 0;
    return (data[CardMastery.young] ?? 0) + (data[CardMastery.mature] ?? 0);
  }
}
