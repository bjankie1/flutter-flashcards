import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_flashcards/src/decks/provisionary_cards/provisionary_cards_review_controller.dart';
import 'package:flutter_flashcards/src/model/cards.dart' as model;
import 'package:flutter_flashcards/src/decks/deck_list/decks_controller.dart';
import '../mocks/mock_cards_repository.dart';
import 'package:flutter_flashcards/src/model/card.dart' as card_model;

class FakeCard extends Fake implements card_model.Card {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeCard());
  });

  late MockCardsRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockCardsRepository();
    container = ProviderContainer(
      overrides: [cardsRepositoryProvider.overrideWithValue(mockRepository)],
    );
    addTearDown(container.dispose);
  });

  group('ProvisionaryCardsReviewController', () {
    final now = DateTime(2020, 1, 1);
    final provisionaryCards = [
      model.ProvisionaryCard('1', 'Card 1', null, now, null, null),
      model.ProvisionaryCard('2', 'Card 2', null, now, null, null),
    ];

    test('loads provisionary cards and sets initial state', () async {
      when(
        () => mockRepository.listProvisionaryCards(),
      ).thenAnswer((_) async => provisionaryCards);

      final asyncValue = container.read(
        provisionaryCardsReviewControllerProvider,
      );
      expect(asyncValue.isLoading, true);

      await container
          .read(provisionaryCardsReviewControllerProvider.notifier)
          .refresh();
      final state = container
          .read(provisionaryCardsReviewControllerProvider)
          .requireValue;
      expect(state.provisionaryCards, provisionaryCards);
      expect(state.currentIndex, 0);
      expect(state.finalizedCardsIndexes, isEmpty);
      expect(state.discardedCardsIndexes, isEmpty);
    });

    test('finalizes a card and updates state', () async {
      when(
        () => mockRepository.listProvisionaryCards(),
      ).thenAnswer((_) async => provisionaryCards);
      when(() => mockRepository.nextCardId()).thenReturn('cardId');
      when(() => mockRepository.saveCard(any())).thenAnswer((invocation) async {
        final arg = invocation.positionalArguments.first as card_model.Card;
        return arg;
      });
      when(
        () => mockRepository.finalizeProvisionaryCard(any(), any()),
      ).thenAnswer((_) async {});

      await container
          .read(provisionaryCardsReviewControllerProvider.notifier)
          .refresh();
      final notifier = container.read(
        provisionaryCardsReviewControllerProvider.notifier,
      );
      final stateBefore = container
          .read(provisionaryCardsReviewControllerProvider)
          .requireValue;
      expect(stateBefore.finalizedCardsIndexes, isEmpty);

      await notifier.finalizeCard(
        0,
        provisionaryCards[0],
        'deck',
        'Q',
        'A',
        'Explanation',
        true,
      );
      final state = container
          .read(provisionaryCardsReviewControllerProvider)
          .requireValue;
      expect(state.finalizedCardsIndexes, contains(0));
      expect(state.currentIndex, 1);
      expect(state.lastDeckId, 'deck');
      expect(state.doubleSided, true);
    });

    test('discards a card and updates state', () async {
      when(
        () => mockRepository.listProvisionaryCards(),
      ).thenAnswer((_) async => provisionaryCards);
      when(
        () => mockRepository.finalizeProvisionaryCard(any(), any()),
      ).thenAnswer((_) async {});

      await container
          .read(provisionaryCardsReviewControllerProvider.notifier)
          .refresh();
      final notifier = container.read(
        provisionaryCardsReviewControllerProvider.notifier,
      );
      await notifier.discardCard(0, provisionaryCards[0]);
      final state = container
          .read(provisionaryCardsReviewControllerProvider)
          .requireValue;
      expect(state.discardedCardsIndexes, contains(0));
      expect(state.currentIndex, 1);
    });

    test('snooze moves to next card', () async {
      when(
        () => mockRepository.listProvisionaryCards(),
      ).thenAnswer((_) async => provisionaryCards);
      await container
          .read(provisionaryCardsReviewControllerProvider.notifier)
          .refresh();
      final notifier = container.read(
        provisionaryCardsReviewControllerProvider.notifier,
      );
      notifier.snoozeCard();
      final state = container
          .read(provisionaryCardsReviewControllerProvider)
          .requireValue;
      expect(state.currentIndex, 1);
    });

    test('handles empty provisionary cards', () async {
      when(
        () => mockRepository.listProvisionaryCards(),
      ).thenAnswer((_) async => <model.ProvisionaryCard>[]);
      await container
          .read(provisionaryCardsReviewControllerProvider.notifier)
          .refresh();
      final state = container
          .read(provisionaryCardsReviewControllerProvider)
          .requireValue;
      expect(state.provisionaryCards, isEmpty);
      expect(state.currentIndex, -1);
    });

    test('handles error from repository', () async {
      when(
        () => mockRepository.listProvisionaryCards(),
      ).thenThrow(Exception('fail'));
      await container
          .read(provisionaryCardsReviewControllerProvider.notifier)
          .refresh();
      final asyncValue = container.read(
        provisionaryCardsReviewControllerProvider,
      );
      expect(asyncValue.hasError, true);
    });
  });
}
