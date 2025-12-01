// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck_groups_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing deck groups

@ProviderFor(DeckGroupsController)
const deckGroupsControllerProvider = DeckGroupsControllerProvider._();

/// Controller for managing deck groups
final class DeckGroupsControllerProvider
    extends
        $StreamNotifierProvider<DeckGroupsController, List<model.DeckGroup>> {
  /// Controller for managing deck groups
  const DeckGroupsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deckGroupsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deckGroupsControllerHash();

  @$internal
  @override
  DeckGroupsController create() => DeckGroupsController();
}

String _$deckGroupsControllerHash() =>
    r'fbf23f26ced7a90e2ee8d49fe638ea55ab96bd9d';

/// Controller for managing deck groups

abstract class _$DeckGroupsController
    extends $StreamNotifier<List<model.DeckGroup>> {
  Stream<List<model.DeckGroup>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<AsyncValue<List<model.DeckGroup>>, List<model.DeckGroup>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<model.DeckGroup>>,
                List<model.DeckGroup>
              >,
              AsyncValue<List<model.DeckGroup>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
