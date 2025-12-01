// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck_cards_to_review_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing cards to review count for a specific deck

@ProviderFor(DeckCardsToReviewController)
const deckCardsToReviewControllerProvider =
    DeckCardsToReviewControllerFamily._();

/// Controller for managing cards to review count for a specific deck
final class DeckCardsToReviewControllerProvider
    extends
        $NotifierProvider<
          DeckCardsToReviewController,
          AsyncValue<Map<model.State, int>>
        > {
  /// Controller for managing cards to review count for a specific deck
  const DeckCardsToReviewControllerProvider._({
    required DeckCardsToReviewControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'deckCardsToReviewControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$deckCardsToReviewControllerHash();

  @override
  String toString() {
    return r'deckCardsToReviewControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  DeckCardsToReviewController create() => DeckCardsToReviewController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<Map<model.State, int>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<Map<model.State, int>>>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DeckCardsToReviewControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$deckCardsToReviewControllerHash() =>
    r'e4b57a3e7f78ad00562c1a838fa7157c9dac5083';

/// Controller for managing cards to review count for a specific deck

final class DeckCardsToReviewControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          DeckCardsToReviewController,
          AsyncValue<Map<model.State, int>>,
          AsyncValue<Map<model.State, int>>,
          AsyncValue<Map<model.State, int>>,
          String
        > {
  const DeckCardsToReviewControllerFamily._()
    : super(
        retry: null,
        name: r'deckCardsToReviewControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Controller for managing cards to review count for a specific deck

  DeckCardsToReviewControllerProvider call(String deckId) =>
      DeckCardsToReviewControllerProvider._(argument: deckId, from: this);

  @override
  String toString() => r'deckCardsToReviewControllerProvider';
}

/// Controller for managing cards to review count for a specific deck

abstract class _$DeckCardsToReviewController
    extends $Notifier<AsyncValue<Map<model.State, int>>> {
  late final _$args = ref.$arg as String;
  String get deckId => _$args;

  AsyncValue<Map<model.State, int>> build(String deckId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref
            as $Ref<
              AsyncValue<Map<model.State, int>>,
              AsyncValue<Map<model.State, int>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<Map<model.State, int>>,
                AsyncValue<Map<model.State, int>>
              >,
              AsyncValue<Map<model.State, int>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
