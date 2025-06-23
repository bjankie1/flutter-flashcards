// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck_cards_to_review_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$deckCardsToReviewControllerHash() =>
    r'e4b57a3e7f78ad00562c1a838fa7157c9dac5083';

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

abstract class _$DeckCardsToReviewController
    extends BuildlessAutoDisposeNotifier<AsyncValue<Map<model.State, int>>> {
  late final String deckId;

  AsyncValue<Map<model.State, int>> build(
    String deckId,
  );
}

/// Controller for managing cards to review count for a specific deck
///
/// Copied from [DeckCardsToReviewController].
@ProviderFor(DeckCardsToReviewController)
const deckCardsToReviewControllerProvider = DeckCardsToReviewControllerFamily();

/// Controller for managing cards to review count for a specific deck
///
/// Copied from [DeckCardsToReviewController].
class DeckCardsToReviewControllerFamily
    extends Family<AsyncValue<Map<model.State, int>>> {
  /// Controller for managing cards to review count for a specific deck
  ///
  /// Copied from [DeckCardsToReviewController].
  const DeckCardsToReviewControllerFamily();

  /// Controller for managing cards to review count for a specific deck
  ///
  /// Copied from [DeckCardsToReviewController].
  DeckCardsToReviewControllerProvider call(
    String deckId,
  ) {
    return DeckCardsToReviewControllerProvider(
      deckId,
    );
  }

  @override
  DeckCardsToReviewControllerProvider getProviderOverride(
    covariant DeckCardsToReviewControllerProvider provider,
  ) {
    return call(
      provider.deckId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'deckCardsToReviewControllerProvider';
}

/// Controller for managing cards to review count for a specific deck
///
/// Copied from [DeckCardsToReviewController].
class DeckCardsToReviewControllerProvider
    extends AutoDisposeNotifierProviderImpl<DeckCardsToReviewController,
        AsyncValue<Map<model.State, int>>> {
  /// Controller for managing cards to review count for a specific deck
  ///
  /// Copied from [DeckCardsToReviewController].
  DeckCardsToReviewControllerProvider(
    String deckId,
  ) : this._internal(
          () => DeckCardsToReviewController()..deckId = deckId,
          from: deckCardsToReviewControllerProvider,
          name: r'deckCardsToReviewControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$deckCardsToReviewControllerHash,
          dependencies: DeckCardsToReviewControllerFamily._dependencies,
          allTransitiveDependencies:
              DeckCardsToReviewControllerFamily._allTransitiveDependencies,
          deckId: deckId,
        );

  DeckCardsToReviewControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.deckId,
  }) : super.internal();

  final String deckId;

  @override
  AsyncValue<Map<model.State, int>> runNotifierBuild(
    covariant DeckCardsToReviewController notifier,
  ) {
    return notifier.build(
      deckId,
    );
  }

  @override
  Override overrideWith(DeckCardsToReviewController Function() create) {
    return ProviderOverride(
      origin: this,
      override: DeckCardsToReviewControllerProvider._internal(
        () => create()..deckId = deckId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        deckId: deckId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<DeckCardsToReviewController,
      AsyncValue<Map<model.State, int>>> createElement() {
    return _DeckCardsToReviewControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DeckCardsToReviewControllerProvider &&
        other.deckId == deckId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, deckId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DeckCardsToReviewControllerRef
    on AutoDisposeNotifierProviderRef<AsyncValue<Map<model.State, int>>> {
  /// The parameter `deckId` of this provider.
  String get deckId;
}

class _DeckCardsToReviewControllerProviderElement
    extends AutoDisposeNotifierProviderElement<DeckCardsToReviewController,
        AsyncValue<Map<model.State, int>>> with DeckCardsToReviewControllerRef {
  _DeckCardsToReviewControllerProviderElement(super.provider);

  @override
  String get deckId => (origin as DeckCardsToReviewControllerProvider).deckId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
