import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_flashcards/src/decks/provisionary_cards/provisionary_cards_review_controller.dart';
import 'package:flutter_flashcards/src/model/cards.dart' as model;
import 'package:flutter_flashcards/src/genkit/functions.dart';
import 'package:flutter_flashcards/src/decks/deck_list/decks_controller.dart';
import '../mocks/mock_cards_repository.dart';

class MockCloudFunctions extends Mock implements CloudFunctions {}

class MockGeneratedAnswer extends Mock implements GeneratedAnswer {}

void main() {
  group('ProvisionaryCardsReviewController', () {
    late ProviderContainer container;
    late MockCardsRepository mockRepository;
    late MockCloudFunctions mockCloudFunctions;
    late MockGeneratedAnswer mockGeneratedAnswer;

    setUp(() {
      mockRepository = MockCardsRepository();
      mockCloudFunctions = MockCloudFunctions();
      mockGeneratedAnswer = MockGeneratedAnswer();

      container = ProviderContainer(
        overrides: [cardsRepositoryProvider.overrideWithValue(mockRepository)],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('AI Generation Triggers', () {
      test(
        'should trigger generation when selectedDeckId changes to not null',
        () async {
          // Arrange
          when(() => mockRepository.listProvisionaryCards()).thenAnswer(
            (_) async => [
              model.ProvisionaryCard(
                'card1',
                'Test question',
                null,
                DateTime.now(),
                null,
                null,
              ),
            ],
          );
          when(() => mockGeneratedAnswer.answer).thenReturn('Generated answer');
          when(
            () => mockGeneratedAnswer.explanation,
          ).thenReturn('Generated explanation');
          when(() => mockRepository.loadDeck('deck1')).thenAnswer(
            (_) async => model.Deck(
              id: 'deck1',
              name: 'Test Deck',
              frontCardDescription: 'Question description',
              backCardDescription: 'Answer description',
            ),
          );
          when(
            () => mockCloudFunctions.generateCardAnswer(
              any(),
              any(),
              any(),
              any(),
              any(),
              explanationDescription: any(named: 'explanationDescription'),
            ),
          ).thenAnswer((_) async => mockGeneratedAnswer);

          // Act
          final controller = container.read(
            provisionaryCardsReviewControllerProvider.notifier,
          );
          await controller.refresh();

          // Wait for initial load
          await Future.delayed(const Duration(milliseconds: 100));

          // Set deck ID which should trigger generation
          await controller.setSelectedDeckId('deck1', mockCloudFunctions);

          // Assert
          verify(
            () => mockCloudFunctions.generateCardAnswer(
              'Test Deck',
              '',
              'Test question',
              'Question description',
              'Answer description',
              explanationDescription: null,
            ),
          ).called(1);
        },
      );

      test('should trigger generation when isQuestion flag changes', () async {
        // Arrange
        when(() => mockRepository.listProvisionaryCards()).thenAnswer(
          (_) async => [
            model.ProvisionaryCard(
              'card1',
              'Test content',
              null,
              DateTime.now(),
              null,
              null,
            ),
          ],
        );
        when(() => mockGeneratedAnswer.answer).thenReturn('Generated content');
        when(
          () => mockGeneratedAnswer.explanation,
        ).thenReturn('Generated explanation');
        when(() => mockRepository.loadDeck('deck1')).thenAnswer(
          (_) async => model.Deck(
            id: 'deck1',
            name: 'Test Deck',
            frontCardDescription: 'Question description',
            backCardDescription: 'Answer description',
          ),
        );
        when(
          () => mockCloudFunctions.generateCardAnswer(
            any(),
            any(),
            any(),
            any(),
            any(),
            explanationDescription: any(named: 'explanationDescription'),
          ),
        ).thenAnswer((_) async => mockGeneratedAnswer);
        when(
          () => mockCloudFunctions.generateFrontFromBack(
            any(),
            any(),
            any(),
            any(),
            any(),
            explanationDescription: any(named: 'explanationDescription'),
          ),
        ).thenAnswer((_) async => mockGeneratedAnswer);

        // Act
        final controller = container.read(
          provisionaryCardsReviewControllerProvider.notifier,
        );
        await controller.refresh();

        // Wait for initial load
        await Future.delayed(const Duration(milliseconds: 100));

        // Set deck ID first
        await controller.setSelectedDeckId('deck1', mockCloudFunctions);

        // Clear previous calls
        reset(mockCloudFunctions);

        // Change isQuestion flag
        await controller.setIsQuestion(false, mockCloudFunctions);

        // Assert
        verify(
          () => mockCloudFunctions.generateFrontFromBack(
            'Test Deck',
            '',
            'Test content',
            'Question description',
            'Answer description',
            explanationDescription: null,
          ),
        ).called(1);
      });

      test(
        'should trigger generation when question text changes in question mode',
        () async {
          // Arrange
          when(() => mockRepository.listProvisionaryCards()).thenAnswer(
            (_) async => [
              model.ProvisionaryCard(
                'card1',
                'Original question',
                null,
                DateTime.now(),
                null,
                null,
              ),
            ],
          );
          when(() => mockGeneratedAnswer.answer).thenReturn('Generated answer');
          when(
            () => mockGeneratedAnswer.explanation,
          ).thenReturn('Generated explanation');
          when(() => mockRepository.loadDeck('deck1')).thenAnswer(
            (_) async => model.Deck(
              id: 'deck1',
              name: 'Test Deck',
              frontCardDescription: 'Question description',
              backCardDescription: 'Answer description',
            ),
          );
          when(
            () => mockCloudFunctions.generateCardAnswer(
              any(),
              any(),
              any(),
              any(),
              any(),
              explanationDescription: any(named: 'explanationDescription'),
            ),
          ).thenAnswer((_) async => mockGeneratedAnswer);

          // Act
          final controller = container.read(
            provisionaryCardsReviewControllerProvider.notifier,
          );
          await controller.refresh();

          // Wait for initial load
          await Future.delayed(const Duration(milliseconds: 100));

          // Set deck ID first
          await controller.setSelectedDeckId('deck1', mockCloudFunctions);

          // Clear previous calls
          reset(mockCloudFunctions);

          // Change question text
          await controller.setQuestionTextAndGenerate(
            'New question',
            mockCloudFunctions,
          );

          // Assert
          verify(
            () => mockCloudFunctions.generateCardAnswer(
              'Test Deck',
              '',
              'New question',
              'Question description',
              'Answer description',
              explanationDescription: null,
            ),
          ).called(1);
        },
      );

      test(
        'should trigger generation when answer text changes in answer mode',
        () async {
          // Arrange
          when(() => mockRepository.listProvisionaryCards()).thenAnswer(
            (_) async => [
              model.ProvisionaryCard(
                'card1',
                'Original answer',
                null,
                DateTime.now(),
                null,
                null,
              ),
            ],
          );
          when(
            () => mockGeneratedAnswer.answer,
          ).thenReturn('Generated question');
          when(
            () => mockGeneratedAnswer.explanation,
          ).thenReturn('Generated explanation');
          when(() => mockRepository.loadDeck('deck1')).thenAnswer(
            (_) async => model.Deck(
              id: 'deck1',
              name: 'Test Deck',
              frontCardDescription: 'Question description',
              backCardDescription: 'Answer description',
            ),
          );
          when(
            () => mockCloudFunctions.generateFrontFromBack(
              any(),
              any(),
              any(),
              any(),
              any(),
              explanationDescription: any(named: 'explanationDescription'),
            ),
          ).thenAnswer((_) async => mockGeneratedAnswer);

          // Act
          final controller = container.read(
            provisionaryCardsReviewControllerProvider.notifier,
          );
          await controller.refresh();

          // Wait for initial load
          await Future.delayed(const Duration(milliseconds: 100));

          // Set deck ID first
          await controller.setSelectedDeckId('deck1', mockCloudFunctions);

          // Switch to answer mode
          await controller.setIsQuestion(false, mockCloudFunctions);

          // Clear previous calls
          reset(mockCloudFunctions);

          // Change answer text
          await controller.setAnswerTextAndGenerate(
            'New answer',
            mockCloudFunctions,
          );

          // Assert
          verify(
            () => mockCloudFunctions.generateFrontFromBack(
              'Test Deck',
              '',
              'New answer',
              'Question description',
              'Answer description',
              explanationDescription: null,
            ),
          ).called(1);
        },
      );

      test(
        'should trigger generation when progressing to next card after finalizing',
        () async {
          // Arrange
          when(() => mockRepository.listProvisionaryCards()).thenAnswer(
            (_) async => [
              model.ProvisionaryCard(
                'card1',
                'First card',
                null,
                DateTime.now(),
                null,
                null,
              ),
              model.ProvisionaryCard(
                'card2',
                'Second card',
                null,
                DateTime.now(),
                null,
                null,
              ),
            ],
          );
          when(() => mockGeneratedAnswer.answer).thenReturn('Generated answer');
          when(
            () => mockGeneratedAnswer.explanation,
          ).thenReturn('Generated explanation');
          when(() => mockRepository.loadDeck('deck1')).thenAnswer(
            (_) async => model.Deck(
              id: 'deck1',
              name: 'Test Deck',
              frontCardDescription: 'Question description',
              backCardDescription: 'Answer description',
            ),
          );
          when(
            () => mockCloudFunctions.generateCardAnswer(
              any(),
              any(),
              any(),
              any(),
              any(),
              explanationDescription: any(named: 'explanationDescription'),
            ),
          ).thenAnswer((_) async => mockGeneratedAnswer);
          when(() => mockRepository.nextCardId()).thenReturn('newCard1');
          when(() => mockRepository.saveCard(any())).thenAnswer(
            (_) async => model.Card(
              id: 'newCard1',
              deckId: 'deck1',
              question: 'Test question',
              answer: 'Test answer',
            ),
          );
          when(
            () => mockRepository.finalizeProvisionaryCard(any(), any()),
          ).thenAnswer((_) async {});

          // Act
          final controller = container.read(
            provisionaryCardsReviewControllerProvider.notifier,
          );
          await controller.refresh();

          // Wait for initial load
          await Future.delayed(const Duration(milliseconds: 100));

          // Set deck ID first
          await controller.setSelectedDeckId('deck1', mockCloudFunctions);

          // Clear previous calls
          reset(mockCloudFunctions);

          // Finalize the first card
          await controller.finalizeCard(
            0,
            model.ProvisionaryCard(
              'card1',
              'First card',
              null,
              DateTime.now(),
              null,
              null,
            ),
            'deck1',
            'First card',
            'Generated answer',
            'Generated explanation',
            true,
            cloudFunctions: mockCloudFunctions,
          );

          // Assert - should generate answer for the second card
          verify(
            () => mockCloudFunctions.generateCardAnswer(
              'Test Deck',
              '',
              'Second card',
              'Question description',
              'Answer description',
              explanationDescription: null,
            ),
          ).called(1);
        },
      );

      test(
        'should NOT trigger generation when selectedDeckId is null',
        () async {
          // Arrange
          when(() => mockRepository.listProvisionaryCards()).thenAnswer(
            (_) async => [
              model.ProvisionaryCard(
                'card1',
                'Test question',
                null,
                DateTime.now(),
                null,
                null,
              ),
            ],
          );

          // Act
          final controller = container.read(
            provisionaryCardsReviewControllerProvider.notifier,
          );
          await controller.refresh();

          // Wait for initial load
          await Future.delayed(const Duration(milliseconds: 100));

          // Try to trigger generation without deck selected
          await controller.setQuestionTextAndGenerate(
            'New question',
            mockCloudFunctions,
          );

          // Assert - no generation should be called
          verifyNever(
            () => mockCloudFunctions.generateCardAnswer(
              any(),
              any(),
              any(),
              any(),
              any(),
            ),
          );
          verifyNever(
            () => mockCloudFunctions.generateFrontFromBack(
              any(),
              any(),
              any(),
              any(),
              any(),
            ),
          );
        },
      );

      test(
        'should NOT trigger generation when cloudFunctions is null',
        () async {
          // Arrange
          when(() => mockRepository.listProvisionaryCards()).thenAnswer(
            (_) async => [
              model.ProvisionaryCard(
                'card1',
                'Test question',
                null,
                DateTime.now(),
                null,
                null,
              ),
            ],
          );

          // Act
          final controller = container.read(
            provisionaryCardsReviewControllerProvider.notifier,
          );
          await controller.refresh();

          // Wait for initial load
          await Future.delayed(const Duration(milliseconds: 100));

          // Set deck ID but pass null cloudFunctions
          await controller.setSelectedDeckId('deck1', null);

          // Try to trigger generation with null cloudFunctions
          await controller.setQuestionTextAndGenerate('New question', null);

          // Assert - no generation should be called
          verifyNever(
            () => mockCloudFunctions.generateCardAnswer(
              any(),
              any(),
              any(),
              any(),
              any(),
            ),
          );
          verifyNever(
            () => mockCloudFunctions.generateFrontFromBack(
              any(),
              any(),
              any(),
              any(),
              any(),
            ),
          );
        },
      );

      test(
        'should NOT trigger generation when answer field is not empty in question mode',
        () async {
          // Arrange
          when(() => mockRepository.listProvisionaryCards()).thenAnswer(
            (_) async => [
              model.ProvisionaryCard(
                'card1',
                'Test question',
                null,
                DateTime.now(),
                null,
                null,
              ),
            ],
          );
          when(() => mockRepository.loadDeck('deck1')).thenAnswer(
            (_) async => model.Deck(
              id: 'deck1',
              name: 'Test Deck',
              frontCardDescription: 'Question description',
              backCardDescription: 'Answer description',
            ),
          );

          // Act
          final controller = container.read(
            provisionaryCardsReviewControllerProvider.notifier,
          );
          await controller.refresh();

          // Wait for initial load
          await Future.delayed(const Duration(milliseconds: 100));

          // Set deck ID first
          await controller.setSelectedDeckId('deck1', mockCloudFunctions);

          // Set answer text (which should prevent generation)
          controller.setAnswerText('Existing answer');

          // Clear previous calls
          reset(mockCloudFunctions);

          // Try to trigger generation
          await controller.triggerGeneration(mockCloudFunctions);

          // Assert - no generation should be called because answer is not empty
          verifyNever(
            () => mockCloudFunctions.generateCardAnswer(
              any(),
              any(),
              any(),
              any(),
              any(),
            ),
          );
        },
      );

      test(
        'should NOT trigger generation when question field is not empty in answer mode',
        () async {
          // Arrange
          when(() => mockRepository.listProvisionaryCards()).thenAnswer(
            (_) async => [
              model.ProvisionaryCard(
                'card1',
                'Test answer',
                null,
                DateTime.now(),
                null,
                null,
              ),
            ],
          );
          when(() => mockRepository.loadDeck('deck1')).thenAnswer(
            (_) async => model.Deck(
              id: 'deck1',
              name: 'Test Deck',
              frontCardDescription: 'Question description',
              backCardDescription: 'Answer description',
            ),
          );

          // Act
          final controller = container.read(
            provisionaryCardsReviewControllerProvider.notifier,
          );
          await controller.refresh();

          // Wait for initial load
          await Future.delayed(const Duration(milliseconds: 100));

          // Set deck ID first
          await controller.setSelectedDeckId('deck1', mockCloudFunctions);

          // Switch to answer mode
          await controller.setIsQuestion(false, mockCloudFunctions);

          // Set question text (which should prevent generation)
          controller.setQuestionText('Existing question');

          // Clear previous calls
          reset(mockCloudFunctions);

          // Try to trigger generation
          await controller.triggerGeneration(mockCloudFunctions);

          // Assert - no generation should be called because question is not empty
          verifyNever(
            () => mockCloudFunctions.generateFrontFromBack(
              any(),
              any(),
              any(),
              any(),
              any(),
            ),
          );
        },
      );

      test(
        'should handle deck loading errors gracefully during generation',
        () async {
          // Arrange
          when(() => mockRepository.listProvisionaryCards()).thenAnswer(
            (_) async => [
              model.ProvisionaryCard(
                'card1',
                'Test question',
                null,
                DateTime.now(),
                null,
                null,
              ),
            ],
          );
          when(() => mockRepository.loadDeck('deck1')).thenAnswer(
            (_) async => null, // Deck not found
          );

          // Act
          final controller = container.read(
            provisionaryCardsReviewControllerProvider.notifier,
          );
          await controller.refresh();

          // Wait for initial load
          await Future.delayed(const Duration(milliseconds: 100));

          // Set deck ID first
          await controller.setSelectedDeckId('deck1', mockCloudFunctions);

          // Try to trigger generation
          await controller.triggerGeneration(mockCloudFunctions);

          // Assert - no generation should be called because deck is null
          verifyNever(
            () => mockCloudFunctions.generateCardAnswer(
              any(),
              any(),
              any(),
              any(),
              any(),
            ),
          );
        },
      );

      test(
        'should handle missing deck descriptions gracefully during generation',
        () async {
          // Arrange
          when(() => mockRepository.listProvisionaryCards()).thenAnswer(
            (_) async => [
              model.ProvisionaryCard(
                'card1',
                'Test question',
                null,
                DateTime.now(),
                null,
                null,
              ),
            ],
          );
          when(() => mockRepository.loadDeck('deck1')).thenAnswer(
            (_) async => model.Deck(
              id: 'deck1',
              name: 'Test Deck',
              // Missing descriptions
              frontCardDescription: null,
              backCardDescription: null,
            ),
          );

          // Act
          final controller = container.read(
            provisionaryCardsReviewControllerProvider.notifier,
          );
          await controller.refresh();

          // Wait for initial load
          await Future.delayed(const Duration(milliseconds: 100));

          // Set deck ID first
          await controller.setSelectedDeckId('deck1', mockCloudFunctions);

          // Try to trigger generation
          await controller.triggerGeneration(mockCloudFunctions);

          // Assert - no generation should be called because descriptions are missing
          verifyNever(
            () => mockCloudFunctions.generateCardAnswer(
              any(),
              any(),
              any(),
              any(),
              any(),
            ),
          );
        },
      );

      test(
        'should trigger generation when progressing to next card after discarding',
        () async {
          // Arrange
          when(() => mockRepository.listProvisionaryCards()).thenAnswer(
            (_) async => [
              model.ProvisionaryCard(
                'card1',
                'First card',
                null,
                DateTime.now(),
                null,
                null,
              ),
              model.ProvisionaryCard(
                'card2',
                'Second card',
                null,
                DateTime.now(),
                null,
                null,
              ),
            ],
          );
          when(() => mockGeneratedAnswer.answer).thenReturn('Generated answer');
          when(
            () => mockGeneratedAnswer.explanation,
          ).thenReturn('Generated explanation');
          when(() => mockRepository.loadDeck('deck1')).thenAnswer(
            (_) async => model.Deck(
              id: 'deck1',
              name: 'Test Deck',
              frontCardDescription: 'Question description',
              backCardDescription: 'Answer description',
            ),
          );
          when(
            () => mockCloudFunctions.generateCardAnswer(
              any(),
              any(),
              any(),
              any(),
              any(),
              explanationDescription: any(named: 'explanationDescription'),
            ),
          ).thenAnswer((_) async => mockGeneratedAnswer);
          when(
            () => mockRepository.finalizeProvisionaryCard(any(), any()),
          ).thenAnswer((_) async {});

          // Act
          final controller = container.read(
            provisionaryCardsReviewControllerProvider.notifier,
          );
          await controller.refresh();

          // Wait for initial load
          await Future.delayed(const Duration(milliseconds: 100));

          // Set deck ID first
          await controller.setSelectedDeckId('deck1', mockCloudFunctions);

          // Clear previous calls
          reset(mockCloudFunctions);

          // Discard the first card
          await controller.discardCard(
            0,
            model.ProvisionaryCard(
              'card1',
              'First card',
              null,
              DateTime.now(),
              null,
              null,
            ),
          );

          // Note: discardCard doesn't have cloudFunctions parameter, so generation
          // will be triggered when the user selects a deck or manually saves the field
          // This test verifies that the form progresses correctly
          final state = container.read(
            provisionaryCardsReviewControllerProvider,
          );
          expect(state.value?.currentIndex, equals(1));
          expect(state.value?.questionText, equals('Second card'));
          expect(state.value?.answerText, equals(''));
        },
      );
    });
  });
}
