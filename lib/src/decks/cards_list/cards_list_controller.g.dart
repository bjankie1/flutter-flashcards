// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cards_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cardsListControllerHash() =>
    r'affcf2e2061963df4bc4f4cb35036a8589c5e80b';

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

abstract class _$CardsListController
    extends BuildlessAutoDisposeNotifier<AsyncValue<CardsListData>> {
  late final String deckId;

  AsyncValue<CardsListData> build(
    String deckId,
  );
}

/// Controller for managing cards list operations
///
/// Copied from [CardsListController].
@ProviderFor(CardsListController)
const cardsListControllerProvider = CardsListControllerFamily();

/// Controller for managing cards list operations
///
/// Copied from [CardsListController].
class CardsListControllerFamily extends Family<AsyncValue<CardsListData>> {
  /// Controller for managing cards list operations
  ///
  /// Copied from [CardsListController].
  const CardsListControllerFamily();

  /// Controller for managing cards list operations
  ///
  /// Copied from [CardsListController].
  CardsListControllerProvider call(
    String deckId,
  ) {
    return CardsListControllerProvider(
      deckId,
    );
  }

  @override
  CardsListControllerProvider getProviderOverride(
    covariant CardsListControllerProvider provider,
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
  String? get name => r'cardsListControllerProvider';
}

/// Controller for managing cards list operations
///
/// Copied from [CardsListController].
class CardsListControllerProvider extends AutoDisposeNotifierProviderImpl<
    CardsListController, AsyncValue<CardsListData>> {
  /// Controller for managing cards list operations
  ///
  /// Copied from [CardsListController].
  CardsListControllerProvider(
    String deckId,
  ) : this._internal(
          () => CardsListController()..deckId = deckId,
          from: cardsListControllerProvider,
          name: r'cardsListControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$cardsListControllerHash,
          dependencies: CardsListControllerFamily._dependencies,
          allTransitiveDependencies:
              CardsListControllerFamily._allTransitiveDependencies,
          deckId: deckId,
        );

  CardsListControllerProvider._internal(
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
  AsyncValue<CardsListData> runNotifierBuild(
    covariant CardsListController notifier,
  ) {
    return notifier.build(
      deckId,
    );
  }

  @override
  Override overrideWith(CardsListController Function() create) {
    return ProviderOverride(
      origin: this,
      override: CardsListControllerProvider._internal(
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
  AutoDisposeNotifierProviderElement<CardsListController,
      AsyncValue<CardsListData>> createElement() {
    return _CardsListControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CardsListControllerProvider && other.deckId == deckId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, deckId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CardsListControllerRef
    on AutoDisposeNotifierProviderRef<AsyncValue<CardsListData>> {
  /// The parameter `deckId` of this provider.
  String get deckId;
}

class _CardsListControllerProviderElement
    extends AutoDisposeNotifierProviderElement<CardsListController,
        AsyncValue<CardsListData>> with CardsListControllerRef {
  _CardsListControllerProviderElement(super.provider);

  @override
  String get deckId => (origin as CardsListControllerProvider).deckId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
