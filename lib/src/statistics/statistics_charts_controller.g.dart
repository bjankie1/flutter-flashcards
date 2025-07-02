// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistics_charts_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$statisticsChartsControllerHash() =>
    r'ba6d2f3f24d5191d703d1afa915ff50ca75b8239';

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

abstract class _$StatisticsChartsController
    extends BuildlessAutoDisposeAsyncNotifier<Iterable<model.CardAnswer>> {
  late final StatisticsLoadParams params;

  FutureOr<Iterable<model.CardAnswer>> build(
    StatisticsLoadParams params,
  );
}

/// Controller for managing statistics charts operations
///
/// Copied from [StatisticsChartsController].
@ProviderFor(StatisticsChartsController)
const statisticsChartsControllerProvider = StatisticsChartsControllerFamily();

/// Controller for managing statistics charts operations
///
/// Copied from [StatisticsChartsController].
class StatisticsChartsControllerFamily
    extends Family<AsyncValue<Iterable<model.CardAnswer>>> {
  /// Controller for managing statistics charts operations
  ///
  /// Copied from [StatisticsChartsController].
  const StatisticsChartsControllerFamily();

  /// Controller for managing statistics charts operations
  ///
  /// Copied from [StatisticsChartsController].
  StatisticsChartsControllerProvider call(
    StatisticsLoadParams params,
  ) {
    return StatisticsChartsControllerProvider(
      params,
    );
  }

  @override
  StatisticsChartsControllerProvider getProviderOverride(
    covariant StatisticsChartsControllerProvider provider,
  ) {
    return call(
      provider.params,
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
  String? get name => r'statisticsChartsControllerProvider';
}

/// Controller for managing statistics charts operations
///
/// Copied from [StatisticsChartsController].
class StatisticsChartsControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<StatisticsChartsController,
        Iterable<model.CardAnswer>> {
  /// Controller for managing statistics charts operations
  ///
  /// Copied from [StatisticsChartsController].
  StatisticsChartsControllerProvider(
    StatisticsLoadParams params,
  ) : this._internal(
          () => StatisticsChartsController()..params = params,
          from: statisticsChartsControllerProvider,
          name: r'statisticsChartsControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$statisticsChartsControllerHash,
          dependencies: StatisticsChartsControllerFamily._dependencies,
          allTransitiveDependencies:
              StatisticsChartsControllerFamily._allTransitiveDependencies,
          params: params,
        );

  StatisticsChartsControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.params,
  }) : super.internal();

  final StatisticsLoadParams params;

  @override
  FutureOr<Iterable<model.CardAnswer>> runNotifierBuild(
    covariant StatisticsChartsController notifier,
  ) {
    return notifier.build(
      params,
    );
  }

  @override
  Override overrideWith(StatisticsChartsController Function() create) {
    return ProviderOverride(
      origin: this,
      override: StatisticsChartsControllerProvider._internal(
        () => create()..params = params,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        params: params,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<StatisticsChartsController,
      Iterable<model.CardAnswer>> createElement() {
    return _StatisticsChartsControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StatisticsChartsControllerProvider &&
        other.params == params;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, params.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin StatisticsChartsControllerRef
    on AutoDisposeAsyncNotifierProviderRef<Iterable<model.CardAnswer>> {
  /// The parameter `params` of this provider.
  StatisticsLoadParams get params;
}

class _StatisticsChartsControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<StatisticsChartsController,
        Iterable<model.CardAnswer>> with StatisticsChartsControllerRef {
  _StatisticsChartsControllerProviderElement(super.provider);

  @override
  StatisticsLoadParams get params =>
      (origin as StatisticsChartsControllerProvider).params;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
