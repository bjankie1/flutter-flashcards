// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collaboration_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing collaboration operations

@ProviderFor(CollaborationController)
const collaborationControllerProvider = CollaborationControllerProvider._();

/// Controller for managing collaboration operations
final class CollaborationControllerProvider
    extends
        $NotifierProvider<
          CollaborationController,
          AsyncValue<CollaborationData>
        > {
  /// Controller for managing collaboration operations
  const CollaborationControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'collaborationControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$collaborationControllerHash();

  @$internal
  @override
  CollaborationController create() => CollaborationController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<CollaborationData> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<CollaborationData>>(
        value,
      ),
    );
  }
}

String _$collaborationControllerHash() =>
    r'058d00640f0d242316e89c242e0283a6922b9afd';

/// Controller for managing collaboration operations

abstract class _$CollaborationController
    extends $Notifier<AsyncValue<CollaborationData>> {
  AsyncValue<CollaborationData> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<CollaborationData>,
              AsyncValue<CollaborationData>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<CollaborationData>,
                AsyncValue<CollaborationData>
              >,
              AsyncValue<CollaborationData>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
