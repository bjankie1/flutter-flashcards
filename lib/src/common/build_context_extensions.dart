import 'package:flutter/material.dart';
import 'package:flutter_flashcards/l10n/app_localizations.dart';
import 'package:flutter_flashcards/src/app_state.dart';
import 'package:flutter_flashcards/src/genkit/functions.dart';
import 'package:provider/provider.dart';

extension ContextAppState on BuildContext {
  AppState get appState => Provider.of<AppState>(this, listen: false);

  AppLocalizations get l10n => AppLocalizations.of(this)!;

  MaterialLocalizations get ml10n => MaterialLocalizations.of(this);

  CloudFunctions get cloudFunctions =>
      Provider.of<CloudFunctions>(this, listen: false);

  /// Get the current theme mode from the user profile
  ThemeMode get themeMode =>
      appState.userProfile.value?.theme ?? ThemeMode.system;

  /// Check if the current theme is dark
  /// Returns true if user selected dark theme or if user selected system theme and system is in dark mode
  bool get isDarkTheme {
    final currentThemeMode = themeMode;
    if (currentThemeMode == ThemeMode.dark) {
      return true;
    }
    if (currentThemeMode == ThemeMode.system) {
      return MediaQuery.platformBrightnessOf(this) == Brightness.dark;
    }
    return false;
  }

  bool get isMobile {
    double screenWidth = MediaQuery.sizeOf(this).width;
    return screenWidth < 600;
  }
}
