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
  String get learn => 'Learn';

  @override
  String get statistics => 'Statistics';

  @override
  String get settings => 'Settings';

  @override
  String get profile => 'Profile';

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
  String get addDeck => 'Add deck';

  @override
  String get addCard => 'Add card';

  @override
  String get editDeck => 'Edit deck';

  @override
  String get editCard => 'Edit card';

  @override
  String get deckEmptyMessage => 'Deck has no cards yet.';

  @override
  String deckHeader(String deckName) {
    return 'Cards for $deckName';
  }

  @override
  String get saveAndNext => 'Save and add next';

  @override
  String deleteDeck(String deck) {
    return 'Delete $deck';
  }

  @override
  String get deleteDeckConfirmation => 'Are you sure you want to delete this deck?';

  @override
  String get delete => 'Delete';

  @override
  String get signIn => 'Login';

  @override
  String get signOut => 'Logout';

  @override
  String get deckNamePrompt => 'Please enter a deck name';

  @override
  String get noCardsToLearn => 'No cards to learn';

  @override
  String get answerRecordedMessage => 'Answer recorded';

  @override
  String get showAnswer => 'Show answer';

  @override
  String learnProgressMessage(int current, int total) {
    return 'Learning card $current of $total';
  }

  @override
  String get learnEverything => 'Learn everything';

  @override
  String get hintPrompt => 'Hint (optional)';

  @override
  String get hintLabel => 'Hint';

  @override
  String get rateAgainLabel => 'Again';

  @override
  String get rateHardLabel => 'Hard';

  @override
  String get rateGoodLabel => 'Good';

  @override
  String get rateEasyLabel => 'Easy';

  @override
  String get userNotLoggedIn => 'You need to log in';

  @override
  String printHours(int hours) {
    return '$hours hours';
  }

  @override
  String printMinutes(int minutes) {
    return '$minutes minutes';
  }

  @override
  String printSeconds(int seconds) {
    return '$seconds seconds';
  }

  @override
  String get weekDurationFilterLabel => 'Last 7 days';

  @override
  String get monthDurationFilterLabel => 'Last month';

  @override
  String get cardReviewedPerHourHeader => 'Cards reviewed per hour';

  @override
  String get deckNameSavedMessage => 'Deck name saved';

  @override
  String get deckDescriptionSavedMessage => 'Deck description saved';

  @override
  String get errorSavingDescriptionMessage => 'Error saving description';

  @override
  String get countCardsPerDeckChartTitle => 'Number of cards studied per deck';

  @override
  String get timePerDeckChartTitle => 'Time spent per deck';

  @override
  String get answerLabel => 'Answer';

  @override
  String get answerHint => 'Answer text';

  @override
  String get questionLabel => 'Question';

  @override
  String get questionHint => 'Question text';
}
