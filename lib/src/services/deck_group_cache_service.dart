import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:flutter_flashcards/src/model/deck_group.dart';

/// Service that caches DeckGroup objects in memory and keeps them in sync
/// with Firebase real-time changes. Provides fast synchronous access to deck groups.
class DeckGroupCacheService {
  final Logger _log = Logger();
  final FirebaseFirestore _firestore;
  final String _userId;

  // Internal cache: groupId -> DeckGroup
  final Map<String, DeckGroup> _groupsById = {};

  // Index: deckId -> Set<DeckGroup> (for finding which groups contain a deck)
  final Map<String, Set<DeckGroup>> _groupsByDeckId = {};

  StreamSubscription<QuerySnapshot<DeckGroup>>? _groupsSubscription;
  bool _isInitialized = false;

  DeckGroupCacheService(this._firestore, this._userId);

  /// Initializes the cache by loading all existing data and setting up
  /// real-time listeners for changes.
  Future<void> initialize() async {
    if (_isInitialized) {
      _log.w('DeckGroupCacheService already initialized');
      return;
    }

    _log.d('Initializing DeckGroupCacheService for user: $_userId');

    try {
      // Load all existing deck groups
      await _loadAllDeckGroups();

      // Set up real-time listener
      _setupDeckGroupsListener();

      _isInitialized = true;
      _log.d(
        'DeckGroupCacheService initialized successfully. Groups: ${_groupsById.length}',
      );
    } catch (error, stackTrace) {
      _log.e(
        'Failed to initialize DeckGroupCacheService',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Loads all existing deck groups into the cache
  Future<void> _loadAllDeckGroups() async {
    _log.d('Loading all deck groups for user: $_userId');

    final deckGroupsCollection = _firestore
        .collection('deckGroups')
        .doc(_userId)
        .collection('userDeckGroups')
        .withConverter<DeckGroup>(
          fromFirestore: (doc, _) => DeckGroup.fromJson(doc.id, doc.data()!),
          toFirestore: (group, _) => group.toJson(),
        );

    _log.d('Querying deck groups collection...');
    final snapshot = await deckGroupsCollection.get();
    _log.d('Got ${snapshot.docs.length} deck group documents from Firebase');

    for (final doc in snapshot.docs) {
      final group = doc.data();
      _log.d(
        'Processing deck group: ${group.name} (id: ${group.id}) with ${group.decks?.length ?? 0} decks',
      );
      _addGroupToCache(group);
    }

    _log.d('Loaded ${_groupsById.length} deck groups into cache');
  }

  /// Sets up real-time listener for deck group changes
  void _setupDeckGroupsListener() {
    final deckGroupsCollection = _firestore
        .collection('deckGroups')
        .doc(_userId)
        .collection('userDeckGroups')
        .withConverter<DeckGroup>(
          fromFirestore: (doc, _) => DeckGroup.fromJson(doc.id, doc.data()!),
          toFirestore: (group, _) => group.toJson(),
        );

    _groupsSubscription = deckGroupsCollection.snapshots().listen(
      (snapshot) {
        for (final change in snapshot.docChanges) {
          final group = change.doc.data();
          if (group == null) continue;

          switch (change.type) {
            case DocumentChangeType.added:
            case DocumentChangeType.modified:
              _addGroupToCache(group);
              _log.d('DeckGroup updated in cache: ${group.id}');
              break;
            case DocumentChangeType.removed:
              _removeGroupFromCache(group);
              _log.d('DeckGroup removed from cache: ${group.id}');
              break;
          }
        }
      },
      onError: (error) {
        _log.e('Error in deck groups listener', error: error);
      },
    );
  }

  /// Adds a DeckGroup object to the cache and updates all indexes
  void _addGroupToCache(DeckGroup group) {
    _log.d('Adding group to cache: ${group.name} (id: ${group.id})');
    _groupsById[group.id] = group;

    // Update deck-to-group mapping
    final decks = group.decks ?? {};
    for (final deckId in decks) {
      _groupsByDeckId.putIfAbsent(deckId, () => <DeckGroup>{}).add(group);
      _log.d('  - Added deck $deckId to group ${group.id}');
    }

    _log.d('Cache now contains ${_groupsById.length} groups');
  }

  /// Removes a DeckGroup object from the cache and updates all indexes
  void _removeGroupFromCache(DeckGroup group) {
    _groupsById.remove(group.id);

    // Remove from deck-to-group mapping
    final decks = group.decks ?? {};
    for (final deckId in decks) {
      _groupsByDeckId[deckId]?.remove(group);
      if (_groupsByDeckId[deckId]?.isEmpty == true) {
        _groupsByDeckId.remove(deckId);
      }
    }
  }

  /// Updates the cache when a deck is added to or removed from a group
  /// This method should be called externally when deck-group relationships change
  void updateDeckInGroup(String deckId, String groupId, bool isAdded) {
    final group = _groupsById[groupId];
    if (group == null) {
      _log.w('Cannot update deck in group: group $groupId not found in cache');
      return;
    }

    if (isAdded) {
      // Add deck to group
      final updatedDecks = <String>{...(group.decks ?? {}), deckId};
      final updatedGroup = group.copyWith(decks: updatedDecks);
      _addGroupToCache(updatedGroup);
      _log.d('Added deck $deckId to group $groupId in cache');
    } else {
      // Remove deck from group
      final updatedDecks = <String>{...(group.decks ?? {})}..remove(deckId);
      final updatedGroup = group.copyWith(decks: updatedDecks);
      _addGroupToCache(updatedGroup);
      _log.d('Removed deck $deckId from group $groupId in cache');
    }
  }

  /// Returns a specific DeckGroup by ID
  DeckGroup? getGroupById(String groupId) {
    if (!_isInitialized) {
      _log.w('DeckGroupCacheService not initialized. Returning null.');
      return null;
    }

    return _groupsById[groupId];
  }

  /// Returns all deck groups
  Iterable<DeckGroup> getAllGroups() {
    if (!_isInitialized) {
      _log.w('DeckGroupCacheService not initialized. Returning empty list.');
      return const <DeckGroup>[];
    }

    _log.d('getAllGroups called, returning ${_groupsById.length} groups');
    for (final group in _groupsById.values) {
      _log.d(
        '  - Group: ${group.name} (id: ${group.id}) with ${group.decks?.length ?? 0} decks',
      );
    }

    return _groupsById.values;
  }

  /// Returns all groups that contain a specific deck
  Iterable<DeckGroup> getGroupsByDeckId(String deckId) {
    if (!_isInitialized) {
      _log.w('DeckGroupCacheService not initialized. Returning empty list.');
      return const <DeckGroup>[];
    }

    return _groupsByDeckId[deckId] ?? const <DeckGroup>[];
  }

  /// Returns all groups that contain any of the specified decks
  Iterable<DeckGroup> getGroupsByDeckIds(Iterable<String> deckIds) {
    if (!_isInitialized) {
      _log.w('DeckGroupCacheService not initialized. Returning empty list.');
      return const <DeckGroup>[];
    }

    final Set<DeckGroup> groups = {};
    for (final deckId in deckIds) {
      final deckGroups = _groupsByDeckId[deckId];
      if (deckGroups != null) {
        groups.addAll(deckGroups);
      }
    }
    return groups;
  }

  /// Returns all groups that have no decks (empty groups)
  Iterable<DeckGroup> getEmptyGroups() {
    if (!_isInitialized) {
      _log.w('DeckGroupCacheService not initialized. Returning empty list.');
      return const <DeckGroup>[];
    }

    return _groupsById.values.where(
      (group) => group.decks == null || group.decks!.isEmpty,
    );
  }

  /// Returns the number of groups in the cache
  int get groupCount => _groupsById.length;

  /// Returns whether the service is initialized
  bool get isInitialized => _isInitialized;

  /// Cleans up orphaned deck references by removing deck IDs that no longer exist
  /// in the deck cache. This prevents displaying groups with dead references.
  /// Returns the list of groups that were updated during cleanup.
  List<DeckGroup> cleanupOrphanedDeckReferences(Iterable<String> validDeckIds) {
    if (!_isInitialized) {
      _log.w(
        'DeckGroupCacheService not initialized. Cannot cleanup orphaned references.',
      );
      return [];
    }

    _log.d(
      'Cleaning up orphaned deck references. Valid deck IDs: ${validDeckIds.length}',
    );

    final validDeckIdsSet = validDeckIds.toSet();
    final groupsToUpdate = <DeckGroup>[];

    for (final group in _groupsById.values) {
      final originalDeckCount = group.decks?.length ?? 0;
      final validDecks =
          group.decks
              ?.where((deckId) => validDeckIdsSet.contains(deckId))
              .toSet() ??
          {};
      final removedCount = originalDeckCount - validDecks.length;

      if (removedCount > 0) {
        _log.d(
          'Group "${group.name}" (${group.id}) has $removedCount orphaned deck references. '
          'Original: ${group.decks?.toList()}, Valid: ${validDecks.toList()}',
        );

        final updatedGroup = group.copyWith(decks: validDecks);
        groupsToUpdate.add(updatedGroup);
      }
    }

    // Update the cache with cleaned groups
    for (final updatedGroup in groupsToUpdate) {
      _addGroupToCache(updatedGroup);
      _log.d(
        'Updated group "${updatedGroup.name}" (${updatedGroup.id}) - removed orphaned references. '
        'Decks: ${updatedGroup.decks?.length ?? 0}',
      );
    }

    if (groupsToUpdate.isNotEmpty) {
      _log.d(
        'Cleaned up ${groupsToUpdate.length} groups with orphaned deck references',
      );
    } else {
      _log.d('No orphaned deck references found');
    }

    return groupsToUpdate;
  }

  /// Disposes the service and cancels all subscriptions
  void dispose() {
    _log.d('Disposing DeckGroupCacheService');
    _groupsSubscription?.cancel();
    _groupsById.clear();
    _groupsByDeckId.clear();
    _isInitialized = false;
  }
}
