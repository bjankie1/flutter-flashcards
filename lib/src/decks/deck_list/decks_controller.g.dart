// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'decks_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cardsRepositoryHash() => r'879788e0959a6d3ef2234d8697f48384f37ee7fd';

/// Provider for the cards repository
///
/// Copied from [cardsRepository].
@ProviderFor(cardsRepository)
final cardsRepositoryProvider = AutoDisposeProvider<CardsRepository>.internal(
  cardsRepository,
  name: r'cardsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cardsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CardsRepositoryRef = AutoDisposeProviderRef<CardsRepository>;
String _$sortedDecksHash() => r'45cd4334167fe9b1410ddf5d396b49c08d1db46a';

/// Provider for sorted decks
///
/// Copied from [sortedDecks].
@ProviderFor(sortedDecks)
final sortedDecksProvider =
    AutoDisposeProvider<AsyncValue<List<model.Deck>>>.internal(
  sortedDecks,
  name: r'sortedDecksProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$sortedDecksHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SortedDecksRef = AutoDisposeProviderRef<AsyncValue<List<model.Deck>>>;
String _$decksControllerHash() => r'f22f1c92251e7f2baa30ffe37ae31a062e2b7138';

/// Controller for managing deck-related operations
///
/// Copied from [DecksController].
@ProviderFor(DecksController)
final decksControllerProvider = AutoDisposeNotifierProvider<DecksController,
    AsyncValue<Iterable<model.Deck>>>.internal(
  DecksController.new,
  name: r'decksControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$decksControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DecksController
    = AutoDisposeNotifier<AsyncValue<Iterable<model.Deck>>>;
String _$deckGroupsHash() => r'7fc704c85fe710518c85436ff468455ab2dca062';

/// See also [DeckGroups].
@ProviderFor(DeckGroups)
final deckGroupsProvider = AutoDisposeAsyncNotifierProvider<DeckGroups,
    Iterable<model.DeckGroup>>.internal(
  DeckGroups.new,
  name: r'deckGroupsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$deckGroupsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DeckGroups = AutoDisposeAsyncNotifier<Iterable<model.DeckGroup>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
