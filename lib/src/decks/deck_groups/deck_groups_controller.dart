import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';

import '../../model/cards.dart' as model;
import '../deck_list/decks_controller.dart';
import '../../services/cache_providers.dart';

part 'deck_groups_controller.g.dart';

/// Controller for managing deck groups
@riverpod
class DeckGroupsController extends _$DeckGroupsController {
  final Logger _log = Logger();

  @override
  Future<List<model.DeckGroup>> build() async {
    _log.d('DeckGroupsController build() called');

    // Wait for cache services to be ready
    final cacheReady = ref.watch(cacheServicesReadyProvider);
    _log.d('Cache services ready: $cacheReady');

    if (!cacheReady) {
      _log.d('Cache services not ready yet, returning empty list');
      return [];
    }

    final deckGroupCacheAsync = ref.watch(deckGroupCacheServiceProvider);
    if (!deckGroupCacheAsync.hasValue) {
      _log.d('DeckGroupCacheService not ready yet');
      return [];
    }

    final deckGroupCache = deckGroupCacheAsync.value;
    if (deckGroupCache == null) {
      _log.w('DeckGroupCacheService not available');
      return [];
    }

    // Get all groups from cache
    final allGroups = deckGroupCache.getAllGroups().toList();
    _log.d('Total groups in cache: ${allGroups.length}');

    for (final group in allGroups) {
      _log.d(
        'Group: ${group.name} (id: ${group.id}), decks: ${group.decks?.length ?? 0}',
      );
    }

    // Get deck cache to cross-reference deck IDs
    final deckCacheAsync = ref.watch(deckCacheServiceProvider);
    List<model.DeckGroup> nonEmptyGroups;

    if (deckCacheAsync.hasValue && deckCacheAsync.value != null) {
      final deckCache = deckCacheAsync.value!;
      final validDeckIds = deckCache
          .getAllDecks()
          .map((deck) => deck.id!)
          .toList();
      _log.d('Valid deck IDs from cache: ${validDeckIds.length}');

      // Clean up orphaned deck references
      final cleanedGroups = deckGroupCache.cleanupOrphanedDeckReferences(
        validDeckIds,
      );

      // Persist cleaned groups to Firebase if any were updated
      if (cleanedGroups.isNotEmpty) {
        _log.d('Persisting ${cleanedGroups.length} cleaned groups to Firebase');
        try {
          final repository = ref.read(cardsRepositoryProvider);
          for (final group in cleanedGroups) {
            await repository.updateDeckGroup(group);
            _log.d('Persisted cleaned group: ${group.name} (${group.id})');
          }
        } catch (error, stackTrace) {
          _log.e(
            'Error persisting cleaned groups',
            error: error,
            stackTrace: stackTrace,
          );
          // Continue with the operation even if persistence fails
        }
      }

      // Get updated groups after cleanup
      final updatedGroups = deckGroupCache.getAllGroups().toList();
      _log.d('Groups after cleanup: ${updatedGroups.length}');

      // Filter out groups that have no decks using the decks property
      nonEmptyGroups = updatedGroups
          .where((group) => group.decks?.isNotEmpty ?? false)
          .toList();
    } else {
      _log.w(
        'DeckCacheService not available, skipping orphaned reference cleanup',
      );

      // Filter out groups that have no decks using the decks property
      nonEmptyGroups = allGroups
          .where((group) => group.decks?.isNotEmpty ?? false)
          .toList();
    }

    _log.d(
      'Successfully loaded ${nonEmptyGroups.length} non-empty deck groups out of ${allGroups.length} total from cache',
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

      // Cache will be updated automatically via real-time listener
      ref.invalidateSelf();
      _log.d('Successfully updated deck group: ${group.name}');
    } catch (error, stackTrace) {
      _log.e('Error updating deck group', error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<model.DeckGroup> createDeckGroup(String name, String? description) async {
    try {
      _log.d('Creating deck group: $name');
      final repository = ref.read(cardsRepositoryProvider);
      final group = await repository.createDeckGroup(name, description);
      ref.invalidateSelf();
      _log.d('Successfully created deck group: $name');
      return group;
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

      // Update cache immediately for faster UI updates
      final deckGroupCacheAsync = ref.read(deckGroupCacheServiceProvider);
      if (deckGroupCacheAsync.hasValue && deckGroupCacheAsync.value != null) {
        deckGroupCacheAsync.value!.updateDeckInGroup(deckId, groupId, true);
        _log.d('Updated cache: added deck $deckId to group $groupId');
      }

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

      // Update cache immediately for faster UI updates
      final deckGroupCacheAsync = ref.read(deckGroupCacheServiceProvider);
      if (deckGroupCacheAsync.hasValue && deckGroupCacheAsync.value != null) {
        deckGroupCacheAsync.value!.updateDeckInGroup(deckId, groupId, false);
        _log.d('Updated cache: removed deck $deckId from group $groupId');
      }

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

  /// Manually trigger cleanup of orphaned deck references
  Future<void> cleanupOrphanedReferences() async {
    try {
      _log.d('Manually triggering orphaned reference cleanup');

      final deckGroupCacheAsync = ref.read(deckGroupCacheServiceProvider);
      final deckCacheAsync = ref.read(deckCacheServiceProvider);

      if (!deckGroupCacheAsync.hasValue ||
          !deckCacheAsync.hasValue ||
          deckGroupCacheAsync.value == null ||
          deckCacheAsync.value == null) {
        _log.w('Cache services not available for cleanup');
        return;
      }

      final deckGroupCache = deckGroupCacheAsync.value!;
      final deckCache = deckCacheAsync.value!;

      final validDeckIds = deckCache
          .getAllDecks()
          .map((deck) => deck.id!)
          .toList();
      final cleanedGroups = deckGroupCache.cleanupOrphanedDeckReferences(
        validDeckIds,
      );

      if (cleanedGroups.isNotEmpty) {
        _log.d('Persisting ${cleanedGroups.length} cleaned groups to Firebase');
        final repository = ref.read(cardsRepositoryProvider);
        for (final group in cleanedGroups) {
          await repository.updateDeckGroup(group);
          _log.d('Persisted cleaned group: ${group.name} (${group.id})');
        }
      }

      ref.invalidateSelf();
      _log.d('Successfully completed orphaned reference cleanup');
    } catch (error, stackTrace) {
      _log.e(
        'Error during orphaned reference cleanup',
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
      // Wait for cache services to be ready
      final cacheReady = ref.watch(cacheServicesReadyProvider);
      if (!cacheReady) {
        return {};
      }

      final decksServiceAsync = ref.watch(decksServiceProvider);
      if (!decksServiceAsync.hasValue || decksServiceAsync.value == null) {
        return {};
      }

      final decksService = decksServiceAsync.value!;

      final count = decksService.getCardsToReviewCountForDeckGroup(
        deckGroupId ?? '',
      );

      // Return in the same format as the repository method
      return {'total': count};
    });

/// Provider for unassigned decks that depends on the main controller
final unassignedDecksProvider = FutureProvider.autoDispose<List<model.DeckId>>((
  ref,
) async {
  // Watch the main controller to ensure this refreshes when it does
  await ref.watch(deckGroupsControllerProvider.future);

  // Wait for cache services to be ready
  final cacheReady = ref.watch(cacheServicesReadyProvider);
  if (!cacheReady) {
    return [];
  }

  final deckCacheAsync = ref.watch(deckCacheServiceProvider);
  final deckGroupCacheAsync = ref.watch(deckGroupCacheServiceProvider);

  if (!deckCacheAsync.hasValue ||
      !deckGroupCacheAsync.hasValue ||
      deckCacheAsync.value == null ||
      deckGroupCacheAsync.value == null) {
    return [];
  }

  final deckCache = deckCacheAsync.value!;
  final deckGroupCache = deckGroupCacheAsync.value!;

  final allDecks = deckCache.getAllDecks();
  final groups = deckGroupCache.getAllGroups();

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
