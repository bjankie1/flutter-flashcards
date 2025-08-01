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
  String get saving => 'Zapisywanie...';

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
  String get explanationLabel => 'Wyjaśnienie:';

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
  String get generateFlashcards => 'Generuj fiszki';

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
  String get cardProposalLabel => 'Propozycja karty';

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

  @override
  String get totalProgressLabel => 'Całkowity postęp';

  @override
  String deckProgress(String deckName) {
    return 'Postęp zestawu $deckName';
  }

  @override
  String progressPercent(int percent) {
    return '+$percent%';
  }

  @override
  String get masteryNew => 'Nowe';

  @override
  String get masteryLearning => 'W nauce';

  @override
  String get masteryYoung => 'Młode';

  @override
  String get masteryMature => 'Doświadczone';

  @override
  String get errorLoadingCards => 'Błąd ładowania kart';

  @override
  String get cardQuestionDisplay => 'Pytanie:';

  @override
  String get cardAnswerDisplay => 'Odpowiedź:';

  @override
  String get cardsSearchHint => 'Szukaj kart...';

  @override
  String get hintIconTooltip => 'Ta karta ma podpowiedź';

  @override
  String get cardOptionDoubleSidedTooltip =>
      'Ta karta może być uczona z obu stron';

  @override
  String get deleteCardTooltip => 'Usuń kartę';

  @override
  String get deckDescriptionSaveErrorMessage =>
      'Nie udało się zapisać opisu zestawu';

  @override
  String get learningStatisticsDialogTitle => 'Statystyki nauki';

  @override
  String get learningStatisticsMetric => 'Metryka';

  @override
  String get learningStatisticsQuestion => 'Pytanie';

  @override
  String get learningStatisticsAnswer => 'Odpowiedź';

  @override
  String get learningStatisticsValue => 'Wartość';

  @override
  String get learningStatisticsNumberOfReviews => 'Liczba powtórek';

  @override
  String get learningStatisticsDifficulty => 'Trudność';

  @override
  String get learningStatisticsLastReview => 'Ostatnia powtórka';

  @override
  String get learningStatisticsNextReview => 'Następna powtórka';

  @override
  String get learningStatisticsDifficultyEasy => 'Łatwa';

  @override
  String get learningStatisticsDifficultyMedium => 'Średnia';

  @override
  String get learningStatisticsDifficultyHard => 'Trudna';

  @override
  String get learningStatisticsNotScheduled => 'Brak terminu';

  @override
  String get learningStatisticsDueAlready => 'już zaległa';

  @override
  String get learningStatisticsToday => 'Dzisiaj';

  @override
  String get learningStatisticsYesterday => 'Wczoraj';

  @override
  String get learningStatisticsClose => 'Zamknij';

  @override
  String learningStatisticsDay(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dni',
      many: '$count dni',
      few: '$count dni',
      one: '$count dzień',
    );
    return '$_temp0';
  }

  @override
  String learningStatisticsHour(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count godziny',
      many: '$count godzin',
      few: '$count godziny',
      one: '$count godzina',
    );
    return '$_temp0';
  }

  @override
  String get updateAvailable => 'Dostępna aktualizacja';

  @override
  String get updateAvailableMessage =>
      'Dostępna jest nowa wersja aplikacji. Zaktualizuj teraz, aby uzyskać najnowsze funkcje i ulepszenia.';

  @override
  String get updateNow => 'Zaktualizuj teraz';

  @override
  String get updateLater => 'Później';

  @override
  String get updatingApp => 'Aktualizowanie...';

  @override
  String get updateCheckFailed => 'Nie udało się sprawdzić aktualizacji';

  @override
  String get updateDownloading => 'Pobieranie aktualizacji...';

  @override
  String get updateInstalling => 'Instalowanie aktualizacji...';

  @override
  String get updateComplete =>
      'Aktualizacja zakończona! Aplikacja zostanie przeładowana.';

  @override
  String get updateError => 'Aktualizacja nie powiodła się. Spróbuj ponownie.';

  @override
  String get checkingForUpdates => 'Sprawdzanie aktualizacji...';

  @override
  String get noUpdateAvailable => 'Używasz najnowszej wersji';

  @override
  String get updateReminder =>
      'Nie zapomnij zaktualizować! Dostępna jest nowa wersja.';

  @override
  String get deckDetails => 'Szczegóły talii';

  @override
  String get generateFromGoogleDoc => 'Generuj z Dokumentu Google';

  @override
  String get personalInfo => 'Informacje osobiste';

  @override
  String get myName => 'Moje imię';

  @override
  String get email => 'Email';

  @override
  String get yourName => 'Twoje imię';

  @override
  String get imageRecorded => 'Obraz zapisany';

  @override
  String get errorUploadingImage => 'Błąd podczas przesyłania obrazu';

  @override
  String get appVersion => 'Wersja aplikacji';

  @override
  String get currentVersion => 'Aktualna wersja';

  @override
  String get latestAvailableVersion => 'Najnowsza dostępna wersja';

  @override
  String get minimumRequiredVersion => 'Minimalna wymagana wersja';

  @override
  String get checkForUpdates => 'Sprawdź aktualizacje';

  @override
  String get updateSettings => 'Ustawienia aktualizacji';

  @override
  String get automaticUpdateChecks =>
      'Automatyczne sprawdzanie aktualizacji co 10 minut';

  @override
  String get versionCheckingWebOnly =>
      'Sprawdzanie wersji jest dostępne tylko na platformie web';

  @override
  String get googleDocLink => 'Link do Dokumentu Google';

  @override
  String get googleDocHelperText =>
      'Wklej link do swojego Dokumentu Google, aby wygenerować z niego fiszki.';

  @override
  String get selectGoogleDoc => 'Wybierz Dokument Google';

  @override
  String docContentLength(int length) {
    return 'Długość treści dokumentu: $length';
  }

  @override
  String errorPrefix(String message) {
    return 'Błąd: $message';
  }

  @override
  String get enterGoogleDocUrl => 'Wprowadź URL Dokumentu Google:';

  @override
  String get googleDocUrlHint => 'https://docs.google.com/document/d/...';

  @override
  String get googleDocUrlExample =>
      'Przykład: https://docs.google.com/document/d/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms/edit';

  @override
  String get pleaseEnterGoogleDocUrl =>
      'Proszę wprowadzić URL Dokumentu Google';

  @override
  String get invalidGoogleDocUrl =>
      'Nieprawidłowy URL Dokumentu Google. Sprawdź URL i spróbuj ponownie.';

  @override
  String get loadButton => 'Załaduj';

  @override
  String get cancelButtonLabel => 'Anuluj';

  @override
  String get retry => 'Ponów';

  @override
  String get answersLabel => 'Odpowiedzi:';

  @override
  String get totalTimeLabel => 'Całkowity czas:';

  @override
  String get averageTimeLabel => 'Średni czas (s):';

  @override
  String errorLoadingCollaborators(String error) {
    return 'Błąd ładowania współpracowników: $error';
  }

  @override
  String get noCollaboratorsYet => 'Brak współpracowników';

  @override
  String get inviteCollaboratorHint =>
      'Zaproś kogoś do współpracy nad fiszkami';

  @override
  String get answersLabelTooltip =>
      'Total number of answers (cards reviewed) in the selected period.';

  @override
  String get totalTimeLabelTooltip =>
      'Total time spent reviewing cards in the selected period.';

  @override
  String get averageTimeLabelTooltip =>
      'Average time spent reviewing cards per day in the selected period.';

  @override
  String get cardReviewedPerHourTooltip =>
      'Distribution of card reviews by time of day. Helps you see when you study most.';

  @override
  String get cardReviewDailyTooltip =>
      'Number of cards reviewed each day in the selected period.';

  @override
  String get countCardsPerDeckChartTooltip =>
      'Shows how many cards you studied from each deck.';

  @override
  String get timePerDeckChartTooltip =>
      'Shows how much time you spent studying each deck.';

  @override
  String get signInTitle => 'Zaloguj się';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Hasło';

  @override
  String get signInButton => 'Zaloguj się';

  @override
  String get orLabel => 'lub';

  @override
  String get signInWithGoogleButton => 'Zaloguj się przez Google';

  @override
  String get signUpTitle => 'Utwórz konto';

  @override
  String get signUpButton => 'Zarejestruj się';

  @override
  String get signUpWithGoogleButton => 'Zarejestruj się przez Google';

  @override
  String get confirmPasswordLabel => 'Potwierdź hasło';

  @override
  String get alreadyHaveAccount => 'Masz już konto?';

  @override
  String get dontHaveAccount => 'Nie masz konta?';

  @override
  String get signUpLink => 'Zarejestruj się';

  @override
  String get signInLink => 'Zaloguj się';

  @override
  String get selectCard => 'Zaznacz fiszkę';

  @override
  String get deselectCard => 'Odznacz fiszkę';

  @override
  String get uploadNewFile => 'Wyślij nowy plik';

  @override
  String get regenerateFlashcards => 'Wygeneruj fiszki ponownie';

  @override
  String generatedFlashcards(Object count) {
    return 'Wygenerowane fiszki ($count)';
  }

  @override
  String get editCards => 'Edytuj fiszki';

  @override
  String get saveToDeck => 'Zapisz do talii';

  @override
  String get showContent => 'Pokaż treść';

  @override
  String get close => 'Zamknij';

  @override
  String docLength(int length) {
    return 'Długość dokumentu: $length';
  }

  @override
  String fileSize(int size) {
    return 'Rozmiar pliku: $size bajtów';
  }

  @override
  String get selectInputSource => 'Wybierz źródło danych';

  @override
  String get pasteText => 'Wklej tekst';

  @override
  String get uploadPdf => 'Wyślij PDF';

  @override
  String get uploadImage => 'Wyślij obraz';

  @override
  String get cancel => 'Anuluj';

  @override
  String get confirm => 'Potwierdź';

  @override
  String get pasteTextHint => 'Wklej swój tekst tutaj...';

  @override
  String textContentLength(int length) {
    return 'Długość tekstu: $length';
  }

  @override
  String get addFrontCardDescription => 'dodaj opis przodu karty';

  @override
  String get addBackCardDescription => 'dodaj opis tyłu karty';

  @override
  String get addExplanationDescription => 'dodaj opis wyjaśnienia odpowiedzi';

  @override
  String get frontCardDescriptionLabel => 'Opis przodu karty';

  @override
  String get backCardDescriptionLabel => 'Opis tyłu karty';

  @override
  String get explanationDescriptionLabel => 'Opis wyjaśnienia odpowiedzi';

  @override
  String get frontCardDescriptionHint =>
      'Opisz co powinno być na przodzie kart w tym zestawie';

  @override
  String get backCardDescriptionHint =>
      'Opisz co powinno być na tyle kart w tym zestawie';

  @override
  String get explanationDescriptionHint =>
      'Opisz co powinny zawierać wyjaśnienia odpowiedzi w tym zestawie';

  @override
  String get frontCardDescriptionSavedMessage => 'Opis przodu karty zapisany';

  @override
  String get backCardDescriptionSavedMessage => 'Opis tyłu karty zapisany';

  @override
  String get explanationDescriptionSavedMessage => 'Opis wyjaśnienia zapisany';

  @override
  String get frontCardDescriptionSaveErrorMessage =>
      'Błąd zapisywania opisu przodu karty';

  @override
  String get backCardDescriptionSaveErrorMessage =>
      'Błąd zapisywania opisu tyłu karty';

  @override
  String get explanationDescriptionSaveErrorMessage =>
      'Błąd zapisywania opisu wyjaśnienia';

  @override
  String get noProvisionaryCardsMessage =>
      'Brak propozycji kart do przejrzenia';

  @override
  String get noProvisionaryCardsDescription =>
      'Nie masz żadnych szybkich notatek oczekujących na przekształcenie w fiszki. Dodaj je używając funkcji szybkiego dodawania kart.';

  @override
  String get allProvisionaryCardsReviewedMessage =>
      'Wszystkie propozycje kart przejrzane!';

  @override
  String get allProvisionaryCardsReviewedDescription =>
      'Świetna robota! Przetworzyłeś wszystkie swoje szybkie notatki. Zostały przekształcone w odpowiednie fiszki i są gotowe do nauki.';

  @override
  String get goBack => 'Wróć';

  @override
  String get openDeck => 'Otwórz zestaw';

  @override
  String get warningTitle => 'Ostrzeżenie';

  @override
  String get finalizeEditingWarning =>
      'Zapisz lub anuluj edycję wszystkich pól przed zapisaniem karty.';

  @override
  String get ok => 'OK';

  @override
  String get generateCardDescriptions => 'Generuj opisy kart';

  @override
  String get cardDescriptionsGeneratedMessage =>
      'Opisy kart zostały wygenerowane pomyślnie';

  @override
  String get cardDescriptionsGenerationErrorMessage =>
      'Błąd podczas generowania opisów kart';

  @override
  String get generatedCardDescriptions => 'Wygenerowane opisy kart';

  @override
  String get confidenceLevel => 'Poziom pewności';

  @override
  String get analysis => 'Analiza';

  @override
  String get apply => 'Zastosuj';

  @override
  String get cardDescriptionsAppliedMessage =>
      'Opisy kart zostały zastosowane pomyślnie';

  @override
  String get cardDescriptionsApplyErrorMessage =>
      'Błąd podczas stosowania opisów kart';

  @override
  String get cardDescriptionsConfigured => 'Opisy kart skonfigurowane';

  @override
  String get regenerateCardDescriptions => 'Wygeneruj opisy ponownie';

  @override
  String get cardDescriptions => 'Opisy kart';
}
