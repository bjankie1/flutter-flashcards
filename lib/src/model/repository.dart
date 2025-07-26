import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_flashcards/src/common/dates.dart';
import 'package:flutter_flashcards/src/model/firebase/firebase_repository.dart';
import 'package:flutter_flashcards/src/model/firebase/firebase_storage.dart';
import 'package:flutter_flashcards/src/model/users_collaboration.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../fsrs/fsrs.dart';
import 'cards.dart' as model;
import 'package:flutter_flashcards/src/model/card_mastery.dart';
import 'package:flutter_flashcards/src/model/deck.dart';

abstract class CardsRepository extends ChangeNotifier {
  final _log = Logger();

  final ValueNotifier<bool> _cardsUpdated = ValueNotifier<bool>(false);

  ValueListenable<bool> get cardsUpdated => _cardsUpdated;

  final ValueNotifier<bool> _decksUpdated = ValueNotifier<bool>(false);

  ValueListenable<bool> get decksUpdated => _decksUpdated;

  final ValueNotifier<bool> _decksGroupUpdated = ValueNotifier<bool>(false);

  ValueListenable<bool> get decksGroupUpdated => _decksGroupUpdated;

  Future<model.Card?> loadCard(String cardId);

  String nextCardId();

  String nextDeckId();

  Future<void> saveDeck(model.Deck deck);

  Future<Iterable<model.Deck>> loadDecks();

  Future<model.Deck?> loadDeck(String deckId);

  Future<void> deleteDeck(String deckId);

  /// Executes multiple operations in a single transaction
  Future<void> runTransaction(Future<void> Function() operations);

  Future<Iterable<model.Card>> loadCards(String deckId);

  Future<Iterable<model.Card>> loadCardsByIds(Iterable<String> cardIds);

  Future<Iterable<model.Deck>> loadDecksByIds(Iterable<String> deckIds);

  Future<model.Card> saveCard(model.Card card);

  Future<void> deleteCard(String cardId);

  Future<Iterable<(model.CardStats, model.Card)>> loadCardsWithStatsToReview({
    model.DeckId? deckId,
    model.DeckGroupId? deckGroupId,
  });

  Future<Iterable<(model.CardStats, model.Card)>> loadCardsWithStats({
    model.DeckId? deckId,
    model.DeckGroupId? deckGroupId,
  });

  Future<Map<model.State, int>> cardsToReviewCount({
    model.DeckId? deckId,
    model.DeckGroupId? deckGroupId,
  });

  Future<model.CardStats> loadCardStats(
    String cardId,
    model.CardReviewVariant variant,
  );

  Future<int> getCardCount(String deckId);

  Future<void> recordCardAnswer(model.CardAnswer answer);

  Future<Iterable<model.CardAnswer>> loadAnswers(
    DateTime dayStart,
    DateTime dayEnd, {
    String? uid,
  });

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

  @protected
  void notifyDeckGroupChanged() {
    _decksGroupUpdated.value = !_decksGroupUpdated.value;
    notifyListeners();
  }

  /// Record an answer if it hasn't been responded today.
  /// Ignores the information if it has.
  /// Calculates next review date based on FSRS algorithm
  Future<void> recordAnswer(
    String cardId,
    model.CardReviewVariant variant,
    model.Rating rating,
    DateTime reviewStart,
    Duration duration,
  ) async {
    _log.d('Recording answer for card $cardId with variant $variant');
    // add answer to review log
    recordCardAnswer(
      model.CardAnswer(
        cardId: cardId,
        variant: variant,
        reviewStart: reviewStart,
        timeSpent: duration,
        rating: rating,
      ),
    );
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
    Iterable<String> cardIds,
  ) async {
    if (cardIds.isEmpty) return {};
    final cards = await loadCardsByIds(
      cardIds,
    ).logError('Error loading cards by ID');
    final decks = await loadDecksByIds(
      cards.map((c) => c.deckId).toSet(),
    ).logError('Error loading decks for cards');
    return Map.fromEntries(
      cards.map(
        (c) => MapEntry(c.id, decks.firstWhere((d) => d.id == c.deckId)),
      ),
    );
  }

  Future<void> saveCollaborationInvitation(String receivingUserEmail);

  Future<Set<String>> listCollaborators();

  Future<Iterable<CollaborationInvitation>> pendingInvitations({
    bool sent = false,
  });

  Future<void> changeInvitationStatus(
    String invitationId,
    InvitationStatus status,
  );

  Future<void> grantStatsAccess(String receivingUserEmail);

  Future<void> revokeStatsAccess(String userId);

  Future<void> grantAccessToDeck(String deckId, String receivingUserEmail);

  Future<void> revokeAccessToDeck(String deckId, String receivingUserEmail);

  /// List users who have been granted access to given deck.
  Future<Iterable<UserProfile>> listGrantedDeckAccess(String deckId);

  Future<Iterable<UserProfile>> listOwnStatsGrants();

  Future<Iterable<UserProfile>> listGivenStatsGrants();

  /// List of decks shared with the user logged in
  Future<Map<UserId, Iterable<model.Deck>>> listSharedDecks();

  /// Incorporate deck into own progress tracking
  Future<void> incorporateSharedDeck(String deckId);

  /// Move card to another deck
  Future<void> moveCard(String cardId, String newDeckId) async {
    final card = await loadCard(cardId);
    await saveCard(card!.copyWith(deckId: newDeckId));
  }

  Future<model.DeckGroup> createDeckGroup(String name, String? description);

  Future<void> addDeckToGroup(String deckId, model.DeckGroupId groupId);

  Future<void> removeDeckFromGroup(String deckId, model.DeckGroupId groupId);

  Future<model.DeckGroup?> loadDeckGroup(model.DeckGroupId groupId);

  Future<Iterable<model.DeckGroup>> loadDeckGroups();

  Future<void> deleteDeckGroup(model.DeckGroupId groupId);

  /// Associates decks with corresponding `DeckGroup`. Same `Deck` can be
  /// associated with none or multiple groups. `Deck` not associated with any
  /// `DeckGroup` is associated with tuple `(null, [])`.
  Future<List<(model.DeckGroup?, List<model.Deck>)>> loadDecksInGroups() async {
    final groups = await loadDeckGroups();
    final decks = await loadDecks();
    final decksMap = decks.fold(<String, model.Deck>{}, (map, deck) {
      map[deck.id!] = deck;
      return map;
    });
    final remainingDecks = decks.map((deck) => deck.id!).toSet();
    final List<(model.DeckGroup?, List<model.Deck>)> groupedDecks = List.empty(
      growable: true,
    );
    for (final group in groups) {
      if (group.decks == null || group.decks!.isEmpty) continue;
      remainingDecks.removeAll(group.decks!);
      // Not decided yet, if deck deletion should be cleaned from DeckGroup
      // Therefore it's better to deal with non-existing decks.
      final groupDecks = group.decks!
          .map((deckId) => decksMap[deckId])
          .where((deck) => deck != null)
          .map((deck) => deck!)
          .toList();
      groupedDecks.add((group, groupDecks));
    }
    if (remainingDecks.isNotEmpty) {
      groupedDecks.add((
        null,
        remainingDecks.map((deckId) => decksMap[deckId]!).toList(),
      ));
    }
    return groupedDecks;
  }

  Future<void> addProvisionaryCard(String text);

  /// Finalize provisionary card. If `resultingCardId` is not null, it means
  /// a corresponding card has been created. Otherwise it has been discarded.
  Future<void> finalizeProvisionaryCard(String id, String? resultingCardId);

  Future<Iterable<model.ProvisionaryCard>> listProvisionaryCards();

  Future<void> updateDeckGroup(model.DeckGroup group);

  /// Returns a breakdown of cards by their mastery level in a deck or deck group.
  /// The mastery levels are:
  /// - New: Cards that haven't been reviewed yet
  /// - Learning: Cards that are actively being memorized (in learning or relearning state)
  /// - Young: Cards in review state with relatively short intervals (< 21 days)
  /// - Mature: Cards in review state with long intervals (>= 21 days)
  Future<Map<CardMastery, int>> getMasteryBreakdown({
    DeckId? deckId,
    DeckGroupId? deckGroupId,
  });

  Future<List<model.CardStats>> loadCardStatsForCardIds(List<String> cardIds);
}

extension ContextProviders on BuildContext {
  CardsRepository get cardRepository =>
      Provider.of<CardsRepository>(this, listen: false);

  StorageService get storageService =>
      Provider.of<StorageService>(this, listen: false);
}
