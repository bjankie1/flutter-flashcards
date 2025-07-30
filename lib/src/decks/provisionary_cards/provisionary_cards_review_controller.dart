import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';

import '../../model/cards.dart' as model;
import '../deck_list/decks_controller.dart';
import '../../genkit/functions.dart';

part 'provisionary_cards_review_controller.g.dart';

/// Data class representing the provisionary cards review state
class ProvisionaryCardsReviewData {
  final List<model.ProvisionaryCard> provisionaryCards;
  final int currentIndex;
  final String? lastDeckId;
  final bool doubleSided;
  final bool isLoading;
  final String? errorMessage;

  // Card finalization state
  final bool isQuestion;
  final String questionText;
  final String answerText;
  final String explanationText;
  final bool fetchingSuggestion;
  final String? selectedDeckId;
  final bool selectedDoubleSided;

  // Track completed cards to keep them visible
  final Set<String> completedCardIds;
  final Set<String> discardedCardIds;

  const ProvisionaryCardsReviewData({
    required this.provisionaryCards,
    required this.currentIndex,
    this.lastDeckId,
    this.doubleSided = true,
    this.isLoading = false,
    this.errorMessage,
    this.isQuestion = true,
    this.questionText = '',
    this.answerText = '',
    this.explanationText = '',
    this.fetchingSuggestion = false,
    this.selectedDeckId,
    this.selectedDoubleSided = true,
    this.completedCardIds = const {},
    this.discardedCardIds = const {},
  });

  ProvisionaryCardsReviewData copyWith({
    List<model.ProvisionaryCard>? provisionaryCards,
    int? currentIndex,
    String? lastDeckId,
    bool? doubleSided,
    bool? isLoading,
    String? errorMessage,
    bool? isQuestion,
    String? questionText,
    String? answerText,
    String? explanationText,
    bool? fetchingSuggestion,
    String? selectedDeckId,
    bool? selectedDoubleSided,
    Set<String>? completedCardIds,
    Set<String>? discardedCardIds,
  }) {
    return ProvisionaryCardsReviewData(
      provisionaryCards: provisionaryCards ?? this.provisionaryCards,
      currentIndex: currentIndex ?? this.currentIndex,
      lastDeckId: lastDeckId ?? this.lastDeckId,
      doubleSided: doubleSided ?? this.doubleSided,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isQuestion: isQuestion ?? this.isQuestion,
      questionText: questionText ?? this.questionText,
      answerText: answerText ?? this.answerText,
      explanationText: explanationText ?? this.explanationText,
      fetchingSuggestion: fetchingSuggestion ?? this.fetchingSuggestion,
      selectedDeckId: selectedDeckId ?? this.selectedDeckId,
      selectedDoubleSided: selectedDoubleSided ?? this.selectedDoubleSided,
      completedCardIds: completedCardIds ?? this.completedCardIds,
      discardedCardIds: discardedCardIds ?? this.discardedCardIds,
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
    return provisionaryCards.isEmpty; // No more cards in the list
  }

  /// Gets the progress percentage
  double get progressPercentage {
    if (provisionaryCards.isEmpty) return 0.0;
    return (provisionaryCards.length - currentIndex) / provisionaryCards.length;
  }

  /// Gets the count of unprocessed provisionary cards (for badge display)
  int get unprocessedCardsCount {
    return provisionaryCards
        .where(
          (card) =>
              !completedCardIds.contains(card.id) &&
              !discardedCardIds.contains(card.id),
        )
        .length;
  }

  /// Checks if a card has been completed
  bool isCardCompleted(String cardId) {
    return completedCardIds.contains(cardId);
  }

  /// Checks if a card has been discarded
  bool isCardDiscarded(String cardId) {
    return discardedCardIds.contains(cardId);
  }

  /// Checks if a card is still pending (not completed or discarded)
  bool isCardPending(String cardId) {
    return !completedCardIds.contains(cardId) &&
        !discardedCardIds.contains(cardId);
  }
}

/// Controller for managing provisionary cards review operations
@riverpod
class ProvisionaryCardsReviewController
    extends _$ProvisionaryCardsReviewController {
  final Logger _log = Logger();

  @override
  AsyncValue<ProvisionaryCardsReviewData> build() {
    // Return initial empty state, then load data
    _initializeData();
    return AsyncValue.data(
      ProvisionaryCardsReviewData(provisionaryCards: [], currentIndex: -1),
    );
  }

  /// Initialize data loading after build
  void _initializeData() {
    // Use Future.microtask to avoid calling async methods directly from build
    Future.microtask(() => _loadProvisionaryCards());
  }

  /// Loads provisionary cards from the repository
  Future<void> _loadProvisionaryCards() async {
    try {
      _log.d('Loading provisionary cards');

      // Preserve current context before loading, but handle uninitialized state
      final currentData = state.valueOrNull;
      final lastDeckId = currentData?.lastDeckId;
      final doubleSided = currentData?.doubleSided ?? true;

      _log.d('Current state: lastDeckId=$lastDeckId, doubleSided=$doubleSided');

      state = const AsyncValue.loading();
      _log.d('Set state to loading');

      final repository = ref.read(cardsRepositoryProvider);
      _log.d('Got repository, calling listProvisionaryCards');

      final provisionaryCards = await repository.listProvisionaryCards();
      final cardsList = provisionaryCards.toList();

      _log.d('Repository returned ${cardsList.length} provisionary cards');

      if (cardsList.isEmpty) {
        _log.d('No provisionary cards found, setting empty state');
        state = AsyncValue.data(
          ProvisionaryCardsReviewData(
            provisionaryCards: cardsList,
            currentIndex: -1,
            lastDeckId: lastDeckId,
            doubleSided: doubleSided,
          ),
        );
      } else {
        _log.d(
          'Found ${cardsList.length} provisionary cards, setting first card as current',
        );
        final firstCard = cardsList[0];
        final newState = ProvisionaryCardsReviewData(
          provisionaryCards: cardsList,
          currentIndex: 0,
          lastDeckId: lastDeckId,
          doubleSided: doubleSided,
          questionText: firstCard.text,
          answerText: '',
        );

        state = AsyncValue.data(newState);

        // Note: AI generation will be triggered when the user selects a deck
        // or when the widget calls triggerGeneration with cloudFunctions
      }

      _log.d('Successfully loaded ${cardsList.length} provisionary cards');
    } catch (error, stackTrace) {
      _log.e(
        'Error loading provisionary cards',
        error: error,
        stackTrace: stackTrace,
      );

      // If the error is due to user not being authenticated, set empty state
      if (error.toString().contains('User not logged in') ||
          error.toString().contains('not logged')) {
        _log.d('User is not authenticated, setting empty state');
        final currentData = state.valueOrNull;
        final lastDeckId = currentData?.lastDeckId;
        final doubleSided = currentData?.doubleSided ?? true;

        state = AsyncValue.data(
          ProvisionaryCardsReviewData(
            provisionaryCards: [],
            currentIndex: -1,
            lastDeckId: lastDeckId,
            doubleSided: doubleSided,
          ),
        );
      } else {
        state = AsyncValue.error(error, stackTrace);
      }
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

      // Mark the card as discarded locally instead of refreshing
      final newDiscardedIds = Set<String>.from(currentData.discardedCardIds)
        ..add(provisionaryCard.id);

      // Move to the next pending card
      final nextIndex = _findNextPendingCardIndex(
        currentData.provisionaryCards,
        newDiscardedIds,
        currentData.completedCardIds,
      );

      // Update form fields for the next card
      String? nextQuestionText;
      String? nextAnswerText;
      if (nextIndex >= 0 && nextIndex < currentData.provisionaryCards.length) {
        final nextCard = currentData.provisionaryCards[nextIndex];
        nextQuestionText = currentData.isQuestion ? nextCard.text : '';
        nextAnswerText = currentData.isQuestion ? '' : nextCard.text;
      }

      state = AsyncValue.data(
        currentData.copyWith(
          isLoading: false,
          discardedCardIds: newDiscardedIds,
          currentIndex: nextIndex,
          questionText: nextQuestionText ?? '',
          answerText: nextAnswerText ?? '',
          explanationText: '',
          fetchingSuggestion: false,
        ),
      );

      // Trigger AI generation for the next card if we have a deck selected
      if (nextIndex >= 0 && nextIndex < currentData.provisionaryCards.length) {
        // Note: We don't have cloudFunctions in discardCard, so we'll trigger generation
        // when the user selects a deck or manually saves the field
      }

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
    String explanation,
    bool doubleSided, {
    CloudFunctions? cloudFunctions,
  }) async {
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
        explanation: explanation.isNotEmpty ? explanation : null,
        options: model.CardOptions(learnBothSides: doubleSided),
      );

      await repository.saveCard(card);
      await repository.finalizeProvisionaryCard(provisionaryCard.id, cardId);

      // Mark the card as completed locally instead of refreshing
      final newCompletedIds = Set<String>.from(currentData.completedCardIds)
        ..add(provisionaryCard.id);

      // Move to the next pending card
      final nextIndex = _findNextPendingCardIndex(
        currentData.provisionaryCards,
        currentData.discardedCardIds,
        newCompletedIds,
      );

      // Update form fields for the next card
      String? nextQuestionText;
      String? nextAnswerText;
      if (nextIndex >= 0 && nextIndex < currentData.provisionaryCards.length) {
        final nextCard = currentData.provisionaryCards[nextIndex];
        nextQuestionText = currentData.isQuestion ? nextCard.text : '';
        nextAnswerText = currentData.isQuestion ? '' : nextCard.text;
      }

      // Set the form fields and trigger generation if we have cloudFunctions
      if (cloudFunctions != null) {
        if (currentData.isQuestion) {
          await setQuestionTextAndGenerate(
            nextQuestionText ?? '',
            cloudFunctions,
          );
        } else {
          await setAnswerTextAndGenerate(nextAnswerText ?? '', cloudFunctions);
        }
      } else {
        // Fallback: just set the fields without generation
        state = AsyncValue.data(
          currentData.copyWith(
            isLoading: false,
            completedCardIds: newCompletedIds,
            currentIndex: nextIndex,
            questionText: nextQuestionText ?? '',
            answerText: nextAnswerText ?? '',
            explanationText: '',
            fetchingSuggestion: false,
          ),
        );
      }

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
      currentData.currentIndex,
    );

    final newState = currentData.copyWith(currentIndex: newCurrentIndex);

    // Reset card finalization state for the new card
    if (newCurrentIndex >= 0 &&
        newCurrentIndex < currentData.provisionaryCards.length) {
      final newCard = currentData.provisionaryCards[newCurrentIndex];
      final resetState = newState.copyWith(
        questionText: newState.isQuestion ? newCard.text : '',
        answerText: newState.isQuestion ? '' : newCard.text,
        explanationText: '',
        selectedDeckId: newState.lastDeckId,
        selectedDoubleSided: newState.doubleSided,
        fetchingSuggestion: false,
      );
      state = AsyncValue.data(resetState);
    } else {
      state = AsyncValue.data(newState);
    }
  }

  /// Calculates the next index to review
  int _calculateNextIndex(int totalCards, int currentIndex) {
    if (totalCards == 0) {
      return -1; // All cards processed
    }

    int nextIndex = currentIndex;
    do {
      nextIndex = (nextIndex + 1) % totalCards;
    } while (nextIndex == currentIndex &&
        totalCards > 1); // Avoid infinite loop

    return nextIndex;
  }

  /// Finds the next pending card index (not completed or discarded)
  int _findNextPendingCardIndex(
    List<model.ProvisionaryCard> cards,
    Set<String> discardedIds,
    Set<String> completedIds,
  ) {
    if (cards.isEmpty) return -1;

    // Start from the current index and look for the next pending card
    for (int i = 0; i < cards.length; i++) {
      final card = cards[i];
      if (!discardedIds.contains(card.id) && !completedIds.contains(card.id)) {
        return i;
      }
    }

    return -1; // No pending cards found
  }

  /// Clears any error message
  void clearError() {
    final currentData = state.value;
    if (currentData != null) {
      state = AsyncValue.data(currentData.copyWith(errorMessage: null));
    }
  }

  // Card finalization state management methods

  /// Sets whether the user is editing the question or answer
  Future<void> setIsQuestion(
    bool isQuestion,
    CloudFunctions? cloudFunctions,
  ) async {
    final currentData = state.value;
    if (currentData != null) {
      final currentCard = currentData.currentCard;
      if (currentCard == null) return;

      // Preserve user edits when switching modes
      String newQuestionText;
      String newAnswerText;

      if (isQuestion) {
        // Switching to question mode: move answer text to question field and generate new answer
        newQuestionText = currentData.answerText.isNotEmpty
            ? currentData.answerText
            : currentCard.text;
        newAnswerText = '';
      } else {
        // Switching to answer mode: move question text to answer field and generate new question
        newAnswerText = currentData.questionText.isNotEmpty
            ? currentData.questionText
            : currentCard.text;
        newQuestionText = '';
      }

      state = AsyncValue.data(
        currentData.copyWith(
          isQuestion: isQuestion,
          questionText: newQuestionText,
          answerText: newAnswerText,
          explanationText: '',
        ),
      );

      // Generate content based on the mode and current text
      if (currentData.selectedDeckId != null && cloudFunctions != null) {
        if (isQuestion) {
          // Question mode: generate answer for the current question text
          await _generateAnswer(
            currentData.selectedDeckId!,
            newQuestionText,
            cloudFunctions,
            flipDescriptions: false,
          );
        } else {
          // Answer mode: generate question for the current answer text
          await _generateAnswer(
            currentData.selectedDeckId!,
            newAnswerText,
            cloudFunctions,
            flipDescriptions: true,
          );
        }
      }
    }
  }

  /// Sets the question text
  void setQuestionText(String questionText) {
    final currentData = state.value;
    if (currentData != null) {
      state = AsyncValue.data(currentData.copyWith(questionText: questionText));
    }
  }

  /// Sets the question text and optionally triggers generation
  Future<void> setQuestionTextAndGenerate(
    String questionText,
    CloudFunctions? cloudFunctions,
  ) async {
    final currentData = state.value;
    if (currentData != null) {
      state = AsyncValue.data(currentData.copyWith(questionText: questionText));

      // Trigger generation if we're in question mode and have a deck selected
      if (currentData.isQuestion &&
          currentData.selectedDeckId != null &&
          cloudFunctions != null) {
        await triggerGeneration(cloudFunctions);
      }
    }
  }

  /// Sets the answer text
  void setAnswerText(String answerText) {
    final currentData = state.value;
    if (currentData != null) {
      state = AsyncValue.data(currentData.copyWith(answerText: answerText));
    }
  }

  /// Sets the answer text and optionally triggers generation
  Future<void> setAnswerTextAndGenerate(
    String answerText,
    CloudFunctions? cloudFunctions,
  ) async {
    final currentData = state.value;
    if (currentData != null) {
      state = AsyncValue.data(currentData.copyWith(answerText: answerText));

      // Trigger generation if we're in answer mode and have a deck selected
      if (!currentData.isQuestion &&
          currentData.selectedDeckId != null &&
          cloudFunctions != null) {
        await triggerGeneration(cloudFunctions);
      }
    }
  }

  /// Sets the explanation text
  void setExplanationText(String explanationText) {
    final currentData = state.value;
    if (currentData != null) {
      state = AsyncValue.data(
        currentData.copyWith(explanationText: explanationText),
      );
    }
  }

  /// Triggers generation based on current mode and content
  Future<void> triggerGeneration(CloudFunctions? cloudFunctions) async {
    final currentData = state.value;
    if (currentData == null || cloudFunctions == null) return;

    if (currentData.selectedDeckId == null) return;

    if (currentData.isQuestion &&
        currentData.questionText.isNotEmpty &&
        currentData.answerText.isEmpty) {
      // Question mode: generate answer
      await _generateAnswer(
        currentData.selectedDeckId!,
        currentData.questionText,
        cloudFunctions,
        flipDescriptions: false,
      );
    } else if (!currentData.isQuestion &&
        currentData.answerText.isNotEmpty &&
        currentData.questionText.isEmpty) {
      // Answer mode: generate question
      await _generateAnswer(
        currentData.selectedDeckId!,
        currentData.answerText,
        cloudFunctions,
        flipDescriptions: true,
      );
    }
  }

  /// Sets the fetching suggestion state
  void setFetchingSuggestion(bool fetchingSuggestion) {
    final currentData = state.value;
    if (currentData != null) {
      state = AsyncValue.data(
        currentData.copyWith(fetchingSuggestion: fetchingSuggestion),
      );
    }
  }

  /// Sets the selected deck ID and triggers answer generation if needed
  Future<void> setSelectedDeckId(
    String? selectedDeckId,
    CloudFunctions? cloudFunctions,
  ) async {
    final currentData = state.value;
    if (currentData != null) {
      state = AsyncValue.data(
        currentData.copyWith(selectedDeckId: selectedDeckId),
      );

      // Generate content if deck is selected and we have content to generate from
      if (selectedDeckId != null && cloudFunctions != null) {
        if (currentData.isQuestion &&
            currentData.questionText.isNotEmpty &&
            currentData.answerText.isEmpty) {
          // Question mode: generate answer
          await _generateAnswer(
            selectedDeckId,
            currentData.questionText,
            cloudFunctions,
            flipDescriptions: false,
          );
        } else if (!currentData.isQuestion &&
            currentData.answerText.isNotEmpty &&
            currentData.questionText.isEmpty) {
          // Answer mode: generate question
          await _generateAnswer(
            selectedDeckId,
            currentData.answerText,
            cloudFunctions,
            flipDescriptions: true,
          );
        }
      }
    }
  }

  /// Sets the selected double sided state
  void setSelectedDoubleSided(bool selectedDoubleSided) {
    final currentData = state.value;
    if (currentData != null) {
      state = AsyncValue.data(
        currentData.copyWith(selectedDoubleSided: selectedDoubleSided),
      );
    }
  }

  /// Resets the card finalization state for a new card
  void resetCardFinalization(model.ProvisionaryCard provisionaryCard) {
    final currentData = state.value;
    if (currentData != null) {
      final isQuestion = currentData.isQuestion;
      state = AsyncValue.data(
        currentData.copyWith(
          isQuestion: isQuestion,
          questionText: isQuestion ? provisionaryCard.text : '',
          answerText: isQuestion ? '' : provisionaryCard.text,
          explanationText: '',
          selectedDeckId: currentData.lastDeckId,
          selectedDoubleSided: currentData.doubleSided,
          fetchingSuggestion: false,
        ),
      );
    }
  }

  /// Checks if the card finalization is complete (all required fields are filled)
  bool get isCardFinalizationComplete {
    final currentData = state.value;
    if (currentData == null) return false;

    return currentData.questionText.isNotEmpty &&
        currentData.answerText.isNotEmpty &&
        currentData.selectedDeckId != null;
  }

  /// Generates an answer for the current question using the selected deck
  Future<void> _generateAnswer(
    String deckId,
    String question,
    CloudFunctions cloudFunctions, {
    bool flipDescriptions = false,
  }) async {
    try {
      final currentData = state.value;
      if (currentData == null) return;

      _log.d('Generating answer for question: "$question" in deck: $deckId');

      // Set loading state
      state = AsyncValue.data(currentData.copyWith(fetchingSuggestion: true));

      // Get the deck details
      final repository = ref.read(cardsRepositoryProvider);
      final deck = await repository.loadDeck(deckId);

      if (deck == null) {
        _log.e('Deck not found: $deckId');
        state = AsyncValue.data(
          currentData.copyWith(fetchingSuggestion: false),
        );
        return;
      }

      // Use translated descriptions if available, otherwise fall back to original
      final effectiveFrontDescription =
          deck.frontCardDescriptionTranslated ?? deck.frontCardDescription;
      final effectiveBackDescription =
          deck.backCardDescriptionTranslated ?? deck.backCardDescription;
      final effectiveExplanationDescription =
          deck.explanationDescriptionTranslated ?? deck.explanationDescription;

      // Check if required descriptions are available
      if (effectiveFrontDescription == null ||
          effectiveBackDescription == null) {
        _log.w('Deck missing required descriptions: ${deck.name}');
        state = AsyncValue.data(
          currentData.copyWith(fetchingSuggestion: false),
        );
        return;
      }

      GeneratedAnswer generatedAnswer;

      if (flipDescriptions) {
        // Generating front from back: use the dedicated function
        generatedAnswer = await cloudFunctions.generateFrontFromBack(
          deck.name,
          deck.description ?? '',
          question, // This is actually the back content
          effectiveFrontDescription,
          effectiveBackDescription,
          explanationDescription: effectiveExplanationDescription,
        );
      } else {
        // Generating back from front: use the normal function
        generatedAnswer = await cloudFunctions.generateCardAnswer(
          deck.name,
          deck.description ?? '',
          question,
          effectiveFrontDescription,
          effectiveBackDescription,
          explanationDescription: effectiveExplanationDescription,
        );
      }

      // Update state with generated content
      final updatedData = currentData.copyWith(
        questionText: flipDescriptions
            ? generatedAnswer.answer
            : currentData.questionText,
        answerText: flipDescriptions
            ? currentData.answerText
            : generatedAnswer.answer,
        explanationText: generatedAnswer.explanation,
        fetchingSuggestion: false,
      );

      state = AsyncValue.data(updatedData);
      _log.d('Successfully generated answer: "${generatedAnswer.answer}"');
    } catch (error, stackTrace) {
      _log.e('Error generating answer', error: error, stackTrace: stackTrace);

      final currentData = state.value;
      if (currentData != null) {
        state = AsyncValue.data(
          currentData.copyWith(fetchingSuggestion: false),
        );
      }
    }
  }
}
