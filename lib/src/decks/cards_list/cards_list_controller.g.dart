// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cards_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing cards list operations

@ProviderFor(CardsListController)
const cardsListControllerProvider = CardsListControllerFamily._();

/// Controller for managing cards list operations
final class CardsListControllerProvider
    extends $NotifierProvider<CardsListController, AsyncValue<CardsListData>> {
  /// Controller for managing cards list operations
  const CardsListControllerProvider._({
    required CardsListControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'cardsListControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$cardsListControllerHash();

  @override
  String toString() {
    return r'cardsListControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CardsListController create() => CardsListController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<CardsListData> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<CardsListData>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CardsListControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cardsListControllerHash() =>
    r'ffaf15ac98b0a88f35cce616b0411a44e3ca30b4';

/// Controller for managing cards list operations

final class CardsListControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          CardsListController,
          AsyncValue<CardsListData>,
          AsyncValue<CardsListData>,
          AsyncValue<CardsListData>,
          String
        > {
  const CardsListControllerFamily._()
    : super(
        retry: null,
        name: r'cardsListControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Controller for managing cards list operations

  CardsListControllerProvider call(String deckId) =>
      CardsListControllerProvider._(argument: deckId, from: this);

  @override
  String toString() => r'cardsListControllerProvider';
}

/// Controller for managing cards list operations

abstract class _$CardsListController
    extends $Notifier<AsyncValue<CardsListData>> {
  late final _$args = ref.$arg as String;
  String get deckId => _$args;

  AsyncValue<CardsListData> build(String deckId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref as $Ref<AsyncValue<CardsListData>, AsyncValue<CardsListData>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CardsListData>, AsyncValue<CardsListData>>,
              AsyncValue<CardsListData>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
