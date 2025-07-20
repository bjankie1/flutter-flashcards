// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistics_page_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$usersWithStatsAccessHash() =>
    r'210fea51c2da60dac9201c983cd465a5f501fed6';

/// Provider for loading users with stats access
///
/// Copied from [usersWithStatsAccess].
@ProviderFor(usersWithStatsAccess)
final usersWithStatsAccessProvider =
    AutoDisposeFutureProvider<Iterable<UserProfile>>.internal(
  usersWithStatsAccess,
  name: r'usersWithStatsAccessProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$usersWithStatsAccessHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UsersWithStatsAccessRef
    = AutoDisposeFutureProviderRef<Iterable<UserProfile>>;
String _$statisticsPageControllerHash() =>
    r'5adde52b97d3d14a63da241bba9122fe16344ece';

/// Controller for managing statistics page operations
///
/// Copied from [StatisticsPageController].
@ProviderFor(StatisticsPageController)
final statisticsPageControllerProvider = AutoDisposeNotifierProvider<
    StatisticsPageController, StatisticsPageData>.internal(
  StatisticsPageController.new,
  name: r'statisticsPageControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$statisticsPageControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$StatisticsPageController = AutoDisposeNotifier<StatisticsPageData>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
