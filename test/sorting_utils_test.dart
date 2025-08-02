import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_flashcards/src/common/sorting_utils.dart';

void main() {
  group('SortingUtils', () {
    group('Polish language support', () {
      test('should normalize Polish diacritics correctly', () {
        expect(SortingUtils.normalizeString('ą'), 'a');
        expect(SortingUtils.normalizeString('ć'), 'c');
        expect(SortingUtils.normalizeString('ę'), 'e');
        expect(
          SortingUtils.normalizeString('ł'),
          'lz',
        ); // ł becomes lz for proper sorting
        expect(SortingUtils.normalizeString('ń'), 'n');
        expect(SortingUtils.normalizeString('ó'), 'o');
        expect(SortingUtils.normalizeString('ś'), 's');
        expect(SortingUtils.normalizeString('ź'), 'z');
        expect(SortingUtils.normalizeString('ż'), 'z');
      });

      test('should sort Polish words correctly', () {
        final words = ['ładowarka', 'laptop', 'mysz'];
        final sorted = SortingUtils.sortWithDiacritics(words);
        expect(sorted, ['laptop', 'ładowarka', 'mysz']);
      });
    });

    group('French language support', () {
      test('should normalize French diacritics correctly', () {
        expect(SortingUtils.normalizeString('à'), 'a');
        expect(SortingUtils.normalizeString('â'), 'a');
        expect(SortingUtils.normalizeString('ä'), 'a');
        expect(SortingUtils.normalizeString('ç'), 'c');
        expect(SortingUtils.normalizeString('é'), 'e');
        expect(SortingUtils.normalizeString('è'), 'e');
        expect(SortingUtils.normalizeString('ê'), 'e');
        expect(SortingUtils.normalizeString('ë'), 'e');
        expect(SortingUtils.normalizeString('î'), 'i');
        expect(SortingUtils.normalizeString('ï'), 'i');
        expect(SortingUtils.normalizeString('ô'), 'o');
        expect(SortingUtils.normalizeString('ù'), 'u');
        expect(SortingUtils.normalizeString('û'), 'u');
        expect(SortingUtils.normalizeString('ü'), 'u');
        expect(SortingUtils.normalizeString('ÿ'), 'y');
      });

      test('should sort French words correctly', () {
        final words = ['café', 'cafe', 'château'];

        final sorted = SortingUtils.sortWithDiacritics(words);

        // café -> cafe, cafe -> cafe, château -> chateau
        // When normalized strings are equal, original order is maintained
        expect(sorted[0], 'café');
        expect(sorted[1], 'cafe');
        expect(sorted[2], 'château');
      });
    });

    group('Spanish language support', () {
      test('should normalize Spanish diacritics correctly', () {
        expect(SortingUtils.normalizeString('á'), 'a');
        expect(SortingUtils.normalizeString('í'), 'i');
        expect(
          SortingUtils.normalizeString('ñ'),
          'n',
        ); // ñ becomes n after normalization
        expect(SortingUtils.normalizeString('ó'), 'o');
        expect(SortingUtils.normalizeString('ú'), 'u');
      });

      test('should sort Spanish words correctly', () {
        final words = ['caña', 'casa', 'niño'];

        final sorted = SortingUtils.sortWithDiacritics(words);

        // caña -> cana, casa -> casa, niño -> nino
        // Order: caña, casa, niño
        expect(sorted[0], 'caña');
        expect(sorted[1], 'casa');
        expect(sorted[2], 'niño');
      });
    });

    group('German language support', () {
      test('should normalize German diacritics correctly', () {
        expect(SortingUtils.normalizeString('ß'), 'ss');
      });

      test('should sort German words correctly', () {
        final words = ['straße', 'strasse', 'straße'];

        final sorted = SortingUtils.sortWithDiacritics(words);

        // straße -> strasse, strasse -> strasse, straße -> strasse
        // When normalized strings are equal, original order is maintained
        expect(sorted[0], 'straße');
        expect(sorted[1], 'strasse');
        expect(sorted[2], 'straße');
      });
    });

    group('Mixed language support', () {
      test('should sort mixed language words correctly', () {
        final words = [
          'café', // French
          'caña', // Spanish
          'casa', // Spanish
          'ładowarka', // Polish
          'laptop', // English
          'mysz', // Polish
        ];

        final sorted = SortingUtils.sortWithDiacritics(words);

        // Expected order based on normalized values:
        // café, caña, casa, laptop, ładowarka, mysz
        expect(sorted[0], 'café');
        expect(sorted[1], 'caña');
        expect(sorted[2], 'casa');
        expect(sorted[3], 'laptop');
        expect(sorted[4], 'ładowarka');
        expect(sorted[5], 'mysz');
      });
    });

    group('Search functionality', () {
      test('should find Polish words with diacritics', () {
        expect(
          SortingUtils.containsWithDiacritics('ładowarka', 'lzad'),
          isTrue,
        );
        expect(
          SortingUtils.containsWithDiacritics('ładowarka', 'mysz'),
          isFalse,
        );
      });

      test('should find French words with diacritics', () {
        expect(SortingUtils.containsWithDiacritics('café', 'cafe'), isTrue);
        expect(
          SortingUtils.containsWithDiacritics('château', 'chateau'),
          isTrue,
        );
      });

      test('should find Spanish words with diacritics', () {
        expect(SortingUtils.containsWithDiacritics('caña', 'cana'), isTrue);
        expect(SortingUtils.containsWithDiacritics('niño', 'nino'), isTrue);
      });
    });

    group('Property sorting', () {
      test('should sort objects by string property', () {
        final items = [
          {'name': 'ładowarka', 'id': 1},
          {'name': 'laptop', 'id': 2},
          {'name': 'mysz', 'id': 3},
        ];

        final sorted = SortingUtils.sortByProperty(
          items,
          (item) => item['name'] as String,
        );

        expect(sorted[0]['name'], 'laptop');
        expect(sorted[1]['name'], 'ładowarka');
        expect(sorted[2]['name'], 'mysz');
      });
    });

    group('Edge cases', () {
      test('should handle empty strings', () {
        expect(SortingUtils.compareWithDiacritics('', ''), 0);
        expect(SortingUtils.compareWithDiacritics('', 'a'), -1);
        expect(SortingUtils.compareWithDiacritics('a', ''), 1);
      });

      test('should handle case sensitivity', () {
        expect(SortingUtils.compareWithDiacritics('A', 'a'), 0);
        expect(SortingUtils.compareWithDiacritics('Ł', 'ł'), 0);
        expect(SortingUtils.compareWithDiacritics('É', 'é'), 0);
      });

      test('should handle mixed case with diacritics', () {
        expect(SortingUtils.compareWithDiacritics('Ładowarka', 'ładowarka'), 0);
        expect(SortingUtils.compareWithDiacritics('Café', 'café'), 0);
        expect(SortingUtils.compareWithDiacritics('Caña', 'caña'), 0);
      });
    });
  });
}
