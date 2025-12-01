// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_descriptions_dialog_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing card descriptions dialog operations

@ProviderFor(CardDescriptionsDialogController)
const cardDescriptionsDialogControllerProvider =
    CardDescriptionsDialogControllerFamily._();

/// Controller for managing card descriptions dialog operations
final class CardDescriptionsDialogControllerProvider
    extends
        $NotifierProvider<
          CardDescriptionsDialogController,
          AsyncValue<model.Deck>
        > {
  /// Controller for managing card descriptions dialog operations
  const CardDescriptionsDialogControllerProvider._({
    required CardDescriptionsDialogControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'cardDescriptionsDialogControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$cardDescriptionsDialogControllerHash();

  @override
  String toString() {
    return r'cardDescriptionsDialogControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CardDescriptionsDialogController create() =>
      CardDescriptionsDialogController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<model.Deck> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<model.Deck>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CardDescriptionsDialogControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cardDescriptionsDialogControllerHash() =>
    r'ea9f26902ee99df4dbafafbce0748d6415e312f5';

/// Controller for managing card descriptions dialog operations

final class CardDescriptionsDialogControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          CardDescriptionsDialogController,
          AsyncValue<model.Deck>,
          AsyncValue<model.Deck>,
          AsyncValue<model.Deck>,
          String
        > {
  const CardDescriptionsDialogControllerFamily._()
    : super(
        retry: null,
        name: r'cardDescriptionsDialogControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Controller for managing card descriptions dialog operations

  CardDescriptionsDialogControllerProvider call(String deckId) =>
      CardDescriptionsDialogControllerProvider._(argument: deckId, from: this);

  @override
  String toString() => r'cardDescriptionsDialogControllerProvider';
}

/// Controller for managing card descriptions dialog operations

abstract class _$CardDescriptionsDialogController
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
