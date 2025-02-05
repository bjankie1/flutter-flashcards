import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_flashcards/src/common/dates.dart';
import 'package:flutter_flashcards/src/model/firebase/firebase_repository.dart';
import 'package:flutter_flashcards/src/model/users_collaboration.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../fsrs/fsrs.dart';
import 'cards.dart' as model;

abstract class CardsRepository extends ChangeNotifier {
  final _log = Logger();

  final ValueNotifier<bool> _cardsUpdated = ValueNotifier<bool>(false);

  ValueListenable<bool> get cardsUpdated => _cardsUpdated;
  final ValueNotifier<bool> _decksUpdated = ValueNotifier<bool>(false);

  ValueListenable<bool> get decksUpdated => _decksUpdated;

  Future<model.Card?> loadCard(String cardId);

  String nextCardId();

  String nextDeckId();

  Future<void> saveDeck(model.Deck deck);

  Future<Iterable<model.Deck>> loadDecks();

  Future<model.Deck?> loadDeck(String deckId);

  Future<void> deleteDeck(String deckId);

  Future<Iterable<model.Card>> loadCards(String deckId);

  Future<Iterable<model.Card>> loadCardsByIds(Iterable<String> cardIds);

  Future<Iterable<model.Deck>> loadDecksByIds(Iterable<String> deckIds);

  Future<model.Card> saveCard(model.Card card);

  Future<void> deleteCard(String cardId);

  Future<Iterable<model.Card>> loadCardToReview({String? deckId});

  Future<Map<model.State, int>> cardsToReviewCount({String? deckId});

  Future<model.CardStats> loadCardStats(
      String cardId, model.CardReviewVariant variant);

  Future<int> getCardCount(String deckId);

  Future<void> recordCardAnswer(model.CardAnswer answer);

  Future<Iterable<model.CardAnswer>> loadAnswers(
      DateTime dayStart, DateTime dayEnd,
      {String? uid});

  @protected
  Future<void> saveCardStats(model.CardStats stats);

  Future<UserProfile?> loadUser(String userId);

  Future<void> saveUser(UserProfile user);

  Future<void> updateAllStats();

  @protected
  void notifyCardChanged() {
    _cardsUpdated.value = !_cardsUpdated.value;
    notifyListeners();
  }

  @protected
  void notifyDeckChanged() {
    _decksUpdated.value = !_decksUpdated.value;
    notifyListeners();
  }

  /// Record an answer if it hasn't been responded today.
  /// Ignores the information if it has.
  /// Calculates next review date based on FSRS algorithm
  Future<void> recordAnswer(String cardId, model.CardReviewVariant variant,
      model.Rating rating, DateTime reviewStart, Duration duration) async {
    _log.d('Recording answer for card $cardId with variant $variant');
    // add answer to review log
    recordCardAnswer(model.CardAnswer(
        cardId: cardId,
        variant: variant,
        reviewStart: reviewStart,
        timeSpent: duration,
        rating: rating));
    final stats = await loadCardStats(cardId, variant);
    if (stats.lastReview != null &&
        stats.lastReview!.difference(currentClockDateTime).inDays == 0 &&
        stats.nextReviewDate != null &&
        stats.nextReviewDate!.difference(currentClockDateTime).inDays > 0) {
      _log.i('Card $cardId has been already reviewed today');
      return;
    }
    final f = FSRS();
    final scheduled = f.repeat(stats, currentClockDateTime)[rating]?.card;
    _log.i('Next schedule for card $cardId is ${scheduled?.nextReviewDate}');
    await saveCardStats(scheduled!);
  }

  Future<Map<String, model.Deck>> mapCardsToDecks(
      Iterable<String> cardIds) async {
    if (cardIds.isEmpty) return {};
    final cards =
        await loadCardsByIds(cardIds).logError('Error loading cards by ID');
    final decks = await loadDecksByIds(cards.map((c) => c.deckId).toSet())
        .logError('Error loading decks for cards');
    return Map.fromEntries(cards.map(
        (c) => MapEntry(c.id!, decks.firstWhere((d) => d.id == c.deckId))));
  }

  Future<void> saveCollaborationInvitation(String receivingUserEmail);

  Future<Set<String>> loadCollaborators();

  Future<Iterable<CollaborationInvitation>> pendingInvitations(
      {bool sent = false});

  Future<void> changeInvitationStatus(
      String invitationId, InvitationStatus status);

  Future<void> grantStatsAccess(String receivingUserEmail);

  Future<void> revokeStatsAccess(String userId);

  Future<void> grantAccessToDeck(String deckId, String receivingUserEmail);

  Future<void> revokeAccessToDeck(String deckId, String receivingUserEmail);

  /// List users who have been granted access to given deck.
  Future<Iterable<UserProfile>> listGrantedDeckAccess(String deckId);

  Future<Iterable<UserProfile>> listOwnStatsGrants();

  Future<Iterable<UserProfile>> listGivenStatsGrants();

  /// List of decks shared with the user logged in
  Future<Iterable<model.Deck>> listSharedDecks();
}

extension CardRepositoryProvider on BuildContext {
  CardsRepository get cardRepository =>
      Provider.of<CardsRepository>(this, listen: false);
}