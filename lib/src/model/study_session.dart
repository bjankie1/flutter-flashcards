import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/dates.dart';
import 'package:flutter_flashcards/src/model/cards.dart' as model;
import 'package:flutter_flashcards/src/model/firebase/firebase_repository.dart';
import 'package:flutter_flashcards/src/model/repository.dart';
import 'package:logger/logger.dart';

/// State used to track progress on a selected set of cards.
/// It aims to load set of cards either for all decks or for
/// a selected deck. It keeps track of the index and rotates
/// to the next card. It also exposes information about the
/// number of remaining cards to review.
/// It may happen that a single card can be reviewed multiple
/// times during a session in case of lapses.
class StudySession with ChangeNotifier {
  final _log = Logger();

  final CardsRepository repository;

  final String? deckId;
  final String? deckGroupId;

  StudySession({required this.repository, this.deckId, this.deckGroupId});

  List<(model.CardReviewVariant, model.Card)> _cards = [];
  int _currentIndex = 0;
  DateTime _reviewStart = currentClockDateTime;
  int _reviewsSinceLastShuffle = 0;
  bool _sessionStarted = false;

  int get remainingCards => _cards.length;

  (model.CardReviewVariant, model.Card)? get currentCard =>
      _cards.isEmpty ? null : _cards[_currentIndex];

  Future<void> startStudySession() async {
    _log.d('Starting session');
    _cards = await repository
        .loadCardsWithStatsToReview(deckId: deckId, deckGroupId: deckGroupId)
        .then((result) {
          // First shuffle to ensure randomness within same hour
          final shuffled = result.map((cs) => (cs.$1, cs.$2)).toList()
            ..shuffle();
          // Then sort by due date (nextReviewDate) rounded to hours
          shuffled.sort((a, b) {
            final aDate = a.$1.nextReviewDate?.hourStart;
            final bDate = b.$1.nextReviewDate?.hourStart;
            // Handle null dates (they should come last)
            if (aDate == null && bDate == null) return 0;
            if (aDate == null) return 1;
            if (bDate == null) return -1;
            return aDate.compareTo(bDate);
          });
          return shuffled.map((cs) => (cs.$1.variant, cs.$2)).toList();
        })
        .logError('Error loading cards to review');
    _currentIndex = 0;
    _reviewStart = currentClockDateTime;
    _sessionStarted = true;
    notifyListeners();
  }

  rateAnswer(model.Rating rating) async {
    if (_cards.isEmpty) {
      throw 'No cards to review';
    }
    if (!_sessionStarted) {
      throw 'Session has not been started';
    }
    final (variant, card) = _cards[(_currentIndex)];
    final duration = currentClockDateTime.difference(_reviewStart);
    await repository.recordAnswer(
      card.id,
      variant,
      rating,
      _reviewStart,
      duration,
    );
    _progressToNextCard(rating);
  }

  /// Rating only one card as `again` leaves this card in the list otherwise
  /// card is removed from the list which impacts pointer modification.
  _progressToNextCard(model.Rating rating) {
    // Remove cards that have been learnt
    if (rating != model.Rating.again) {
      _cards.removeAt(_currentIndex);
    }
    if (_cards.isEmpty) {
      return;
    }
    if (rating == model.Rating.again) {
      _currentIndex = (_currentIndex + 1) % _cards.length;
    } else {
      // card has been removed from list therefore the current index can
      // be exceeding the list length.
      _currentIndex = _currentIndex % _cards.length;
    }
    if (_reviewsSinceLastShuffle > _cards.length) {
      _cards.shuffle();
      _reviewsSinceLastShuffle = 0;
    } else {
      _reviewsSinceLastShuffle++;
    }
    _reviewStart = currentClockDateTime;
    notifyListeners();
  }
}
