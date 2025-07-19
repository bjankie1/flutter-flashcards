import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';

import '../../model/cards.dart' as model;
import '../deck_list/decks_controller.dart';
import '../../genkit/functions.dart';

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

  // Card finalization state
  final bool isQuestion;
  final String questionText;
  final String answerText;
  final String explanationText;
  final bool fetchingSuggestion;
  final String? selectedDeckId;
  final bool selectedDoubleSided;

  const ProvisionaryCardsReviewData({
    required this.provisionaryCards,
    required this.finalizedCardsIndexes,
    required this.discardedCardsIndexes,
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
    bool? isQuestion,
    String? questionText,
    String? answerText,
    String? explanationText,
    bool? fetchingSuggestion,
    String? selectedDeckId,
    bool? selectedDoubleSided,
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
      isQuestion: isQuestion ?? this.isQuestion,
      questionText: questionText ?? this.questionText,
      answerText: answerText ?? this.answerText,
      explanationText: explanationText ?? this.explanationText,
      fetchingSuggestion: fetchingSuggestion ?? this.fetchingSuggestion,
      selectedDeckId: selectedDeckId ?? this.selectedDeckId,
      selectedDoubleSided: selectedDoubleSided ?? this.selectedDoubleSided,
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
        final firstCard = cardsList[0];
        state = AsyncValue.data(
          ProvisionaryCardsReviewData(
            provisionaryCards: cardsList,
            finalizedCardsIndexes: {},
            discardedCardsIndexes: {},
            currentIndex: 0,
            questionText: firstCard.text,
            answerText: '',
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

      final newState = currentData.copyWith(
        discardedCardsIndexes: newDiscardedIndexes,
        currentIndex: newCurrentIndex,
        isLoading: false,
      );

      // Reset card finalization state for the new card
      if (newCurrentIndex >= 0 &&
          newCurrentIndex < currentData.provisionaryCards.length) {
        final newCard = currentData.provisionaryCards[newCurrentIndex];
        final resetState = newState.copyWith(
          questionText: newState.isQuestion ? newCard.text : '',
          answerText: newState.isQuestion ? '' : newCard.text,
          selectedDeckId: newState.lastDeckId,
          selectedDoubleSided: newState.doubleSided,
          fetchingSuggestion: false,
        );
        state = AsyncValue.data(resetState);
      } else {
        state = AsyncValue.data(newState);
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

      final newState = currentData.copyWith(
        finalizedCardsIndexes: newFinalizedIndexes,
        currentIndex: newCurrentIndex,
        lastDeckId: deckId,
        doubleSided: doubleSided,
        isLoading: false,
      );

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

        // Trigger generation for the next card based on current settings
        if (newState.lastDeckId != null && cloudFunctions != null) {
          if (newState.isQuestion) {
            // Question mode: generate answer for the card text
            await _generateAnswer(
              newState.lastDeckId!,
              newCard.text,
              cloudFunctions,
              flipDescriptions: false,
            );
          } else {
            // Answer mode: generate question for the card text
            await _generateAnswer(
              newState.lastDeckId!,
              newCard.text,
              cloudFunctions,
              flipDescriptions: true,
            );
          }
        }
      } else {
        state = AsyncValue.data(newState);
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
      currentData.finalizedCardsIndexes,
      currentData.discardedCardsIndexes,
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

  /// Sets the answer text
  void setAnswerText(String answerText) {
    final currentData = state.value;
    if (currentData != null) {
      state = AsyncValue.data(currentData.copyWith(answerText: answerText));
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
      final effectiveReverseFrontDescription = deck.reverseFrontDescription;

      // Use appropriate descriptions based on the generation direction
      String? finalFrontDescription;
      String? finalBackDescription;

      if (flipDescriptions) {
        // Generating question from answer: use reverse description for front
        finalFrontDescription =
            effectiveReverseFrontDescription ?? effectiveBackDescription;
        finalBackDescription = effectiveFrontDescription;
      } else {
        // Generating answer from question: use normal descriptions
        finalFrontDescription = effectiveFrontDescription;
        finalBackDescription = effectiveBackDescription;
      }

      // Check if required descriptions are available
      if (finalFrontDescription == null || finalBackDescription == null) {
        _log.w('Deck missing required descriptions: ${deck.name}');
        state = AsyncValue.data(
          currentData.copyWith(fetchingSuggestion: false),
        );
        return;
      }

      final generatedAnswer = await cloudFunctions.generateCardAnswer(
        deck.name,
        deck.description ?? '',
        question,
        finalFrontDescription,
        finalBackDescription,
        explanationDescription: effectiveExplanationDescription,
      );

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
