// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck_details_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing deck details operations

@ProviderFor(DeckDetailsController)
const deckDetailsControllerProvider = DeckDetailsControllerFamily._();

/// Controller for managing deck details operations
final class DeckDetailsControllerProvider
    extends $NotifierProvider<DeckDetailsController, AsyncValue<model.Deck>> {
  /// Controller for managing deck details operations
  const DeckDetailsControllerProvider._({
    required DeckDetailsControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'deckDetailsControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$deckDetailsControllerHash();

  @override
  String toString() {
    return r'deckDetailsControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  DeckDetailsController create() => DeckDetailsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<model.Deck> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<model.Deck>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DeckDetailsControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$deckDetailsControllerHash() =>
    r'351b5eccd28b5deabb3e3c8478573e4576faf8b2';

/// Controller for managing deck details operations

final class DeckDetailsControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          DeckDetailsController,
          AsyncValue<model.Deck>,
          AsyncValue<model.Deck>,
          AsyncValue<model.Deck>,
          String
        > {
  const DeckDetailsControllerFamily._()
    : super(
        retry: null,
        name: r'deckDetailsControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Controller for managing deck details operations

  DeckDetailsControllerProvider call(String deckId) =>
      DeckDetailsControllerProvider._(argument: deckId, from: this);

  @override
  String toString() => r'deckDetailsControllerProvider';
}

/// Controller for managing deck details operations

abstract class _$DeckDetailsController
    extends $Notifier<AsyncValue<model.Deck>> {
  late final _$args = ref.$arg as String;
  String get deckId => _$args;

  AsyncValue<model.Deck> build(String deckId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref as $Ref<AsyncValue<model.Deck>, AsyncValue<model.Deck>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<model.Deck>, AsyncValue<model.Deck>>,
              AsyncValue<model.Deck>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
