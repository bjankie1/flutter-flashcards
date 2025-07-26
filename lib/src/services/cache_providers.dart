import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import 'card_stats_cache_service.dart';
import 'deck_cache_service.dart';
import 'deck_group_cache_service.dart';
import 'decks_service.dart';

final _log = Logger();

/// Provider for Firebase Firestore instance
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Provider for current Firebase Auth user
final currentUserProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Provider for current user ID
final currentUserIdProvider = Provider<String?>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.value?.uid;
});

/// Provider for CardStatsCacheService
final cardStatsCacheServiceProvider = Provider<CardStatsCacheService?>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) {
    _log.d('No user logged in, returning null for CardStatsCacheService');
    return null;
  }

  _log.d('Creating CardStatsCacheService for user: $userId');
  return CardStatsCacheService(firestore, userId);
});

/// Provider for CardStatsCacheService initialization
final cardStatsCacheInitializerProvider =
    FutureProvider<CardStatsCacheService?>((ref) async {
      final service = ref.watch(cardStatsCacheServiceProvider);
      if (service == null) return null;

      _log.d('Initializing CardStatsCacheService...');
      await service.initialize();
      _log.d('CardStatsCacheService initialized successfully');
      return service;
    });

/// Provider for DeckCacheService
final deckCacheServiceProvider = Provider<DeckCacheService?>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) {
    _log.d('No user logged in, returning null for DeckCacheService');
    return null;
  }

  _log.d('Creating DeckCacheService for user: $userId');
  return DeckCacheService(firestore, userId);
});

/// Provider for DeckCacheService initialization
final deckCacheInitializerProvider = FutureProvider<DeckCacheService?>((
  ref,
) async {
  final service = ref.watch(deckCacheServiceProvider);
  if (service == null) return null;

  _log.d('Initializing DeckCacheService...');
  await service.initialize();
  _log.d('DeckCacheService initialized successfully');
  return service;
});

/// Provider for DeckGroupCacheService
final deckGroupCacheServiceProvider = Provider<DeckGroupCacheService?>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) {
    _log.d('No user logged in, returning null for DeckGroupCacheService');
    return null;
  }

  _log.d('Creating DeckGroupCacheService for user: $userId');
  return DeckGroupCacheService(firestore, userId);
});

/// Provider for DeckGroupCacheService initialization
final deckGroupCacheInitializerProvider =
    FutureProvider<DeckGroupCacheService?>((ref) async {
      final service = ref.watch(deckGroupCacheServiceProvider);
      if (service == null) return null;

      _log.d('Initializing DeckGroupCacheService...');
      await service.initialize();
      _log.d('DeckGroupCacheService initialized successfully');
      return service;
    });

/// Provider for DecksService that uses all cache services
final decksServiceProvider = Provider<DecksService?>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final userId = ref.watch(currentUserIdProvider);
  final cardStatsCache = ref.watch(readyCardStatsCacheServiceProvider);
  final deckCache = ref.watch(readyDeckCacheServiceProvider);
  final deckGroupCache = ref.watch(readyDeckGroupCacheServiceProvider);

  if (userId == null ||
      cardStatsCache == null ||
      deckCache == null ||
      deckGroupCache == null) {
    _log.d('Cannot create DecksService: missing dependencies');
    return null;
  }

  _log.d('Creating DecksService for user: $userId');
  return DecksService(
    firestore,
    userId,
    cardStatsCache,
    deckCache,
    deckGroupCache,
  );
});

/// Provider that watches cache initialization status
final cacheServicesReadyProvider = Provider<bool>((ref) {
  final cardStatsInit = ref.watch(cardStatsCacheInitializerProvider);
  final deckInit = ref.watch(deckCacheInitializerProvider);
  final deckGroupInit = ref.watch(deckGroupCacheInitializerProvider);

  final cardStatsReady = cardStatsInit.hasValue && !cardStatsInit.hasError;
  final deckReady = deckInit.hasValue && !deckInit.hasError;
  final deckGroupReady = deckGroupInit.hasValue && !deckGroupInit.hasError;

  _log.d(
    'Cache readiness - CardStats: $cardStatsReady, Deck: $deckReady, DeckGroup: $deckGroupReady',
  );

  // Check if all services are available and initialized
  final allReady = cardStatsReady && deckReady && deckGroupReady;
  _log.d('All cache services ready: $allReady');

  return allReady;
});

/// Provider for initialized CardStatsCacheService (only available when ready)
final readyCardStatsCacheServiceProvider = Provider<CardStatsCacheService?>((
  ref,
) {
  final initAsync = ref.watch(cardStatsCacheInitializerProvider);
  return initAsync.value;
});

/// Provider for initialized DeckCacheService (only available when ready)
final readyDeckCacheServiceProvider = Provider<DeckCacheService?>((ref) {
  final initAsync = ref.watch(deckCacheInitializerProvider);
  return initAsync.value;
});

/// Provider for initialized DeckGroupCacheService (only available when ready)
final readyDeckGroupCacheServiceProvider = Provider<DeckGroupCacheService?>((
  ref,
) {
  final initAsync = ref.watch(deckGroupCacheInitializerProvider);
  return initAsync.value;
});

/// Provider for initialized DecksService (only available when ready)
final readyDecksServiceProvider = Provider<DecksService?>((ref) {
  final isReady = ref.watch(cacheServicesReadyProvider);
  if (!isReady) return null;

  return ref.watch(decksServiceProvider);
});
