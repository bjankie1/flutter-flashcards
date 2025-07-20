import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_flashcards/src/common/category_image.dart';
import 'package:flutter_flashcards/src/model/enums.dart';

void main() {
  group('CategoryImage', () {
    testWidgets('displays image for each category', (
      WidgetTester tester,
    ) async {
      for (final category in DeckCategory.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: CategoryImage(category: category, size: 32)),
          ),
        );

        // Verify that the widget builds without errors
        expect(find.byType(CategoryImage), findsOneWidget);

        // Verify that an image widget is present
        expect(find.byType(Image), findsOneWidget);
      }
    });

    testWidgets('applies custom size', (WidgetTester tester) async {
      const testSize = 64.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryImage(
              category: DeckCategory.language,
              size: testSize,
            ),
          ),
        ),
      );

      final imageWidget = tester.widget<Image>(find.byType(Image));
      expect(imageWidget.width, equals(testSize));
      expect(imageWidget.height, equals(testSize));
    });

    testWidgets('applies borderRadius when provided', (
      WidgetTester tester,
    ) async {
      const borderRadius = BorderRadius.all(Radius.circular(16));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryImage(
              category: DeckCategory.history,
              size: 32,
              borderRadius: borderRadius,
            ),
          ),
        ),
      );

      // Verify that ClipRRect is present when borderRadius is provided
      expect(find.byType(ClipRRect), findsOneWidget);
    });

    testWidgets('does not apply borderRadius when not provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryImage(category: DeckCategory.science, size: 32),
          ),
        ),
      );

      // Verify that ClipRRect is not present when borderRadius is not provided
      expect(find.byType(ClipRRect), findsNothing);
    });
  });
}
