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
}
