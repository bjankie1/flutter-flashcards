import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/model/firebase/firebase_repository.dart';
import 'package:flutter_flashcards/src/model/firebase/firebase_storage.dart';
import 'package:flutter_flashcards/src/model/repository.dart';
import 'package:flutter_flashcards/src/model/users_collaboration.dart';
import 'package:logger/logger.dart';

class AppState extends ChangeNotifier {
  final _log = Logger(); // Create a Logger instance

  final CardsRepository cardRepository;

  final StorageService storageService;

  bool get loggedIn => _authenticatedUser.value != null;

  ValueNotifier<UserProfile?> _userProfile = ValueNotifier(null);

  ValueListenable<UserProfile?> get userProfile => _userProfile;

  ValueNotifier<User?> _authenticatedUser = ValueNotifier(null);

  ValueListenable<User?> get authenticatedUser => _authenticatedUser;

  final _appTitle = ValueNotifier<String>('Flashcards');

  ValueListenable<String> get appTitle => _appTitle;

  final _userAvatarUrl = ValueNotifier<String?>(null);

  ValueListenable<String?> get userAvatarUrl => _userAvatarUrl;

  AppState(this.cardRepository, this.storageService) {
    _log.i('Initializing Firebase authentication');
    FirebaseAuth.instance.userChanges().listen((user) async {
      if (user != null) {
        _log.d('user in instance: ${FirebaseAuth.instance.currentUser?.email}');
        await loadUserProfile(user.uid);
        _authenticatedUser.value = user;
        await reloadAvatarUrl();
      } else {
        resetState(); // Debug log for logout
      }
    });
    userProfile.addListener(() async {
      if (_userProfile.value != null) {
        _log.d('Saving new value of user profile');
        await cardRepository.saveUser(_userProfile.value!);
        if (_userProfile.value!.avatarUploadTime != null) {
          await reloadAvatarUrl();
        }
      } else {
        _log.d('Not saving null value of user profile');
      }
      notifyListeners();
    });
  }

  void resetState() {
    _authenticatedUser.value = null;
    _log.d('User logged out'); // Debug log for logout
    _userProfile.value = null;
    _userAvatarUrl.value = null;
    notifyListeners();
  }

  /// Method executed in result to authentication change. Loads user profile
  /// from firestore and restores state data based on that.
  Future<void> loadUserProfile(String userId) async {
    _log.d('User logged in: $userId'); // Debug log for user ID
    var userProfile = await cardRepository.loadUser(userId);
    var authUser = FirebaseAuth.instance.currentUser!;
    if (userProfile == null) {
      _log.i('User profile not found, creating new one');
      userProfile = UserProfile(
        id: userId,
        name: authUser.displayName ?? '',
        email: authUser.email ?? '',
        theme: ThemeMode.system,
        locale: WidgetsBinding.instance.platformDispatcher.locale,
      );
      await cardRepository.saveUser(userProfile);
    }
    _userProfile.value = userProfile;
    _log.i('Loaded theme ${userProfile.theme.name}');
    _log.i('Loaded locale ${userProfile.locale.languageCode}');
    notifyListeners();
  }

  set locale(Locale locale) {
    updateUserProfile(locale: locale);
  }

  set theme(ThemeMode newTheme) {
    updateUserProfile(theme: newTheme);
  }

  void toggleTheme() {
    theme = userProfile.value!.theme == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  void updateUserProfile({
    Locale? locale,
    ThemeMode? theme,
    String? name,
    bool newAvatar = false,
  }) {
    var newProfile = _userProfile.value!;
    if (locale != null) {
      _log.d('Updating locale to ${locale.languageCode}');
      newProfile = _userProfile.value!.copyWith(locale: locale);
    }
    if (theme != null) {
      _log.d('Updating theme to ${theme.name}');
      newProfile = _userProfile.value!.copyWith(theme: theme);
    }
    if (name != null) {
      _log.d('Updating name to: $name');
      newProfile = _userProfile.value!.copyWith(name: name);
    }
    if (newAvatar) {
      _log.d('Updated avatar');
      newProfile = _userProfile.value!.copyWith(
        avatarUploadTime: DateTime.now(),
      );
    }
    _userProfile.value = newProfile;
  }

  set title(String newTitle) {
    _appTitle.value = newTitle;
  }

  Future<void> reloadAvatarUrl() async {
    _log.d('Reloading avatar url');
    _userAvatarUrl.value = await storageService
        .userAvatarUrl()
        .then(
          (value) => value != null
              ? '$value?v=${userProfile.value?.avatarUploadTime}' // add timestamp to URL to force reload
              : null,
        )
        .logError('Error loading avatar URL');
  }
}
