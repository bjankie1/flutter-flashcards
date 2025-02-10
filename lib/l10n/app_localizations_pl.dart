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
  String learnProgressMessage(int total) {
    return 'Pozostało $total kart do nauki';
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

  @override
  String get deckNameSavedMessage => 'Nazwa zestawu zapisana';

  @override
  String get deckDescriptionSavedMessage => 'Opis zestawu zapisany';

  @override
  String get errorSavingDescriptionMessage => 'Nie udało się zapisać opisu';

  @override
  String get countCardsPerDeckChartTitle => 'Według liczby kart';

  @override
  String get timePerDeckChartTitle => 'Czas poświęcony na każdy zestaw';

  @override
  String get answerLabel => 'Odpowiedź';

  @override
  String get answerHint => 'Tekst odpowiedzi';

  @override
  String get questionLabel => 'Pytanie';

  @override
  String get questionHint => 'Tekst pytania';

  @override
  String get cardSavedMessage => 'Karta zapisana';

  @override
  String get cardSavingErrorMessage => 'Nie udało się zapisać karty';

  @override
  String editCardTitle(String deck) {
    return 'Edycja karty w zestawie **$deck**';
  }

  @override
  String createCardTitle(String deck) {
    return 'Nowa karta w zestawie **$deck**';
  }

  @override
  String get collaboration => 'Współpraca';

  @override
  String get sentInvitationsHeader => 'Wysłane zaproszenia';

  @override
  String get pendingInvitationsHeader => 'Oczekujące zaproszenia';

  @override
  String get collaboratorsHeader => 'Współpracownicy';

  @override
  String get inviteCollaboratorPrompt => 'Zaproszenie współpracownika';

  @override
  String get invitationEmailHelperText => 'Adres email osoby zapraszanej';

  @override
  String get invalidEmailMessage => 'Proszę podać poprawny adres email';

  @override
  String get sendInvitationButtonTooltip => 'Wyślij zaproszenie';

  @override
  String get invitationSentMessage => 'Zaproszenie wysłane';

  @override
  String get cardDeletedMessage => 'Karta usunięta';

  @override
  String get cardDeletionErrorMessage => 'Nie udało się usunąć karty';

  @override
  String get allCardsReviewedMessage => 'Gratulacje!';

  @override
  String get personFilterLabel => 'Osoba';

  @override
  String get deckSharedMessage => 'Deck udostępniony';

  @override
  String get deckSharedFailedMessage => 'Wystąpił błąd podczas udostępniania';

  @override
  String get decksTitle => 'Moje zestawy';

  @override
  String get noDecksMessage => 'Nie masz jeszcze zestawów. Dodaj swój pierwszy.';

  @override
  String get profileNameChanged => 'Nazwa profilu zmieniona';

  @override
  String get noSharedDecksMessage => 'Nie ma udostępnionych zestawów kart';

  @override
  String get deckNotFoundMessage => 'Nie ma takiego zestawu';

  @override
  String get cardOptionDoubleSided => 'Nauka obu stron karty';
}
