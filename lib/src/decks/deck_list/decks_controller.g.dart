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

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CardsRepositoryRef = AutoDisposeProviderRef<CardsRepository>;
String _$sortedDecksHash() => r'40c334840807521d331ac3dc15dd671b146bcd22';

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

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SortedDecksRef = AutoDisposeProviderRef<AsyncValue<List<model.Deck>>>;
String _$decksControllerHash() => r'ab3ecf329bd19d2318c703d484545f304cb2e063';

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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
