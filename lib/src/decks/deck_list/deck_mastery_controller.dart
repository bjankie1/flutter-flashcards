import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../model/card_mastery.dart';
import '../../services/cache_providers.dart';

part 'deck_mastery_controller.g.dart';

/// Controller for managing deck mastery data
@riverpod
class DeckMasteryController extends _$DeckMasteryController {
  final Logger _log = Logger();

  @override
  AsyncValue<Map<CardMastery, int>> build(String deckId) {
    _log.d('Building DeckMasteryController for deck: $deckId');

    // Watch cache readiness - this will automatically rebuild when cache becomes ready
    final cacheReady = ref.watch(cacheServicesReadyProvider);

    if (!cacheReady) {
      _log.d('Cache services not ready yet');
      return const AsyncValue.loading();
    }

    // Watch the decks service - this will automatically rebuild when service becomes available
    final decksServiceAsync = ref.watch(decksServiceProvider);

    return decksServiceAsync.when(
      data: (decksService) {
        if (decksService == null) {
          _log.w('DecksService not available');
          return AsyncValue.error(
            'DecksService not available',
            StackTrace.current,
          );
        }

        try {
          _log.d('Loading mastery data for deck: $deckId');
          final masteryData = decksService.getMasteryBreakdown(deckId: deckId);
          _log.d('Successfully loaded mastery data for deck: $deckId');
          return AsyncValue.data(masteryData);
        } catch (error, stackTrace) {
          _log.e(
            'Error loading mastery data for deck: $deckId',
            error: error,
            stackTrace: stackTrace,
          );
          return AsyncValue.error(error, stackTrace);
        }
      },
      loading: () => const AsyncValue.loading(),
      error: (error, stackTrace) {
        _log.e(
          'Error with DecksService for deck: $deckId',
          error: error,
          stackTrace: stackTrace,
        );
        return AsyncValue.error(error, stackTrace);
      },
    );
  }

  /// Refreshes the mastery data for the deck
  Future<void> refresh() async {
    _log.d('Refreshing mastery data');
    ref.invalidateSelf();
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
