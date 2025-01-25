import 'package:firebase_auth/firebase_auth.dart'; // For authentication
import 'package:cloud_functions/cloud_functions.dart';
import 'package:logger/logger.dart';
import '../model/cards.dart';

class GeneratedAnswer {
  final String answer;
  final String explanation;

  const GeneratedAnswer(this.answer, this.explanation);
}

class CloudFunctions {
  final _log = Logger();

  User? get user => FirebaseAuth.instance.currentUser;

  // Create a Firebase Functions instance (optional, but recommended)
  // - or use FirebaseFunctions.instance in place of functions everywhere
  final functions = FirebaseFunctions.instanceFor(region: "europe-central2");

  Future<DeckCategory> deckCategory(
      String deckName, String deckDescription) async {
    // 1. Ensure the user is authenticated:
    if (user == null) {
      throw Exception("User must be logged in to call the function.");
    }

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
}
