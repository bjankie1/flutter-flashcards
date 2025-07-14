import 'package:flutter/material.dart';

/// Context extension methods that operate on Snackbar
extension SnackBarMessaging on BuildContext {
  void showErrorSnackbar(String message) {
    ScaffoldMessenger.of(this)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Theme.of(this).colorScheme.onErrorContainer,
              ),
              const SizedBox(width: 8),
              Text(
                message,
                style: TextStyle(
                  color: Theme.of(this).colorScheme.onErrorContainer,
                ),
              ),
            ],
          ),
          backgroundColor: Theme.of(this).colorScheme.errorContainer,
        ),
      );
  }

  void showInfoSnackbar(String message) {
    ScaffoldMessenger.of(this)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(this).colorScheme.onSurface,
              ),
              const SizedBox(width: 8),
              Text(message),
            ],
          ),
        ),
      );
  }
}
