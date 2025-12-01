// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reviews_history_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing review history operations

@ProviderFor(ReviewHistoryController)
const reviewHistoryControllerProvider = ReviewHistoryControllerFamily._();

/// Controller for managing review history operations
final class ReviewHistoryControllerProvider
    extends $NotifierProvider<ReviewHistoryController, ReviewHistoryData> {
  /// Controller for managing review history operations
  const ReviewHistoryControllerProvider._({
    required ReviewHistoryControllerFamily super.from,
    required (Iterable<CardAnswer>, DateTimeRange<DateTime>) super.argument,
  }) : super(
         retry: null,
         name: r'reviewHistoryControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$reviewHistoryControllerHash();

  @override
  String toString() {
    return r'reviewHistoryControllerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  ReviewHistoryController create() => ReviewHistoryController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReviewHistoryData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReviewHistoryData>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ReviewHistoryControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$reviewHistoryControllerHash() =>
    r'1036347007ce03c0d320ac2757976853482aa3cb';

/// Controller for managing review history operations

final class ReviewHistoryControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ReviewHistoryController,
          ReviewHistoryData,
          ReviewHistoryData,
          ReviewHistoryData,
          (Iterable<CardAnswer>, DateTimeRange<DateTime>)
        > {
  const ReviewHistoryControllerFamily._()
    : super(
        retry: null,
        name: r'reviewHistoryControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Controller for managing review history operations

  ReviewHistoryControllerProvider call(
    Iterable<CardAnswer> answers,
    DateTimeRange<DateTime> dateRange,
  ) => ReviewHistoryControllerProvider._(
    argument: (answers, dateRange),
    from: this,
  );

  @override
  String toString() => r'reviewHistoryControllerProvider';
}

/// Controller for managing review history operations

abstract class _$ReviewHistoryController extends $Notifier<ReviewHistoryData> {
  late final _$args =
      ref.$arg as (Iterable<CardAnswer>, DateTimeRange<DateTime>);
  Iterable<CardAnswer> get answers => _$args.$1;
  DateTimeRange<DateTime> get dateRange => _$args.$2;

  ReviewHistoryData build(
    Iterable<CardAnswer> answers,
    DateTimeRange<DateTime> dateRange,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args.$1, _$args.$2);
    final ref = this.ref as $Ref<ReviewHistoryData, ReviewHistoryData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ReviewHistoryData, ReviewHistoryData>,
              ReviewHistoryData,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
