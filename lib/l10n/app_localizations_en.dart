// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get add => 'Add';

  @override
  String get addBackCardDescription => 'add back of the card description';

  @override
  String get addCard => 'Add card';

  @override
  String get addCardsToDeck => 'Add cards to deck';

  @override
  String get addDeck => 'Add deck';

  @override
  String get addDeckToGroup => 'Add deck to group';

  @override
  String get addExplanationDescription => 'add answer explanation description';

  @override
  String get addFrontCardDescription => 'add front of the card description';

  @override
  String get allCardsReviewedMessage => 'Well done!';

  @override
  String get allProvisionaryCardsReviewedDescription =>
      'Great job! You\'ve processed all your quick notes. They\'ve been converted into proper flashcards and are ready for learning.';

  @override
  String get allProvisionaryCardsReviewedMessage =>
      'All card proposals reviewed!';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get analysis => 'Analysis';

  @override
  String get answerHint => 'Answer text';

  @override
  String get answerLabel => 'Answer';

  @override
  String get answerRecordedMessage => 'Answer recorded';

  @override
  String get answersLabel => 'Answers:';

  @override
  String get answersLabelTooltip =>
      'Total number of answers (cards reviewed) in the selected period.';

  @override
  String get apply => 'Apply';

  @override
  String get appTitle => 'Flashcards';

  @override
  String get appVersion => 'App Version';

  @override
  String get automaticUpdateChecks =>
      'Automatic update checks every 10 minutes';

  @override
  String get averageTimeLabel => 'Average (s):';

  @override
  String get averageTimeLabelTooltip =>
      'Average time spent reviewing cards per day in the selected period.';

  @override
  String get backCardDescriptionHint =>
      'Describe what should be on the back of cards in this deck';

  @override
  String get backCardDescriptionLabel => 'Back of card description';

  @override
  String get backCardDescriptionSaveErrorMessage =>
      'Error saving back card description';

  @override
  String get backCardDescriptionSavedMessage => 'Back card description saved';

  @override
  String get cancel => 'Cancel';

  @override
  String get cancelButtonLabel => 'Cancel';

  @override
  String get cardAnswerDisplay => 'Answer:';

  @override
  String get cardDeletedMessage => 'Card deleted';

  @override
  String get cardDeletionErrorMessage => 'Error deleting card';

  @override
  String get cardDescriptions => 'Card Descriptions';

  @override
  String get cardDescriptionsAppliedMessage =>
      'Card descriptions applied successfully';

  @override
  String get cardDescriptionsApplyErrorMessage =>
      'Error applying card descriptions';

  @override
  String get cardDescriptionsConfigured => 'Card descriptions configured';

  @override
  String get cardDescriptionsGeneratedMessage =>
      'Card descriptions generated successfully';

  @override
  String get cardDescriptionsGenerationErrorMessage =>
      'Error generating card descriptions';

  @override
  String get cardOptionDoubleSided => 'Learn both sides';

  @override
  String get cardOptionDoubleSidedTooltip =>
      'This card can be learned from both sides';

  @override
  String get cardProposalLabel => 'Card Proposal';

  @override
  String get cardQuestionDisplay => 'Question:';

  @override
  String get cardReviewDaily => 'Cards reviews per day';

  @override
  String get cardReviewDailyTooltip =>
      'Number of cards reviewed each day in the selected period.';

  @override
  String get cardReviewedPerHourHeader => 'Cards reviewed per hour';

  @override
  String get cardReviewedPerHourTooltip =>
      'Distribution of card reviews by time of day. Helps you see when you study most.';

  @override
  String get cardSavedMessage => 'Card saved';

  @override
  String get cardSavingErrorMessage => 'Error saving card';

  @override
  String get cards => 'Cards';

  @override
  String get cardsSearchHint => 'Search cards...';

  @override
  String cardsToReview(int count) {
    return 'To review: $count';
  }

  @override
  String get checkForUpdates => 'Check for Updates';

  @override
  String get checkingForUpdates => 'Checking for updates...';

  @override
  String get close => 'Close';

  @override
  String get collaboration => 'Collaboration';

  @override
  String get collaboratorsHeader => 'Collaborators';

  @override
  String get confidenceLevel => 'Confidence Level';

  @override
  String get confirm => 'Confirm';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get countCardsPerDeckChartTitle => 'Number of cards studied per deck';

  @override
  String get countCardsPerDeckChartTooltip =>
      'Shows how many cards you studied from each deck.';

  @override
  String createCardTitle(String deck) {
    return 'Create card in **$deck**';
  }

  @override
  String get createNewDeck => 'Create new deck';

  @override
  String get currentVersion => 'Current Version';

  @override
  String get deckDescription => 'Deck description';

  @override
  String get deckDescriptionSaveErrorMessage => 'Error saving deck description';

  @override
  String get deckDescriptionSavedMessage => 'Deck description saved';

  @override
  String get deckDetails => 'Deck Details';

  @override
  String get deckEmptyMessage => 'Deck has no cards yet.';

  @override
  String get deckGeneration => 'Generate cards';

  @override
  String deckHeader(String deckName) {
    return 'Cards for $deckName';
  }

  @override
  String get deckName => 'Deck name';

  @override
  String get deckNamePrompt => 'Please enter a deck name';

  @override
  String get deckNameSavedMessage => 'Deck name saved';

  @override
  String get deckNotFoundMessage => 'Deck not found';

  @override
  String deckProgress(String deckName) {
    return '$deckName Progress';
  }

  @override
  String get deckSaved => '\'Deck saved!\'';

  @override
  String get deckSelect => 'Select a deck';

  @override
  String get deckSharedFailedMessage => 'Failed sharing deck';

  @override
  String get deckSharedListTitle => 'People with access';

  @override
  String get deckSharedMessage => 'Deck has been shared';

  @override
  String get deckSharingHeader => 'Deck sharing';

  @override
  String get decks => 'Decks';

  @override
  String get decksTitle => 'My decks';

  @override
  String get decksWithoutGroupHeader => 'Decks without group';

  @override
  String get delete => 'Delete';

  @override
  String get deleteCardTooltip => 'Delete card';

  @override
  String deleteDeck(String deck) {
    return 'Delete $deck';
  }

  @override
  String get deleteDeckConfirmation =>
      'Are you sure you want to delete this deck?';

  @override
  String get deselectCard => 'Deselect card';

  @override
  String get discard => 'Discard';

  @override
  String docContentLength(int length) {
    return 'Doc content length: $length';
  }

  @override
  String docLength(int length) {
    return 'Doc length: $length';
  }

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get editCard => 'Edit card';

  @override
  String editCardTitle(String deck) {
    return 'Editing card in **$deck** deck';
  }

  @override
  String get editCards => 'Edit Cards';

  @override
  String get editDeck => 'Edit deck';

  @override
  String get email => 'Email';

  @override
  String get emailLabel => 'Email';

  @override
  String get enterGoogleDocUrl => 'Enter Google Doc URL:';

  @override
  String get errorLoadingCards => 'Error loading cards';

  @override
  String errorLoadingCollaborators(String error) {
    return 'Error loading collaborators: $error';
  }

  @override
  String errorPrefix(String message) {
    return 'Error: $message';
  }

  @override
  String get errorSavingDescriptionMessage => 'Error saving description';

  @override
  String get errorUploadingImage => 'Error uploading image';

  @override
  String get explanationDescriptionHint =>
      'Describe what explanations should include for answers in this deck';

  @override
  String get explanationDescriptionLabel => 'Answer explanation description';

  @override
  String get explanationDescriptionSaveErrorMessage =>
      'Error saving explanation description';

  @override
  String get explanationDescriptionSavedMessage =>
      'Explanation description saved';

  @override
  String get explanationLabel => 'Explanation:';

  @override
  String fileSize(int size) {
    return 'File size: $size bytes';
  }

  @override
  String get finalizeEditingWarning =>
      'Please save or cancel your edits in all fields before saving the card.';

  @override
  String get frontCardDescriptionHint =>
      'Describe what should be on the front of cards in this deck';

  @override
  String get frontCardDescriptionLabel => 'Front of card description';

  @override
  String get frontCardDescriptionSaveErrorMessage =>
      'Error saving front card description';

  @override
  String get frontCardDescriptionSavedMessage => 'Front card description saved';

  @override
  String get frontCardLabel => 'Front card language';

  @override
  String get generateCardDescriptions => 'Generate Card Descriptions';

  @override
  String get generateCards => 'Generate cards';

  @override
  String generateCardsForDeck(String deck) {
    return 'Generate card for **$deck** deck';
  }

  @override
  String get generateFlashcards => 'Generate flashcards';

  @override
  String get generateFromGoogleDoc => 'Generate from Google Doc';

  @override
  String get generatedCardDescriptions => 'Generated Card Descriptions';

  @override
  String generatedFlashcards(Object count) {
    return 'Generated Flashcards ($count)';
  }

  @override
  String get goBack => 'Go back';

  @override
  String get googleDocHelperText =>
      'Paste the link to your Google Doc to generate cards from it.';

  @override
  String get googleDocLink => 'Google Doc Link';

  @override
  String get googleDocUrlExample =>
      'Example: https://docs.google.com/document/d/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms/edit';

  @override
  String get googleDocUrlHint => 'https://docs.google.com/document/d/...';

  @override
  String get hintIconTooltip => 'This card has a hint';

  @override
  String get hintLabel => 'Hint';

  @override
  String get hintPrompt => 'Hint (optional)';

  @override
  String get imageRecorded => 'Image recorded';

  @override
  String get inputText => 'Text';

  @override
  String get inputTextForGenerator => 'Text to generate flashcards for';

  @override
  String get invalidEmailMessage => 'Please enter a valid email';

  @override
  String get invalidGoogleDocUrl =>
      'Invalid Google Doc URL. Please check the URL and try again.';

  @override
  String get invitationSentMessage => 'Invitation sent';

  @override
  String get inviteCollaboratorHint =>
      'Invite someone to collaborate on your flashcards';

  @override
  String get inviteCollaboratorPrompt => 'Enter collaborator email';

  @override
  String get languageHint => 'Choose language';

  @override
  String lastUpdated(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Last updated on $dateString';
  }

  @override
  String get later => 'Later';

  @override
  String get latestAvailableVersion => 'Latest Available Version';

  @override
  String get learn => 'Learn';

  @override
  String get learnEverything => 'Learn everything';

  @override
  String get learning => 'Learning';

  @override
  String get learningStatisticsAnswer => 'Answer';

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
  String get learningStatisticsDifficulty => 'Difficulty';

  @override
  String get learningStatisticsDifficultyEasy => 'Easy';

  @override
  String get learningStatisticsDifficultyHard => 'Hard';

  @override
  String get learningStatisticsDifficultyMedium => 'Medium';

  @override
  String get learningStatisticsDialogTitle => 'Learning Statistics';

  @override
  String get learningStatisticsDueAlready => 'due already';

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
  String get learningStatisticsLastReview => 'Last review';

  @override
  String get learningStatisticsMetric => 'Metric';

  @override
  String get learningStatisticsNextReview => 'Next review';

  @override
  String get learningStatisticsNotScheduled => 'Not scheduled';

  @override
  String get learningStatisticsNumberOfReviews => 'Number of reviews';

  @override
  String get learningStatisticsQuestion => 'Question';

  @override
  String get learningStatisticsToday => 'Today';

  @override
  String get learningStatisticsValue => 'Value';

  @override
  String get learningStatisticsYesterday => 'Yesterday';

  @override
  String get loadButton => 'Load';

  @override
  String get masteryLearning => 'Learning';

  @override
  String get masteryMature => 'Mature';

  @override
  String get masteryNew => 'New';

  @override
  String get masteryYoung => 'Young';

  @override
  String get minimumRequiredVersion => 'Minimum Required Version';

  @override
  String get monthDurationFilterLabel => 'Last month';

  @override
  String get myName => 'My name';

  @override
  String get newDeckGroupAddedMessage => 'New deck group added';

  @override
  String get newDeckGroupHelper => 'Enter new deck group name';

  @override
  String get newDeckGroupName => 'New deck group';

  @override
  String get noCardsMessage => 'No cards found.';

  @override
  String get noCardsToLearn => 'No cards to learn';

  @override
  String get noCollaboratorsYet => 'No collaborators yet';

  @override
  String get noDecksMessage => 'No decks found. Add your first deck';

  @override
  String get noProvisionaryCardsDescription =>
      'You don\'t have any quick notes waiting to be turned into flashcards. Add some by using the quick card creation feature.';

  @override
  String get noProvisionaryCardsHeadline => 'No provisionary cards to review';

  @override
  String get noProvisionaryCardsMessage => 'No card proposals to review';

  @override
  String get noSharedDecksMessage => 'No shared decks found';

  @override
  String get noUpdateAvailable => 'You\'re using the latest version';

  @override
  String get notReviewed => 'Not reviewed';

  @override
  String get ok => 'OK';

  @override
  String get openDeck => 'Open deck';

  @override
  String get orLabel => 'or';

  @override
  String get passwordLabel => 'Password';

  @override
  String get pasteText => 'Paste text';

  @override
  String get pasteTextHint => 'Paste your text here...';

  @override
  String get pendingInvitationsHeader => 'Pending invitations';

  @override
  String get personFilterLabel => 'You or friend';

  @override
  String get personalInfo => 'Personal info';

  @override
  String get pleaseEnterGoogleDocUrl => 'Please enter a Google Doc URL';

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
  String get profile => 'Profile';

  @override
  String get profileNameChanged => 'Profile name changed';

  @override
  String progressPercent(int percent) {
    return '+$percent%';
  }

  @override
  String get provisionaryCardsReviewButton => 'Review provisionary cards';

  @override
  String get provisionaryCardsReviewHeadline => 'Provisionary cards review';

  @override
  String get provisionaryCardText => 'Provisionary note';

  @override
  String get questionHint => 'Question text';

  @override
  String get questionLabel => 'Question';

  @override
  String get quickAddCard => 'Quick add card';

  @override
  String get rateAgainLabel => 'Again';

  @override
  String get rateEasyLabel => 'Easy';

  @override
  String get rateGoodLabel => 'Good';

  @override
  String get rateHardLabel => 'Hard';

  @override
  String get regenerateCardDescriptions => 'Regenerate descriptions';

  @override
  String get regenerateFlashcards => 'Regenerate flashcards';

  @override
  String get retry => 'Retry';

  @override
  String get saveAndNext => 'Save and add next';

  @override
  String get saveButton => 'Save';

  @override
  String get saveToDeck => 'Save to Deck';

  @override
  String get saving => 'Saving...';

  @override
  String get selectCard => 'Select card';

  @override
  String get selectGoogleDoc => 'Select Google Doc';

  @override
  String get selectInputSource => 'Select input source';

  @override
  String get sendInvitationButtonTooltip => 'Send invitation';

  @override
  String get sentInvitationsHeader => 'Sent invitations';

  @override
  String get settings => 'Settings';

  @override
  String get shareDeck => 'Share deck with others';

  @override
  String get sharedDecksHeader => 'Decks sheared by other users';

  @override
  String get showAnswer => 'Show answer';

  @override
  String get showContent => 'Show content';

  @override
  String get signIn => 'Login';

  @override
  String get signInButton => 'Sign In';

  @override
  String get signInLink => 'Sign in';

  @override
  String get signInTitle => 'Sign In';

  @override
  String get signInWithGoogleButton => 'Sign in with Google';

  @override
  String get signOut => 'Logout';

  @override
  String get signUpButton => 'Sign Up';

  @override
  String get signUpLink => 'Sign up';

  @override
  String get signUpTitle => 'Create Account';

  @override
  String get signUpWithGoogleButton => 'Sign up with Google';

  @override
  String get statistics => 'Statistics';

  @override
  String get switchToDarkMode => 'Switch to dark mode';

  @override
  String get switchToEnglish => 'Switch to English';

  @override
  String get switchToLightMode => 'Switch to light mode';

  @override
  String get switchToPolish => 'Switch to Polish';

  @override
  String textContentLength(int length) {
    return 'Text content length: $length';
  }

  @override
  String get timePerDeckChartTitle => 'Time spent per deck';

  @override
  String get timePerDeckChartTooltip =>
      'Shows how much time you spent studying each deck.';

  @override
  String get totalProgressLabel => 'Total Progress';

  @override
  String get totalTimeLabel => 'Total time:';

  @override
  String get totalTimeLabelTooltip =>
      'Total time spent reviewing cards in the selected period.';

  @override
  String get updateAvailable => 'Update Available';

  @override
  String get updateAvailableMessage =>
      'A new version of the app is available. Update now to get the latest features and improvements.';

  @override
  String get updateCheckFailed => 'Failed to check for updates';

  @override
  String get updateComplete => 'Update complete! The app will reload.';

  @override
  String get updateDownloading => 'Downloading update...';

  @override
  String get updateError => 'Update failed. Please try again.';

  @override
  String get updateInstalling => 'Installing update...';

  @override
  String get updateLater => 'Later';

  @override
  String get updateNow => 'Update Now';

  @override
  String get updateReminder =>
      'Don\'t forget to update! A new version is available.';

  @override
  String get updateSettings => 'Update Settings';

  @override
  String get updatingApp => 'Updating...';

  @override
  String get uploadImage => 'Upload image';

  @override
  String get uploadNewFile => 'Upload new file';

  @override
  String get uploadPdf => 'Upload PDF';

  @override
  String get userNotLoggedIn => 'You need to log in';

  @override
  String get versionCheckingWebOnly =>
      'Version checking is only available on web platform';

  @override
  String get warningTitle => 'Warning';

  @override
  String get weekDurationFilterLabel => 'Last 7 days';

  @override
  String get yourName => 'Your name';
}
