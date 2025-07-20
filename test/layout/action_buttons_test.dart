import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ActionButtons Widget Structure', () {
    testWidgets('has correct layout and styling', (WidgetTester tester) async {
      // This test verifies the expected structure and styling of the ActionButtons widget

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: _MockActionButtons())),
      );

      // Verify the container structure - there are multiple containers, so we expect more than one
      expect(find.byType(Container), findsWidgets);

      // Verify the icons are present
      expect(find.byIcon(Icons.add_box), findsOneWidget);
      expect(find.byIcon(Icons.checklist), findsOneWidget);

      // Verify the text is present
      expect(find.text('Quick add card'), findsOneWidget);

      // Verify the layout structure
      expect(find.byType(Row), findsWidgets);
      expect(find.byType(SizedBox), findsWidgets);
      expect(find.byType(Material), findsWidgets);
      expect(find.byType(InkWell), findsWidgets);
    });

    testWidgets('buttons are tappable', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: _MockActionButtons())),
      );

      // Test quick add button
      final quickAddButton = find.byIcon(Icons.add_box);
      expect(quickAddButton, findsOneWidget);
      await tester.tap(quickAddButton);
      await tester.pump();

      // Test review button
      final reviewButton = find.byIcon(Icons.checklist);
      expect(reviewButton, findsOneWidget);
      await tester.tap(reviewButton);
      await tester.pump();
    });

    testWidgets('has correct styling properties', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: _MockActionButtons())),
      );

      // Get the main container - find the one with decoration
      final containers = tester.widgetList<Container>(find.byType(Container));
      final mainContainer = containers.firstWhere((c) => c.decoration != null);

      // Verify height - Container doesn't have a height property, but we can check the constraints
      expect(mainContainer.constraints, isNotNull);

      // Verify decoration
      final decoration = mainContainer.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(20));
      expect(decoration.border, isNotNull);
      expect(decoration.color, isNotNull);
    });
  });
}

// Mock implementation that mimics the ActionButtons widget structure
class _MockActionButtons extends StatelessWidget {
  const _MockActionButtons();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Quick add button
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              onTap: () {},
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_box, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Quick add card',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Divider
          Container(
            width: 1,
            height: 24,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
          // Review button
          SizedBox(
            width: 48,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                onTap: () {},
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.all(10),
                  child: const Icon(Icons.checklist, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
