import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';

import '../../model/cards.dart' as model;
import '../deck_list/decks_controller.dart';

part 'provisionary_cards_review_controller.g.dart';

/// Data class representing the provisionary cards review state
class ProvisionaryCardsReviewData {
  final List<model.ProvisionaryCard> provisionaryCards;
  final Set<int> finalizedCardsIndexes;
  final Set<int> discardedCardsIndexes;
  final int currentIndex;
  final String? lastDeckId;
  final bool doubleSided;
  final bool isLoading;
  final String? errorMessage;

  const ProvisionaryCardsReviewData({
    required this.provisionaryCards,
    required this.finalizedCardsIndexes,
    required this.discardedCardsIndexes,
    required this.currentIndex,
    this.lastDeckId,
    this.doubleSided = true,
    this.isLoading = false,
    this.errorMessage,
  });

  ProvisionaryCardsReviewData copyWith({
    List<model.ProvisionaryCard>? provisionaryCards,
    Set<int>? finalizedCardsIndexes,
    Set<int>? discardedCardsIndexes,
    int? currentIndex,
    String? lastDeckId,
    bool? doubleSided,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ProvisionaryCardsReviewData(
      provisionaryCards: provisionaryCards ?? this.provisionaryCards,
      finalizedCardsIndexes:
          finalizedCardsIndexes ?? this.finalizedCardsIndexes,
      discardedCardsIndexes:
          discardedCardsIndexes ?? this.discardedCardsIndexes,
      currentIndex: currentIndex ?? this.currentIndex,
      lastDeckId: lastDeckId ?? this.lastDeckId,
      doubleSided: doubleSided ?? this.doubleSided,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Gets the current provisionary card being reviewed
  model.ProvisionaryCard? get currentCard {
    if (currentIndex >= 0 && currentIndex < provisionaryCards.length) {
      return provisionaryCards[currentIndex];
    }
    return null;
  }

  /// Checks if all cards have been processed
  bool get isComplete {
    return finalizedCardsIndexes.length + discardedCardsIndexes.length ==
        provisionaryCards.length;
  }

  /// Gets the progress percentage
  double get progressPercentage {
    if (provisionaryCards.isEmpty) return 0.0;
    return (finalizedCardsIndexes.length + discardedCardsIndexes.length) /
        provisionaryCards.length;
  }
}

/// Controller for managing provisionary cards review operations
@riverpod
class ProvisionaryCardsReviewController
    extends _$ProvisionaryCardsReviewController {
  final Logger _log = Logger();

  @override
  AsyncValue<ProvisionaryCardsReviewData> build() {
    _loadProvisionaryCards();
    return const AsyncValue.loading();
  }

  /// Loads provisionary cards from the repository
  Future<void> _loadProvisionaryCards() async {
    try {
      _log.d('Loading provisionary cards');
      state = const AsyncValue.loading();
      final repository = ref.read(cardsRepositoryProvider);
      final provisionaryCards = await repository.listProvisionaryCards();
      final cardsList = provisionaryCards.toList();

      if (cardsList.isEmpty) {
        state = AsyncValue.data(
          ProvisionaryCardsReviewData(
            provisionaryCards: cardsList,
            finalizedCardsIndexes: {},
            discardedCardsIndexes: {},
            currentIndex: -1,
          ),
        );
      } else {
        state = AsyncValue.data(
          ProvisionaryCardsReviewData(
            provisionaryCards: cardsList,
            finalizedCardsIndexes: {},
            discardedCardsIndexes: {},
            currentIndex: 0,
          ),
        );
      }

      _log.d('Successfully loaded ${cardsList.length} provisionary cards');
    } catch (error, stackTrace) {
      _log.e(
        'Error loading provisionary cards',
        error: error,
        stackTrace: stackTrace,
      );
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Refreshes the provisionary cards data
  Future<void> refresh() async {
    await _loadProvisionaryCards();
  }

  /// Discards a provisionary card
  Future<void> discardCard(
    int index,
    model.ProvisionaryCard provisionaryCard,
  ) async {
    try {
      _log.d('Discarding provisionary card at index: $index');
      final currentData = state.value;
      if (currentData == null) return;

      state = AsyncValue.data(currentData.copyWith(isLoading: true));

      final repository = ref.read(cardsRepositoryProvider);
      await repository.finalizeProvisionaryCard(provisionaryCard.id, null);

      final newDiscardedIndexes = Set<int>.from(
        currentData.discardedCardsIndexes,
      );
      newDiscardedIndexes.add(index);

      final newCurrentIndex = _calculateNextIndex(
        currentData.provisionaryCards.length,
        currentData.finalizedCardsIndexes,
        newDiscardedIndexes,
        currentData.currentIndex,
      );

      state = AsyncValue.data(
        currentData.copyWith(
          discardedCardsIndexes: newDiscardedIndexes,
          currentIndex: newCurrentIndex,
          isLoading: false,
        ),
      );

      _log.d('Successfully discarded provisionary card at index: $index');
    } catch (error, stackTrace) {
      _log.e(
        'Error discarding provisionary card',
        error: error,
        stackTrace: stackTrace,
      );
      final currentData = state.value;
      if (currentData != null) {
        state = AsyncValue.data(
          currentData.copyWith(
            isLoading: false,
            errorMessage: error.toString(),
          ),
        );
      }
    }
  }

  /// Finalizes a provisionary card by creating a new card
  Future<void> finalizeCard(
    int index,
    model.ProvisionaryCard provisionaryCard,
    String deckId,
    String question,
    String answer,
    bool doubleSided,
  ) async {
    try {
      _log.d('Finalizing provisionary card at index: $index');
      final currentData = state.value;
      if (currentData == null) return;

      state = AsyncValue.data(currentData.copyWith(isLoading: true));

      final repository = ref.read(cardsRepositoryProvider);
      final cardId = repository.nextCardId();
      final card = model.Card(
        id: cardId,
        deckId: deckId,
        question: question,
        answer: answer,
        options: model.CardOptions(learnBothSides: doubleSided),
      );

      await repository.saveCard(card);
      await repository.finalizeProvisionaryCard(provisionaryCard.id, cardId);

      final newFinalizedIndexes = Set<int>.from(
        currentData.finalizedCardsIndexes,
      );
      newFinalizedIndexes.add(index);

      final newCurrentIndex = _calculateNextIndex(
        currentData.provisionaryCards.length,
        newFinalizedIndexes,
        currentData.discardedCardsIndexes,
        currentData.currentIndex,
      );

      state = AsyncValue.data(
        currentData.copyWith(
          finalizedCardsIndexes: newFinalizedIndexes,
          currentIndex: newCurrentIndex,
          lastDeckId: deckId,
          doubleSided: doubleSided,
          isLoading: false,
        ),
      );

      _log.d('Successfully finalized provisionary card at index: $index');
    } catch (error, stackTrace) {
      _log.e(
        'Error finalizing provisionary card',
        error: error,
        stackTrace: stackTrace,
      );
      final currentData = state.value;
      if (currentData != null) {
        state = AsyncValue.data(
          currentData.copyWith(
            isLoading: false,
            errorMessage: error.toString(),
          ),
        );
      }
    }
  }

  /// Moves to the next card (snooze action)
  void snoozeCard() {
    final currentData = state.value;
    if (currentData == null) return;

    final newCurrentIndex = _calculateNextIndex(
      currentData.provisionaryCards.length,
      currentData.finalizedCardsIndexes,
      currentData.discardedCardsIndexes,
      currentData.currentIndex,
    );

    state = AsyncValue.data(
      currentData.copyWith(currentIndex: newCurrentIndex),
    );
  }

  /// Calculates the next index to review
  int _calculateNextIndex(
    int totalCards,
    Set<int> finalizedIndexes,
    Set<int> discardedIndexes,
    int currentIndex,
  ) {
    if (finalizedIndexes.length + discardedIndexes.length == totalCards) {
      return -1; // All cards processed
    }

    int nextIndex = currentIndex;
    do {
      nextIndex = (nextIndex + 1) % totalCards;
    } while (finalizedIndexes.contains(nextIndex) ||
        discardedIndexes.contains(nextIndex));

    return nextIndex;
  }

  /// Clears any error message
  void clearError() {
    final currentData = state.value;
    if (currentData != null) {
      state = AsyncValue.data(currentData.copyWith(errorMessage: null));
    }
  }
}
