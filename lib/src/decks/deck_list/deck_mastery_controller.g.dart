// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck_mastery_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$deckMasteryControllerHash() =>
    r'f9a9b965b55975b2c6d67eb205444397f935034e';

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

abstract class _$DeckMasteryController
    extends BuildlessAutoDisposeNotifier<AsyncValue<Map<CardMastery, int>>> {
  late final String deckId;

  AsyncValue<Map<CardMastery, int>> build(
    String deckId,
  );
}

/// Controller for managing deck mastery data
///
/// Copied from [DeckMasteryController].
@ProviderFor(DeckMasteryController)
const deckMasteryControllerProvider = DeckMasteryControllerFamily();

/// Controller for managing deck mastery data
///
/// Copied from [DeckMasteryController].
class DeckMasteryControllerFamily
    extends Family<AsyncValue<Map<CardMastery, int>>> {
  /// Controller for managing deck mastery data
  ///
  /// Copied from [DeckMasteryController].
  const DeckMasteryControllerFamily();

  /// Controller for managing deck mastery data
  ///
  /// Copied from [DeckMasteryController].
  DeckMasteryControllerProvider call(
    String deckId,
  ) {
    return DeckMasteryControllerProvider(
      deckId,
    );
  }

  @override
  DeckMasteryControllerProvider getProviderOverride(
    covariant DeckMasteryControllerProvider provider,
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
  String? get name => r'deckMasteryControllerProvider';
}

/// Controller for managing deck mastery data
///
/// Copied from [DeckMasteryController].
class DeckMasteryControllerProvider extends AutoDisposeNotifierProviderImpl<
    DeckMasteryController, AsyncValue<Map<CardMastery, int>>> {
  /// Controller for managing deck mastery data
  ///
  /// Copied from [DeckMasteryController].
  DeckMasteryControllerProvider(
    String deckId,
  ) : this._internal(
          () => DeckMasteryController()..deckId = deckId,
          from: deckMasteryControllerProvider,
          name: r'deckMasteryControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$deckMasteryControllerHash,
          dependencies: DeckMasteryControllerFamily._dependencies,
          allTransitiveDependencies:
              DeckMasteryControllerFamily._allTransitiveDependencies,
          deckId: deckId,
        );

  DeckMasteryControllerProvider._internal(
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
  AsyncValue<Map<CardMastery, int>> runNotifierBuild(
    covariant DeckMasteryController notifier,
  ) {
    return notifier.build(
      deckId,
    );
  }

  @override
  Override overrideWith(DeckMasteryController Function() create) {
    return ProviderOverride(
      origin: this,
      override: DeckMasteryControllerProvider._internal(
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
  AutoDisposeNotifierProviderElement<DeckMasteryController,
      AsyncValue<Map<CardMastery, int>>> createElement() {
    return _DeckMasteryControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DeckMasteryControllerProvider && other.deckId == deckId;
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
mixin DeckMasteryControllerRef
    on AutoDisposeNotifierProviderRef<AsyncValue<Map<CardMastery, int>>> {
  /// The parameter `deckId` of this provider.
  String get deckId;
}

class _DeckMasteryControllerProviderElement
    extends AutoDisposeNotifierProviderElement<DeckMasteryController,
        AsyncValue<Map<CardMastery, int>>> with DeckMasteryControllerRef {
  _DeckMasteryControllerProviderElement(super.provider);

  @override
  String get deckId => (origin as DeckMasteryControllerProvider).deckId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
