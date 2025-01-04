import 'package:flutter/material.dart';

/// Context extension methods that operate on Snackbar
extension SnackBarMessaging on BuildContext {
  void showErrorSnackbar(String message) {
    ScaffoldMessenger.of(this)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(this).colorScheme.error,
      ));
  }

  void showInfoSnackbar(String message) {
    ScaffoldMessenger.of(this)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
      ));
  }
}
