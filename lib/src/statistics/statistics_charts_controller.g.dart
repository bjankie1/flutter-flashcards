// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistics_charts_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing statistics charts operations

@ProviderFor(StatisticsChartsController)
const statisticsChartsControllerProvider = StatisticsChartsControllerFamily._();

/// Controller for managing statistics charts operations
final class StatisticsChartsControllerProvider
    extends
        $AsyncNotifierProvider<
          StatisticsChartsController,
          Iterable<model.CardAnswer>
        > {
  /// Controller for managing statistics charts operations
  const StatisticsChartsControllerProvider._({
    required StatisticsChartsControllerFamily super.from,
    required StatisticsLoadParams super.argument,
  }) : super(
         retry: null,
         name: r'statisticsChartsControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$statisticsChartsControllerHash();

  @override
  String toString() {
    return r'statisticsChartsControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  StatisticsChartsController create() => StatisticsChartsController();

  @override
  bool operator ==(Object other) {
    return other is StatisticsChartsControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$statisticsChartsControllerHash() =>
    r'ba6d2f3f24d5191d703d1afa915ff50ca75b8239';

/// Controller for managing statistics charts operations

final class StatisticsChartsControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          StatisticsChartsController,
          AsyncValue<Iterable<model.CardAnswer>>,
          Iterable<model.CardAnswer>,
          FutureOr<Iterable<model.CardAnswer>>,
          StatisticsLoadParams
        > {
  const StatisticsChartsControllerFamily._()
    : super(
        retry: null,
        name: r'statisticsChartsControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Controller for managing statistics charts operations

  StatisticsChartsControllerProvider call(StatisticsLoadParams params) =>
      StatisticsChartsControllerProvider._(argument: params, from: this);

  @override
  String toString() => r'statisticsChartsControllerProvider';
}

/// Controller for managing statistics charts operations

abstract class _$StatisticsChartsController
    extends $AsyncNotifier<Iterable<model.CardAnswer>> {
  late final _$args = ref.$arg as StatisticsLoadParams;
  StatisticsLoadParams get params => _$args;

  FutureOr<Iterable<model.CardAnswer>> build(StatisticsLoadParams params);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref
            as $Ref<
              AsyncValue<Iterable<model.CardAnswer>>,
              Iterable<model.CardAnswer>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<Iterable<model.CardAnswer>>,
                Iterable<model.CardAnswer>
              >,
              AsyncValue<Iterable<model.CardAnswer>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
