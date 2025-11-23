import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_flashcards/src/decks/deck_list/decks_controller.dart';

import 'package:flutter_flashcards/src/model/cards.dart' as model;
import 'package:flutter_flashcards/src/model/repository.dart';

class MockCardsRepository extends Mock implements CardsRepository {}

void main() {
  group('Deck Deletion with Transaction', () {
    late ProviderContainer container;
    late MockCardsRepository mockRepository;

    setUp(() {
      mockRepository = MockCardsRepository();
      container = ProviderContainer(
        overrides: [cardsRepositoryProvider.overrideWithValue(mockRepository)],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test(
      'should delete deck and clean up group references in transaction',
      () async {
        // Arrange
        const deckId = 'test-deck-id';
        const groupId = 'test-group-id';

        final testGroup = model.DeckGroup(
          id: groupId,
          name: 'Test Group',
          description: 'Test Group Description',
          decks: {deckId},
        );

        // Mock repository methods
        when(
          () => mockRepository.loadDeckGroups(),
        ).thenAnswer((_) async => [testGroup]);
        when(
          () => mockRepository.removeDeckFromGroup(deckId, groupId),
        ).thenAnswer((_) async {});
        when(() => mockRepository.deleteDeck(deckId)).thenAnswer((_) async {});
        when(() => mockRepository.runTransaction(any())).thenAnswer((
          invocation,
        ) async {
          final operations =
              invocation.positionalArguments[0] as Future<void> Function();
          await operations();
        });
        when(() => mockRepository.loadDecks()).thenAnswer((_) async => []);

        // Act
        final controller = container.read(decksControllerProvider.notifier);
        await controller.deleteDeck(deckId);

        // Assert
        verify(
          () => mockRepository.runTransaction(any()),
        ).called(1); // Called once during deletion
        verify(
          () => mockRepository.loadDeckGroups(),
        ).called(1); // Called during transaction
        verify(
          () => mockRepository.removeDeckFromGroup(deckId, groupId),
        ).called(1);
        verify(() => mockRepository.deleteDeck(deckId)).called(1);
      },
    );

    test('should handle deck not in any groups', () async {
      // Arrange
      const deckId = 'test-deck-id';

      final testGroup = model.DeckGroup(
        id: 'test-group-id',
        name: 'Test Group',
        description: 'Test Group Description',
        decks: {'other-deck-id'}, // Different deck
      );

      // Mock repository methods
      when(
        () => mockRepository.loadDeckGroups(),
      ).thenAnswer((_) async => [testGroup]);
      when(() => mockRepository.deleteDeck(deckId)).thenAnswer((_) async {});
      when(() => mockRepository.runTransaction(any())).thenAnswer((
        invocation,
      ) async {
        final operations =
            invocation.positionalArguments[0] as Future<void> Function();
        await operations();
      });
      when(() => mockRepository.loadDecks()).thenAnswer((_) async => []);

      // Act
      final controller = container.read(decksControllerProvider.notifier);
      await controller.deleteDeck(deckId);

      // Assert
      verify(
        () => mockRepository.runTransaction(any()),
      ).called(1); // Called once during deletion
      verify(
        () => mockRepository.loadDeckGroups(),
      ).called(1); // Called during transaction
      verifyNever(() => mockRepository.removeDeckFromGroup(any(), any()));
      verify(() => mockRepository.deleteDeck(deckId)).called(1);
    });

    test('should handle deck in multiple groups', () async {
      // Arrange
      const deckId = 'test-deck-id';

      final group1 = model.DeckGroup(
        id: 'group-1',
        name: 'Group 1',
        decks: {deckId, 'other-deck-1'},
      );

      final group2 = model.DeckGroup(
        id: 'group-2',
        name: 'Group 2',
        decks: {deckId, 'other-deck-2'},
      );

      // Mock repository methods
      when(
        () => mockRepository.loadDeckGroups(),
      ).thenAnswer((_) async => [group1, group2]);
      when(
        () => mockRepository.removeDeckFromGroup(deckId, 'group-1'),
      ).thenAnswer((_) async {});
      when(
        () => mockRepository.removeDeckFromGroup(deckId, 'group-2'),
      ).thenAnswer((_) async {});
      when(() => mockRepository.deleteDeck(deckId)).thenAnswer((_) async {});
      when(() => mockRepository.runTransaction(any())).thenAnswer((
        invocation,
      ) async {
        final operations =
            invocation.positionalArguments[0] as Future<void> Function();
        await operations();
      });
      when(() => mockRepository.loadDecks()).thenAnswer((_) async => []);

      // Act
      final controller = container.read(decksControllerProvider.notifier);
      await controller.deleteDeck(deckId);

      // Assert
      verify(
        () => mockRepository.runTransaction(any()),
      ).called(1); // Called once during deletion
      verify(
        () => mockRepository.loadDeckGroups(),
      ).called(1); // Called during transaction
      verify(
        () => mockRepository.removeDeckFromGroup(deckId, 'group-1'),
      ).called(1);
      verify(
        () => mockRepository.removeDeckFromGroup(deckId, 'group-2'),
      ).called(1);
      verify(() => mockRepository.deleteDeck(deckId)).called(1);
    });

    test('should rollback transaction on error', () async {
      // Arrange
      const deckId = 'test-deck-id';

      final testGroup = model.DeckGroup(
        id: 'test-group-id',
        name: 'Test Group',
        decks: {deckId},
      );

      // Mock repository methods
      when(
        () => mockRepository.loadDeckGroups(),
      ).thenAnswer((_) async => [testGroup]);
      when(
        () => mockRepository.removeDeckFromGroup(deckId, 'test-group-id'),
      ).thenAnswer((_) async {});
      when(
        () => mockRepository.deleteDeck(deckId),
      ).thenThrow(Exception('Delete failed'));
      when(() => mockRepository.runTransaction(any())).thenAnswer((
        invocation,
      ) async {
        final operations =
            invocation.positionalArguments[0] as Future<void> Function();
        await operations();
      });
      when(() => mockRepository.loadDecks()).thenAnswer((_) async => []);

      // Act & Assert
      final controller = container.read(decksControllerProvider.notifier);
      expect(() => controller.deleteDeck(deckId), throwsA(isA<Exception>()));

      // Verify transaction was called but operations failed
      verify(
        () => mockRepository.runTransaction(any()),
      ).called(1); // Called once during deletion attempt
    });

    test('should handle group with null decks property', () async {
      // Arrange
      const deckId = 'test-deck-id';

      final testGroup = model.DeckGroup(
        id: 'test-group-id',
        name: 'Test Group',
        decks: null, // Null decks property
      );

      // Mock repository methods
      when(
        () => mockRepository.loadDeckGroups(),
      ).thenAnswer((_) async => [testGroup]);
      when(() => mockRepository.deleteDeck(deckId)).thenAnswer((_) async {});
      when(() => mockRepository.runTransaction(any())).thenAnswer((
        invocation,
      ) async {
        final operations =
            invocation.positionalArguments[0] as Future<void> Function();
        await operations();
      });
      when(() => mockRepository.loadDecks()).thenAnswer((_) async => []);

      // Act
      final controller = container.read(decksControllerProvider.notifier);
      await controller.deleteDeck(deckId);

      // Assert
      verify(
        () => mockRepository.runTransaction(any()),
      ).called(1); // Called once during deletion
      verify(
        () => mockRepository.loadDeckGroups(),
      ).called(1); // Called during transaction
      verifyNever(() => mockRepository.removeDeckFromGroup(any(), any()));
      verify(() => mockRepository.deleteDeck(deckId)).called(1);
    });
  });
}
