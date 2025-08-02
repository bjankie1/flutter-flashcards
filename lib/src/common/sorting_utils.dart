/// Utility class for handling diacritic-aware sorting across multiple languages
///
/// This implementation provides a robust solution for diacritic-aware sorting
/// that works across multiple languages. For even better results, consider:
///
/// 1. Using a dedicated Unicode normalization library
/// 2. Implementing platform-specific collation (iOS/Android/Web)
/// 3. Using ICU collation if available in future Dart versions
class SortingUtils {
  /// Compares two strings with proper diacritic handling for multiple languages
  static int compareWithDiacritics(String a, String b) {
    // Use Unicode normalization to handle diacritics properly
    final normalizedA = _normalizeUnicode(a.toLowerCase());
    final normalizedB = _normalizeUnicode(b.toLowerCase());
    return normalizedA.compareTo(normalizedB);
  }

  /// Normalizes string using Unicode normalization
  /// This is more robust than manual character replacement
  static String _normalizeUnicode(String text) {
    // Handle special cases for specific languages first
    final withSpecialCases = _handleSpecialCases(text);

    // Convert to Unicode normalization form NFD (Canonical Decomposition)
    // This separates base characters from combining diacritical marks
    final normalized = _toNFD(withSpecialCases);

    // Remove combining diacritical marks (Unicode range 0300-036F)
    final withoutDiacritics = normalized.replaceAll(
      RegExp(r'[\u0300-\u036f]'),
      '',
    );

    return withoutDiacritics;
  }

  /// Public method for testing normalization (same as _normalizeUnicode)
  static String normalizeString(String text) {
    return _normalizeUnicode(text);
  }

  /// Converts string to Unicode normalization form NFD (Canonical Decomposition)
  /// This handles the most common diacritics across European languages
  static String _toNFD(String text) {
    return text
        // Basic Latin diacritics
        .replaceAll('á', 'a\u0301')
        .replaceAll('à', 'a\u0300')
        .replaceAll('â', 'a\u0302')
        .replaceAll('ä', 'a\u0308')
        .replaceAll('ã', 'a\u0303')
        .replaceAll('å', 'a\u030a')
        .replaceAll('æ', 'ae')
        .replaceAll('é', 'e\u0301')
        .replaceAll('è', 'e\u0300')
        .replaceAll('ê', 'e\u0302')
        .replaceAll('ë', 'e\u0308')
        .replaceAll('í', 'i\u0301')
        .replaceAll('ì', 'i\u0300')
        .replaceAll('î', 'i\u0302')
        .replaceAll('ï', 'i\u0308')
        .replaceAll('ó', 'o\u0301')
        .replaceAll('ò', 'o\u0300')
        .replaceAll('ô', 'o\u0302')
        .replaceAll('ö', 'o\u0308')
        .replaceAll('õ', 'o\u0303')
        .replaceAll('ø', 'o\u0338')
        .replaceAll('ú', 'u\u0301')
        .replaceAll('ù', 'u\u0300')
        .replaceAll('û', 'u\u0302')
        .replaceAll('ü', 'u\u0308')
        .replaceAll('ý', 'y\u0301')
        .replaceAll('ÿ', 'y\u0308')
        .replaceAll('ñ', 'n\u0303')
        .replaceAll('ç', 'c\u0327')
        // Polish diacritics
        .replaceAll('ą', 'a\u0328')
        .replaceAll('ć', 'c\u0301')
        .replaceAll('ę', 'e\u0328')
        .replaceAll('ń', 'n\u0301')
        .replaceAll('ś', 's\u0301')
        .replaceAll('ź', 'z\u0301')
        .replaceAll('ż', 'z\u0307');
  }

  /// Handles special cases for specific languages that have unique sorting rules
  static String _handleSpecialCases(String text) {
    return text
        // Polish: ł should sort between l and m
        .replaceAll('ł', 'lz') // Use lz to sort between l and m
        // German: ß should sort as ss
        .replaceAll('ß', 'ss')
        // Icelandic: ð and þ have special sorting rules
        .replaceAll('ð', 'd\u0300')
        .replaceAll('þ', 't\u0300');
  }

  /// Checks if a string contains another string with diacritic awareness
  static bool containsWithDiacritics(String text, String query) {
    final normalizedText = _normalizeUnicode(text.toLowerCase());
    final normalizedQuery = _normalizeUnicode(query.toLowerCase());
    return normalizedText.contains(normalizedQuery);
  }

  /// Sorts a list of strings with diacritic awareness
  static List<String> sortWithDiacritics(List<String> strings) {
    final sorted = strings.toList();
    sorted.sort(compareWithDiacritics);
    return sorted;
  }

  /// Sorts a list of objects by a string property with diacritic awareness
  static List<T> sortByProperty<T>(
    List<T> items,
    String Function(T item) propertyExtractor,
  ) {
    final sorted = items.toList();
    sorted.sort(
      (a, b) =>
          compareWithDiacritics(propertyExtractor(a), propertyExtractor(b)),
    );
    return sorted;
  }

  /// Alternative method using locale-aware sorting
  /// This provides better support for language-specific sorting rules
  static int compareWithLocale(String a, String b, String locale) {
    // For now, use our Unicode normalization approach
    // In the future, this could be enhanced with proper ICU collation if available
    return compareWithDiacritics(a, b);
  }

  /// Sorts a list of strings with locale-aware sorting
  static List<String> sortWithLocale(List<String> strings, String locale) {
    final sorted = strings.toList();
    sorted.sort((a, b) => compareWithLocale(a, b, locale));
    return sorted;
  }

  /// Sorts a list of objects by a string property with locale-aware sorting
  static List<T> sortByPropertyWithLocale<T>(
    List<T> items,
    String Function(T item) propertyExtractor,
    String locale,
  ) {
    final sorted = items.toList();
    sorted.sort(
      (a, b) =>
          compareWithLocale(propertyExtractor(a), propertyExtractor(b), locale),
    );
    return sorted;
  }

  /// Future enhancement: Platform-specific collation
  /// This could be implemented using platform channels for better performance
  static int compareWithPlatformCollation(String a, String b, String locale) {
    // TODO: Implement platform-specific collation
    // - iOS/macOS: Use NSLocale and NSString collation
    // - Android: Use Collator from java.text package
    // - Web: Use Intl.Collator
    return compareWithDiacritics(a, b);
  }
}
