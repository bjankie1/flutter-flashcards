import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/model/repository.dart';
import 'package:flutter_flashcards/src/model/user.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class AppState extends ChangeNotifier {
  final _log = Logger(); // Create a Logger instance

  final CardsRepository cardRepository;

  bool _loggedIn = false;

  bool get loggedIn => _loggedIn;

  UserProfile? _userProfile;

  UserProfile? get loggedInUser => _userProfile;

  AppState(this.cardRepository) {
    _log.i('Initializing Firebase authentication');
    FirebaseAuth.instance.userChanges().listen((user) async {
      if (user != null) {
        _log.d('user in instance: ${FirebaseAuth.instance.currentUser?.email}');
        await loadState(user.uid); // Debug log for user ID
      } else {
        resetState(); // Debug log for logout
      }
    });
    currentTheme.addListener(() async {
      if (_userProfile != null && _userProfile?.theme != currentTheme.value) {
        _userProfile = _userProfile!.copyWith(theme: currentTheme.value);
        await cardRepository.saveUser(_userProfile!);
      }
    });
    currentLocale.addListener(() async {
      if (_userProfile != null && _userProfile?.locale != currentLocale.value) {
        _userProfile = _userProfile!.copyWith(locale: currentLocale.value);
        await cardRepository.saveUser(_userProfile!);
      }
    });
  }

  void resetState() {
    _loggedIn = false;
    _log.d('User logged out'); // Debug log for logout
    setTheme(ThemeMode.system);
    _userProfile = null;
    _currentLocale.value = WidgetsBinding.instance.platformDispatcher.locale;
    notifyListeners();
  }

  Future<void> loadState(String userId) async {
    _log.d('User logged in: $userId'); // Debug log for user ID
    _loggedIn = true;
    _userProfile = await cardRepository.loadUser(userId);
    if (_userProfile == null) {
      _log.i('User profile not found, creating new one');
      _userProfile = UserProfile(
          id: userId,
          name: '',
          theme: currentTheme.value,
          locale: _currentLocale.value,
          photoUrl: '');
      await cardRepository.saveUser(_userProfile!);
    } else {
      _log.i('Loaded theme ${_userProfile?.theme.name}');
      _log.i('Loaded locale ${_userProfile?.locale.languageCode}');
      setTheme(_userProfile!.theme);
      _currentLocale.value = _userProfile!.locale;
    }
    notifyListeners();
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
}

extension ContextAppState on BuildContext {
  AppState get appState => Provider.of<AppState>(this);
}
