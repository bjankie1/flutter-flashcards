import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../model/cards.dart' as model;
import '../deck_list/decks_controller.dart';
import '../../genkit/functions.dart';

part 'deck_details_controller.g.dart';

/// Controller for managing deck details operations
@riverpod
class DeckDetailsController extends _$DeckDetailsController {
  final Logger _log = Logger();
  late String _deckId;

  @override
  AsyncValue<model.Deck> build(String deckId) {
    _deckId = deckId;
    _loadDeck();
    return const AsyncValue.loading();
  }

  /// Loads the deck details
  Future<void> _loadDeck() async {
    try {
      _log.d('Loading deck details for deck: $_deckId');
      state = const AsyncValue.loading();
      final repository = ref.read(cardsRepositoryProvider);
      final deck = await repository.loadDeck(_deckId);
      if (deck == null) {
        throw Exception('Deck not found: $_deckId');
      }
      state = AsyncValue.data(deck);
      _log.d('Successfully loaded deck details for deck: $_deckId');
    } catch (error, stackTrace) {
      _log.e(
        'Error loading deck details for deck: $_deckId',
        error: error,
        stackTrace: stackTrace,
      );
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Updates the deck name
  Future<void> updateDeckName(
    String name,
    CloudFunctions cloudFunctions,
  ) async {
    try {
      _log.d('Updating deck name for deck: $_deckId to: $name');
      final currentDeck = state.value;
      if (currentDeck == null) {
        throw Exception('No deck loaded');
      }

      var newDeck = currentDeck.copyWith(name: name);

      // Get category from cloud functions
      try {
        final category = await cloudFunctions.deckCategory(
          name,
          newDeck.description ?? '',
        );
        newDeck = newDeck.copyWith(category: category);
      } catch (e, stackTrace) {
        _log.e('Error getting deck category', error: e, stackTrace: stackTrace);
        // Continue without category update
      }

      // Save the deck
      final repository = ref.read(cardsRepositoryProvider);
      await repository.saveDeck(newDeck);

      // Update state
      state = AsyncValue.data(newDeck);

      // Refresh the decks list
      await ref.read(decksControllerProvider.notifier).refresh();

      _log.d('Successfully updated deck name for deck: $_deckId');
    } catch (error, stackTrace) {
      _log.e(
        'Error updating deck name for deck: $_deckId',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Updates the deck description
  Future<void> updateDeckDescription(
    String description,
    CloudFunctions cloudFunctions,
  ) async {
    try {
      _log.d('Updating deck description for deck: $_deckId');
      final currentDeck = state.value;
      if (currentDeck == null) {
        throw Exception('No deck loaded');
      }

      var newDeck = currentDeck.copyWith(description: description);

      // Get category from cloud functions
      try {
        final category = await cloudFunctions.deckCategory(
          newDeck.name,
          description,
        );
        newDeck = newDeck.copyWith(category: category);
      } catch (e, stackTrace) {
        _log.e('Error getting deck category', error: e, stackTrace: stackTrace);
        // Continue without category update
      }

      // Save the deck
      final repository = ref.read(cardsRepositoryProvider);
      await repository.saveDeck(newDeck);

      // Update state
      state = AsyncValue.data(newDeck);

      // Refresh the decks list
      await ref.read(decksControllerProvider.notifier).refresh();

      _log.d('Successfully updated deck description for deck: $_deckId');
    } catch (error, stackTrace) {
      _log.e(
        'Error updating deck description for deck: $_deckId',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Refreshes the deck details
  Future<void> refresh() async {
    await _loadDeck();
  }

  /// Gets the current deck
  model.Deck? getDeck() {
    return state.value;
  }

  /// Gets the deck category
  model.DeckCategory? getCategory() {
    return state.value?.category;
  }
}
