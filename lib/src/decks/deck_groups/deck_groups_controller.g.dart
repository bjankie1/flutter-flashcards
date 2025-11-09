// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck_groups_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sharedDecksHash() => r'8ce5b4306b749e8c17fc883dc32ae175ebb9beac';

/// Provider for shared decks
///
/// Copied from [sharedDecks].
@ProviderFor(sharedDecks)
final sharedDecksProvider =
    AutoDisposeFutureProvider<Map<UserId, Iterable<model.Deck>>>.internal(
      sharedDecks,
      name: r'sharedDecksProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$sharedDecksHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef SharedDecksRef =
    AutoDisposeFutureProviderRef<Map<UserId, Iterable<model.Deck>>>;
String _$cardsToReviewCountByGroupHash() =>
    r'e043537ed703fe3a72b2523c7c74dad807bf33a2';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Provider for cards to review count by deck group
///
/// Copied from [cardsToReviewCountByGroup].
@ProviderFor(cardsToReviewCountByGroup)
const cardsToReviewCountByGroupProvider = CardsToReviewCountByGroupFamily();

/// Provider for cards to review count by deck group
///
/// Copied from [cardsToReviewCountByGroup].
class CardsToReviewCountByGroupFamily
    extends Family<AsyncValue<Map<model.State, int>>> {
  /// Provider for cards to review count by deck group
  ///
  /// Copied from [cardsToReviewCountByGroup].
  const CardsToReviewCountByGroupFamily();

  /// Provider for cards to review count by deck group
  ///
  /// Copied from [cardsToReviewCountByGroup].
  CardsToReviewCountByGroupProvider call(String? deckGroupId) {
    return CardsToReviewCountByGroupProvider(deckGroupId);
  }

  @override
  CardsToReviewCountByGroupProvider getProviderOverride(
    covariant CardsToReviewCountByGroupProvider provider,
  ) {
    return call(provider.deckGroupId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'cardsToReviewCountByGroupProvider';
}

/// Provider for cards to review count by deck group
///
/// Copied from [cardsToReviewCountByGroup].
class CardsToReviewCountByGroupProvider
    extends AutoDisposeFutureProvider<Map<model.State, int>> {
  /// Provider for cards to review count by deck group
  ///
  /// Copied from [cardsToReviewCountByGroup].
  CardsToReviewCountByGroupProvider(String? deckGroupId)
    : this._internal(
        (ref) => cardsToReviewCountByGroup(
          ref as CardsToReviewCountByGroupRef,
          deckGroupId,
        ),
        from: cardsToReviewCountByGroupProvider,
        name: r'cardsToReviewCountByGroupProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$cardsToReviewCountByGroupHash,
        dependencies: CardsToReviewCountByGroupFamily._dependencies,
        allTransitiveDependencies:
            CardsToReviewCountByGroupFamily._allTransitiveDependencies,
        deckGroupId: deckGroupId,
      );

  CardsToReviewCountByGroupProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.deckGroupId,
  }) : super.internal();

  final String? deckGroupId;

  @override
  Override overrideWith(
    FutureOr<Map<model.State, int>> Function(
      CardsToReviewCountByGroupRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CardsToReviewCountByGroupProvider._internal(
        (ref) => create(ref as CardsToReviewCountByGroupRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        deckGroupId: deckGroupId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<model.State, int>> createElement() {
    return _CardsToReviewCountByGroupProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CardsToReviewCountByGroupProvider &&
        other.deckGroupId == deckGroupId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, deckGroupId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CardsToReviewCountByGroupRef
    on AutoDisposeFutureProviderRef<Map<model.State, int>> {
  /// The parameter `deckGroupId` of this provider.
  String? get deckGroupId;
}

class _CardsToReviewCountByGroupProviderElement
    extends AutoDisposeFutureProviderElement<Map<model.State, int>>
    with CardsToReviewCountByGroupRef {
  _CardsToReviewCountByGroupProviderElement(super.provider);

  @override
  String? get deckGroupId =>
      (origin as CardsToReviewCountByGroupProvider).deckGroupId;
}

String _$deckGroupsControllerHash() =>
    r'9fd74845931642f38d4ab7251a43a190e6a3790d';

/// Controller for managing deck groups and their operations
///
/// Copied from [DeckGroupsController].
@ProviderFor(DeckGroupsController)
final deckGroupsControllerProvider =
    AutoDisposeNotifierProvider<
      DeckGroupsController,
      AsyncValue<List<(model.DeckGroup?, List<model.Deck>)>>
    >.internal(
      DeckGroupsController.new,
      name: r'deckGroupsControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$deckGroupsControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DeckGroupsController =
    AutoDisposeNotifier<AsyncValue<List<(model.DeckGroup?, List<model.Deck>)>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
