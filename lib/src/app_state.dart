import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

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

  var title = 'Flashcards';

  void setTitle(String newTitle) {
    title = newTitle;
    notifyListeners();
  }

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;
}
