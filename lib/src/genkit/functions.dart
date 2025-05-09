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

  CloudFunctions(
      {this.useEmulator = false,
      this.region = "europe-central2",
      this.emulatorHost = 'localhost',
      this.emulatorPort = 5001}) {
    functions = FirebaseFunctions.instanceFor(region: region);
    if (useEmulator) {
      functions.useFunctionsEmulator(emulatorHost, emulatorPort);
    }
  }

  User? get user => FirebaseAuth.instance.currentUser;

  Future<DeckCategory> deckCategory(
      String deckName, String deckDescription) async {
    // 1. Ensure the user is authenticated:
    if (user == null) {
      throw Exception("User must be logged in to call the function.");
    }
    _log.d('Categorizing deck: $deckName with description: $deckDescription');

    // 3. Call the Cloud Function using the HttpsCallable class.
    final callable =
        functions.httpsCallable('deckCategory'); // Function name as deployed

    try {
      // 4. Invoke the callable function with the required data.
      final result = await callable
          .call({'deckName': deckName, 'deckDescription': deckDescription});

      final categoryString = result.data as String;
      _log.d('Category result from model: $categoryString');
      return DeckCategory.values.firstWhere(
          (value) => value.name == categoryString.trim().toLowerCase());
    } on FirebaseFunctionsException catch (e) {
      print(
          'Error calling function: ${e.code}, ${e.message}, ${e.details}'); // Better error handling here for your users
      // Handle the error appropriately (e.g., show an error message, retry, etc.).
      rethrow; // Re-throw the exception so the caller can also handle it.
    }
  }

  Future<GeneratedAnswer> generateCardAnswer(DeckCategory category,
      String deckName, String deckDescription, String cardQuestion) async {
    if (cardQuestion.trim().isEmpty) {
      throw 'Card question is empty';
    }
    _log.d(
        'Fetching LLM answer for category: $category question: $cardQuestion');
    // 1. Ensure the user is authenticated:
    if (user == null) {
      throw Exception("User must be logged in to call the function.");
    }

    // 3. Call the Cloud Function using the HttpsCallable class.
    final callable =
        functions.httpsCallable('cardAnswer'); // Function name as deployed

    try {
      // 4. Invoke the callable function with the required data.
      final result = await callable.call({
        'deckName': deckName,
        'deckDescription': deckDescription,
        'cardQuestion': cardQuestion,
        'category': category.name,
      });

      _log.d('Answer result from model: ${result.data}');

      // 5. Extract the data from the result. The result will be a String since that's the defined outputSchema.
      return GeneratedAnswer(result.data['answer'], result.data['explanation']);
    } on FirebaseFunctionsException catch (e) {
      print(
          'Error calling function: ${e.code}, ${e.message}, ${e.details}'); // Better error handling here for your users
      // Handle the error appropriately (e.g., show an error message, retry, etc.).
      rethrow; // Re-throw the exception so the caller can also handle it.
    }
  }

  Future<Iterable<FrontBack>> generateCardsForText(
      String frontLanguage, String backLanguage, String text) async {
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
        'generateFlashCardsFromText'); // Function name as deployed

    try {
      final result = await callable.call({
        'frontLanguage': frontLanguage,
        'backLanguage': backLanguage,
        'text': text,
      });
      final cards = result.data['cards'];

      _log.d('Cards generated: ${cards?.length}');

      return cards.map<FrontBack>(
          (card) => FrontBack(front: card['front'], back: card['back']));
    } on FirebaseFunctionsException catch (e) {
      print(
          'Error calling function: ${e.code}, ${e.message}, ${e.details}'); // Better error handling here for your users
      // Handle the error appropriately (e.g., show an error message, retry, etc.).
      rethrow; // Re-throw the exception so the caller can also handle it.
    }
  }
}