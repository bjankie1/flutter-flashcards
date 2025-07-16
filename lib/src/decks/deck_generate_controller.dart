import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../services/gemini_service.dart';
import '../google/google_doc_reader.dart';
import 'package:logger/logger.dart';

enum InputSource { text, pdf, image, googleDoc }

class GenerateState {
  final bool isLoading;
  final String? error;
  final String? content;
  final String? title;
  final InputSource? source;
  final List<FlashcardData>? generatedFlashcards;
  final bool isGeneratingFlashcards;
  final Set<int> selectedFlashcardIndexes;
  final Uint8List? binaryData;
  final String? fileName;

  static const Object _unset = Object();

  GenerateState({
    this.isLoading = false,
    this.error,
    this.content,
    this.title,
    this.source,
    this.generatedFlashcards,
    this.isGeneratingFlashcards = false,
    Set<int>? selectedFlashcardIndexes,
    this.binaryData,
    this.fileName,
  }) : selectedFlashcardIndexes = selectedFlashcardIndexes ?? const {};

  GenerateState copyWith({
    bool? isLoading,
    Object? error = _unset,
    Object? content = _unset,
    Object? title = _unset,
    Object? source = _unset,
    Object? generatedFlashcards = _unset,
    bool? isGeneratingFlashcards,
    Set<int>? selectedFlashcardIndexes,
    Object? binaryData = _unset,
    Object? fileName = _unset,
  }) {
    return GenerateState(
      isLoading: isLoading ?? this.isLoading,
      error: error == _unset ? this.error : error as String?,
      content: content == _unset ? this.content : content as String?,
      title: title == _unset ? this.title : title as String?,
      source: source == _unset ? this.source : source as InputSource?,
      generatedFlashcards: generatedFlashcards == _unset
          ? this.generatedFlashcards
          : generatedFlashcards as List<FlashcardData>?,
      isGeneratingFlashcards:
          isGeneratingFlashcards ?? this.isGeneratingFlashcards,
      selectedFlashcardIndexes:
          selectedFlashcardIndexes ?? this.selectedFlashcardIndexes,
      binaryData: binaryData == _unset
          ? this.binaryData
          : binaryData as Uint8List?,
      fileName: fileName == _unset ? this.fileName : fileName as String?,
    );
  }
}

class GenerateController extends StateNotifier<GenerateState> {
  final GeminiService _geminiService;
  final GoogleDocReader _docReader;
  final Logger _log = Logger();

  GenerateController({GeminiService? geminiService, GoogleDocReader? docReader})
    : _geminiService = geminiService ?? GeminiService(useEmulator: false),
      _docReader = docReader ?? GoogleDocReader(),
      super(GenerateState());

  Future<void> setTextContent(String text) async {
    if (text.trim().isEmpty) {
      throw ArgumentError('Text content cannot be empty.');
    }

    state = state.copyWith(
      isLoading: true,
      error: null,
      source: InputSource.text,
    );

    try {
      state = state.copyWith(
        isLoading: false,
        content: text,
        title: 'Text Input',
        selectedFlashcardIndexes: const {},
        binaryData: null,
        fileName: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> pickAndProcessFile(InputSource source) async {
    _log.i('pickAndProcessFile called with source: $source');
    state = state.copyWith(isLoading: true, error: null);

    try {
      FilePickerResult? result;

      switch (source) {
        case InputSource.pdf:
          _log.i('Opening file picker for PDF');
          try {
            // Try a simpler approach first - just pick any file
            _log.i('Attempting to pick PDF file...');
            _log.i('About to call FilePicker.platform.pickFiles...');
            result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['pdf'],
              withData: true, // Ensure we get the file data
            );
            _log.i('FilePicker.platform.pickFiles completed');
            _log.i('PDF picker result: ${result != null ? 'success' : 'null'}');
            if (result != null) {
              _log.i('Number of files selected: ${result.files.length}');
            } else {
              _log.i(
                'No file selected - user likely canceled or dialog failed to open',
              );
            }
          } catch (e) {
            _log.e('Error in PDF file picker', error: e);
            throw Exception('Failed to open file picker: $e');
          }
          break;
        case InputSource.image:
          _log.i('Opening file picker for image');
          try {
            _log.i('Attempting to pick image file...');
            _log.i('About to call FilePicker.platform.pickFiles...');
            result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
              withData: true, // Ensure we get the file data
            );
            _log.i('FilePicker.platform.pickFiles completed');
            _log.i(
              'Image picker result: ${result != null ? 'success' : 'null'}',
            );
            if (result != null) {
              _log.i('Number of files selected: ${result.files.length}');
            } else {
              _log.i(
                'No file selected - user likely canceled or dialog failed to open',
              );
            }
          } catch (e) {
            _log.e('Error in image file picker', error: e);
            throw Exception('Failed to open file picker: $e');
          }
          break;
        default:
          throw ArgumentError('Unsupported file type');
      }

      if (result == null) {
        _log.w('File picker returned null (user likely canceled)');
        state = state.copyWith(isLoading: false);
        return;
      }

      if (result.files.isEmpty) {
        _log.w('File picker returned empty files list');
        state = state.copyWith(isLoading: false);
        return;
      }

      final file = result.files.first;
      _log.i(
        'File selected: name="${file.name}", size="${file.size}" bytes, path="${file.path}"',
      );

      final bytes = file.bytes;

      if (bytes == null) {
        _log.e('Failed to read file data - bytes is null');
        throw Exception('Failed to read file data');
      }

      _log.i('File data read successfully: ${bytes.length} bytes');
      state = state.copyWith(
        isLoading: false,
        source: source,
        binaryData: bytes,
        fileName: file.name,
        title: file.name,
        content: null, // No preview for binary files
        selectedFlashcardIndexes: const {},
      );
      _log.i(
        'State updated after PDF selection: binaryData set, fileName="${file.name}"',
      );
    } catch (e) {
      _log.e('Error in pickAndProcessFile', error: e);
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> processGoogleDoc(String docId) async {
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
        source: InputSource.googleDoc,
        selectedFlashcardIndexes: const {},
        binaryData: null,
        fileName: null,
      );
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
      binaryData: null,
      fileName: null,
      source: null,
      title: null,
    );
  }

  Future<void> generateFlashcards({
    String? deckName,
    String? deckDescription,
    String? frontCardDescription,
    String? backCardDescription,
    String? explanationDescription,
  }) async {
    final content = state.content;
    final binaryData = state.binaryData;
    final source = state.source;

    if (source == null) {
      throw Exception('No input source selected');
    }

    if (source == InputSource.text || source == InputSource.googleDoc) {
      if (content == null || content.trim().isEmpty) {
        throw Exception('No content loaded');
      }
    } else if (source == InputSource.pdf || source == InputSource.image) {
      if (binaryData == null) {
        throw Exception('No file loaded');
      }
    }

    state = state.copyWith(isGeneratingFlashcards: true, error: null);

    try {
      List<FlashcardData> flashcards;

      if (source == InputSource.text || source == InputSource.googleDoc) {
        flashcards = await _geminiService.generateFlashcards(
          content!,
          deckName: deckName,
          deckDescription: deckDescription,
          frontCardDescription: frontCardDescription,
          backCardDescription: backCardDescription,
          explanationDescription: explanationDescription,
        );
      } else {
        // For PDF and image, we'll need to implement binary data processing
        // For now, we'll use a placeholder that will be implemented in GeminiService
        flashcards = await _geminiService.generateFlashcardsFromBinary(
          binaryData!,
          source == InputSource.pdf ? 'pdf' : 'image',
          state.fileName ?? 'Unknown file',
          deckName: deckName,
          deckDescription: deckDescription,
          frontCardDescription: frontCardDescription,
          backCardDescription: backCardDescription,
          explanationDescription: explanationDescription,
        );
      }

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

  // Reset the controller to initial state
  void reset() {
    _log.i('Resetting GenerateController to initial state');
    state = GenerateState();
  }

  // Test method to check if file picker works at all
  Future<void> testFilePicker() async {
    _log.i('Testing file picker functionality...');
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        withData: true,
      );
      _log.i('File picker test result: ${result != null ? 'success' : 'null'}');
      if (result != null) {
        _log.i('Test selected file: ${result.files.first.name}');
      }
    } catch (e) {
      _log.e('File picker test failed', error: e);
    }
  }
}

final generateControllerProvider =
    StateNotifierProvider<GenerateController, GenerateState>((ref) {
      return GenerateController();
    });
