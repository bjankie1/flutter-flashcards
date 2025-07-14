import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../google/google_doc_reader.dart';
import '../services/gemini_service.dart';

class GoogleDocImportState {
  final bool isLoading;
  final String? error;
  final String? content;
  final String? title;
  final List<FlashcardData>? generatedFlashcards;
  final bool isGeneratingFlashcards;

  const GoogleDocImportState({
    this.isLoading = false,
    this.error,
    this.content,
    this.title,
    this.generatedFlashcards,
    this.isGeneratingFlashcards = false,
  });

  GoogleDocImportState copyWith({
    bool? isLoading,
    String? error,
    String? content,
    String? title,
    List<FlashcardData>? generatedFlashcards,
    bool? isGeneratingFlashcards,
  }) {
    return GoogleDocImportState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      content: content ?? this.content,
      title: title ?? this.title,
      generatedFlashcards: generatedFlashcards ?? this.generatedFlashcards,
      isGeneratingFlashcards:
          isGeneratingFlashcards ?? this.isGeneratingFlashcards,
    );
  }
}

class GoogleDocImportController extends StateNotifier<GoogleDocImportState> {
  final GoogleDocReader _docReader;
  final GeminiService _geminiService;

  GoogleDocImportController({
    GoogleDocReader? docReader,
    GeminiService? geminiService,
  }) : _docReader = docReader ?? GoogleDocReader(),
       _geminiService = geminiService ?? GeminiService(useEmulator: false),
       super(const GoogleDocImportState());

  Future<String> processGoogleDoc(String docId) async {
    if (docId.trim().isEmpty) {
      throw ArgumentError('Document ID cannot be empty.');
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final docData = await _docReader.readDoc(docId);
      state = state.copyWith(
        isLoading: false,
        content: docData.content,
        title: docData.title,
      );
      return docData.content;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearContent() {
    state = state.copyWith(content: null, generatedFlashcards: null);
  }

  Future<void> generateFlashcards() async {
    final content = state.content;
    if (content == null || content.trim().isEmpty) {
      throw Exception('No document content loaded');
    }

    state = state.copyWith(isGeneratingFlashcards: true, error: null);

    try {
      final flashcards = await _geminiService.generateFlashcards(content);
      state = state.copyWith(
        isGeneratingFlashcards: false,
        generatedFlashcards: flashcards,
      );
    } catch (e) {
      state = state.copyWith(
        isGeneratingFlashcards: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  void clearGeneratedFlashcards() {
    state = state.copyWith(generatedFlashcards: null);
  }
}

final googleDocImportControllerProvider =
    StateNotifierProvider<GoogleDocImportController, GoogleDocImportState>((
      ref,
    ) {
      return GoogleDocImportController();
    });
