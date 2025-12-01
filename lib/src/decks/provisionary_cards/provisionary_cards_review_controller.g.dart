// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provisionary_cards_review_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing provisionary cards review operations

@ProviderFor(ProvisionaryCardsReviewController)
const provisionaryCardsReviewControllerProvider =
    ProvisionaryCardsReviewControllerProvider._();

/// Controller for managing provisionary cards review operations
final class ProvisionaryCardsReviewControllerProvider
    extends
        $NotifierProvider<
          ProvisionaryCardsReviewController,
          AsyncValue<ProvisionaryCardsReviewData>
        > {
  /// Controller for managing provisionary cards review operations
  const ProvisionaryCardsReviewControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'provisionaryCardsReviewControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$provisionaryCardsReviewControllerHash();

  @$internal
  @override
  ProvisionaryCardsReviewController create() =>
      ProvisionaryCardsReviewController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<ProvisionaryCardsReviewData> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<AsyncValue<ProvisionaryCardsReviewData>>(value),
    );
  }
}

String _$provisionaryCardsReviewControllerHash() =>
    r'8f3afb2e144535e65c90585a2001b876df7d017b';

/// Controller for managing provisionary cards review operations

abstract class _$ProvisionaryCardsReviewController
    extends $Notifier<AsyncValue<ProvisionaryCardsReviewData>> {
  AsyncValue<ProvisionaryCardsReviewData> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<ProvisionaryCardsReviewData>,
              AsyncValue<ProvisionaryCardsReviewData>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<ProvisionaryCardsReviewData>,
                AsyncValue<ProvisionaryCardsReviewData>
              >,
              AsyncValue<ProvisionaryCardsReviewData>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
