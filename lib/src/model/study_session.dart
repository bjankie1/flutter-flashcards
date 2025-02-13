import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/dates.dart';
import 'package:flutter_flashcards/src/model/cards.dart' as model;
import 'package:flutter_flashcards/src/model/firebase/firebase_repository.dart';
import 'package:flutter_flashcards/src/model/repository.dart';

/// State used to track progress on a selected set of cards.
/// It aims to load set of cards either for all decks or for
/// a selected deck. It keeps track of the index and rotates
/// to the next card. It also exposes information about the
/// number of remaining cards to review.
/// It may happen that a single card can be reviewed multiple
/// times during a session in case of lapses.
class StudySession with ChangeNotifier {
  final CardsRepository repository;

  final String? deckId;

  StudySession({required this.repository, this.deckId});

  List<model.Card> _cards = [];
  int _currentIndex = 0;
  DateTime _reviewStart = currentClockDateTime;
  int _reviewsSinceLastShuffle = 0;
  bool _sessionStarted = false;

  int get remainingCards => _cards.length;

  model.Card? get currentCard =>
      _cards.isEmpty ? null : _cards[_currentIndex % _cards.length];

  Future<void> startStudySession() async {
    _cards = await repository
        .loadCardToReview(deckId: deckId)
        .then((result) => result.toList())
        .logError('Error loading cards to review');
    _cards.shuffle();
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
    final card = _cards[(_currentIndex) % _cards.length];
    final duration = currentClockDateTime.difference(_reviewStart);
    await repository.recordAnswer(
        card.id, model.CardReviewVariant.front, rating, _reviewStart, duration);
    // Remove cards that have been learnt
    if (rating != model.Rating.again) {
      _cards.removeAt(_currentIndex);
    }
    _progressToNextCard();
  }

  _progressToNextCard() {
    if (_cards.isEmpty) {
      return;
    }
    if (_reviewsSinceLastShuffle > _cards.length) {
      _cards.shuffle();
      _reviewsSinceLastShuffle = 0;
    } else {
      _reviewsSinceLastShuffle++;
    }
    _currentIndex = (_currentIndex + 1) % _cards.length;
    _reviewStart = currentClockDateTime;
    notifyListeners();
  }
}