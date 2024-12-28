import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class AppState extends ChangeNotifier {
  final _logger = Logger(); // Create a Logger instance

  AppState() {
    _logger.i('Initializing Firebase authentication'); // Use logger.i for info
    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loggedIn = true;
        _logger.d('User logged in: ${user.uid}'); // Debug log for user ID
      } else {
        _loggedIn = false;
        _logger.d('User logged out'); // Debug log for logout
      }
      notifyListeners();
    });
  }

  final ValueNotifier<ThemeMode> _currentTheme =
      ValueNotifier(ThemeMode.system);
  ValueListenable<ThemeMode> get currentTheme => _currentTheme;

  void setTheme(ThemeMode newTheme) {
    _currentTheme.value = newTheme;
  }

  void toggleTheme() {
    _currentTheme.value = _currentTheme.value == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  final ValueNotifier<Locale> _currentLocale =
      ValueNotifier(WidgetsBinding.instance.platformDispatcher.locale);
  ValueListenable<Locale> get currentLocale => _currentLocale;

  void setLocale(Locale newLocale) {
    _currentLocale.value = newLocale;
  }

  final ValueNotifier<String> _appTitle = ValueNotifier<String>('Flashcards');
  ValueListenable<String> get appTitle => _appTitle;

  void setTitle(String newTitle) {
    _appTitle.value = newTitle;
  }

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;
}

extension ContextAppState on BuildContext {
  AppState get appState => Provider.of<AppState>(this);
}
