import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../model/cards.dart' as model;
import '../deck_list/decks_controller.dart';

// Notifier that watches the repository's decksUpdated and decksGroupUpdated values
class DecksUpdatedNotifier extends Notifier<bool> {
  final Logger _log = Logger();

  @override
  bool build() {
    final repository = ref.watch(cardsRepositoryProvider);
    // Listen to both deck changes and deck group changes
    repository.decksUpdated.addListener(_onChange);
    repository.decksGroupUpdated.addListener(_onChange);
    final initialValue =
        repository.decksUpdated.value || repository.decksGroupUpdated.value;
    _log.d('DecksUpdatedNotifier initialized with value: $initialValue');
    return initialValue;
  }

  void _onChange() {
    final repository = ref.read(cardsRepositoryProvider);
    final newValue =
        repository.decksUpdated.value || repository.decksGroupUpdated.value;
    _log.d(
      'DecksUpdatedNotifier detected change, updating state to: $newValue',
    );
    state = newValue;
  }
}

final decksUpdatedProvider = NotifierProvider<DecksUpdatedNotifier, bool>(
  DecksUpdatedNotifier.new,
);

final deckGroupsControllerProvider =
    AutoDisposeNotifierProvider<
      DeckGroupsController,
      AsyncValue<List<(model.DeckGroup?, List<model.Deck>)>>
    >(DeckGroupsController.new);

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

class DeckGroupsController
    extends
        AutoDisposeNotifier<
          AsyncValue<List<(model.DeckGroup?, List<model.Deck>)>>
        > {
  final Logger _log = Logger();

  @override
  AsyncValue<List<(model.DeckGroup?, List<model.Deck>)>> build() {
    // Watch the decks updated state to trigger rebuilds when decks change
    ref.watch(decksUpdatedProvider);
    _loadDecksInGroups();
    return const AsyncValue.loading();
  }

  Future<void> _loadDecksInGroups() async {
    try {
      _log.d('Loading decks in groups');
      state = const AsyncValue.loading();
      final repository = ref.read(cardsRepositoryProvider);
      final groups = await repository.loadDecksInGroups();
      _log.d('Repository returned ${groups.length} groups');
      _log.d(
        'Groups data: ${groups.map((g) => '${g.$1?.name ?? 'null'}: ${g.$2.length} decks').join(', ')}',
      );

      final oldState = state;
      state = AsyncValue.data(groups);
      _log.d('State updated. Old state: $oldState, New state: $state');
      _log.d('Successfully loaded  [32m${groups.length} [0m deck groups');
    } catch (error, stackTrace) {
      _log.e(
        'Error loading decks in groups',
        error: error,
        stackTrace: stackTrace,
      );
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _loadDecksInGroups();
  }

  Future<void> updateDeckGroup(model.DeckGroup group) async {
    try {
      _log.d('Updating deck group: ${group.name}');
      final repository = ref.read(cardsRepositoryProvider);
      await repository.updateDeckGroup(group);
      await _loadDecksInGroups();
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
      await _loadDecksInGroups();
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
      await _loadDecksInGroups();
      _log.d('Successfully deleted deck group: $groupId');
    } catch (error, stackTrace) {
      _log.e('Error deleting deck group', error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> addDeckToGroup(String deckId, model.DeckGroupId groupId) async {
    try {
      _log.d('Adding deck $deckId to group $groupId');
      final repository = ref.read(cardsRepositoryProvider);
      await repository.addDeckToGroup(deckId, groupId);
      await _loadDecksInGroups();
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

  Future<void> removeDeckFromGroup(
    String deckId,
    model.DeckGroupId groupId,
  ) async {
    try {
      _log.d('Removing deck $deckId from group $groupId');
      final repository = ref.read(cardsRepositoryProvider);
      await repository.removeDeckFromGroup(deckId, groupId);
      await _loadDecksInGroups();
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
