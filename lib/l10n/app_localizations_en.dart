import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Flashcards';

  @override
  String get cards => 'Cards';

  @override
  String get decks => 'Decks';

  @override
  String get learning => 'Learning';

  @override
  String get settings => 'Settings';

  @override
  String cardsToReview(int count) {
    return 'To review: $count';
  }

  @override
  String get noCardsMessage => 'No cards found.';

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
