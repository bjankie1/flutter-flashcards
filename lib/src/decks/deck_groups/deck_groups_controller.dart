import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';

import '../../model/cards.dart' as model;
import '../deck_list/decks_controller.dart';

part 'deck_groups_controller.g.dart';

/// Controller for managing deck groups
@riverpod
class DeckGroupsController extends _$DeckGroupsController {
  final Logger _log = Logger();

  @override
  Future<List<model.DeckGroup>> build() async {
    _log.d('DeckGroupsController build() called');
    final repository = ref.watch(cardsRepositoryProvider);
    final groups = await repository.loadDeckGroups();

    // Filter out groups that have no decks using the decks property
    final nonEmptyGroups = groups
        .where((group) => group.decks?.isNotEmpty ?? false)
        .toList();

    _log.d(
      'Successfully loaded ${nonEmptyGroups.length} non-empty deck groups out of ${groups.length} total',
    );
    return nonEmptyGroups;
  }

  Future<void> refresh() async {
    _log.d('Refreshing deck groups');
    ref.invalidateSelf();
  }

  Future<void> updateDeckGroup(model.DeckGroup group) async {
    try {
      _log.d('Updating deck group: ${group.name}');
      final repository = ref.read(cardsRepositoryProvider);
      await repository.updateDeckGroup(group);
      ref.invalidateSelf();
      _log.d('Successfully updated deck group: ${group.name}');
    } catch (error, stackTrace) {
      _log.e('Error updating deck group', error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> createDeckGroup(String name, String? description) async {
    try {
      _log.d('Creating deck group: $name');
      final repository = ref.read(cardsRepositoryProvider);
      await repository.createDeckGroup(name, description);
      ref.invalidateSelf();
      _log.d('Successfully created deck group: $name');
    } catch (error, stackTrace) {
      _log.e('Error creating deck group', error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> deleteDeckGroup(model.DeckGroupId groupId) async {
    try {
      _log.d('Deleting deck group: $groupId');
      final repository = ref.read(cardsRepositoryProvider);
      await repository.deleteDeckGroup(groupId);
      ref.invalidateSelf();
      _log.d('Successfully deleted deck group: $groupId');
    } catch (error, stackTrace) {
      _log.e('Error deleting deck group', error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> addDeckToGroup({
    required model.DeckId deckId,
    required model.DeckGroupId groupId,
  }) async {
    try {
      _log.d('Adding deck $deckId to group $groupId');
      final repository = ref.read(cardsRepositoryProvider);
      await repository.addDeckToGroup(deckId, groupId);
      ref.invalidateSelf();
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

  Future<void> removeDeckFromGroup({
    required model.DeckId deckId,
    required model.DeckGroupId groupId,
  }) async {
    try {
      _log.d('Removing deck $deckId from group $groupId');
      final repository = ref.read(cardsRepositoryProvider);
      await repository.removeDeckFromGroup(deckId, groupId);
      ref.invalidateSelf();
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

  /// Refresh the controller when decks are created or deleted
  Future<void> onDeckChanged() async {
    try {
      _log.d('Refreshing controller due to deck changes');
      ref.invalidateSelf();
      _log.d('Successfully refreshed controller');
    } catch (error, stackTrace) {
      _log.e(
        'Error refreshing controller',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}

// Legacy providers for backward compatibility
final sharedDecksProvider =
    FutureProvider.autoDispose<Map<String, Iterable<model.Deck>>>((ref) async {
      final repository = ref.watch(cardsRepositoryProvider);
      return await repository.listSharedDecks();
    });

final cardsToReviewCountByGroupProvider = FutureProvider.autoDispose
    .family<Map<dynamic, int>, String?>((ref, deckGroupId) async {
      final repository = ref.watch(cardsRepositoryProvider);
      return await repository.cardsToReviewCount(deckGroupId: deckGroupId);
    });

/// Provider for unassigned decks that depends on the main controller
final unassignedDecksProvider = FutureProvider.autoDispose<List<model.DeckId>>((
  ref,
) async {
  // Watch the main controller to ensure this refreshes when it does
  await ref.watch(deckGroupsControllerProvider.future);

  final repository = ref.watch(cardsRepositoryProvider);
  final allDecks = await repository.loadDecks();
  final groups = await repository.loadDeckGroups();

  // Get all deck IDs that are assigned to groups
  final assignedDeckIds = groups
      .expand((group) => group.decks ?? <model.DeckId>{})
      .toSet();

  // Return deck IDs that are not assigned to any group
  return allDecks
      .map((deck) => deck.id!)
      .where((deckId) => !assignedDeckIds.contains(deckId))
      .toList();
});
