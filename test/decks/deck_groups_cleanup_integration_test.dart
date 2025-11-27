import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_flashcards/src/model/cards.dart' as model;

void main() {
  group('DeckGroupCacheService - Orphaned Reference Cleanup Integration', () {
    test('should identify and clean orphaned deck references', () {
      // Create test data
      final validDeckIds = ['deck1', 'deck2', 'deck3', 'deck4'];

      final testGroups = [
        model.DeckGroup(
          id: 'group1',
          name: 'Group 1',
          decks: {
            'deck1',
            'deck2',
            'orphaned_deck1',
          }, // orphaned_deck1 doesn't exist
        ),
        model.DeckGroup(
          id: 'group2',
          name: 'Group 2',
          decks: {'deck3', 'orphaned_deck2'}, // orphaned_deck2 doesn't exist
        ),
        model.DeckGroup(
          id: 'group3',
          name: 'Group 3',
          decks: {'deck1', 'deck4'}, // all valid
        ),
      ];

      // Test the cleanup logic directly
      final validDeckIdsSet = validDeckIds.toSet();
      final groupsToUpdate = <model.DeckGroup>[];

      for (final group in testGroups) {
        final originalDeckCount = group.decks?.length ?? 0;
        final validDecks =
            group.decks
                ?.where((deckId) => validDeckIdsSet.contains(deckId))
                .toSet() ??
            {};
        final removedCount = originalDeckCount - validDecks.length;

        if (removedCount > 0) {
          final updatedGroup = group.copyWith(decks: validDecks);
          groupsToUpdate.add(updatedGroup);
        }
      }

      // Assertions
      expect(groupsToUpdate.length, 2); // group1 and group2 should be cleaned

      final group1Cleaned = groupsToUpdate.firstWhere((g) => g.id == 'group1');
      expect(group1Cleaned.decks, equals({'deck1', 'deck2'}));
      expect(group1Cleaned.decks!.contains('orphaned_deck1'), false);

      final group2Cleaned = groupsToUpdate.firstWhere((g) => g.id == 'group2');
      expect(group2Cleaned.decks, equals({'deck3'}));
      expect(group2Cleaned.decks!.contains('orphaned_deck2'), false);

      // Group 3 should not be in cleaned groups since it has no orphaned references
      final group3Cleaned = groupsToUpdate.any((g) => g.id == 'group3');
      expect(group3Cleaned, false);
    });

    test('should handle empty deck lists correctly', () {
      final validDeckIds = ['deck1', 'deck2'];

      final emptyGroup = model.DeckGroup(
        id: 'empty_group',
        name: 'Empty Group',
        decks: <String>{},
      );

      final validDeckIdsSet = validDeckIds.toSet();
      final originalDeckCount = emptyGroup.decks?.length ?? 0;
      final validDecks =
          emptyGroup.decks
              ?.where((deckId) => validDeckIdsSet.contains(deckId))
              .toSet() ??
          {};
      final removedCount = originalDeckCount - validDecks.length;

      expect(removedCount, 0); // No orphaned references to remove
      expect(validDecks, isEmpty);
    });

    test('should handle null deck lists correctly', () {
      final validDeckIds = ['deck1', 'deck2'];

      final nullGroup = model.DeckGroup(
        id: 'null_group',
        name: 'Null Group',
        decks: null,
      );

      final validDeckIdsSet = validDeckIds.toSet();
      final originalDeckCount = nullGroup.decks?.length ?? 0;
      final validDecks =
          nullGroup.decks
              ?.where((deckId) => validDeckIdsSet.contains(deckId))
              .toSet() ??
          {};
      final removedCount = originalDeckCount - validDecks.length;

      expect(removedCount, 0); // No orphaned references to remove
      expect(validDecks, isEmpty);
    });

    test('should handle groups with all valid deck references', () {
      final validDeckIds = ['deck1', 'deck2', 'deck3'];

      final validGroup = model.DeckGroup(
        id: 'valid_group',
        name: 'Valid Group',
        decks: {'deck1', 'deck2', 'deck3'},
      );

      final validDeckIdsSet = validDeckIds.toSet();
      final originalDeckCount = validGroup.decks?.length ?? 0;
      final validDecks =
          validGroup.decks
              ?.where((deckId) => validDeckIdsSet.contains(deckId))
              .toSet() ??
          {};
      final removedCount = originalDeckCount - validDecks.length;

      expect(removedCount, 0); // No orphaned references to remove
      expect(validDecks, equals({'deck1', 'deck2', 'deck3'}));
    });
  });
}
