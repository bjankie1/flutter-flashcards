import 'package:flutter/foundation.dart';

class AppConfig {
  static const String _forceProdEnvVar = 'FORCE_PROD_FIREBASE';
  static const String _useEmulatorEnvVar = 'USE_FIREBASE_EMULATOR';

  /// Whether to force production Firebase even in debug mode
  static bool get forceProductionFirebase {
    if (kReleaseMode) return true;

    // Check environment variable
    final forceProd = const String.fromEnvironment(
      _forceProdEnvVar,
      defaultValue: 'false',
    );
    if (forceProd.toLowerCase() == 'true') return true;

    // Check if emulator should be used
    final useEmulator = const String.fromEnvironment(
      _useEmulatorEnvVar,
      defaultValue: 'true',
    );
    if (useEmulator.toLowerCase() == 'false') return true;

    return false;
  }

  /// Whether to use Firebase emulator
  static bool get useFirebaseEmulator {
    if (kReleaseMode) return false;
    return !forceProductionFirebase;
  }

  /// Whether to show Firebase UI auth in debug mode
  static bool get showFirebaseUIAuth {
    if (kReleaseMode) return false;
    return !forceProductionFirebase;
  }
}
