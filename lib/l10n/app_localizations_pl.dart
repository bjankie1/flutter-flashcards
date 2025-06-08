// ignore: unused_import
import 'package:intl/intl.dart' as intl;
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
  String get deleteDeckConfirmation =>
      'Czy na pewno chcesz usunąć ten zestaw kart?';

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
  String generateCardsForDeck(String deck) {
    return 'Wygeneruj karty dla zestawu $deck';
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
  String get noDecksMessage =>
      'Nie masz jeszcze zestawów. Dodaj swój pierwszy.';

  @override
  String get profileNameChanged => 'Nazwa profilu zmieniona';

  @override
  String get noSharedDecksMessage => 'Nie ma udostępnionych zestawów kart';

  @override
  String get deckNotFoundMessage => 'Nie ma takiego zestawu';

  @override
  String get cardOptionDoubleSided => 'Nauka obu stron karty';

  @override
  String get decksWithoutGroupHeader => 'Zestawy bez grupy';

  @override
  String get sharedDecksHeader => 'Zestawy udostępnione tobie';

  @override
  String get addDeckToGroup => 'Dodaj zestaw do grupy';

  @override
  String get saveButton => 'Zapisz';

  @override
  String get newDeckGroupName => 'Nowa grupa kart';

  @override
  String get newDeckGroupHelper => 'Podaj nazwę nowej grupy';

  @override
  String get newDeckGroupAddedMessage => 'Grupa została dodana';

  @override
  String get explanationLabel => 'Wyjaśnienie';

  @override
  String get cardReviewDaily => 'Liczba powtórek dziennie';

  @override
  String get frontCardLabel => 'Język na karcie z przodu';

  @override
  String get languageHint => 'Wybierz język';

  @override
  String get backCardLabel => 'Język na karcie z tyłu';

  @override
  String get deckDescription => 'Opis zestawu';

  @override
  String get deckSelect => 'Wybierz zestaw';

  @override
  String get addToDeck => 'Dodaj do zestawu';

  @override
  String get deckGeneration => 'Generowanie zestawów kart';

  @override
  String get inputTextForGenerator =>
      'Wprowadź tekst na podstawie którego chcesz wygenerować karty';

  @override
  String get generateCards => 'Generuj karty';

  @override
  String get inputText => 'Tekst';

  @override
  String get addCardsToDeck => 'Dodaj karty';

  @override
  String get createNewDeck => 'Utwórz nowy zestaw';

  @override
  String get shareDeck => 'Udostępnij zestaw';

  @override
  String get deckSharingHeader => 'Udostępnianie zestawu';

  @override
  String get deckSharedListTitle => 'Kto ma już dostęp';

  @override
  String get deckNotSharedMessage =>
      'Nie ma jeszcze nikogo, kto ma dostęp do tego zestawu';

  @override
  String get quickAddCard => 'Szybko dodaj kartę';

  @override
  String get provisionaryCardText => 'Tekst do użycia w karcie';

  @override
  String get provisionaryCardsReviewHeadline => 'Przegląd notatek';

  @override
  String get provisionaryCardsReviewButton => 'Przejrzyj notatki';

  @override
  String get discard => 'Odrzuć';

  @override
  String get later => 'Potem';

  @override
  String get noProvisionaryCardsHeadline => 'Brak notatek do przejrzenia';

  @override
  String get switchToLightMode => 'Przełącz na jasny motyw';

  @override
  String get switchToDarkMode => 'Przełącz na ciemny motyw';

  @override
  String get switchToEnglish => 'Przełącz na język angielski';

  @override
  String get switchToPolish => 'Przełącz na język polski';
}
