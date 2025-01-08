import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flashcards/firebase_options.dart';
import 'package:flutter_flashcards/src/app_state.dart';
import 'package:flutter_flashcards/src/model/firebase/firebase_repository.dart';
import 'package:flutter_flashcards/src/model/firebase/firebase_storage.dart';
import 'package:flutter_flashcards/src/model/repository.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:url_strategy/url_strategy.dart';

import 'src/app.dart';
import 'src/model/repository_provider.dart';

void main() async {
  final _log = Logger();
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseUIAuth.configureProviders([
    EmailAuthProvider(),
    GoogleProvider(clientId: DefaultFirebaseOptions.GOOGLE_CLIENT_ID)
  ]);

  late CardsRepository cardRepository;
  if (const bool.fromEnvironment("testing")) {
    _log.i('Instantiating in-memory repository');
    // TODO: FakeFirebaseFirestore
    cardRepository = FirebaseCardsRepository(FirebaseFirestore.instance, null);
  } else {
    _log.i('Instantiating Firebase repository');
    cardRepository = FirebaseCardsRepository(FirebaseFirestore.instance, null);
  }

  GoRouter.optionURLReflectsImperativeAPIs = true;
  setPathUrlStrategy();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppState(cardRepository)),
        FutureProvider<CardsRepository>.value(
          value: FirebaseAuth.instance.authStateChanges().first.then((user) {
            // Create the real repository after auth state is known
            final repository =
                FirebaseCardsRepository(FirebaseFirestore.instance, user);
            return repository;
          }),
          initialData: cardRepository,
          catchError: (context, error) {
            // Handle errors during repository initialization
            _log.e('Error initializing repository: $error');
            return FirebaseCardsRepository(FirebaseFirestore.instance,
                null); // Return a fallback repository
          },
        ),
        Provider(create: (context) => StorageService()),
      ],
      child: const FlashcardsApp(),
    ),
  );
}
