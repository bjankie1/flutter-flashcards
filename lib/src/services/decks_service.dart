import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:flutter_flashcards/src/model/card_stats.dart';
import 'package:flutter_flashcards/src/model/card.dart';
import 'package:flutter_flashcards/src/model/deck.dart';
import 'package:flutter_flashcards/src/model/deck_group.dart';
import 'package:flutter_flashcards/src/model/enums.dart';
import 'package:flutter_flashcards/src/services/card_stats_cache_service.dart';
import 'package:flutter_flashcards/src/services/deck_cache_service.dart';
import 'package:flutter_flashcards/src/services/deck_group_cache_service.dart';

/// Service that provides fast access to deck data using cache services.
/// Implements business logic for loading cards with stats to review using
/// cached data instead of direct Firebase queries.
class DecksService {
  final Logger _log = Logger();
  final FirebaseFirestore _firestore;
  final String _userId;
  final CardStatsCacheService _cardStatsCache;
  final DeckCacheService _deckCache;
  final DeckGroupCacheService _deckGroupCache;

  DecksService(
    this._firestore,
    this._userId,
    this._cardStatsCache,
    this._deckCache,
    this._deckGroupCache,
  );

  /// Loads cards with stats that are ready for review, using cached data.
  /// Returns CardStats objects - the Card can be retrieved by ID from Firebase
  /// which will use its own caching algorithm.
  ///
  /// [deckId] - Optional deck ID to filter cards from a specific deck
  /// [deckGroupId] - Optional deck group ID to filter cards from decks in the group
  Future<Iterable<CardStats>> loadCardsWithStatsToReview({
    String? deckId,
    String? deckGroupId,
  }) async {
    _log.d(
      'Loading cards with stats to review for deck: $deckId deckGroup: $deckGroupId',
    );

    // Get all card stats that are ready for review
    final allCardStats = _cardStatsCache.getAllCardStats();
    final cardStatsToReview = allCardStats.where((stats) {
      // Check if card is ready for review (same logic as Firebase repository)
      return stats.nextReviewDate == null ||
          stats.nextReviewDate!.isBefore(DateTime.now());
    }).toList();

    _log.d('Found ${cardStatsToReview.length} cards ready for review');

    if (cardStatsToReview.isEmpty) {
      return <CardStats>[];
    }

    // Apply deck filtering if specified
    if (deckId != null) {
      return _filterCardStatsByDeck(cardStatsToReview, deckId);
    }

    if (deckGroupId != null) {
      return _filterCardStatsByDeckGroup(cardStatsToReview, deckGroupId);
    }

    // No filtering - return all cards ready for review
    return cardStatsToReview;
  }

  /// Filters card stats to only include those from a specific deck
  Iterable<CardStats> _filterCardStatsByDeck(
    List<CardStats> cardStats,
    String deckId,
  ) {
    final deckStats = _cardStatsCache.getCardStatsByDeckId(deckId);
    final deckStatsSet = deckStats.toSet();

    final filteredStats = cardStats
        .where((stats) => deckStatsSet.contains(stats))
        .toList();

    _log.d('Filtered to ${filteredStats.length} cards from deck $deckId');
    return filteredStats;
  }

  /// Filters card stats to only include those from decks in a specific group
  Iterable<CardStats> _filterCardStatsByDeckGroup(
    List<CardStats> cardStats,
    String deckGroupId,
  ) {
    // Get the deck group
    final group = _deckGroupCache.getGroupById(deckGroupId);
    if (group == null) {
      _log.w('Deck group $deckGroupId not found in cache');
      return <CardStats>[];
    }

    // Get all deck IDs in the group
    final deckIds = group.decks ?? {};
    if (deckIds.isEmpty) {
      _log.d('Deck group $deckGroupId has no decks');
      return <CardStats>[];
    }

    // Get all card stats for all decks in the group
    final Set<CardStats> groupStats = {};
    for (final deckId in deckIds) {
      final deckStats = _cardStatsCache.getCardStatsByDeckId(deckId);
      groupStats.addAll(deckStats);
    }

    // Filter card stats to only include those from the group
    final filteredStats = cardStats
        .where((stats) => groupStats.contains(stats))
        .toList();

    _log.d(
      'Filtered to ${filteredStats.length} cards from deck group $deckGroupId (${deckIds.length} decks)',
    );
    return filteredStats;
  }

  /// Loads a specific card by ID from Firebase (uses Firebase's caching)
  Future<Card?> loadCard(String cardId) async {
    try {
      final cardDoc = await _firestore
          .collection('cards')
          .doc(_userId)
          .collection('userCards')
          .doc(cardId)
          .withConverter<Card>(
            fromFirestore: (doc, _) => Card.fromJson(doc.id, doc.data()!),
            toFirestore: (card, _) => card.toJson(),
          )
          .get();

      return cardDoc.data();
    } catch (error, stackTrace) {
      _log.e(
        'Error loading card $cardId',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Gets all decks from cache
  Iterable<Deck> getAllDecks() {
    return _deckCache.getAllDecks();
  }

  /// Gets a specific deck by ID from cache
  Deck? getDeckById(String deckId) {
    return _deckCache.getDeckById(deckId);
  }

  /// Gets all deck groups from cache
  Iterable<DeckGroup> getAllDeckGroups() {
    return _deckGroupCache.getAllGroups();
  }

  /// Gets a specific deck group by ID from cache
  DeckGroup? getDeckGroupById(String groupId) {
    return _deckGroupCache.getGroupById(groupId);
  }

  /// Gets all card stats for a specific deck from cache
  Iterable<CardStats> getCardStatsByDeckId(String deckId) {
    return _cardStatsCache.getCardStatsByDeckId(deckId);
  }

  /// Gets all card stats for a specific card from cache
  Iterable<CardStats> getCardStatsByCardId(String cardId) {
    return _cardStatsCache.getCardStatsByCardId(cardId);
  }

  /// Gets a specific card stat by card ID and variant from cache
  CardStats? getCardStats(String cardId, CardReviewVariant variant) {
    return _cardStatsCache.getCardStats(cardId, variant);
  }

  /// Returns the count of cards ready for review in a specific deck
  int getCardsToReviewCountForDeck(String deckId) {
    final deckStats = _cardStatsCache.getCardStatsByDeckId(deckId);
    return deckStats.where((stats) {
      return stats.nextReviewDate == null ||
          stats.nextReviewDate!.isBefore(DateTime.now());
    }).length;
  }

  /// Returns the count of cards ready for review in a specific deck group
  int getCardsToReviewCountForDeckGroup(String deckGroupId) {
    final group = _deckGroupCache.getGroupById(deckGroupId);
    if (group == null) return 0;

    final deckIds = group.decks ?? {};
    int totalCount = 0;

    for (final deckId in deckIds) {
      totalCount += getCardsToReviewCountForDeck(deckId);
    }

    return totalCount;
  }

  /// Returns the count of cards ready for review across all decks
  int getTotalCardsToReviewCount() {
    final allCardStats = _cardStatsCache.getAllCardStats();
    return allCardStats.where((stats) {
      return stats.nextReviewDate == null ||
          stats.nextReviewDate!.isBefore(DateTime.now());
    }).length;
  }
}
