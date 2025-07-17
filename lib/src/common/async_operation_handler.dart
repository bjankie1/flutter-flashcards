import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/snackbar_messaging.dart';
import 'package:logger/logger.dart';

/// Mixin to handle common async operations with error handling and user feedback
mixin AsyncOperationHandler {
  final Logger _log = Logger();

  /// Executes an async operation with standardized error handling and user feedback
  Future<void> executeWithFeedback<T>({
    required BuildContext context,
    required Future<T> Function() operation,
    required String successMessage,
    required String errorMessage,
    required String logErrorPrefix,
  }) async {
    try {
      await operation();
      if (context.mounted) {
        context.showInfoSnackbar(successMessage);
      }
    } catch (e, stackTrace) {
      _log.e(logErrorPrefix, error: e, stackTrace: stackTrace);
      if (context.mounted) {
        context.showErrorSnackbar(errorMessage);
      }
    }
  }

  /// Executes a navigation operation with simple error handling
  void executeNavigation({
    required BuildContext context,
    required VoidCallback operation,
    required String errorMessage,
  }) {
    try {
      operation();
    } on Exception {
      if (!context.mounted) return;
      context.showErrorSnackbar(errorMessage);
    }
  }
}
