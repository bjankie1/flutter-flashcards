// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_descriptions_dialog_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cardDescriptionsDialogControllerHash() =>
    r'7f5fdea0cf6ef4c2325c1ff655e7089aa88d4e3e';

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

abstract class _$CardDescriptionsDialogController
    extends BuildlessAutoDisposeNotifier<AsyncValue<model.Deck>> {
  late final String deckId;

  AsyncValue<model.Deck> build(
    String deckId,
  );
}

/// Controller for managing card descriptions dialog operations
///
/// Copied from [CardDescriptionsDialogController].
@ProviderFor(CardDescriptionsDialogController)
const cardDescriptionsDialogControllerProvider =
    CardDescriptionsDialogControllerFamily();

/// Controller for managing card descriptions dialog operations
///
/// Copied from [CardDescriptionsDialogController].
class CardDescriptionsDialogControllerFamily
    extends Family<AsyncValue<model.Deck>> {
  /// Controller for managing card descriptions dialog operations
  ///
  /// Copied from [CardDescriptionsDialogController].
  const CardDescriptionsDialogControllerFamily();

  /// Controller for managing card descriptions dialog operations
  ///
  /// Copied from [CardDescriptionsDialogController].
  CardDescriptionsDialogControllerProvider call(
    String deckId,
  ) {
    return CardDescriptionsDialogControllerProvider(
      deckId,
    );
  }

  @override
  CardDescriptionsDialogControllerProvider getProviderOverride(
    covariant CardDescriptionsDialogControllerProvider provider,
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
  String? get name => r'cardDescriptionsDialogControllerProvider';
}

/// Controller for managing card descriptions dialog operations
///
/// Copied from [CardDescriptionsDialogController].
class CardDescriptionsDialogControllerProvider
    extends AutoDisposeNotifierProviderImpl<CardDescriptionsDialogController,
        AsyncValue<model.Deck>> {
  /// Controller for managing card descriptions dialog operations
  ///
  /// Copied from [CardDescriptionsDialogController].
  CardDescriptionsDialogControllerProvider(
    String deckId,
  ) : this._internal(
          () => CardDescriptionsDialogController()..deckId = deckId,
          from: cardDescriptionsDialogControllerProvider,
          name: r'cardDescriptionsDialogControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$cardDescriptionsDialogControllerHash,
          dependencies: CardDescriptionsDialogControllerFamily._dependencies,
          allTransitiveDependencies:
              CardDescriptionsDialogControllerFamily._allTransitiveDependencies,
          deckId: deckId,
        );

  CardDescriptionsDialogControllerProvider._internal(
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
    covariant CardDescriptionsDialogController notifier,
  ) {
    return notifier.build(
      deckId,
    );
  }

  @override
  Override overrideWith(CardDescriptionsDialogController Function() create) {
    return ProviderOverride(
      origin: this,
      override: CardDescriptionsDialogControllerProvider._internal(
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
  AutoDisposeNotifierProviderElement<CardDescriptionsDialogController,
      AsyncValue<model.Deck>> createElement() {
    return _CardDescriptionsDialogControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CardDescriptionsDialogControllerProvider &&
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
mixin CardDescriptionsDialogControllerRef
    on AutoDisposeNotifierProviderRef<AsyncValue<model.Deck>> {
  /// The parameter `deckId` of this provider.
  String get deckId;
}

class _CardDescriptionsDialogControllerProviderElement
    extends AutoDisposeNotifierProviderElement<CardDescriptionsDialogController,
        AsyncValue<model.Deck>> with CardDescriptionsDialogControllerRef {
  _CardDescriptionsDialogControllerProviderElement(super.provider);

  @override
  String get deckId =>
      (origin as CardDescriptionsDialogControllerProvider).deckId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
