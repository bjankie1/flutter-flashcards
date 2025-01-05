import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flashcards/firebase_options.dart';
import 'package:flutter_flashcards/src/app_state.dart';
import 'package:flutter_flashcards/src/model/firebase/firebase_repository.dart';
import 'package:flutter_flashcards/src/model/repository.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:url_strategy/url_strategy.dart';

import 'src/app.dart';
import 'src/model/repository_provider.dart';

void main() async {
  final log = Logger();
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseUIAuth.configureProviders([
    EmailAuthProvider(),
    GoogleProvider(clientId: DefaultFirebaseOptions.GOOGLE_CLIENT_ID)
  ]);

  late CardsRepository cardRepository;
  if (const bool.fromEnvironment("testing")) {
    log.i('Instantiating in-memory repository');
    cardRepository = InMemoryCardsRepository();
  } else {
    log.i('Instantiating Firebase repository');
    cardRepository = FirebaseCardsRepository();
  }

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  var cardsRepositoryProvider = CardsRepositoryProvider(cardRepository);

  GoRouter.optionURLReflectsImperativeAPIs = true;
  setPathUrlStrategy();

  runApp(
    MultiProvider(
      providers: [
        cardsRepositoryProvider,
        ChangeNotifierProvider(create: (context) => AppState(cardRepository)),
      ],
      child: const FlashcardsApp(),
    ),
  );
}
