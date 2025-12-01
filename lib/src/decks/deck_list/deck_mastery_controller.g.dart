// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck_mastery_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing deck mastery data

@ProviderFor(DeckMasteryController)
const deckMasteryControllerProvider = DeckMasteryControllerFamily._();

/// Controller for managing deck mastery data
final class DeckMasteryControllerProvider
    extends
        $NotifierProvider<
          DeckMasteryController,
          AsyncValue<Map<CardMastery, int>>
        > {
  /// Controller for managing deck mastery data
  const DeckMasteryControllerProvider._({
    required DeckMasteryControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'deckMasteryControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$deckMasteryControllerHash();

  @override
  String toString() {
    return r'deckMasteryControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  DeckMasteryController create() => DeckMasteryController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<Map<CardMastery, int>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<Map<CardMastery, int>>>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DeckMasteryControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$deckMasteryControllerHash() =>
    r'0dba1d92484a835dd1ff632ecbc9ffbf13c72993';

/// Controller for managing deck mastery data

final class DeckMasteryControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          DeckMasteryController,
          AsyncValue<Map<CardMastery, int>>,
          AsyncValue<Map<CardMastery, int>>,
          AsyncValue<Map<CardMastery, int>>,
          String
        > {
  const DeckMasteryControllerFamily._()
    : super(
        retry: null,
        name: r'deckMasteryControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Controller for managing deck mastery data

  DeckMasteryControllerProvider call(String deckId) =>
      DeckMasteryControllerProvider._(argument: deckId, from: this);

  @override
  String toString() => r'deckMasteryControllerProvider';
}

/// Controller for managing deck mastery data

abstract class _$DeckMasteryController
    extends $Notifier<AsyncValue<Map<CardMastery, int>>> {
  late final _$args = ref.$arg as String;
  String get deckId => _$args;

  AsyncValue<Map<CardMastery, int>> build(String deckId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref
            as $Ref<
              AsyncValue<Map<CardMastery, int>>,
              AsyncValue<Map<CardMastery, int>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<Map<CardMastery, int>>,
                AsyncValue<Map<CardMastery, int>>
              >,
              AsyncValue<Map<CardMastery, int>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
