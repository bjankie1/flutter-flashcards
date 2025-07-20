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
  final Set<int> selectedFlashcardIndexes;

  GoogleDocImportState({
    this.isLoading = false,
    this.error,
    this.content,
    this.title,
    this.generatedFlashcards,
    this.isGeneratingFlashcards = false,
    Set<int>? selectedFlashcardIndexes,
  }) : selectedFlashcardIndexes = selectedFlashcardIndexes ?? const {};

  GoogleDocImportState copyWith({
    bool? isLoading,
    String? error,
    String? content,
    String? title,
    List<FlashcardData>? generatedFlashcards,
    bool? isGeneratingFlashcards,
    Set<int>? selectedFlashcardIndexes,
  }) {
    return GoogleDocImportState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      content: content ?? this.content,
      title: title ?? this.title,
      generatedFlashcards: generatedFlashcards ?? this.generatedFlashcards,
      isGeneratingFlashcards:
          isGeneratingFlashcards ?? this.isGeneratingFlashcards,
      selectedFlashcardIndexes:
          selectedFlashcardIndexes ?? this.selectedFlashcardIndexes,
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
       super(GoogleDocImportState());

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
        selectedFlashcardIndexes: const {},
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
    state = state.copyWith(
      content: null,
      generatedFlashcards: null,
      selectedFlashcardIndexes: const {},
    );
  }

  Future<void> generateFlashcards() async {
    final content = state.content;
    if (content == null || content.trim().isEmpty) {
      throw Exception('No document content loaded');
    }

    state = state.copyWith(isGeneratingFlashcards: true, error: null);

    try {
      final flashcards = await _geminiService.generateFlashcards(content);
      final allIndexes = Set<int>.from(
        List.generate(flashcards.length, (i) => i),
      );
      state = state.copyWith(
        isGeneratingFlashcards: false,
        generatedFlashcards: flashcards,
        selectedFlashcardIndexes: allIndexes,
      );
    } catch (e) {
      state = state.copyWith(
        isGeneratingFlashcards: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  void toggleFlashcardSelection(int index) {
    final selected = Set<int>.from(state.selectedFlashcardIndexes);
    if (selected.contains(index)) {
      selected.remove(index);
    } else {
      selected.add(index);
    }
    state = state.copyWith(selectedFlashcardIndexes: selected);
  }

  List<FlashcardData> get selectedFlashcards {
    final cards = state.generatedFlashcards;
    if (cards == null) return [];
    return [
      for (var i = 0; i < cards.length; i++)
        if (state.selectedFlashcardIndexes.contains(i)) cards[i],
    ];
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
