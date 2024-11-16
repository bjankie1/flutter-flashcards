import 'package:english_words/english_words.dart';
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

  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    _logger.d('Generated new word pair: $current'); // Debug log for word pair
    notifyListeners();
  }

  var favourites = <WordPair>[];

  void toggleFavorite() {
    if (favourites.contains(current)) {
      favourites.remove(current);
      _logger.d('Removed word pair from favorites: $current');
    } else {
      favourites.add(current);
      _logger.d('Added word pair to favorites: $current');
    }
    notifyListeners();
  }

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;
}
