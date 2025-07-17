import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../model/cards.dart' as model;
import '../deck_list/decks_controller.dart';
import '../../genkit/functions.dart';
import '../../services/translation_service.dart';
import '../../common/build_context_extensions.dart';

part 'deck_details_controller.g.dart';

/// Controller for managing deck details operations
@riverpod
class DeckDetailsController extends _$DeckDetailsController {
  final Logger _log = Logger();
  bool _isUpdating = false;
  late TranslationService _translationService;

  String get _deckId => deckId;

  @override
  AsyncValue<model.Deck> build(String deckId) {
    _log.d('Loading deck details for deck: $deckId');
    _translationService = TranslationService();
    _loadDeck();
    return const AsyncValue.loading();
  }

  /// Loads the deck details
  Future<void> _loadDeck() async {
    try {
      _log.d('Loading deck details for deck: $_deckId');
      state = const AsyncValue.loading();
      final repository = ref.read(cardsRepositoryProvider);
      final deck = await repository.loadDeck(_deckId);
      if (deck == null) {
        throw Exception('Deck not found: $_deckId');
      }
      state = AsyncValue.data(deck);
      _log.d('Successfully loaded deck details for deck: $_deckId');
    } catch (error, stackTrace) {
      _log.e(
        'Error loading deck details for deck: $_deckId',
        error: error,
        stackTrace: stackTrace,
      );
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Generic method to update deck fields
  Future<void> _updateDeckField({
    required String fieldName,
    required Future<model.Deck> Function(model.Deck) updateFunction,
    CloudFunctions? cloudFunctions,
    String? logMessage,
  }) async {
    // Prevent parallel updates
    if (_isUpdating) {
      _log.d(
        'Update already in progress for deck: $_deckId, skipping duplicate call',
      );
      return;
    }

    _isUpdating = true;
    try {
      _log.d(logMessage ?? 'Updating $fieldName for deck: $_deckId');
      final currentDeck = state.value;
      if (currentDeck == null) {
        throw Exception('No deck loaded');
      }

      var newDeck = await updateFunction(currentDeck);

      // Get category from cloud functions if provided
      if (cloudFunctions != null) {
        try {
          final category = await cloudFunctions.deckCategory(
            newDeck.name,
            newDeck.description ?? '',
          );
          newDeck = newDeck.copyWith(category: category);
        } catch (e, stackTrace) {
          _log.e(
            'Error getting deck category',
            error: e,
            stackTrace: stackTrace,
          );
          // Continue without category update
        }
      }

      // Save the deck
      final repository = ref.read(cardsRepositoryProvider);
      await repository.saveDeck(newDeck);

      // Update state
      state = AsyncValue.data(newDeck);

      // Refresh the decks list
      await ref.read(decksControllerProvider.notifier).refresh();

      _log.d('Successfully updated $fieldName for deck: $_deckId');
    } catch (error, stackTrace) {
      _log.e(
        'Error updating $fieldName for deck: $_deckId',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    } finally {
      _isUpdating = false;
    }
  }

  /// Updates the deck name
  Future<void> updateDeckName(
    String name,
    CloudFunctions cloudFunctions,
  ) async {
    await _updateDeckField(
      fieldName: 'name',
      updateFunction: (deck) async => deck.copyWith(name: name),
      cloudFunctions: cloudFunctions,
      logMessage: 'Updating deck name for deck: $_deckId to: $name',
    );
  }

  /// Updates the deck description
  Future<void> updateDeckDescription(
    String description,
    CloudFunctions cloudFunctions,
  ) async {
    await _updateDeckField(
      fieldName: 'description',
      updateFunction: (deck) async => deck.copyWith(description: description),
      cloudFunctions: cloudFunctions,
    );
  }

  /// Updates the front card description
  Future<void> updateFrontCardDescription(String frontCardDescription) async {
    _log.d('Starting updateFrontCardDescription for deck: $_deckId');
    _log.d('Original front card description: "$frontCardDescription"');

    await _updateDeckField(
      fieldName: 'front card description',
      updateFunction: (deck) async {
        _log.d('Calling translation service for front card description');
        final translatedDescription = await _translationService
            .translateToEnglish(frontCardDescription);
        _log.d('Translation result: "$translatedDescription"');
        _log.d(
          'Original vs translated: "${frontCardDescription}" -> "${translatedDescription}"',
        );

        final updatedDeck = deck.copyWith(
          frontCardDescription: frontCardDescription,
          frontCardDescriptionTranslated: translatedDescription,
        );
        _log.d(
          'Updated deck frontCardDescription: "${updatedDeck.frontCardDescription}"',
        );
        _log.d(
          'Updated deck frontCardDescriptionTranslated: "${updatedDeck.frontCardDescriptionTranslated}"',
        );

        return updatedDeck;
      },
    );
  }

  /// Updates the back card description
  Future<void> updateBackCardDescription(String backCardDescription) async {
    _log.d('Starting updateBackCardDescription for deck: $_deckId');
    _log.d('Original back card description: "$backCardDescription"');

    await _updateDeckField(
      fieldName: 'back card description',
      updateFunction: (deck) async {
        _log.d('Calling translation service for back card description');
        final translatedDescription = await _translationService
            .translateToEnglish(backCardDescription);
        _log.d('Translation result: "$translatedDescription"');
        _log.d(
          'Original vs translated: "${backCardDescription}" -> "${translatedDescription}"',
        );

        final updatedDeck = deck.copyWith(
          backCardDescription: backCardDescription,
          backCardDescriptionTranslated: translatedDescription,
        );
        _log.d(
          'Updated deck backCardDescription: "${updatedDeck.backCardDescription}"',
        );
        _log.d(
          'Updated deck backCardDescriptionTranslated: "${updatedDeck.backCardDescriptionTranslated}"',
        );

        return updatedDeck;
      },
    );
  }

  /// Updates the explanation description
  Future<void> updateExplanationDescription(
    String explanationDescription,
  ) async {
    _log.d('Starting updateExplanationDescription for deck: $_deckId');
    _log.d('Original explanation description: "$explanationDescription"');

    await _updateDeckField(
      fieldName: 'explanation description',
      updateFunction: (deck) async {
        _log.d('Calling translation service for explanation description');
        final translatedDescription = await _translationService
            .translateToEnglish(explanationDescription);
        _log.d('Translation result: "$translatedDescription"');
        _log.d(
          'Original vs translated: "${explanationDescription}" -> "${translatedDescription}"',
        );

        final updatedDeck = deck.copyWith(
          explanationDescription: explanationDescription,
          explanationDescriptionTranslated: translatedDescription,
        );
        _log.d(
          'Updated deck explanationDescription: "${updatedDeck.explanationDescription}"',
        );
        _log.d(
          'Updated deck explanationDescriptionTranslated: "${updatedDeck.explanationDescriptionTranslated}"',
        );

        return updatedDeck;
      },
    );
  }

  /// Refreshes the deck details
  Future<void> refresh() async {
    await _loadDeck();
  }

  /// Checks if the controller is ready and has a valid deck loaded
  bool get isReady {
    return state.hasValue && state.value != null;
  }

  /// Ensures the deck is loaded, refreshing if necessary
  Future<void> ensureDeckLoaded() async {
    if (!isReady) {
      _log.d('Deck not ready, attempting to load deck: $_deckId');
      await _loadDeck();
    }
  }

  /// Gets the current deck with null safety check
  model.Deck? getDeck() {
    return state.value;
  }

  /// Gets the deck category
  model.DeckCategory? getCategory() {
    return state.value?.category;
  }

  /// Generates a card answer suggestion using AI with fallback logic for descriptions
  Future<GeneratedAnswer> generateCardAnswer(
    String cardQuestion,
    BuildContext context,
  ) async {
    final currentDeck = state.value;
    if (currentDeck == null) {
      _log.e('No deck loaded in controller for deck ID: $_deckId');
      throw Exception('No deck loaded for deck ID: $_deckId');
    }

    if (currentDeck.category == null) {
      _log.w(
        'Deck category is not set for deck: ${currentDeck.name} (ID: $_deckId)',
      );
      throw Exception('Deck category is not set for deck: ${currentDeck.name}');
    }

    // Use translated descriptions if available, otherwise fall back to original
    final effectiveFrontDescription =
        currentDeck.frontCardDescriptionTranslated ??
        currentDeck.frontCardDescription;
    final effectiveBackDescription =
        currentDeck.backCardDescriptionTranslated ??
        currentDeck.backCardDescription;
    final effectiveExplanationDescription =
        currentDeck.explanationDescriptionTranslated ??
        currentDeck.explanationDescription;

    try {
      return await context.cloudFunctions.generateCardAnswer(
        currentDeck.category!,
        currentDeck.name,
        currentDeck.description ?? '',
        cardQuestion,
        frontCardDescription: effectiveFrontDescription,
        backCardDescription: effectiveBackDescription,
        explanationDescription: effectiveExplanationDescription,
      );
    } catch (e, stackTrace) {
      _log.e(
        'Error generating card answer for deck: $_deckId',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
