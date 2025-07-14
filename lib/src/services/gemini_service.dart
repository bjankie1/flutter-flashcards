import 'dart:typed_data';
import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

final _log = Logger();

class FlashcardData {
  final String question;
  final String answer;
  final String? explanation;

  const FlashcardData({
    required this.question,
    required this.answer,
    this.explanation,
  });

  factory FlashcardData.fromJson(Map<String, dynamic> json) {
    return FlashcardData(
      question: json['question'] as String,
      answer: json['answer'] as String,
      explanation: json['explanation'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'answer': answer,
      if (explanation != null) 'explanation': explanation,
    };
  }
}

class GeminiService {
  final FirebaseFunctions _functions;
  final bool _useEmulator;

  GeminiService({
    FirebaseFunctions? functions,
    bool useEmulator = false,
    String region = "europe-central2",
  }) : _functions = functions ?? FirebaseFunctions.instanceFor(region: region),
       _useEmulator = useEmulator {
    if (_useEmulator) {
      _functions.useFunctionsEmulator('localhost', 5001);
    }
  }

  Future<List<FlashcardData>> generateFlashcards(String documentContent) async {
    try {
      _log.i(
        'Generating flashcards from document content (length: ${documentContent.length})',
      );

      // Ensure user is authenticated
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User must be logged in to generate flashcards');
      }

      // Call the Cloud Function
      final callable = _functions.httpsCallable('generateFlashCardsFromText');

      final result = await callable.call({
        'text': documentContent,
        'frontLanguage': 'English',
        'backLanguage': 'English',
      });

      final responseData = result.data as Map<String, dynamic>;
      final cardsJson = responseData['cards'] as List;

      final flashcards = cardsJson
          .map(
            (json) => FlashcardData(
              question: json['front'] as String,
              answer: json['back'] as String,
            ),
          )
          .toList();

      _log.i('Successfully generated ${flashcards.length} flashcards');
      return flashcards;
    } catch (e, st) {
      _log.e('Error generating flashcards', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<List<FlashcardData>> generateFlashcardsFromBinary(
    Uint8List binaryData,
    String fileType,
    String fileName,
  ) async {
    try {
      _log.i(
        'Generating flashcards from binary data (type: $fileType, name: $fileName, size: ${binaryData.length})',
      );

      // Ensure user is authenticated
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User must be logged in to generate flashcards');
      }

      // Call the Cloud Function for binary data
      final callable = _functions.httpsCallable('generateFlashCardsFromBinary');

      final result = await callable.call({
        'binaryData': base64Encode(binaryData),
        'fileType': fileType,
        'fileName': fileName,
        'frontLanguage': 'English',
        'backLanguage': 'English',
      });

      final responseData = result.data as Map<String, dynamic>;
      final cardsJson = responseData['cards'] as List;

      final flashcards = cardsJson
          .map(
            (json) => FlashcardData(
              question: json['front'] as String,
              answer: json['back'] as String,
            ),
          )
          .toList();

      _log.i(
        'Successfully generated ${flashcards.length} flashcards from binary data',
      );
      return flashcards;
    } catch (e, st) {
      _log.e(
        'Error generating flashcards from binary data',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}
