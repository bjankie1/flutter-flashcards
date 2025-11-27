import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:flutter_flashcards/src/model/deck.dart';

/// Service that caches Deck objects in memory and keeps them in sync
/// with Firebase real-time changes. Provides fast synchronous access to decks.
class DeckCacheService {
  final Logger _log = Logger();
  final FirebaseFirestore _firestore;
  final String _userId;

  // Internal cache: deckId -> Deck
  final Map<String, Deck> _decksById = {};

  // Index: deckId -> Set<Deck> (for parent-child relationships)
  final Map<String, Set<Deck>> _decksByParentId = {};

  StreamSubscription<QuerySnapshot<Deck>>? _decksSubscription;
  bool _isInitialized = false;

  DeckCacheService(this._firestore, this._userId);

  /// Initializes the cache by loading all existing data and setting up
  /// real-time listeners for changes.
  Future<void> initialize() async {
    if (_isInitialized) {
      _log.w('DeckCacheService already initialized');
      return;
    }

    _log.d('Initializing DeckCacheService for user: $_userId');

    try {
      // Load all existing decks
      await _loadAllDecks();

      // Set up real-time listener
      _setupDecksListener();

      _isInitialized = true;
      _log.d(
        'DeckCacheService initialized successfully. Decks: ${_decksById.length}',
      );
    } catch (error, stackTrace) {
      _log.e(
        'Failed to initialize DeckCacheService',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Loads all existing decks into the cache
  Future<void> _loadAllDecks() async {
    _log.d('Loading all decks...');

    final decksCollection = _firestore
        .collection('decks')
        .doc(_userId)
        .collection('userDecks')
        .withConverter<Deck>(
          fromFirestore: (doc, _) => Deck.fromJson(doc.id, doc.data()!),
          toFirestore: (deck, _) => deck.toJson(),
        );

    final snapshot = await decksCollection.get();

    for (final doc in snapshot.docs) {
      final deck = doc.data();
      _addDeckToCache(deck);
    }

    _log.d('Loaded ${_decksById.length} decks into cache');
  }

  /// Sets up real-time listener for deck changes
  void _setupDecksListener() {
    final decksCollection = _firestore
        .collection('decks')
        .doc(_userId)
        .collection('userDecks')
        .withConverter<Deck>(
          fromFirestore: (doc, _) => Deck.fromJson(doc.id, doc.data()!),
          toFirestore: (deck, _) => deck.toJson(),
        );

    _decksSubscription = decksCollection.snapshots().listen(
      (snapshot) {
        for (final change in snapshot.docChanges) {
          final deck = change.doc.data();
          if (deck == null) continue;

          switch (change.type) {
            case DocumentChangeType.added:
            case DocumentChangeType.modified:
              _addDeckToCache(deck);
              _log.d('Deck updated in cache: ${deck.id}');
              break;
            case DocumentChangeType.removed:
              _removeDeckFromCache(deck);
              _log.d('Deck removed from cache: ${deck.id}');
              break;
          }
        }
      },
      onError: (error) {
        _log.e('Error in decks listener', error: error);
      },
    );
  }

  /// Adds a Deck object to the cache and updates all indexes
  void _addDeckToCache(Deck deck) {
    if (deck.id == null) {
      _log.w('Cannot add deck to cache: deck has no ID');
      return;
    }

    _decksById[deck.id!] = deck;

    // Update parent-child relationships
    if (deck.parentDeckId != null) {
      _decksByParentId
          .putIfAbsent(deck.parentDeckId!, () => <Deck>{})
          .add(deck);
    }
  }

  /// Removes a Deck object from the cache and updates all indexes
  void _removeDeckFromCache(Deck deck) {
    if (deck.id == null) return;

    _decksById.remove(deck.id!);

    // Remove from parent-child relationships
    if (deck.parentDeckId != null) {
      _decksByParentId[deck.parentDeckId!]?.remove(deck);
      if (_decksByParentId[deck.parentDeckId!]?.isEmpty == true) {
        _decksByParentId.remove(deck.parentDeckId!);
      }
    }
  }

  /// Returns a specific Deck by ID
  Deck? getDeckById(String deckId) {
    if (!_isInitialized) {
      _log.w('DeckCacheService not initialized. Returning null.');
      return null;
    }

    return _decksById[deckId];
  }

  /// Returns all decks
  Iterable<Deck> getAllDecks() {
    if (!_isInitialized) {
      _log.w('DeckCacheService not initialized. Returning empty list.');
      return const <Deck>[];
    }

    return _decksById.values;
  }

  /// Returns all child decks for a given parent deck ID
  Iterable<Deck> getChildDecks(String parentDeckId) {
    if (!_isInitialized) {
      _log.w('DeckCacheService not initialized. Returning empty list.');
      return const <Deck>[];
    }

    return _decksByParentId[parentDeckId] ?? const <Deck>[];
  }

  /// Returns all root decks (decks without parent)
  Iterable<Deck> getRootDecks() {
    if (!_isInitialized) {
      _log.w('DeckCacheService not initialized. Returning empty list.');
      return const <Deck>[];
    }

    return _decksById.values.where((deck) => deck.parentDeckId == null);
  }

  /// Returns the number of decks in the cache
  int get deckCount => _decksById.length;

  /// Returns whether the service is initialized
  bool get isInitialized => _isInitialized;

  /// Disposes the service and cancels all subscriptions
  void dispose() {
    _log.d('Disposing DeckCacheService');
    _decksSubscription?.cancel();
    _decksById.clear();
    _decksByParentId.clear();
    _isInitialized = false;
  }
}
