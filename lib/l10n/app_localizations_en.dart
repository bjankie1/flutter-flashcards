// ignore: unused_import
import 'package:intl/intl.dart' as intl;
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
  String get deleteDeckConfirmation =>
      'Are you sure you want to delete this deck?';

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
  String learnProgressMessage(int total) {
    return '$total cards to review';
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

  @override
  String get cardSavedMessage => 'Card saved';

  @override
  String get cardSavingErrorMessage => 'Error saving card';

  @override
  String editCardTitle(String deck) {
    return 'Editing card in **$deck** deck';
  }

  @override
  String generateCardsForDeck(String deck) {
    return 'Generate card for **$deck** deck';
  }

  @override
  String createCardTitle(String deck) {
    return 'Create card in **$deck**';
  }

  @override
  String get collaboration => 'Collaboration';

  @override
  String get sentInvitationsHeader => 'Sent invitations';

  @override
  String get pendingInvitationsHeader => 'Pending invitations';

  @override
  String get collaboratorsHeader => 'Collaborators';

  @override
  String get inviteCollaboratorPrompt => 'Enter collaborator email';

  @override
  String get invitationEmailHelperText => 'Invitees email';

  @override
  String get invalidEmailMessage => 'Please enter a valid email';

  @override
  String get sendInvitationButtonTooltip => 'Send invitation';

  @override
  String get invitationSentMessage => 'Invitation sent';

  @override
  String get cardDeletedMessage => 'Card deleted';

  @override
  String get cardDeletionErrorMessage => 'Error deleting card';

  @override
  String get allCardsReviewedMessage => 'Well done!';

  @override
  String get personFilterLabel => 'You or friend';

  @override
  String get deckSharedMessage => 'Deck has been shared';

  @override
  String get deckSharedFailedMessage => 'Failed sharing deck';

  @override
  String get decksTitle => 'My decks';

  @override
  String get noDecksMessage => 'No decks found. Add your first deck';

  @override
  String get profileNameChanged => 'Profile name changed';

  @override
  String get noSharedDecksMessage => 'No shared decks found';

  @override
  String get deckNotFoundMessage => 'Deck not found';

  @override
  String get cardOptionDoubleSided => 'Learn both sides';

  @override
  String get decksWithoutGroupHeader => 'Decks without group';

  @override
  String get sharedDecksHeader => 'Decks sheared by other users';

  @override
  String get addDeckToGroup => 'Add deck to group';

  @override
  String get saveButton => 'Save';

  @override
  String get newDeckGroupName => 'New deck group';

  @override
  String get newDeckGroupHelper => 'Enter new deck group name';

  @override
  String get newDeckGroupAddedMessage => 'New deck group added';

  @override
  String get explanationLabel => 'Explanation';

  @override
  String get cardReviewDaily => 'Cards reviews per day';

  @override
  String get frontCardLabel => 'Front card language';

  @override
  String get languageHint => 'Choose language';

  @override
  String get backCardLabel => 'Back card language';

  @override
  String get deckDescription => 'Deck description';

  @override
  String get deckSelect => 'Select a deck';

  @override
  String get addToDeck => 'Add cards to deck';

  @override
  String get deckGeneration => 'Generate cards';

  @override
  String get inputTextForGenerator => 'Text to generate flashcards for';

  @override
  String get generateCards => 'Generate cards';

  @override
  String get inputText => 'Text';

  @override
  String get addCardsToDeck => 'Add cards to deck';

  @override
  String get createNewDeck => 'Create new deck';

  @override
  String get shareDeck => 'Share deck with others';

  @override
  String get deckSharingHeader => 'Deck sharing';

  @override
  String get deckSharedListTitle => 'People with access';

  @override
  String get deckNotSharedMessage => 'Deck has yet been shared with anyone';

  @override
  String get quickAddCard => 'Quick add card';

  @override
  String get provisionaryCardText => 'Provisionary note';

  @override
  String get provisionaryCardsReviewHeadline => 'Provisionary cards review';

  @override
  String get provisionaryCardsReviewButton => 'Review provisionary cards';

  @override
  String get discard => 'Discard';

  @override
  String get later => 'Later';

  @override
  String get noProvisionaryCardsHeadline => 'No provisionary cards to review';

  @override
  String get switchToLightMode => 'Switch to light mode';

  @override
  String get switchToDarkMode => 'Switch to dark mode';

  @override
  String get switchToEnglish => 'Switch to English';

  @override
  String get switchToPolish => 'Switch to Polish';

  @override
  String get totalProgressLabel => 'Total Progress';

  @override
  String deckProgress(String deckName) {
    return '$deckName Progress';
  }

  @override
  String progressPercent(int percent) {
    return '+$percent%';
  }

  @override
  String get masteryNew => 'New';

  @override
  String get masteryLearning => 'Learning';

  @override
  String get masteryYoung => 'Young';

  @override
  String get masteryMature => 'Mature';

  @override
  String get errorLoadingCards => 'Error loading cards';

  @override
  String get cardQuestionDisplay => 'Question:';

  @override
  String get cardAnswerDisplay => 'Answer:';

  @override
  String get cardsSearchHint => 'Search cards...';

  @override
  String get hintIconTooltip => 'This card has a hint';

  @override
  String get cardOptionDoubleSidedTooltip =>
      'This card can be learned from both sides';

  @override
  String get deleteCardTooltip => 'Delete card';

  @override
  String get deckDescriptionSaveErrorMessage => 'Error saving deck description';

  @override
  String get learningStatisticsDialogTitle => 'Learning Statistics';

  @override
  String get learningStatisticsMetric => 'Metric';

  @override
  String get learningStatisticsQuestion => 'Question';

  @override
  String get learningStatisticsAnswer => 'Answer';

  @override
  String get learningStatisticsValue => 'Value';

  @override
  String get learningStatisticsNumberOfReviews => 'Number of reviews';

  @override
  String get learningStatisticsDifficulty => 'Difficulty';

  @override
  String get learningStatisticsLastReview => 'Last review';

  @override
  String get learningStatisticsNextReview => 'Next review';

  @override
  String get learningStatisticsDifficultyEasy => 'Easy';

  @override
  String get learningStatisticsDifficultyMedium => 'Medium';

  @override
  String get learningStatisticsDifficultyHard => 'Hard';

  @override
  String get learningStatisticsNotScheduled => 'Not scheduled';

  @override
  String get learningStatisticsDueAlready => 'due already';

  @override
  String get learningStatisticsToday => 'Today';

  @override
  String get learningStatisticsYesterday => 'Yesterday';

  @override
  String get learningStatisticsClose => 'Close';

  @override
  String learningStatisticsDay(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# days',
      one: '# day',
    );
    return '$_temp0';
  }

  @override
  String learningStatisticsHour(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# hours',
      one: '# hour',
    );
    return '$_temp0';
  }

  @override
  String get updateAvailable => 'Update Available';

  @override
  String get updateAvailableMessage =>
      'A new version of the app is available. Update now to get the latest features and improvements.';

  @override
  String get updateNow => 'Update Now';

  @override
  String get updateLater => 'Later';

  @override
  String get updatingApp => 'Updating...';

  @override
  String get updateCheckFailed => 'Failed to check for updates';

  @override
  String get updateDownloading => 'Downloading update...';

  @override
  String get updateInstalling => 'Installing update...';

  @override
  String get updateComplete => 'Update complete! The app will reload.';

  @override
  String get updateError => 'Update failed. Please try again.';

  @override
  String get checkingForUpdates => 'Checking for updates...';

  @override
  String get noUpdateAvailable => 'You\'re using the latest version';

  @override
  String get updateReminder =>
      'Don\'t forget to update! A new version is available.';
}
