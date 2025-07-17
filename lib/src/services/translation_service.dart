import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

/// Service for translating text to English using AI
class TranslationService {
  final Logger _log = Logger();
  final FirebaseFunctions _functions;
  final bool _useEmulator;

  TranslationService({
    FirebaseFunctions? functions,
    bool useEmulator = false,
    String region = "europe-central2",
  }) : _functions = functions ?? FirebaseFunctions.instanceFor(region: region),
       _useEmulator = useEmulator {
    if (_useEmulator) {
      _functions.useFunctionsEmulator('localhost', 5001);
    }
  }

  /// Translates text to English using AI
  /// Returns the original text if it's already in English or if translation fails
  Future<String> translateToEnglish(String text) async {
    if (text.trim().isEmpty) {
      return text;
    }

    try {
      _log.d('Translating text to English (length: ${text.length})');

      // Ensure user is authenticated
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _log.w('User not authenticated, returning original text');
        return text;
      }

      // Call the Cloud Function for translation
      final callable = _functions.httpsCallable('translateToEnglish');

      final result = await callable.call({'text': text});

      final responseData = result.data as Map<String, dynamic>;
      final translatedText = responseData['translatedText'] as String? ?? text;

      _log.d('Successfully translated text to English');
      return translatedText;
    } catch (e, st) {
      _log.e('Error translating text to English', error: e, stackTrace: st);
      // Return original text on error to avoid breaking functionality
      return text;
    }
  }
}
