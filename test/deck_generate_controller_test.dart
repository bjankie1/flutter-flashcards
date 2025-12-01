import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_flashcards/src/decks/deck_generate_controller.dart';
import 'package:flutter_flashcards/src/services/gemini_service.dart';
import 'package:flutter_flashcards/src/google/google_doc_reader.dart';

class MockGeminiService extends Mock implements GeminiService {}

class MockGoogleDocReader extends Mock implements GoogleDocReader {}

void main() {
  group('GenerateController', () {
    late ProviderContainer container;
    late MockGeminiService mockGeminiService;
    late MockGoogleDocReader mockGoogleDocReader;

    setUp(() {
      mockGeminiService = MockGeminiService();
      mockGoogleDocReader = MockGoogleDocReader();
      container = ProviderContainer(
        overrides: [
          geminiServiceProvider.overrideWithValue(mockGeminiService),
          googleDocReaderProvider.overrideWithValue(mockGoogleDocReader),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    GenerateController getController() {
      return container.read(generateControllerProvider.notifier);
    }

    GenerateState getState() {
      return container.read(generateControllerProvider);
    }

    test('should initialize with default state', () {
      final state = getState();
      expect(state.isLoading, false);
      expect(state.error, null);
      expect(state.content, null);
      expect(state.title, null);
      expect(state.source, null);
      expect(state.generatedFlashcards, null);
      expect(state.isGeneratingFlashcards, false);
      expect(state.selectedFlashcardIndexes, isEmpty);
      expect(state.binaryData, null);
      expect(state.fileName, null);
    });

    test('should set text content correctly', () async {
      const testText = 'This is a test text for flashcard generation';
      final controller = getController();

      await controller.setTextContent(testText);

      final state = getState();
      expect(state.content, testText);
      expect(state.title, 'Text Input');
      expect(state.source, InputSource.text);
      expect(state.binaryData, null);
      expect(state.fileName, null);
      expect(state.isLoading, false);
      expect(state.error, null);
    });

    test('should clear content correctly', () async {
      final controller = getController();
      // First set some content
      await controller.setTextContent('Test content');

      // Then clear it
      controller.clearContent();

      final state = getState();
      expect(state.content, null);
      expect(state.title, null);
      expect(state.source, null);
      expect(state.binaryData, null);
      expect(state.fileName, null);
      expect(state.generatedFlashcards, null);
      expect(state.selectedFlashcardIndexes, isEmpty);
    });

    test('should toggle flashcard selection', () {
      final controller = getController();
      // Mock some generated flashcards
      final mockFlashcards = [
        FlashcardData(question: 'Q1', answer: 'A1'),
        FlashcardData(question: 'Q2', answer: 'A2'),
      ];

      controller.debugState = getState().copyWith(
        generatedFlashcards: mockFlashcards,
        selectedFlashcardIndexes: {0},
      );

      // Toggle selection
      controller.toggleFlashcardSelection(1);

      expect(getState().selectedFlashcardIndexes, {0, 1});

      // Toggle again to deselect
      controller.toggleFlashcardSelection(0);

      expect(getState().selectedFlashcardIndexes, {1});
    });

    test('should get selected flashcards', () {
      final controller = getController();
      final mockFlashcards = [
        FlashcardData(question: 'Q1', answer: 'A1'),
        FlashcardData(question: 'Q2', answer: 'A2'),
        FlashcardData(question: 'Q3', answer: 'A3'),
      ];

      controller.debugState = getState().copyWith(
        generatedFlashcards: mockFlashcards,
        selectedFlashcardIndexes: {0, 2},
      );

      final selected = controller.selectedFlashcards;
      expect(selected.length, 2);
      expect(selected[0].question, 'Q1');
      expect(selected[1].question, 'Q3');
    });

    test('should handle empty text content', () async {
      final controller = getController();
      expect(
        () => controller.setTextContent(''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should handle whitespace-only text content', () async {
      final controller = getController();
      expect(
        () => controller.setTextContent('   '),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
