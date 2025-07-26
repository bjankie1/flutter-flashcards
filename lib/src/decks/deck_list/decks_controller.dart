import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';

import '../../model/cards.dart' as model;
import '../../model/repository.dart';
import '../deck_groups/deck_groups_controller.dart';

part 'decks_controller.g.dart';

/// Controller for managing deck-related operations
@riverpod
class DecksController extends _$DecksController {
  final Logger _log = Logger();

  @override
  AsyncValue<Iterable<model.Deck>> build() {
    _loadDecks();
    return const AsyncValue.loading();
  }

  /// Loads all decks from the repository
  Future<void> _loadDecks() async {
    try {
      _log.d('Loading decks');
      state = const AsyncValue.loading();
      final repository = ref.read(cardsRepositoryProvider);
      final decks = await repository.loadDecks();
      state = AsyncValue.data(decks);
      _log.d('Successfully loaded ${decks.length} decks');
    } catch (error, stackTrace) {
      _log.e('Error loading decks', error: error, stackTrace: stackTrace);
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Refreshes the decks data
  Future<void> refresh() async {
    await _loadDecks();
  }

  /// Saves a deck
  Future<void> saveDeck(model.Deck deck) async {
    try {
      _log.d('Saving deck: ${deck.name}');
      final repository = ref.read(cardsRepositoryProvider);
      await repository.saveDeck(deck);
      await _loadDecks(); // Refresh the list

      // Refresh deck groups controller to show new deck in unassigned decks
      try {
        await ref.read(deckGroupsControllerProvider.notifier).onDeckChanged();
      } catch (e) {
        _log.w('Failed to refresh deck groups controller: $e');
      }

      _log.d('Successfully saved deck: ${deck.name}');
    } catch (error, stackTrace) {
      _log.e('Error saving deck', error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Deletes a deck
  Future<void> deleteDeck(String deckId) async {
    try {
      _log.d('Deleting deck: $deckId');
      final repository = ref.read(cardsRepositoryProvider);

      // Use a transaction to ensure atomicity
      await repository.runTransaction(() async {
        // First, remove the deck from all groups to clean up references
        final groups = await repository.loadDeckGroups();
        for (final group in groups) {
          if (group.decks?.contains(deckId) ?? false) {
            _log.d('Removing deck $deckId from group ${group.name}');
            await repository.removeDeckFromGroup(deckId, group.id);
          }
        }

        // Now delete the deck
        await repository.deleteDeck(deckId);
      });

      await _loadDecks(); // Refresh the list

      // Refresh deck groups controller to update unassigned decks list
      try {
        await ref.read(deckGroupsControllerProvider.notifier).onDeckChanged();
      } catch (e) {
        _log.w('Failed to refresh deck groups controller: $e');
      }

      _log.d('Successfully deleted deck: $deckId');
    } catch (error, stackTrace) {
      _log.e('Error deleting deck', error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Gets a specific deck by ID
  Future<model.Deck?> getDeck(String deckId) async {
    try {
      _log.d('Loading deck: $deckId');
      final repository = ref.read(cardsRepositoryProvider);
      return await repository.loadDeck(deckId);
    } catch (error, stackTrace) {
      _log.e('Error loading deck', error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> saveDeckGroup(model.DeckGroup deckGroup) async {
    try {
      _log.d('Saving deck group: ${deckGroup.name}');
      final repository = ref.read(cardsRepositoryProvider);
      await repository.createDeckGroup(deckGroup.name, deckGroup.description);
      await _loadDecks(); // Refresh the list
      _log.d('Successfully saved deck group: ${deckGroup.name}');
    } catch (error, stackTrace) {
      _log.e('Error saving deck group', error: error, stackTrace: stackTrace);
      rethrow;
    }
  }
}

/// Provider for the cards repository
@riverpod
CardsRepository cardsRepository(Ref ref) {
  // This will be provided by the main app setup
  throw UnimplementedError('CardsRepository should be provided at app level');
}

/// Provider for sorted decks
@riverpod
AsyncValue<List<model.Deck>> sortedDecks(Ref ref) {
  final decksAsync = ref.watch(decksControllerProvider);

  return decksAsync.when(
    data: (decks) {
      final sortedDecks = decks.toList();
      sortedDecks.sort((deck1, deck2) => deck1.name.compareTo(deck2.name));
      return AsyncValue.data(sortedDecks);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
}

@riverpod
class DeckGroups extends _$DeckGroups {
  @override
  Future<Iterable<model.DeckGroup>> build() async {
    return ref.watch(cardsRepositoryProvider).loadDeckGroups();
  }

  Future<void> createDeckGroup(String name, String? description) async {
    final repository = ref.read(cardsRepositoryProvider);
    await repository.createDeckGroup(name, description);
    ref.invalidateSelf();
  }

  Future<void> deleteDeckGroup(String groupId) async {
    final repository = ref.read(cardsRepositoryProvider);
    await repository.deleteDeckGroup(groupId);
    ref.invalidateSelf();
  }

  Future<void> addDeckToGroup(String deckId, String groupId) async {
    final repository = ref.read(cardsRepositoryProvider);
    await repository.addDeckToGroup(deckId, groupId);
    ref.invalidateSelf();
  }

  Future<void> removeDeckFromGroup(String deckId, String groupId) async {
    final repository = ref.read(cardsRepositoryProvider);
    await repository.removeDeckFromGroup(deckId, groupId);
    ref.invalidateSelf();
  }

  Future<void> updateDeckGroup(model.DeckGroup group) async {
    final repository = ref.read(cardsRepositoryProvider);
    await repository.updateDeckGroup(group);
    ref.invalidateSelf();
  }
}

/// Provider for loading a single deck by ID
final deckProvider = FutureProvider.family<model.Deck?, model.DeckId>((
  ref,
  deckId,
) async {
  final repository = ref.watch(cardsRepositoryProvider);
  return await repository.loadDeck(deckId);
});
