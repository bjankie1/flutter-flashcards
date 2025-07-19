import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_flashcards/src/model/deck.dart';
import 'package:flutter_flashcards/src/model/enums.dart';

void main() {
  group('Reverse Description Tests', () {
    test('Deck model should support reverse description field', () {
      final deck = Deck(
        name: 'Spanish Vocabulary',
        description: 'Learn Spanish words',
        category: DeckCategory.language,
        frontCardDescription: 'A word or phrase I want to learn in Spanish.',
        backCardDescription:
            'Translation of a word or phrase from Polish to Spanish.',
        reverseFrontDescription:
            'Generate the Polish translation of the Spanish word.',
      );

      expect(deck.reverseFrontDescription, isNotNull);
      expect(deck.reverseFrontDescription, contains('translation'));
      expect(deck.reverseFrontDescription, contains('Spanish'));
    });

    test('Deck copyWith should preserve reverse description field', () {
      final originalDeck = Deck(
        name: 'Spanish Vocabulary',
        description: 'Learn Spanish words',
        category: DeckCategory.language,
        frontCardDescription: 'A word or phrase I want to learn in Spanish.',
        backCardDescription:
            'Translation of a word or phrase from Polish to Spanish.',
        reverseFrontDescription:
            'Generate the Polish translation of the Spanish word.',
      );

      final updatedDeck = originalDeck.copyWith(
        name: 'Updated Spanish Vocabulary',
        reverseFrontDescription: 'Updated reverse description',
      );

      expect(updatedDeck.name, 'Updated Spanish Vocabulary');
      expect(
        updatedDeck.reverseFrontDescription,
        'Updated reverse description',
      );
      expect(
        updatedDeck.frontCardDescription,
        originalDeck.frontCardDescription,
      );
      expect(updatedDeck.backCardDescription, originalDeck.backCardDescription);
    });

    test(
      'Deck JSON serialization should include reverse description field',
      () {
        final deck = Deck(
          name: 'Spanish Vocabulary',
          description: 'Learn Spanish words',
          category: DeckCategory.language,
          frontCardDescription: 'A word or phrase I want to learn in Spanish.',
          backCardDescription:
              'Translation of a word or phrase from Polish to Spanish.',
          reverseFrontDescription:
              'Generate the Polish translation of the Spanish word.',
        );

        final json = deck.toJson();

        expect(json['reverseFrontDescription'], deck.reverseFrontDescription);
      },
    );

    test(
      'Deck JSON deserialization should include reverse description field',
      () {
        final json = {
          'name': 'Spanish Vocabulary',
          'description': 'Learn Spanish words',
          'category': 'language',
          'frontCardDescription':
              'A word or phrase I want to learn in Spanish.',
          'backCardDescription':
              'Translation of a word or phrase from Polish to Spanish.',
          'reverseFrontDescription':
              'Generate the Polish translation of the Spanish word.',
        };

        final deck = Deck.fromJson('test-deck-id', json);

        expect(deck.reverseFrontDescription, json['reverseFrontDescription']);
      },
    );
  });
}
