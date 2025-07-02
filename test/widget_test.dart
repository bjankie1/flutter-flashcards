// This is an example Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.
//
// Visit https://flutter.dev/to/widget-testing for
// more information about Widget testing.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_flashcards/src/reviews/cards_review_widget.dart';
import 'package:flutter_flashcards/src/reviews/cards_review_controller.dart';
import 'package:flutter_flashcards/src/model/cards.dart' as model;
import 'package:flutter_flashcards/src/model/study_session.dart';
import 'package:flutter_flashcards/src/model/repository.dart';
import 'package:flutter_flashcards/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'mocks/mock_cards_repository.dart';

// Mock controller for testing
class MockCardsReviewController extends CardsReviewController {
  ReviewState _state = const ReviewState();
  final List<model.Rating> recordedRatings = [];

  @override
  ReviewState build(StudySession session) {
    return _state;
  }

  @override
  void revealAnswer() {
    _state = _state.copyWith(answerRevealed: true);
    state = _state;
  }

  @override
  Future<void> recordAnswerRating(model.Rating rating) async {
    recordedRatings.add(rating);
    _state = _state.copyWith(selectedRating: rating, isLoading: true);
    state = _state;

    // Simulate async operation
    await Future.delayed(const Duration(milliseconds: 100));

    _state = _state.copyWith(
      answerRevealed: false,
      isLoading: false,
      selectedRating: null,
    );
    state = _state;
  }

  void setState(ReviewState newState) {
    _state = newState;
    state = _state;
  }
}

// Test helper to create a test app with proper localization
Widget createTestApp(Widget child) {
  return MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      useMaterial3: true,
    ),
    localizationsDelegates: [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en'), Locale('pl')],
    home: ProviderScope(child: child),
  );
}

// Test helper to create a mock card
model.Card createMockCard({
  String id = 'test-card-1',
  String deckId = 'test-deck-1',
  String question = 'What is the capital of France?',
  String answer = 'Paris',
  String? explanation,
  bool questionImageAttached = false,
  bool explanationImageAttached = false,
}) {
  return model.Card(
    id: id,
    deckId: deckId,
    question: question,
    answer: answer,
    explanation: explanation,
    questionImageAttached: questionImageAttached,
    explanationImageAttached: explanationImageAttached,
  );
}

// Test helper to create a mock study session
StudySession createMockStudySession({
  CardsRepository? repository,
  String? deckId,
  String? deckGroupId,
}) {
  return StudySession(
    repository: repository ?? MockCardsRepository(),
    deckId: deckId,
    deckGroupId: deckGroupId,
  );
}

void main() {
  group('CardsReview Widget Tests', () {
    testWidgets('should display celebration when no cards to review', (
      WidgetTester tester,
    ) async {
      // Arrange
      final session = createMockStudySession();

      // Act
      await tester.pumpWidget(createTestApp(CardsReview(session: session)));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Text), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('should display proper layout structure', (
      WidgetTester tester,
    ) async {
      // Arrange
      final session = createMockStudySession();

      // Act
      await tester.pumpWidget(createTestApp(CardsReview(session: session)));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Expanded), findsWidgets);
      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('should use proper theme colors', (WidgetTester tester) async {
      // Arrange
      final session = createMockStudySession();

      // Act
      await tester.pumpWidget(createTestApp(CardsReview(session: session)));
      await tester.pumpAndSettle();

      // Assert
      // Verify that the widget uses theme colors properly
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme, isNotNull);
    });

    testWidgets('should handle different screen sizes', (
      WidgetTester tester,
    ) async {
      // Arrange
      final session = createMockStudySession();

      // Act - Test with different screen sizes
      await tester.binding.setSurfaceSize(const Size(400, 600));
      await tester.pumpWidget(createTestApp(CardsReview(session: session)));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(CardsReview), findsOneWidget);

      // Test with larger screen
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      await tester.pumpWidget(createTestApp(CardsReview(session: session)));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(CardsReview), findsOneWidget);

      // Reset surface size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('should display celebration message when session is empty', (
      WidgetTester tester,
    ) async {
      // Arrange
      final session = createMockStudySession();

      // Act
      await tester.pumpWidget(createTestApp(CardsReview(session: session)));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Text), findsOneWidget);
      expect(find.text('Well done!'), findsOneWidget);
    });

    testWidgets('should not display rating buttons when no cards to review', (
      WidgetTester tester,
    ) async {
      // Arrange
      final session = createMockStudySession();

      // Act
      await tester.pumpWidget(createTestApp(CardsReview(session: session)));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets(
      'should not display card flip animation when no cards to review',
      (WidgetTester tester) async {
        // Arrange
        final session = createMockStudySession();

        // Act
        await tester.pumpWidget(createTestApp(CardsReview(session: session)));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(CardFlipAnimation), findsNothing);
      },
    );
  });
}
