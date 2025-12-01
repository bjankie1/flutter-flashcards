// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'decks_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing deck-related operations

@ProviderFor(DecksController)
const decksControllerProvider = DecksControllerProvider._();

/// Controller for managing deck-related operations
final class DecksControllerProvider
    extends
        $NotifierProvider<DecksController, AsyncValue<Iterable<model.Deck>>> {
  /// Controller for managing deck-related operations
  const DecksControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'decksControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$decksControllerHash();

  @$internal
  @override
  DecksController create() => DecksController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<Iterable<model.Deck>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<Iterable<model.Deck>>>(
        value,
      ),
    );
  }
}

String _$decksControllerHash() => r'e8caa923ea990d4c05dab0901f2a881c2fec7bac';

/// Controller for managing deck-related operations

abstract class _$DecksController
    extends $Notifier<AsyncValue<Iterable<model.Deck>>> {
  AsyncValue<Iterable<model.Deck>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<Iterable<model.Deck>>,
              AsyncValue<Iterable<model.Deck>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<Iterable<model.Deck>>,
                AsyncValue<Iterable<model.Deck>>
              >,
              AsyncValue<Iterable<model.Deck>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Provider for the cards repository

@ProviderFor(cardsRepository)
const cardsRepositoryProvider = CardsRepositoryProvider._();

/// Provider for the cards repository

final class CardsRepositoryProvider
    extends
        $FunctionalProvider<CardsRepository, CardsRepository, CardsRepository>
    with $Provider<CardsRepository> {
  /// Provider for the cards repository
  const CardsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cardsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cardsRepositoryHash();

  @$internal
  @override
  $ProviderElement<CardsRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CardsRepository create(Ref ref) {
    return cardsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CardsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CardsRepository>(value),
    );
  }
}

String _$cardsRepositoryHash() => r'879788e0959a6d3ef2234d8697f48384f37ee7fd';

/// Provider for sorted decks

@ProviderFor(sortedDecks)
const sortedDecksProvider = SortedDecksProvider._();

/// Provider for sorted decks

final class SortedDecksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<model.Deck>>,
          AsyncValue<List<model.Deck>>,
          AsyncValue<List<model.Deck>>
        >
    with $Provider<AsyncValue<List<model.Deck>>> {
  /// Provider for sorted decks
  const SortedDecksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sortedDecksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sortedDecksHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<List<model.Deck>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<model.Deck>> create(Ref ref) {
    return sortedDecks(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<model.Deck>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<model.Deck>>>(value),
    );
  }
}

String _$sortedDecksHash() => r'45cd4334167fe9b1410ddf5d396b49c08d1db46a';

@ProviderFor(DeckGroups)
const deckGroupsProvider = DeckGroupsProvider._();

final class DeckGroupsProvider
    extends $AsyncNotifierProvider<DeckGroups, Iterable<model.DeckGroup>> {
  const DeckGroupsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deckGroupsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deckGroupsHash();

  @$internal
  @override
  DeckGroups create() => DeckGroups();
}

String _$deckGroupsHash() => r'7fc704c85fe710518c85436ff468455ab2dca062';

abstract class _$DeckGroups extends $AsyncNotifier<Iterable<model.DeckGroup>> {
  FutureOr<Iterable<model.DeckGroup>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<Iterable<model.DeckGroup>>,
              Iterable<model.DeckGroup>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<Iterable<model.DeckGroup>>,
                Iterable<model.DeckGroup>
              >,
              AsyncValue<Iterable<model.DeckGroup>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
