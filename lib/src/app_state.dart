import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/model/repository.dart';
import 'package:flutter_flashcards/src/model/users_collaboration.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class AppState extends ChangeNotifier {
  final _log = Logger(); // Create a Logger instance

  final CardsRepository cardRepository;

  bool get loggedIn => _authenticatedUser.value != null;
  UserProfile? _userProfile;
  ValueNotifier<User?> _authenticatedUser = ValueNotifier(null);
  ValueListenable<User?> get authenticatedUser => _authenticatedUser;

  final ValueNotifier<Locale> _currentLocale =
      ValueNotifier(WidgetsBinding.instance.platformDispatcher.locale);
  ValueListenable<Locale> get currentLocale => _currentLocale;

  final ValueNotifier<String> _appTitle = ValueNotifier<String>('Flashcards');
  ValueListenable<String> get appTitle => _appTitle;

  AppState(this.cardRepository) {
    _log.i('Initializing Firebase authentication');
    FirebaseAuth.instance.userChanges().listen((user) async {
      if (user != null) {
        _log.d('user in instance: ${FirebaseAuth.instance.currentUser?.email}');
        await loadUserProfile(user.uid);
        _authenticatedUser.value = user;
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
    _authenticatedUser.value = null;
    _log.d('User logged out'); // Debug log for logout
    setTheme(ThemeMode.system);
    _userProfile = null;
    _currentLocale.value = WidgetsBinding.instance.platformDispatcher.locale;
    notifyListeners();
  }

  /// Method executed in result to authentication change. Loads user profile
  /// from firestore and restores state data based on that.
  Future<void> loadUserProfile(String userId) async {
    _log.d('User logged in: $userId'); // Debug log for user ID
    _userProfile = await cardRepository.loadUser(userId);
    if (_userProfile == null) {
      _log.i('User profile not found, creating new one');
      _userProfile = UserProfile(
          id: userId,
          name: '',
          email: FirebaseAuth.instance.currentUser!.email ?? '',
          theme: currentTheme.value,
          locale: _currentLocale.value,
          photoUrl: '');
      await cardRepository.saveUser(_userProfile!);
    } else if (_userProfile != null &&
        (_userProfile?.email == null || _userProfile!.email.isEmpty)) {
      _userProfile = _userProfile!.copyWith(
        email: FirebaseAuth.instance.currentUser!.email ?? '',
      );
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

  void setLocale(Locale newLocale) {
    _currentLocale.value = newLocale;
  }

  void setTitle(String newTitle) {
    _appTitle.value = newTitle;
  }
}

extension ContextAppState on BuildContext {
  AppState get appState => Provider.of<AppState>(this);
}
