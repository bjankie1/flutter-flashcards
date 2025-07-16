// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck_details_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$deckDetailsControllerHash() =>
    r'25ee32ba230de40a65c98b8efc132100f1f9aa82';

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

abstract class _$DeckDetailsController
    extends BuildlessAutoDisposeNotifier<AsyncValue<model.Deck>> {
  late final String deckId;

  AsyncValue<model.Deck> build(
    String deckId,
  );
}

/// Controller for managing deck details operations
///
/// Copied from [DeckDetailsController].
@ProviderFor(DeckDetailsController)
const deckDetailsControllerProvider = DeckDetailsControllerFamily();

/// Controller for managing deck details operations
///
/// Copied from [DeckDetailsController].
class DeckDetailsControllerFamily extends Family<AsyncValue<model.Deck>> {
  /// Controller for managing deck details operations
  ///
  /// Copied from [DeckDetailsController].
  const DeckDetailsControllerFamily();

  /// Controller for managing deck details operations
  ///
  /// Copied from [DeckDetailsController].
  DeckDetailsControllerProvider call(
    String deckId,
  ) {
    return DeckDetailsControllerProvider(
      deckId,
    );
  }

  @override
  DeckDetailsControllerProvider getProviderOverride(
    covariant DeckDetailsControllerProvider provider,
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
  String? get name => r'deckDetailsControllerProvider';
}

/// Controller for managing deck details operations
///
/// Copied from [DeckDetailsController].
class DeckDetailsControllerProvider extends AutoDisposeNotifierProviderImpl<
    DeckDetailsController, AsyncValue<model.Deck>> {
  /// Controller for managing deck details operations
  ///
  /// Copied from [DeckDetailsController].
  DeckDetailsControllerProvider(
    String deckId,
  ) : this._internal(
          () => DeckDetailsController()..deckId = deckId,
          from: deckDetailsControllerProvider,
          name: r'deckDetailsControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$deckDetailsControllerHash,
          dependencies: DeckDetailsControllerFamily._dependencies,
          allTransitiveDependencies:
              DeckDetailsControllerFamily._allTransitiveDependencies,
          deckId: deckId,
        );

  DeckDetailsControllerProvider._internal(
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
  AsyncValue<model.Deck> runNotifierBuild(
    covariant DeckDetailsController notifier,
  ) {
    return notifier.build(
      deckId,
    );
  }

  @override
  Override overrideWith(DeckDetailsController Function() create) {
    return ProviderOverride(
      origin: this,
      override: DeckDetailsControllerProvider._internal(
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
  AutoDisposeNotifierProviderElement<DeckDetailsController,
      AsyncValue<model.Deck>> createElement() {
    return _DeckDetailsControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DeckDetailsControllerProvider && other.deckId == deckId;
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
mixin DeckDetailsControllerRef
    on AutoDisposeNotifierProviderRef<AsyncValue<model.Deck>> {
  /// The parameter `deckId` of this provider.
  String get deckId;
}

class _DeckDetailsControllerProviderElement
    extends AutoDisposeNotifierProviderElement<DeckDetailsController,
        AsyncValue<model.Deck>> with DeckDetailsControllerRef {
  _DeckDetailsControllerProviderElement(super.provider);

  @override
  String get deckId => (origin as DeckDetailsControllerProvider).deckId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
