import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_flashcards/firebase_options.dart';
import 'package:flutter_flashcards/src/app_info.dart';
import 'package:flutter_flashcards/src/app_state.dart';
import 'package:flutter_flashcards/src/drawer_state.dart';
import 'package:flutter_flashcards/src/genkit/functions.dart';
import 'package:flutter_flashcards/src/model/firebase/firebase_repository.dart';
import 'package:flutter_flashcards/src/model/firebase/firebase_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart' as provider_package;
import 'package:url_strategy/url_strategy.dart';

import 'src/app.dart';
import 'src/model/repository_provider.dart';
import 'src/decks/deck_list/index.dart';

final _log = Logger();

void _setupLogging() {
  Logger.level = kReleaseMode ? Level.warning : Level.trace;
  Logger.addOutputListener((event) {
    for (var line in event.lines) {
      debugPrint(line); // This will print each formatted line from the printer
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _setupLogging();
  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseUIAuth.configureProviders([
    EmailAuthProvider(),
    GoogleProvider(clientId: DefaultFirebaseOptions.GOOGLE_CLIENT_ID),
  ]);

  // settings that cause the route to be represented in the URL
  GoRouter.optionURLReflectsImperativeAPIs = true;
  setPathUrlStrategy();

  if (kDebugMode) {
    // Connect to the Firestore emulator
    await _connectFirebaseEmulator();
  } else {
    FirebaseFirestore.instance.settings = Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    _log.d('Connected to production Firestore');
  }
  final repository = FirebaseCardsRepository(FirebaseFirestore.instance, null);
  FirebaseAuth.instance.authStateChanges().listen((user) {
    _log.i('User logged in as ${user?.email}');
    repository.user = user;
  });

  final cloudFunctions = CloudFunctions(useEmulator: kDebugMode);
  var storageService = StorageService();
  final appInfo = AppInfo();
  await appInfo.init();

  runApp(
    ProviderScope(
      overrides: [cardsRepositoryProvider.overrideWithValue(repository)],
      child: provider_package.MultiProvider(
        providers: [
          CardsRepositoryProvider(repository),
          provider_package.Provider(
            create: (context) {
              return storageService;
            },
          ),
          provider_package.ChangeNotifierProvider(
            create: (context) => AppState(repository, storageService),
          ),
          provider_package.ChangeNotifierProvider(
            create: (context) => DrawerState(),
          ),
          provider_package.Provider(create: (context) => cloudFunctions),
          provider_package.ChangeNotifierProvider(create: (context) => appInfo),
        ],
        child: const FlashcardsApp(),
      ),
    ),
  );
}

Future<void> _connectFirebaseEmulator() async {
  final localhost = kIsWeb
      ? 'localhost'
      : (Platform.isAndroid ? '10.0.2.2' : 'localhost');
  FirebaseFirestore.instance.useFirestoreEmulator(localhost, 8080);
  await FirebaseAuth.instance.useAuthEmulator(localhost, 9099);
  await FirebaseStorage.instance.useStorageEmulator(localhost, 9199);
  _log.d('Connected to Firestore emulator');
}
