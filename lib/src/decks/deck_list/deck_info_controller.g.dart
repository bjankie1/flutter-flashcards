// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck_info_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing deck info data (card count)

@ProviderFor(DeckInfoController)
const deckInfoControllerProvider = DeckInfoControllerFamily._();

/// Controller for managing deck info data (card count)
final class DeckInfoControllerProvider
    extends $NotifierProvider<DeckInfoController, AsyncValue<int>> {
  /// Controller for managing deck info data (card count)
  const DeckInfoControllerProvider._({
    required DeckInfoControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'deckInfoControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$deckInfoControllerHash();

  @override
  String toString() {
    return r'deckInfoControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  DeckInfoController create() => DeckInfoController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<int> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<int>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DeckInfoControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$deckInfoControllerHash() =>
    r'3cac09dd7d1b443dff904a9804d0971446b56cc5';

/// Controller for managing deck info data (card count)

final class DeckInfoControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          DeckInfoController,
          AsyncValue<int>,
          AsyncValue<int>,
          AsyncValue<int>,
          String
        > {
  const DeckInfoControllerFamily._()
    : super(
        retry: null,
        name: r'deckInfoControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Controller for managing deck info data (card count)

  DeckInfoControllerProvider call(String deckId) =>
      DeckInfoControllerProvider._(argument: deckId, from: this);

  @override
  String toString() => r'deckInfoControllerProvider';
}

/// Controller for managing deck info data (card count)

abstract class _$DeckInfoController extends $Notifier<AsyncValue<int>> {
  late final _$args = ref.$arg as String;
  String get deckId => _$args;

  AsyncValue<int> build(String deckId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<AsyncValue<int>, AsyncValue<int>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<int>, AsyncValue<int>>,
              AsyncValue<int>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
