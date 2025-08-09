import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../model/cards.dart' as model;
import '../deck_list/decks_controller.dart';
import '../../genkit/functions.dart';
import '../../services/translation_service.dart';
import '../../common/build_context_extensions.dart';

part 'card_descriptions_dialog_controller.g.dart';

/// Controller for managing card descriptions dialog operations
@riverpod
class CardDescriptionsDialogController
    extends _$CardDescriptionsDialogController {
  final Logger _log = Logger();
  bool _isUpdating = false;
  bool _isGeneratingDescriptions = false;
  late TranslationService _translationService;

  String get _deckId => deckId;

  /// Getter for the generating descriptions state
  bool get isGeneratingDescriptions => _isGeneratingDescriptions;

  @override
  AsyncValue<model.Deck> build(String deckId) {
    _log.d('Loading deck details for card descriptions dialog: $deckId');
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

  /// Updates the front card description
  Future<void> updateFrontCardDescription(
    String frontCardDescription,
    CloudFunctions cloudFunctions,
  ) async {
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
      cloudFunctions: cloudFunctions,
    );
  }

  /// Updates the back card description
  Future<void> updateBackCardDescription(
    String backCardDescription,
    CloudFunctions cloudFunctions,
  ) async {
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
      cloudFunctions: cloudFunctions,
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

  /// Generates card descriptions using AI
  Future<CardDescriptionResult> generateCardDescriptions(
    BuildContext context,
  ) async {
    if (_isGeneratingDescriptions) {
      throw Exception('Already generating descriptions');
    }

    _isGeneratingDescriptions = true;
    try {
      final currentDeck = state.value;
      if (currentDeck == null) {
        throw Exception('No deck loaded');
      }

      // Load cards for the deck
      final repository = ref.read(cardsRepositoryProvider);
      final cards = await repository.loadCards(_deckId);
      final cardsList = cards.toList();

      _log.d(
        'Generating card descriptions for deck: $_deckId with ${cardsList.length} cards',
      );
      final cloudFunctions = context.cloudFunctions;
      final result = await cloudFunctions.generateCardDescriptions(
        deckName: currentDeck.name,
        deckDescription: currentDeck.description,
        cards: cardsList,
      );

      _log.d('Successfully generated card descriptions for deck: $_deckId');
      return result;
    } catch (error, stackTrace) {
      _log.e(
        'Error generating card descriptions for deck: $_deckId',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    } finally {
      _isGeneratingDescriptions = false;
    }
  }

  /// Applies generated descriptions to the deck
  Future<void> applyGeneratedDescriptions(
    CardDescriptionResult result,
    CloudFunctions cloudFunctions,
  ) async {
    try {
      if (result.frontCardDescription != null) {
        await updateFrontCardDescription(
          result.frontCardDescription!,
          cloudFunctions,
        );
      }
      if (result.backCardDescription != null) {
        await updateBackCardDescription(
          result.backCardDescription!,
          cloudFunctions,
        );
      }
      if (result.explanationDescription != null) {
        await updateExplanationDescription(result.explanationDescription!);
      }

      _log.d('Successfully applied generated descriptions for deck: $_deckId');
    } catch (error, stackTrace) {
      _log.e(
        'Error applying generated descriptions for deck: $_deckId',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
