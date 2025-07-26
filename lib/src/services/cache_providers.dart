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

/// Provider for initialized CardStatsCacheService
final cardStatsCacheServiceProvider = FutureProvider<CardStatsCacheService?>((
  ref,
) async {
  final firestore = ref.watch(firestoreProvider);
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) {
    _log.d('No user logged in, returning null for CardStatsCacheService');
    return null;
  }

  _log.d('Creating and initializing CardStatsCacheService for user: $userId');
  final service = CardStatsCacheService(firestore, userId);
  await service.initialize();
  _log.d('CardStatsCacheService initialized successfully');
  return service;
});

/// Provider for initialized DeckCacheService
final deckCacheServiceProvider = FutureProvider<DeckCacheService?>((ref) async {
  final firestore = ref.watch(firestoreProvider);
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) {
    _log.d('No user logged in, returning null for DeckCacheService');
    return null;
  }

  _log.d('Creating and initializing DeckCacheService for user: $userId');
  final service = DeckCacheService(firestore, userId);
  await service.initialize();
  _log.d('DeckCacheService initialized successfully');
  return service;
});

/// Provider for initialized DeckGroupCacheService
final deckGroupCacheServiceProvider = FutureProvider<DeckGroupCacheService?>((
  ref,
) async {
  final firestore = ref.watch(firestoreProvider);
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) {
    _log.d('No user logged in, returning null for DeckGroupCacheService');
    return null;
  }

  _log.d('Creating and initializing DeckGroupCacheService for user: $userId');
  final service = DeckGroupCacheService(firestore, userId);
  await service.initialize();
  _log.d('DeckGroupCacheService initialized successfully');
  return service;
});

/// Provider for DecksService that uses all cache services
final decksServiceProvider = FutureProvider<DecksService?>((ref) async {
  final firestore = ref.watch(firestoreProvider);
  final userId = ref.watch(currentUserIdProvider);
  final cardStatsCache = await ref.watch(cardStatsCacheServiceProvider.future);
  final deckCache = await ref.watch(deckCacheServiceProvider.future);
  final deckGroupCache = await ref.watch(deckGroupCacheServiceProvider.future);

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
  final cardStatsInit = ref.watch(cardStatsCacheServiceProvider);
  final deckInit = ref.watch(deckCacheServiceProvider);
  final deckGroupInit = ref.watch(deckGroupCacheServiceProvider);

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
