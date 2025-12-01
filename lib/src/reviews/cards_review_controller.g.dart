// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cards_review_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing card review operations

@ProviderFor(CardsReviewController)
const cardsReviewControllerProvider = CardsReviewControllerFamily._();

/// Controller for managing card review operations
final class CardsReviewControllerProvider
    extends $NotifierProvider<CardsReviewController, ReviewState> {
  /// Controller for managing card review operations
  const CardsReviewControllerProvider._({
    required CardsReviewControllerFamily super.from,
    required StudySession super.argument,
  }) : super(
         retry: null,
         name: r'cardsReviewControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$cardsReviewControllerHash();

  @override
  String toString() {
    return r'cardsReviewControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CardsReviewController create() => CardsReviewController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReviewState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReviewState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CardsReviewControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cardsReviewControllerHash() =>
    r'897277a460faf3dad0e298d312b3e111563f84f2';

/// Controller for managing card review operations

final class CardsReviewControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          CardsReviewController,
          ReviewState,
          ReviewState,
          ReviewState,
          StudySession
        > {
  const CardsReviewControllerFamily._()
    : super(
        retry: null,
        name: r'cardsReviewControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Controller for managing card review operations

  CardsReviewControllerProvider call(StudySession session) =>
      CardsReviewControllerProvider._(argument: session, from: this);

  @override
  String toString() => r'cardsReviewControllerProvider';
}

/// Controller for managing card review operations

abstract class _$CardsReviewController extends $Notifier<ReviewState> {
  late final _$args = ref.$arg as StudySession;
  StudySession get session => _$args;

  ReviewState build(StudySession session);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<ReviewState, ReviewState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ReviewState, ReviewState>,
              ReviewState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
