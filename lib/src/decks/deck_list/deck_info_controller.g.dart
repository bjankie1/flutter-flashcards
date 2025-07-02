// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck_info_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$deckInfoControllerHash() =>
    r'3cac09dd7d1b443dff904a9804d0971446b56cc5';

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

abstract class _$DeckInfoController
    extends BuildlessAutoDisposeNotifier<AsyncValue<int>> {
  late final String deckId;

  AsyncValue<int> build(
    String deckId,
  );
}

/// Controller for managing deck info data (card count)
///
/// Copied from [DeckInfoController].
@ProviderFor(DeckInfoController)
const deckInfoControllerProvider = DeckInfoControllerFamily();

/// Controller for managing deck info data (card count)
///
/// Copied from [DeckInfoController].
class DeckInfoControllerFamily extends Family<AsyncValue<int>> {
  /// Controller for managing deck info data (card count)
  ///
  /// Copied from [DeckInfoController].
  const DeckInfoControllerFamily();

  /// Controller for managing deck info data (card count)
  ///
  /// Copied from [DeckInfoController].
  DeckInfoControllerProvider call(
    String deckId,
  ) {
    return DeckInfoControllerProvider(
      deckId,
    );
  }

  @override
  DeckInfoControllerProvider getProviderOverride(
    covariant DeckInfoControllerProvider provider,
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
  String? get name => r'deckInfoControllerProvider';
}

/// Controller for managing deck info data (card count)
///
/// Copied from [DeckInfoController].
class DeckInfoControllerProvider extends AutoDisposeNotifierProviderImpl<
    DeckInfoController, AsyncValue<int>> {
  /// Controller for managing deck info data (card count)
  ///
  /// Copied from [DeckInfoController].
  DeckInfoControllerProvider(
    String deckId,
  ) : this._internal(
          () => DeckInfoController()..deckId = deckId,
          from: deckInfoControllerProvider,
          name: r'deckInfoControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$deckInfoControllerHash,
          dependencies: DeckInfoControllerFamily._dependencies,
          allTransitiveDependencies:
              DeckInfoControllerFamily._allTransitiveDependencies,
          deckId: deckId,
        );

  DeckInfoControllerProvider._internal(
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
  AsyncValue<int> runNotifierBuild(
    covariant DeckInfoController notifier,
  ) {
    return notifier.build(
      deckId,
    );
  }

  @override
  Override overrideWith(DeckInfoController Function() create) {
    return ProviderOverride(
      origin: this,
      override: DeckInfoControllerProvider._internal(
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
  AutoDisposeNotifierProviderElement<DeckInfoController, AsyncValue<int>>
      createElement() {
    return _DeckInfoControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DeckInfoControllerProvider && other.deckId == deckId;
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
mixin DeckInfoControllerRef on AutoDisposeNotifierProviderRef<AsyncValue<int>> {
  /// The parameter `deckId` of this provider.
  String get deckId;
}

class _DeckInfoControllerProviderElement
    extends AutoDisposeNotifierProviderElement<DeckInfoController,
        AsyncValue<int>> with DeckInfoControllerRef {
  _DeckInfoControllerProviderElement(super.provider);

  @override
  String get deckId => (origin as DeckInfoControllerProvider).deckId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
