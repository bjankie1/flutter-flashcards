import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../model/cards.dart' as model;
import '../card_edit_page.dart';

part 'deck_details_page_controller.g.dart';

/// Controller for managing deck details page operations
@riverpod
class DeckDetailsPageController extends _$DeckDetailsPageController {
  final Logger _log = Logger();

  @override
  void build() {
    // No state needed for this controller
  }

  /// Navigates to the card edit page to add a new card
  void navigateToAddCard(BuildContext context, String deckId) {
    try {
      _log.d('Navigating to add card for deck: $deckId');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CardEditPage(deckId: deckId, card: null),
        ),
      );
    } catch (error, stackTrace) {
      _log.e(
        'Error navigating to add card for deck: $deckId',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Navigates to the card edit page to edit an existing card
  void navigateToEditCard(
    BuildContext context,
    String deckId,
    model.Card card,
  ) {
    try {
      _log.d('Navigating to edit card for deck: $deckId, card: ${card.id}');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CardEditPage(deckId: deckId, card: card),
        ),
      );
    } catch (error, stackTrace) {
      _log.e(
        'Error navigating to edit card for deck: $deckId, card: ${card.id}',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
