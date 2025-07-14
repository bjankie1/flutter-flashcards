import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../google/google_doc_reader.dart';

class GoogleDocImportState {
  final bool isLoading;
  final String? error;
  final String? content;

  const GoogleDocImportState({
    this.isLoading = false,
    this.error,
    this.content,
  });

  GoogleDocImportState copyWith({
    bool? isLoading,
    String? error,
    String? content,
  }) {
    return GoogleDocImportState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      content: content ?? this.content,
    );
  }
}

class GoogleDocImportController extends StateNotifier<GoogleDocImportState> {
  final GoogleDocReader _docReader;

  GoogleDocImportController({GoogleDocReader? docReader})
    : _docReader = docReader ?? GoogleDocReader(),
      super(const GoogleDocImportState());

  Future<String> processGoogleDoc(String docId) async {
    if (docId.trim().isEmpty) {
      throw ArgumentError('Document ID cannot be empty.');
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final content = await _docReader.readDoc(docId);
      state = state.copyWith(isLoading: false, content: content);
      return content;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearContent() {
    state = state.copyWith(content: null);
  }
}

final googleDocImportControllerProvider =
    StateNotifierProvider<GoogleDocImportController, GoogleDocImportState>((
      ref,
    ) {
      return GoogleDocImportController();
    });
