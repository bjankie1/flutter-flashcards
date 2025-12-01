// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck_details_page_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing deck details page operations

@ProviderFor(DeckDetailsPageController)
const deckDetailsPageControllerProvider = DeckDetailsPageControllerProvider._();

/// Controller for managing deck details page operations
final class DeckDetailsPageControllerProvider
    extends $NotifierProvider<DeckDetailsPageController, void> {
  /// Controller for managing deck details page operations
  const DeckDetailsPageControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deckDetailsPageControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deckDetailsPageControllerHash();

  @$internal
  @override
  DeckDetailsPageController create() => DeckDetailsPageController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$deckDetailsPageControllerHash() =>
    r'b968544ffce738871d9a25ac25b0b082b1ce1248';

/// Controller for managing deck details page operations

abstract class _$DeckDetailsPageController extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
