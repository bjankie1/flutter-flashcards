import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For authentication
import 'package:logger/logger.dart';

import '../model/cards.dart';

class GeneratedAnswer {
  final String answer;
  final String explanation;

  const GeneratedAnswer(this.answer, this.explanation);
}

class FrontBack {
  final String front;
  final String back;

  FrontBack({required this.front, required this.back});
}

class CloudFunctions {
  final _log = Logger();

  final bool useEmulator;

  final String emulatorHost;

  final int emulatorPort;

  final String region;

  // Create a Firebase Functions instance (optional, but recommended)
  // - or use FirebaseFunctions.instance in place of functions everywhere
  late FirebaseFunctions functions;

  CloudFunctions({
    this.useEmulator = false,
    this.region = "europe-central2",
    this.emulatorHost = 'localhost',
    this.emulatorPort = 5001,
  }) {
    _log.d(
      'Initializing CloudFunctions with region: $region, useEmulator: $useEmulator',
    );
    functions = FirebaseFunctions.instanceFor(region: region);
    if (useEmulator) {
      _log.d('Using Functions emulator at $emulatorHost:$emulatorPort');
      functions.useFunctionsEmulator(emulatorHost, emulatorPort);
    } else {
      _log.d('Using production Functions in region: $region');
    }

    // Log current user state
    final currentUser = FirebaseAuth.instance.currentUser;
    _log.d('Current user: ${currentUser?.email}, UID: ${currentUser?.uid}');
    _log.d('User is authenticated: ${currentUser != null}');
  }

  User? get user {
    final currentUser = FirebaseAuth.instance.currentUser;
    _log.d(
      'Getting current user: ${currentUser?.email}, UID: ${currentUser?.uid}',
    );
    return currentUser;
  }

  Future<DeckCategory> deckCategory(
    String deckName,
    String deckDescription,
  ) async {
    // 1. Ensure the user is authenticated:
    if (user == null) {
      throw Exception("User must be logged in to call the function.");
    }
    _log.d('Categorizing deck: $deckName with description: $deckDescription');

    // 3. Call the Cloud Function using the HttpsCallable class.
    final callable = functions.httpsCallable(
      'deckCategory',
    ); // Function name as deployed

    try {
      // 4. Invoke the callable function with the required data.
      final result = await callable.call({
        'deckName': deckName,
        'deckDescription': deckDescription,
      });

      final categoryString = result.data as String;
      _log.d('Category result from model: $categoryString');
      return DeckCategory.values.firstWhere(
        (value) => value.name == categoryString.trim().toLowerCase(),
      );
    } on FirebaseFunctionsException catch (e) {
      print(
        'Error calling function: ${e.code}, ${e.message}, ${e.details}',
      ); // Better error handling here for your users
      // Handle the error appropriately (e.g., show an error message, retry, etc.).
      rethrow; // Re-throw the exception so the caller can also handle it.
    }
  }

  Future<GeneratedAnswer> generateCardAnswer(
    DeckCategory category,
    String deckName,
    String deckDescription,
    String cardQuestion, {
    String? frontCardDescription,
    String? backCardDescription,
    String? explanationDescription,
  }) async {
    if (cardQuestion.trim().isEmpty) {
      throw 'Card question is empty';
    }
    _log.d(
      'Fetching LLM answer for category: $category question: $cardQuestion',
    );
    _log.d('User: ${user?.email}, UID: ${user?.uid}');
    _log.d('Region: $region, useEmulator: $useEmulator');

    // 1. Ensure the user is authenticated:
    if (user == null) {
      throw Exception("User must be logged in to call the function.");
    }

    // 2. Log the function configuration
    _log.d('Function project ID: ${functions.app.options.projectId}');
    _log.d('Function name: cardAnswer');

    // 3. Call the Cloud Function using the HttpsCallable class.
    final callable = functions.httpsCallable(
      'cardAnswer',
    ); // Function name as deployed

    final requestData = {
      'deckName': deckName,
      'deckDescription': deckDescription,
      'cardQuestion': cardQuestion,
      'category': category.name,
      'frontCardDescription': frontCardDescription,
      'backCardDescription': backCardDescription,
      'explanationDescription': explanationDescription,
    };

    _log.d('Calling function with data: $requestData');

    try {
      // 4. Invoke the callable function with the required data.
      final result = await callable.call(requestData);
      _log.d('Answer result from model: ${result.data}');

      // 5. Extract the data from the result. The result will be a String since that's the defined outputSchema.
      return GeneratedAnswer(result.data['answer'], result.data['explanation']);
    } on FirebaseFunctionsException catch (e) {
      _log.e(
        'FirebaseFunctionsException: ${e.code}, ${e.message}, ${e.details}',
      );
      _log.e('Exception type: ${e.runtimeType}');
      _log.e('Stack trace: ${e.stackTrace}');
      // Handle the error appropriately (e.g., show an error message, retry, etc.).
      rethrow; // Re-throw the exception so the caller can also handle it.
    } catch (e, stackTrace) {
      _log.e('Unexpected error: $e');
      _log.e('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<Iterable<FrontBack>> generateCardsForText(
    String frontLanguage,
    String backLanguage,
    String text,
  ) async {
    if (text.trim().isEmpty) {
      throw 'No input text provided';
    }
    if (frontLanguage.trim().isEmpty) {
      throw 'No front language provided';
    }
    if (backLanguage.trim().isEmpty) {
      throw 'No back language provided';
    }
    _log.d('Fetching LLM card suggestions for the text');
    if (user == null) {
      throw Exception("User must be logged in to call the function.");
    }

    final callable = functions.httpsCallable(
      'generateFlashCardsFromText',
    ); // Function name as deployed

    try {
      final result = await callable.call({
        'frontLanguage': frontLanguage,
        'backLanguage': backLanguage,
        'text': text,
      });
      final cards = result.data['cards'];

      _log.d('Cards generated: ${cards?.length}');

      return cards.map<FrontBack>(
        (card) => FrontBack(front: card['front'], back: card['back']),
      );
    } on FirebaseFunctionsException catch (e) {
      print(
        'Error calling function: ${e.code}, ${e.message}, ${e.details}',
      ); // Better error handling here for your users
      // Handle the error appropriately (e.g., show an error message, retry, etc.).
      rethrow; // Re-throw the exception so the caller can also handle it.
    }
  }
}
