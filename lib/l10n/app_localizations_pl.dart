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
  String get deckNamePrompt => 'Proszę podać nazwę zestawu';

  @override
  String get noCardsToLearn => 'Brak kart do nauki';

  @override
  String get answerRecordedMessage => 'Odpowiedź zapisana';

  @override
  String get showAnswer => 'Pokaż odpowiedź';

  @override
  String learnProgressMessage(int current, int total) {
    return 'Uczysz się karty $current z $total';
  }

  @override
  String get learnEverything => 'Pełna powtórka';

  @override
  String get hintPrompt => 'Opcjonalna podpowiedź';

  @override
  String get hintLabel => 'Podpowiedź';

  @override
  String get rateAgainLabel => 'Ponownie';

  @override
  String get rateHardLabel => 'Trudne';

  @override
  String get rateGoodLabel => 'Dobrze';

  @override
  String get rateEasyLabel => 'Łatwe';

  @override
  String get userNotLoggedIn => 'Musisz być zalogowany';

  @override
  String printHours(int hours) {
    return '$hours godzin';
  }

  @override
  String printMinutes(int minutes) {
    return '$minutes minut';
  }

  @override
  String printSeconds(int seconds) {
    return '$seconds sekund';
  }

  @override
  String get weekDurationFilterLabel => 'Ostatnie 7 dni';

  @override
  String get monthDurationFilterLabel => 'Ostatni miesiąc';

  @override
  String get cardReviewedPerHourHeader => 'Godziny powtórek';
}
