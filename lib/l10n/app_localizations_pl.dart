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
  String get learn => 'Nauka';

  @override
  String get statistics => 'Statystyki';

  @override
  String get settings => 'Ustawienia';

  @override
  String get profile => 'Profil';

  @override
  String cardsToReview(int count) {
    return 'Do nauki: $count';
  }

  @override
  String get noCardsMessage => 'Brak kart.';

  @override
  String get add => 'Dodaj';

  @override
  String get deckSaved => 'Zestaw zapisany';

  @override
  String get deckName => 'Nazwa zestawu';

  @override
  String get addDeck => 'Dodaj zestaw';

  @override
  String get addCard => 'Dodaj kartę';

  @override
  String get editDeck => 'Edytuj zestaw';

  @override
  String get editCard => 'Edytuj kartę';

  @override
  String get deckEmptyMessage => 'Zestaw jest pusty.';

  @override
  String deckHeader(String deckName) {
    return 'Zestaw: $deckName';
  }

  @override
  String get saveAndNext => 'Zapisz i dodaj kolejną';

  @override
  String deleteDeck(String deck) {
    return 'Usuń zestaw kart \'$deck\'?';
  }

  @override
  String get deleteDeckConfirmation => 'Czy na pewno chcesz usunąć ten zestaw kart?';

  @override
  String get delete => 'Usuń';

  @override
  String get signIn => 'Zaloguj';

  @override
  String get signOut => 'Wyloguj';

  @override
  String get deckNamePrompt => 'Please enter a deck name';

  @override
  String get noCardsToLearn => 'No cards to learn';
}
