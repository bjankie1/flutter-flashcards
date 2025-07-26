import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:flutter_flashcards/src/model/card_stats.dart';
import 'package:flutter_flashcards/src/model/card.dart';
import 'package:flutter_flashcards/src/model/enums.dart';

/// Service that caches CardStats objects in memory and keeps them in sync
/// with Firebase real-time changes. Provides fast synchronous access to
/// card stats grouped by deck ID.
class CardStatsCacheService {
  final Logger _log = Logger();
  final FirebaseFirestore _firestore;
  final String _userId;

  // Internal cache: cardId::variant -> CardStats
  final Map<String, CardStats> _statsById = {};

  // Index: deckId -> Set<CardStats>
  final Map<String, Set<CardStats>> _statsByDeckId = {};

  // Index: cardId -> deckId (for mapping cards to their decks)
  final Map<String, String> _cardToDeckMapping = {};

  StreamSubscription<QuerySnapshot<CardStats>>? _cardStatsSubscription;
  StreamSubscription<QuerySnapshot<Card>>? _cardsSubscription;
  bool _isInitialized = false;

  CardStatsCacheService(this._firestore, this._userId);

  /// Initializes the cache by loading all existing data and setting up
  /// real-time listeners for changes.
  Future<void> initialize() async {
    if (_isInitialized) {
      _log.w('CardStatsCacheService already initialized');
      return;
    }

    _log.d('Initializing CardStatsCacheService for user: $_userId');

    try {
      // First, load all cards to build the cardId -> deckId mapping
      await _loadCardsMapping();

      // Then load all card stats
      await _loadAllCardStats();

      // Set up real-time listeners
      _setupCardStatsListener();
      _setupCardsListener();

      _isInitialized = true;
      _log.d(
        'CardStatsCacheService initialized successfully. Stats: ${_statsById.length}, Decks: ${_statsByDeckId.length}',
      );
    } catch (error, stackTrace) {
      _log.e(
        'Failed to initialize CardStatsCacheService',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Loads all cards to build the cardId -> deckId mapping
  Future<void> _loadCardsMapping() async {
    _log.d('Loading cards mapping...');

    final cardsCollection = _firestore
        .collection('cards')
        .doc(_userId)
        .collection('userCards')
        .withConverter<Card>(
          fromFirestore: (doc, _) => Card.fromJson(doc.id, doc.data()!),
          toFirestore: (card, _) => card.toJson(),
        );

    final snapshot = await cardsCollection.get();

    for (final doc in snapshot.docs) {
      final card = doc.data();
      _cardToDeckMapping[card.id] = card.deckId;
    }

    _log.d('Loaded ${_cardToDeckMapping.length} cards mapping');
  }

  /// Loads all existing card stats into the cache
  Future<void> _loadAllCardStats() async {
    _log.d('Loading all card stats...');

    final cardStatsCollection = _firestore
        .collection('cardStats')
        .doc(_userId)
        .collection('userCardStats')
        .withConverter<CardStats>(
          fromFirestore: (doc, _) => CardStats.fromJson(doc.id, doc.data()!),
          toFirestore: (stats, _) => stats.toJson(),
        );

    final snapshot = await cardStatsCollection.get();

    for (final doc in snapshot.docs) {
      final stats = doc.data();
      _addStatsToCache(stats);
    }

    _log.d('Loaded ${_statsById.length} card stats into cache');
  }

  /// Sets up real-time listener for card stats changes
  void _setupCardStatsListener() {
    final cardStatsCollection = _firestore
        .collection('cardStats')
        .doc(_userId)
        .collection('userCardStats')
        .withConverter<CardStats>(
          fromFirestore: (doc, _) => CardStats.fromJson(doc.id, doc.data()!),
          toFirestore: (stats, _) => stats.toJson(),
        );

    _cardStatsSubscription = cardStatsCollection.snapshots().listen(
      (snapshot) {
        for (final change in snapshot.docChanges) {
          final stats = change.doc.data();
          if (stats == null) continue;

          switch (change.type) {
            case DocumentChangeType.added:
            case DocumentChangeType.modified:
              _addStatsToCache(stats);
              _log.d('CardStats updated in cache: ${stats.idValue}');
              break;
            case DocumentChangeType.removed:
              _removeStatsFromCache(stats);
              _log.d('CardStats removed from cache: ${stats.idValue}');
              break;
          }
        }
      },
      onError: (error) {
        _log.e('Error in card stats listener', error: error);
      },
    );
  }

  /// Sets up real-time listener for cards changes (to update cardId -> deckId mapping)
  void _setupCardsListener() {
    final cardsCollection = _firestore
        .collection('cards')
        .doc(_userId)
        .collection('userCards')
        .withConverter<Card>(
          fromFirestore: (doc, _) => Card.fromJson(doc.id, doc.data()!),
          toFirestore: (card, _) => card.toJson(),
        );

    _cardsSubscription = cardsCollection.snapshots().listen(
      (snapshot) {
        for (final change in snapshot.docChanges) {
          final card = change.doc.data();
          if (card == null) continue;

          switch (change.type) {
            case DocumentChangeType.added:
            case DocumentChangeType.modified:
              _cardToDeckMapping[card.id] = card.deckId;
              _updateStatsForCard(card.id, card.deckId);
              _log.d('Card mapping updated: ${card.id} -> ${card.deckId}');
              break;
            case DocumentChangeType.removed:
              _cardToDeckMapping.remove(card.id);
              _removeStatsForCard(card.id);
              _log.d('Card mapping removed: ${card.id}');
              break;
          }
        }
      },
      onError: (error) {
        _log.e('Error in cards listener', error: error);
      },
    );
  }

  /// Adds a CardStats object to the cache and updates all indexes
  void _addStatsToCache(CardStats stats) {
    _statsById[stats.idValue] = stats;

    final deckId = _cardToDeckMapping[stats.cardId];
    if (deckId != null) {
      _statsByDeckId.putIfAbsent(deckId, () => <CardStats>{}).add(stats);
    }
  }

  /// Removes a CardStats object from the cache and updates all indexes
  void _removeStatsFromCache(CardStats stats) {
    _statsById.remove(stats.idValue);

    final deckId = _cardToDeckMapping[stats.cardId];
    if (deckId != null) {
      _statsByDeckId[deckId]?.remove(stats);
      if (_statsByDeckId[deckId]?.isEmpty == true) {
        _statsByDeckId.remove(deckId);
      }
    }
  }

  /// Updates stats for a card when its deck assignment changes
  void _updateStatsForCard(String cardId, String newDeckId) {
    // Find all stats for this card
    final statsToUpdate = _statsById.values
        .where((stats) => stats.cardId == cardId)
        .toList();

    for (final stats in statsToUpdate) {
      // Remove from old deck
      for (final deckStats in _statsByDeckId.values) {
        deckStats.remove(stats);
      }

      // Add to new deck
      _statsByDeckId.putIfAbsent(newDeckId, () => <CardStats>{}).add(stats);
    }
  }

  /// Removes all stats for a card when the card is deleted
  void _removeStatsForCard(String cardId) {
    final statsToRemove = _statsById.values
        .where((stats) => stats.cardId == cardId)
        .toList();

    for (final stats in statsToRemove) {
      _removeStatsFromCache(stats);
    }
  }

  /// Returns all CardStats for a given deckId
  Iterable<CardStats> getCardStatsByDeckId(String deckId) {
    if (!_isInitialized) {
      _log.w('CardStatsCacheService not initialized. Returning empty list.');
      return const <CardStats>[];
    }

    return _statsByDeckId[deckId] ?? const <CardStats>[];
  }

  /// Returns a specific CardStats by cardId and variant
  CardStats? getCardStats(String cardId, CardReviewVariant variant) {
    if (!_isInitialized) {
      _log.w('CardStatsCacheService not initialized. Returning null.');
      return null;
    }

    final idValue = '$cardId::${variant.name}';
    return _statsById[idValue];
  }

  /// Returns all CardStats for a given cardId
  Iterable<CardStats> getCardStatsByCardId(String cardId) {
    if (!_isInitialized) {
      _log.w('CardStatsCacheService not initialized. Returning empty list.');
      return const <CardStats>[];
    }

    return _statsById.values.where((stats) => stats.cardId == cardId);
  }

  /// Returns all CardStats in the cache
  Iterable<CardStats> getAllCardStats() {
    if (!_isInitialized) {
      _log.w('CardStatsCacheService not initialized. Returning empty list.');
      return const <CardStats>[];
    }

    return _statsById.values;
  }

  /// Returns the number of CardStats in the cache
  int get statsCount => _statsById.length;

  /// Returns the number of decks with stats
  int get deckCount => _statsByDeckId.length;

  /// Returns whether the service is initialized
  bool get isInitialized => _isInitialized;

  /// Disposes the service and cancels all subscriptions
  void dispose() {
    _log.d('Disposing CardStatsCacheService');
    _cardStatsSubscription?.cancel();
    _cardsSubscription?.cancel();
    _statsById.clear();
    _statsByDeckId.clear();
    _cardToDeckMapping.clear();
    _isInitialized = false;
  }
}
