import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/cards.dart' as model;
import '../model/study_session.dart';

part 'cards_review_controller.g.dart';

/// Data class representing the current review state
class ReviewState {
  final bool answerRevealed;
  final model.Rating? selectedRating;
  final bool isLoading;
  final String? errorMessage;

  const ReviewState({
    this.answerRevealed = false,
    this.selectedRating,
    this.isLoading = false,
    this.errorMessage,
  });

  ReviewState copyWith({
    bool? answerRevealed,
    model.Rating? selectedRating,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ReviewState(
      answerRevealed: answerRevealed ?? this.answerRevealed,
      selectedRating: selectedRating ?? this.selectedRating,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Controller for managing card review operations
@riverpod
class CardsReviewController extends _$CardsReviewController {
  final Logger _log = Logger();
  late StudySession _session;

  @override
  ReviewState build(StudySession session) {
    _session = session;
    return const ReviewState();
  }

  /// Reveals the answer for the current card
  void revealAnswer() {
    _log.d('Revealing answer for current card');
    state = state.copyWith(answerRevealed: true);
  }

  /// Records a rating for the current card
  Future<void> recordAnswerRating(model.Rating rating) async {
    try {
      _log.d('Recording answer rating: $rating');
      state = state.copyWith(
        isLoading: true,
        selectedRating: rating,
        errorMessage: null,
      );

      await _session.rateAnswer(rating);

      state = state.copyWith(
        answerRevealed: false,
        isLoading: false,
        selectedRating: null,
      );

      _log.d('Successfully recorded answer rating: $rating');
    } catch (error, stackTrace) {
      _log.e(
        'Error recording answer rating: $rating',
        error: error,
        stackTrace: stackTrace,
      );
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error recording answer',
      );
    }
  }

  /// Gets the current card being reviewed
  (model.CardReviewVariant, model.Card)? get currentCard =>
      _session.currentCard;

  /// Gets the number of remaining cards
  int get remainingCards => _session.remainingCards;

  /// Checks if the session is completed (no more cards)
  bool get isSessionCompleted => _session.remainingCards == 0;

  /// Gets the current review state
  ReviewState get reviewState => state;
}
