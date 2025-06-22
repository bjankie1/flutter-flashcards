import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';

import '../../model/cards.dart' as model;
import '../../model/users_collaboration.dart';
import '../deck_list/decks_controller.dart';

part 'deck_groups_controller.g.dart';

/// Controller for managing deck groups and their operations
@riverpod
class DeckGroupsController extends _$DeckGroupsController {
  final Logger _log = Logger();

  @override
  AsyncValue<List<(model.DeckGroup?, List<model.Deck>)>> build() {
    _loadDecksInGroups();
    return const AsyncValue.loading();
  }

  /// Loads all decks organized by groups from the repository
  Future<void> _loadDecksInGroups() async {
    try {
      _log.d('Loading decks in groups');
      state = const AsyncValue.loading();
      final repository = ref.read(cardsRepositoryProvider);
      final groups = await repository.loadDecksInGroups();
      state = AsyncValue.data(groups);
      _log.d('Successfully loaded ${groups.length} deck groups');
    } catch (error, stackTrace) {
      _log.e(
        'Error loading decks in groups',
        error: error,
        stackTrace: stackTrace,
      );
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Refreshes the deck groups data
  Future<void> refresh() async {
    await _loadDecksInGroups();
  }

  /// Updates a deck group
  Future<void> updateDeckGroup(model.DeckGroup group) async {
    try {
      _log.d('Updating deck group: ${group.name}');
      final repository = ref.read(cardsRepositoryProvider);
      await repository.updateDeckGroup(group);
      await _loadDecksInGroups(); // Refresh the list
      _log.d('Successfully updated deck group: ${group.name}');
    } catch (error, stackTrace) {
      _log.e('Error updating deck group', error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Creates a new deck group
  Future<void> createDeckGroup(String name, String? description) async {
    try {
      _log.d('Creating deck group: $name');
      final repository = ref.read(cardsRepositoryProvider);
      await repository.createDeckGroup(name, description);
      await _loadDecksInGroups(); // Refresh the list
      _log.d('Successfully created deck group: $name');
    } catch (error, stackTrace) {
      _log.e('Error creating deck group', error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Deletes a deck group
  Future<void> deleteDeckGroup(model.DeckGroupId groupId) async {
    try {
      _log.d('Deleting deck group: $groupId');
      final repository = ref.read(cardsRepositoryProvider);
      await repository.deleteDeckGroup(groupId);
      await _loadDecksInGroups(); // Refresh the list
      _log.d('Successfully deleted deck group: $groupId');
    } catch (error, stackTrace) {
      _log.e('Error deleting deck group', error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Adds a deck to a group
  Future<void> addDeckToGroup(String deckId, model.DeckGroupId groupId) async {
    try {
      _log.d('Adding deck $deckId to group $groupId');
      final repository = ref.read(cardsRepositoryProvider);
      await repository.addDeckToGroup(deckId, groupId);
      await _loadDecksInGroups(); // Refresh the list
      _log.d('Successfully added deck $deckId to group $groupId');
    } catch (error, stackTrace) {
      _log.e(
        'Error adding deck to group',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Removes a deck from a group
  Future<void> removeDeckFromGroup(
    String deckId,
    model.DeckGroupId groupId,
  ) async {
    try {
      _log.d('Removing deck $deckId from group $groupId');
      final repository = ref.read(cardsRepositoryProvider);
      await repository.removeDeckFromGroup(deckId, groupId);
      await _loadDecksInGroups(); // Refresh the list
      _log.d('Successfully removed deck $deckId from group $groupId');
    } catch (error, stackTrace) {
      _log.e(
        'Error removing deck from group',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}

/// Provider for shared decks
@riverpod
Future<Map<UserId, Iterable<model.Deck>>> sharedDecks(Ref ref) async {
  final repository = ref.read(cardsRepositoryProvider);
  return await repository.listSharedDecks();
}

/// Provider for cards to review count by deck group
@riverpod
Future<Map<model.State, int>> cardsToReviewCountByGroup(
  Ref ref,
  model.DeckGroupId? deckGroupId,
) async {
  final repository = ref.read(cardsRepositoryProvider);
  return await repository.cardsToReviewCount(deckGroupId: deckGroupId);
}
