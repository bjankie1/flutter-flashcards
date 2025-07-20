import 'package:cloud_functions/cloud_functions.dart';
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
      _log.d('Empty text provided, returning as-is');
      return text;
    }

    try {
      _log.d('Translating text to English (length: ${text.length})');
      _log.d('Input text: "$text"');

      // Call the Cloud Function for translation
      final callable = _functions.httpsCallable('translateToEnglish');
      _log.d('Calling translateToEnglish cloud function...');

      final result = await callable.call({'text': text});
      _log.d('Cloud function call completed successfully');

      final responseData = result.data as Map<String, dynamic>;
      _log.d('Response data: $responseData');

      final translatedText = responseData['translatedText'] as String? ?? text;
      _log.d('Extracted translated text: "$translatedText"');
      _log.d('Original vs translated: "$text" -> "$translatedText"');

      if (translatedText == text) {
        _log.w(
          'Translation returned the same text - possible issue with translation service',
        );
      } else {
        _log.d('Successfully translated text to English');
      }

      return translatedText;
    } catch (e, st) {
      _log.e('Error translating text to English', error: e, stackTrace: st);
      _log.e('Input text that caused error: "$text"');
      // Return original text on error to avoid breaking functionality
      return text;
    }
  }
}
