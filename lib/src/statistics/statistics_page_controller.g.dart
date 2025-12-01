// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistics_page_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing statistics page operations

@ProviderFor(StatisticsPageController)
const statisticsPageControllerProvider = StatisticsPageControllerProvider._();

/// Controller for managing statistics page operations
final class StatisticsPageControllerProvider
    extends $NotifierProvider<StatisticsPageController, StatisticsPageData> {
  /// Controller for managing statistics page operations
  const StatisticsPageControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'statisticsPageControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$statisticsPageControllerHash();

  @$internal
  @override
  StatisticsPageController create() => StatisticsPageController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StatisticsPageData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StatisticsPageData>(value),
    );
  }
}

String _$statisticsPageControllerHash() =>
    r'5adde52b97d3d14a63da241bba9122fe16344ece';

/// Controller for managing statistics page operations

abstract class _$StatisticsPageController
    extends $Notifier<StatisticsPageData> {
  StatisticsPageData build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<StatisticsPageData, StatisticsPageData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<StatisticsPageData, StatisticsPageData>,
              StatisticsPageData,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Provider for loading users with stats access

@ProviderFor(usersWithStatsAccess)
const usersWithStatsAccessProvider = UsersWithStatsAccessProvider._();

/// Provider for loading users with stats access

final class UsersWithStatsAccessProvider
    extends
        $FunctionalProvider<
          AsyncValue<Iterable<UserProfile>>,
          Iterable<UserProfile>,
          FutureOr<Iterable<UserProfile>>
        >
    with
        $FutureModifier<Iterable<UserProfile>>,
        $FutureProvider<Iterable<UserProfile>> {
  /// Provider for loading users with stats access
  const UsersWithStatsAccessProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'usersWithStatsAccessProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$usersWithStatsAccessHash();

  @$internal
  @override
  $FutureProviderElement<Iterable<UserProfile>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Iterable<UserProfile>> create(Ref ref) {
    return usersWithStatsAccess(ref);
  }
}

String _$usersWithStatsAccessHash() =>
    r'210fea51c2da60dac9201c983cd465a5f501fed6';
