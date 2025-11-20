// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cards_review_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cardsReviewControllerHash() =>
    r'897277a460faf3dad0e298d312b3e111563f84f2';

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

abstract class _$CardsReviewController
    extends BuildlessAutoDisposeNotifier<ReviewState> {
  late final StudySession session;

  ReviewState build(
    StudySession session,
  );
}

/// Controller for managing card review operations
///
/// Copied from [CardsReviewController].
@ProviderFor(CardsReviewController)
const cardsReviewControllerProvider = CardsReviewControllerFamily();

/// Controller for managing card review operations
///
/// Copied from [CardsReviewController].
class CardsReviewControllerFamily extends Family<ReviewState> {
  /// Controller for managing card review operations
  ///
  /// Copied from [CardsReviewController].
  const CardsReviewControllerFamily();

  /// Controller for managing card review operations
  ///
  /// Copied from [CardsReviewController].
  CardsReviewControllerProvider call(
    StudySession session,
  ) {
    return CardsReviewControllerProvider(
      session,
    );
  }

  @override
  CardsReviewControllerProvider getProviderOverride(
    covariant CardsReviewControllerProvider provider,
  ) {
    return call(
      provider.session,
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
  String? get name => r'cardsReviewControllerProvider';
}

/// Controller for managing card review operations
///
/// Copied from [CardsReviewController].
class CardsReviewControllerProvider extends AutoDisposeNotifierProviderImpl<
    CardsReviewController, ReviewState> {
  /// Controller for managing card review operations
  ///
  /// Copied from [CardsReviewController].
  CardsReviewControllerProvider(
    StudySession session,
  ) : this._internal(
          () => CardsReviewController()..session = session,
          from: cardsReviewControllerProvider,
          name: r'cardsReviewControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$cardsReviewControllerHash,
          dependencies: CardsReviewControllerFamily._dependencies,
          allTransitiveDependencies:
              CardsReviewControllerFamily._allTransitiveDependencies,
          session: session,
        );

  CardsReviewControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.session,
  }) : super.internal();

  final StudySession session;

  @override
  ReviewState runNotifierBuild(
    covariant CardsReviewController notifier,
  ) {
    return notifier.build(
      session,
    );
  }

  @override
  Override overrideWith(CardsReviewController Function() create) {
    return ProviderOverride(
      origin: this,
      override: CardsReviewControllerProvider._internal(
        () => create()..session = session,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        session: session,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<CardsReviewController, ReviewState>
      createElement() {
    return _CardsReviewControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CardsReviewControllerProvider && other.session == session;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, session.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CardsReviewControllerRef on AutoDisposeNotifierProviderRef<ReviewState> {
  /// The parameter `session` of this provider.
  StudySession get session;
}

class _CardsReviewControllerProviderElement
    extends AutoDisposeNotifierProviderElement<CardsReviewController,
        ReviewState> with CardsReviewControllerRef {
  _CardsReviewControllerProviderElement(super.provider);

  @override
  StudySession get session => (origin as CardsReviewControllerProvider).session;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
