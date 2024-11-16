// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```

class DefaultFirebaseOptions {
  static const String GOOGLE_CLIENT_ID =
      '264542271356-fakng0208n8pak72m1j90tbjc38ng5ag.apps.googleusercontent.com';

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAm_lRTB1lzoXxhZqrpLDmJmIHk55uI7AM',
    appId: '1:264542271356:web:26353284293e1650fe96f9',
    messagingSenderId: '264542271356',
    projectId: 'flashcards-521f0',
    authDomain: 'flashcards-521f0.firebaseapp.com',
    storageBucket: 'flashcards-521f0.firebasestorage.app',
    measurementId: 'G-9RNEV1WPNH',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDPDK1Ik1wcRDP64jYSPjjzkwp6aq_2Wns',
    appId: '1:264542271356:android:f6bd8c85223be9f3fe96f9',
    messagingSenderId: '264542271356',
    projectId: 'flashcards-521f0',
    storageBucket: 'flashcards-521f0.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAmVzV2IYJJxGLO9VG0Mgjrwy2TaR0FySA',
    appId: '1:264542271356:ios:cdff2b12850f21a4fe96f9',
    messagingSenderId: '264542271356',
    projectId: 'flashcards-521f0',
    storageBucket: 'flashcards-521f0.firebasestorage.app',
    iosBundleId: 'com.example.flutterFlashcards',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAmVzV2IYJJxGLO9VG0Mgjrwy2TaR0FySA',
    appId: '1:264542271356:ios:cdff2b12850f21a4fe96f9',
    messagingSenderId: '264542271356',
    projectId: 'flashcards-521f0',
    storageBucket: 'flashcards-521f0.firebasestorage.app',
    iosBundleId: 'com.example.flutterFlashcards',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAm_lRTB1lzoXxhZqrpLDmJmIHk55uI7AM',
    appId: '1:264542271356:web:6c0e3aeb718afb40fe96f9',
    messagingSenderId: '264542271356',
    projectId: 'flashcards-521f0',
    authDomain: 'flashcards-521f0.firebaseapp.com',
    storageBucket: 'flashcards-521f0.firebasestorage.app',
    measurementId: 'G-0672HCZSK8',
  );
}