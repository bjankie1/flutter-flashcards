import 'package:flutter/foundation.dart';
import '../google/google_doc_reader.dart';

class GoogleDocImportController extends ChangeNotifier {
  final GoogleDocReader _docReader;

  GoogleDocImportController({GoogleDocReader? docReader})
    : _docReader = docReader ?? GoogleDocReader();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<String> processGoogleDoc(String docId) async {
    if (docId.trim().isEmpty) {
      throw ArgumentError('Document ID cannot be empty.');
    }
    _isLoading = true;
    notifyListeners();

    try {
      return await _docReader.readDoc(docId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
