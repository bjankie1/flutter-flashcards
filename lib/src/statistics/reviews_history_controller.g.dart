// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reviews_history_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$reviewHistoryControllerHash() =>
    r'1036347007ce03c0d320ac2757976853482aa3cb';

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

abstract class _$ReviewHistoryController
    extends BuildlessAutoDisposeNotifier<ReviewHistoryData> {
  late final Iterable<CardAnswer> answers;
  late final DateTimeRange<DateTime> dateRange;

  ReviewHistoryData build(
    Iterable<CardAnswer> answers,
    DateTimeRange<DateTime> dateRange,
  );
}

/// Controller for managing review history operations
///
/// Copied from [ReviewHistoryController].
@ProviderFor(ReviewHistoryController)
const reviewHistoryControllerProvider = ReviewHistoryControllerFamily();

/// Controller for managing review history operations
///
/// Copied from [ReviewHistoryController].
class ReviewHistoryControllerFamily extends Family<ReviewHistoryData> {
  /// Controller for managing review history operations
  ///
  /// Copied from [ReviewHistoryController].
  const ReviewHistoryControllerFamily();

  /// Controller for managing review history operations
  ///
  /// Copied from [ReviewHistoryController].
  ReviewHistoryControllerProvider call(
    Iterable<CardAnswer> answers,
    DateTimeRange<DateTime> dateRange,
  ) {
    return ReviewHistoryControllerProvider(
      answers,
      dateRange,
    );
  }

  @override
  ReviewHistoryControllerProvider getProviderOverride(
    covariant ReviewHistoryControllerProvider provider,
  ) {
    return call(
      provider.answers,
      provider.dateRange,
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
  String? get name => r'reviewHistoryControllerProvider';
}

/// Controller for managing review history operations
///
/// Copied from [ReviewHistoryController].
class ReviewHistoryControllerProvider extends AutoDisposeNotifierProviderImpl<
    ReviewHistoryController, ReviewHistoryData> {
  /// Controller for managing review history operations
  ///
  /// Copied from [ReviewHistoryController].
  ReviewHistoryControllerProvider(
    Iterable<CardAnswer> answers,
    DateTimeRange<DateTime> dateRange,
  ) : this._internal(
          () => ReviewHistoryController()
            ..answers = answers
            ..dateRange = dateRange,
          from: reviewHistoryControllerProvider,
          name: r'reviewHistoryControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$reviewHistoryControllerHash,
          dependencies: ReviewHistoryControllerFamily._dependencies,
          allTransitiveDependencies:
              ReviewHistoryControllerFamily._allTransitiveDependencies,
          answers: answers,
          dateRange: dateRange,
        );

  ReviewHistoryControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.answers,
    required this.dateRange,
  }) : super.internal();

  final Iterable<CardAnswer> answers;
  final DateTimeRange<DateTime> dateRange;

  @override
  ReviewHistoryData runNotifierBuild(
    covariant ReviewHistoryController notifier,
  ) {
    return notifier.build(
      answers,
      dateRange,
    );
  }

  @override
  Override overrideWith(ReviewHistoryController Function() create) {
    return ProviderOverride(
      origin: this,
      override: ReviewHistoryControllerProvider._internal(
        () => create()
          ..answers = answers
          ..dateRange = dateRange,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        answers: answers,
        dateRange: dateRange,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<ReviewHistoryController, ReviewHistoryData>
      createElement() {
    return _ReviewHistoryControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ReviewHistoryControllerProvider &&
        other.answers == answers &&
        other.dateRange == dateRange;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, answers.hashCode);
    hash = _SystemHash.combine(hash, dateRange.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ReviewHistoryControllerRef
    on AutoDisposeNotifierProviderRef<ReviewHistoryData> {
  /// The parameter `answers` of this provider.
  Iterable<CardAnswer> get answers;

  /// The parameter `dateRange` of this provider.
  DateTimeRange<DateTime> get dateRange;
}

class _ReviewHistoryControllerProviderElement
    extends AutoDisposeNotifierProviderElement<ReviewHistoryController,
        ReviewHistoryData> with ReviewHistoryControllerRef {
  _ReviewHistoryControllerProviderElement(super.provider);

  @override
  Iterable<CardAnswer> get answers =>
      (origin as ReviewHistoryControllerProvider).answers;
  @override
  DateTimeRange<DateTime> get dateRange =>
      (origin as ReviewHistoryControllerProvider).dateRange;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
