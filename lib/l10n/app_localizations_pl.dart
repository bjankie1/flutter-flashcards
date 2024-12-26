import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Flashcards - fiszki';

  @override
  String get cards => 'Karty';

  @override
  String get decks => 'Zestawy';

  @override
  String get learning => 'Nauczanie';

  @override
  String get settings => 'Ustawienia';

  @override
  String cardsToReview(int count) {
    return 'Do nauki: $count';
  }

  @override
  String get noCardsMessage => 'Brak kart.';

  @override
  String get add => 'Add';

  @override
  String get deckSaved => '\'Deck saved!\'';

  @override
  String get deckName => 'Deck name';

  @override
  String get addDeck => 'Add Deck';

  @override
  String get editDeck => 'Edit Deck';

  @override
  String get editCard => 'Edit card';

  @override
  String get deckEmptyMessage => 'Deck has no cards yet.';

  @override
  String deckHeader(String deckName) {
    return 'Cards for $deckName';
  }
}
