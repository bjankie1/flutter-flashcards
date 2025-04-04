import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flashcards/firebase_options.dart';
import 'package:flutter_flashcards/src/app_info.dart';
import 'package:flutter_flashcards/src/app_state.dart';
import 'package:flutter_flashcards/src/drawer_state.dart';
import 'package:flutter_flashcards/src/genkit/functions.dart';
import 'package:flutter_flashcards/src/model/firebase/firebase_repository.dart';
import 'package:flutter_flashcards/src/model/firebase/firebase_storage.dart';
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

  // settings that cause the route to be represented in the URL
  GoRouter.optionURLReflectsImperativeAPIs = true;
  setPathUrlStrategy();

  if (false && kDebugMode) {
    // Connect to the Firestore emulator
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    await FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
    log.d('Connected to Firestore emulator');
  } else {
    FirebaseFirestore.instance.settings = Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    log.d('Connected to production Firestore');
  }
  final repository = FirebaseCardsRepository(FirebaseFirestore.instance, null);
  FirebaseAuth.instance.authStateChanges().listen((user) {
    log.i('User logged in as ${user?.email}');
    repository.user = user;
  });

  final cloudFunctions = CloudFunctions(useEmulator: kDebugMode);
  var storageService = StorageService();
  final appInfo = AppInfo();
  await appInfo.init();

  runApp(
    MultiProvider(
      providers: [
        CardsRepositoryProvider(repository),
        Provider(create: (context) {
          return storageService;
        }),
        ChangeNotifierProvider(
            create: (context) => AppState(repository, storageService)),
        ChangeNotifierProvider(create: (context) => DrawerState()),
        Provider(create: (context) => cloudFunctions),
        Provider(create: (context) => appInfo),
      ],
      child: const FlashcardsApp(),
    ),
  );
}