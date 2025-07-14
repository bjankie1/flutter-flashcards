import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_flashcards/src/decks/deck_generate_controller.dart';
import 'package:flutter_flashcards/src/services/gemini_service.dart';
import 'package:flutter_flashcards/src/google/google_doc_reader.dart';

class MockGeminiService extends Mock implements GeminiService {}

class MockGoogleDocReader extends Mock implements GoogleDocReader {}

void main() {
  group('GenerateController', () {
    late GenerateController controller;

    setUp(() {
      final mockGeminiService = MockGeminiService();
      final mockGoogleDocReader = MockGoogleDocReader();
      controller = GenerateController(
        geminiService: mockGeminiService,
        docReader: mockGoogleDocReader,
      );
    });

    test('should initialize with default state', () {
      final state = controller.state;
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

      await controller.setTextContent(testText);

      final state = controller.state;
      expect(state.content, testText);
      expect(state.title, 'Text Input');
      expect(state.source, InputSource.text);
      expect(state.binaryData, null);
      expect(state.fileName, null);
      expect(state.isLoading, false);
      expect(state.error, null);
    });

    test('should clear content correctly', () async {
      // First set some content
      await controller.setTextContent('Test content');

      // Then clear it
      controller.clearContent();

      final state = controller.state;
      expect(state.content, null);
      expect(state.title, null);
      expect(state.source, null);
      expect(state.binaryData, null);
      expect(state.fileName, null);
      expect(state.generatedFlashcards, null);
      expect(state.selectedFlashcardIndexes, isEmpty);
    });

    test('should toggle flashcard selection', () {
      // Mock some generated flashcards
      final mockFlashcards = [
        FlashcardData(question: 'Q1', answer: 'A1'),
        FlashcardData(question: 'Q2', answer: 'A2'),
      ];

      controller.state = controller.state.copyWith(
        generatedFlashcards: mockFlashcards,
        selectedFlashcardIndexes: {0},
      );

      // Toggle selection
      controller.toggleFlashcardSelection(1);

      expect(controller.state.selectedFlashcardIndexes, {0, 1});

      // Toggle again to deselect
      controller.toggleFlashcardSelection(0);

      expect(controller.state.selectedFlashcardIndexes, {1});
    });

    test('should get selected flashcards', () {
      final mockFlashcards = [
        FlashcardData(question: 'Q1', answer: 'A1'),
        FlashcardData(question: 'Q2', answer: 'A2'),
        FlashcardData(question: 'Q3', answer: 'A3'),
      ];

      controller.state = controller.state.copyWith(
        generatedFlashcards: mockFlashcards,
        selectedFlashcardIndexes: {0, 2},
      );

      final selected = controller.selectedFlashcards;
      expect(selected.length, 2);
      expect(selected[0].question, 'Q1');
      expect(selected[1].question, 'Q3');
    });

    test('should handle empty text content', () async {
      expect(
        () => controller.setTextContent(''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should handle whitespace-only text content', () async {
      expect(
        () => controller.setTextContent('   '),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
