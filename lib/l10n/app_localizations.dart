import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pl')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Flashcards'**
  String get appTitle;

  /// No description provided for @cards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get cards;

  /// No description provided for @decks.
  ///
  /// In en, this message translates to:
  /// **'Decks'**
  String get decks;

  /// No description provided for @learning.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get learning;

  /// No description provided for @learn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get learn;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @cardsToReview.
  ///
  /// In en, this message translates to:
  /// **'To review: {count}'**
  String cardsToReview(int count);

  /// No description provided for @noCardsMessage.
  ///
  /// In en, this message translates to:
  /// **'No cards found.'**
  String get noCardsMessage;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @deckSaved.
  ///
  /// In en, this message translates to:
  /// **'\'Deck saved!\''**
  String get deckSaved;

  /// No description provided for @deckName.
  ///
  /// In en, this message translates to:
  /// **'Deck name'**
  String get deckName;

  /// No description provided for @addDeck.
  ///
  /// In en, this message translates to:
  /// **'Add deck'**
  String get addDeck;

  /// Label for add card button
  ///
  /// In en, this message translates to:
  /// **'Add card'**
  String get addCard;

  /// No description provided for @editDeck.
  ///
  /// In en, this message translates to:
  /// **'Edit deck'**
  String get editDeck;

  /// No description provided for @editCard.
  ///
  /// In en, this message translates to:
  /// **'Edit card'**
  String get editCard;

  /// No description provided for @deckEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Deck has no cards yet.'**
  String get deckEmptyMessage;

  /// No description provided for @deckHeader.
  ///
  /// In en, this message translates to:
  /// **'Cards for {deckName}'**
  String deckHeader(String deckName);

  /// No description provided for @saveAndNext.
  ///
  /// In en, this message translates to:
  /// **'Save and add next'**
  String get saveAndNext;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @deleteDeck.
  ///
  /// In en, this message translates to:
  /// **'Delete {deck}'**
  String deleteDeck(String deck);

  /// No description provided for @deleteDeckConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this deck?'**
  String get deleteDeckConfirmation;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get signOut;

  /// No description provided for @deckNamePrompt.
  ///
  /// In en, this message translates to:
  /// **'Please enter a deck name'**
  String get deckNamePrompt;

  /// No description provided for @noCardsToLearn.
  ///
  /// In en, this message translates to:
  /// **'No cards to learn'**
  String get noCardsToLearn;

  /// No description provided for @answerRecordedMessage.
  ///
  /// In en, this message translates to:
  /// **'Answer recorded'**
  String get answerRecordedMessage;

  /// No description provided for @showAnswer.
  ///
  /// In en, this message translates to:
  /// **'Show answer'**
  String get showAnswer;

  /// No description provided for @learnProgressMessage.
  ///
  /// In en, this message translates to:
  /// **'{total} cards to review'**
  String learnProgressMessage(int total);

  /// No description provided for @learnEverything.
  ///
  /// In en, this message translates to:
  /// **'Learn everything'**
  String get learnEverything;

  /// No description provided for @hintPrompt.
  ///
  /// In en, this message translates to:
  /// **'Hint (optional)'**
  String get hintPrompt;

  /// No description provided for @hintLabel.
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get hintLabel;

  /// No description provided for @rateAgainLabel.
  ///
  /// In en, this message translates to:
  /// **'Again'**
  String get rateAgainLabel;

  /// No description provided for @rateHardLabel.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get rateHardLabel;

  /// No description provided for @rateGoodLabel.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get rateGoodLabel;

  /// No description provided for @rateEasyLabel.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get rateEasyLabel;

  /// No description provided for @userNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'You need to log in'**
  String get userNotLoggedIn;

  /// No description provided for @printHours.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours'**
  String printHours(int hours);

  /// No description provided for @printMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes'**
  String printMinutes(int minutes);

  /// No description provided for @printSeconds.
  ///
  /// In en, this message translates to:
  /// **'{seconds} seconds'**
  String printSeconds(int seconds);

  /// No description provided for @weekDurationFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get weekDurationFilterLabel;

  /// No description provided for @monthDurationFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Last month'**
  String get monthDurationFilterLabel;

  /// No description provided for @cardReviewedPerHourHeader.
  ///
  /// In en, this message translates to:
  /// **'Cards reviewed per hour'**
  String get cardReviewedPerHourHeader;

  /// No description provided for @deckNameSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Deck name saved'**
  String get deckNameSavedMessage;

  /// No description provided for @deckDescriptionSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Deck description saved'**
  String get deckDescriptionSavedMessage;

  /// No description provided for @errorSavingDescriptionMessage.
  ///
  /// In en, this message translates to:
  /// **'Error saving description'**
  String get errorSavingDescriptionMessage;

  /// No description provided for @countCardsPerDeckChartTitle.
  ///
  /// In en, this message translates to:
  /// **'Number of cards studied per deck'**
  String get countCardsPerDeckChartTitle;

  /// No description provided for @timePerDeckChartTitle.
  ///
  /// In en, this message translates to:
  /// **'Time spent per deck'**
  String get timePerDeckChartTitle;

  /// No description provided for @answerLabel.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get answerLabel;

  /// No description provided for @answerHint.
  ///
  /// In en, this message translates to:
  /// **'Answer text'**
  String get answerHint;

  /// No description provided for @questionLabel.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get questionLabel;

  /// No description provided for @questionHint.
  ///
  /// In en, this message translates to:
  /// **'Question text'**
  String get questionHint;

  /// No description provided for @cardSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Card saved'**
  String get cardSavedMessage;

  /// No description provided for @cardSavingErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error saving card'**
  String get cardSavingErrorMessage;

  /// No description provided for @editCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Editing card in **{deck}** deck'**
  String editCardTitle(String deck);

  /// No description provided for @generateCardsForDeck.
  ///
  /// In en, this message translates to:
  /// **'Generate card for **{deck}** deck'**
  String generateCardsForDeck(String deck);

  /// No description provided for @createCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Create card in **{deck}**'**
  String createCardTitle(String deck);

  /// No description provided for @collaboration.
  ///
  /// In en, this message translates to:
  /// **'Collaboration'**
  String get collaboration;

  /// No description provided for @sentInvitationsHeader.
  ///
  /// In en, this message translates to:
  /// **'Sent invitations'**
  String get sentInvitationsHeader;

  /// No description provided for @pendingInvitationsHeader.
  ///
  /// In en, this message translates to:
  /// **'Pending invitations'**
  String get pendingInvitationsHeader;

  /// No description provided for @collaboratorsHeader.
  ///
  /// In en, this message translates to:
  /// **'Collaborators'**
  String get collaboratorsHeader;

  /// No description provided for @inviteCollaboratorPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter collaborator email'**
  String get inviteCollaboratorPrompt;

  /// No description provided for @invitationEmailHelperText.
  ///
  /// In en, this message translates to:
  /// **'Invitees email'**
  String get invitationEmailHelperText;

  /// No description provided for @invalidEmailMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get invalidEmailMessage;

  /// No description provided for @sendInvitationButtonTooltip.
  ///
  /// In en, this message translates to:
  /// **'Send invitation'**
  String get sendInvitationButtonTooltip;

  /// No description provided for @invitationSentMessage.
  ///
  /// In en, this message translates to:
  /// **'Invitation sent'**
  String get invitationSentMessage;

  /// No description provided for @cardDeletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Card deleted'**
  String get cardDeletedMessage;

  /// No description provided for @cardDeletionErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error deleting card'**
  String get cardDeletionErrorMessage;

  /// No description provided for @allCardsReviewedMessage.
  ///
  /// In en, this message translates to:
  /// **'Well done!'**
  String get allCardsReviewedMessage;

  /// No description provided for @personFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'You or friend'**
  String get personFilterLabel;

  /// No description provided for @deckSharedMessage.
  ///
  /// In en, this message translates to:
  /// **'Deck has been shared'**
  String get deckSharedMessage;

  /// No description provided for @deckSharedFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed sharing deck'**
  String get deckSharedFailedMessage;

  /// No description provided for @decksTitle.
  ///
  /// In en, this message translates to:
  /// **'My decks'**
  String get decksTitle;

  /// No description provided for @noDecksMessage.
  ///
  /// In en, this message translates to:
  /// **'No decks found. Add your first deck'**
  String get noDecksMessage;

  /// No description provided for @profileNameChanged.
  ///
  /// In en, this message translates to:
  /// **'Profile name changed'**
  String get profileNameChanged;

  /// No description provided for @noSharedDecksMessage.
  ///
  /// In en, this message translates to:
  /// **'No shared decks found'**
  String get noSharedDecksMessage;

  /// No description provided for @deckNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'Deck not found'**
  String get deckNotFoundMessage;

  /// No description provided for @cardOptionDoubleSided.
  ///
  /// In en, this message translates to:
  /// **'Learn both sides'**
  String get cardOptionDoubleSided;

  /// No description provided for @decksWithoutGroupHeader.
  ///
  /// In en, this message translates to:
  /// **'Decks without group'**
  String get decksWithoutGroupHeader;

  /// No description provided for @sharedDecksHeader.
  ///
  /// In en, this message translates to:
  /// **'Decks sheared by other users'**
  String get sharedDecksHeader;

  /// No description provided for @addDeckToGroup.
  ///
  /// In en, this message translates to:
  /// **'Add deck to group'**
  String get addDeckToGroup;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @newDeckGroupName.
  ///
  /// In en, this message translates to:
  /// **'New deck group'**
  String get newDeckGroupName;

  /// No description provided for @newDeckGroupHelper.
  ///
  /// In en, this message translates to:
  /// **'Enter new deck group name'**
  String get newDeckGroupHelper;

  /// No description provided for @newDeckGroupAddedMessage.
  ///
  /// In en, this message translates to:
  /// **'New deck group added'**
  String get newDeckGroupAddedMessage;

  /// No description provided for @explanationLabel.
  ///
  /// In en, this message translates to:
  /// **'Explanation:'**
  String get explanationLabel;

  /// No description provided for @cardReviewDaily.
  ///
  /// In en, this message translates to:
  /// **'Cards reviews per day'**
  String get cardReviewDaily;

  /// No description provided for @frontCardLabel.
  ///
  /// In en, this message translates to:
  /// **'Front card language'**
  String get frontCardLabel;

  /// No description provided for @languageHint.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get languageHint;

  /// No description provided for @backCardLabel.
  ///
  /// In en, this message translates to:
  /// **'Back card language'**
  String get backCardLabel;

  /// No description provided for @deckDescription.
  ///
  /// In en, this message translates to:
  /// **'Deck description'**
  String get deckDescription;

  /// No description provided for @deckSelect.
  ///
  /// In en, this message translates to:
  /// **'Select a deck'**
  String get deckSelect;

  /// No description provided for @addToDeck.
  ///
  /// In en, this message translates to:
  /// **'Add cards to deck'**
  String get addToDeck;

  /// No description provided for @deckGeneration.
  ///
  /// In en, this message translates to:
  /// **'Generate cards'**
  String get deckGeneration;

  /// No description provided for @inputTextForGenerator.
  ///
  /// In en, this message translates to:
  /// **'Text to generate flashcards for'**
  String get inputTextForGenerator;

  /// No description provided for @generateCards.
  ///
  /// In en, this message translates to:
  /// **'Generate cards'**
  String get generateCards;

  /// No description provided for @generateFlashcards.
  ///
  /// In en, this message translates to:
  /// **'Generate flashcards'**
  String get generateFlashcards;

  /// No description provided for @inputText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get inputText;

  /// No description provided for @addCardsToDeck.
  ///
  /// In en, this message translates to:
  /// **'Add cards to deck'**
  String get addCardsToDeck;

  /// No description provided for @createNewDeck.
  ///
  /// In en, this message translates to:
  /// **'Create new deck'**
  String get createNewDeck;

  /// No description provided for @shareDeck.
  ///
  /// In en, this message translates to:
  /// **'Share deck with others'**
  String get shareDeck;

  /// No description provided for @deckSharingHeader.
  ///
  /// In en, this message translates to:
  /// **'Deck sharing'**
  String get deckSharingHeader;

  /// No description provided for @deckSharedListTitle.
  ///
  /// In en, this message translates to:
  /// **'People with access'**
  String get deckSharedListTitle;

  /// No description provided for @deckNotSharedMessage.
  ///
  /// In en, this message translates to:
  /// **'Deck has yet been shared with anyone'**
  String get deckNotSharedMessage;

  /// No description provided for @quickAddCard.
  ///
  /// In en, this message translates to:
  /// **'Quick add card'**
  String get quickAddCard;

  /// No description provided for @provisionaryCardText.
  ///
  /// In en, this message translates to:
  /// **'Provisionary note'**
  String get provisionaryCardText;

  /// No description provided for @cardProposalLabel.
  ///
  /// In en, this message translates to:
  /// **'Card Proposal'**
  String get cardProposalLabel;

  /// No description provided for @provisionaryCardsReviewHeadline.
  ///
  /// In en, this message translates to:
  /// **'Provisionary cards review'**
  String get provisionaryCardsReviewHeadline;

  /// No description provided for @provisionaryCardsReviewButton.
  ///
  /// In en, this message translates to:
  /// **'Review provisionary cards'**
  String get provisionaryCardsReviewButton;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @noProvisionaryCardsHeadline.
  ///
  /// In en, this message translates to:
  /// **'No provisionary cards to review'**
  String get noProvisionaryCardsHeadline;

  /// No description provided for @switchToLightMode.
  ///
  /// In en, this message translates to:
  /// **'Switch to light mode'**
  String get switchToLightMode;

  /// No description provided for @switchToDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Switch to dark mode'**
  String get switchToDarkMode;

  /// No description provided for @switchToEnglish.
  ///
  /// In en, this message translates to:
  /// **'Switch to English'**
  String get switchToEnglish;

  /// No description provided for @switchToPolish.
  ///
  /// In en, this message translates to:
  /// **'Switch to Polish'**
  String get switchToPolish;

  /// No description provided for @totalProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Progress'**
  String get totalProgressLabel;

  /// No description provided for @deckProgress.
  ///
  /// In en, this message translates to:
  /// **'{deckName} Progress'**
  String deckProgress(String deckName);

  /// No description provided for @progressPercent.
  ///
  /// In en, this message translates to:
  /// **'+{percent}%'**
  String progressPercent(int percent);

  /// No description provided for @masteryNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get masteryNew;

  /// No description provided for @masteryLearning.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get masteryLearning;

  /// No description provided for @masteryYoung.
  ///
  /// In en, this message translates to:
  /// **'Young'**
  String get masteryYoung;

  /// No description provided for @masteryMature.
  ///
  /// In en, this message translates to:
  /// **'Mature'**
  String get masteryMature;

  /// No description provided for @errorLoadingCards.
  ///
  /// In en, this message translates to:
  /// **'Error loading cards'**
  String get errorLoadingCards;

  /// No description provided for @cardQuestionDisplay.
  ///
  /// In en, this message translates to:
  /// **'Question:'**
  String get cardQuestionDisplay;

  /// No description provided for @cardAnswerDisplay.
  ///
  /// In en, this message translates to:
  /// **'Answer:'**
  String get cardAnswerDisplay;

  /// No description provided for @cardsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search cards...'**
  String get cardsSearchHint;

  /// No description provided for @hintIconTooltip.
  ///
  /// In en, this message translates to:
  /// **'This card has a hint'**
  String get hintIconTooltip;

  /// No description provided for @cardOptionDoubleSidedTooltip.
  ///
  /// In en, this message translates to:
  /// **'This card can be learned from both sides'**
  String get cardOptionDoubleSidedTooltip;

  /// No description provided for @deleteCardTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete card'**
  String get deleteCardTooltip;

  /// No description provided for @deckDescriptionSaveErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error saving deck description'**
  String get deckDescriptionSaveErrorMessage;

  /// No description provided for @learningStatisticsDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Learning Statistics'**
  String get learningStatisticsDialogTitle;

  /// No description provided for @learningStatisticsMetric.
  ///
  /// In en, this message translates to:
  /// **'Metric'**
  String get learningStatisticsMetric;

  /// No description provided for @learningStatisticsQuestion.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get learningStatisticsQuestion;

  /// No description provided for @learningStatisticsAnswer.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get learningStatisticsAnswer;

  /// No description provided for @learningStatisticsValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get learningStatisticsValue;

  /// No description provided for @learningStatisticsNumberOfReviews.
  ///
  /// In en, this message translates to:
  /// **'Number of reviews'**
  String get learningStatisticsNumberOfReviews;

  /// No description provided for @learningStatisticsDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get learningStatisticsDifficulty;

  /// No description provided for @learningStatisticsLastReview.
  ///
  /// In en, this message translates to:
  /// **'Last review'**
  String get learningStatisticsLastReview;

  /// No description provided for @learningStatisticsNextReview.
  ///
  /// In en, this message translates to:
  /// **'Next review'**
  String get learningStatisticsNextReview;

  /// No description provided for @learningStatisticsDifficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get learningStatisticsDifficultyEasy;

  /// No description provided for @learningStatisticsDifficultyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get learningStatisticsDifficultyMedium;

  /// No description provided for @learningStatisticsDifficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get learningStatisticsDifficultyHard;

  /// No description provided for @learningStatisticsNotScheduled.
  ///
  /// In en, this message translates to:
  /// **'Not scheduled'**
  String get learningStatisticsNotScheduled;

  /// No description provided for @learningStatisticsDueAlready.
  ///
  /// In en, this message translates to:
  /// **'due already'**
  String get learningStatisticsDueAlready;

  /// No description provided for @learningStatisticsToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get learningStatisticsToday;

  /// No description provided for @learningStatisticsYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get learningStatisticsYesterday;

  /// No description provided for @learningStatisticsClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get learningStatisticsClose;

  /// No description provided for @learningStatisticsDay.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {# day} other {# days}}'**
  String learningStatisticsDay(num count);

  /// No description provided for @learningStatisticsHour.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {# hour} other {# hours}}'**
  String learningStatisticsHour(num count);

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Update Available'**
  String get updateAvailable;

  /// No description provided for @updateAvailableMessage.
  ///
  /// In en, this message translates to:
  /// **'A new version of the app is available. Update now to get the latest features and improvements.'**
  String get updateAvailableMessage;

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get updateNow;

  /// No description provided for @updateLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get updateLater;

  /// No description provided for @updatingApp.
  ///
  /// In en, this message translates to:
  /// **'Updating...'**
  String get updatingApp;

  /// No description provided for @updateCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to check for updates'**
  String get updateCheckFailed;

  /// No description provided for @updateDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading update...'**
  String get updateDownloading;

  /// No description provided for @updateInstalling.
  ///
  /// In en, this message translates to:
  /// **'Installing update...'**
  String get updateInstalling;

  /// No description provided for @updateComplete.
  ///
  /// In en, this message translates to:
  /// **'Update complete! The app will reload.'**
  String get updateComplete;

  /// No description provided for @updateError.
  ///
  /// In en, this message translates to:
  /// **'Update failed. Please try again.'**
  String get updateError;

  /// No description provided for @checkingForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Checking for updates...'**
  String get checkingForUpdates;

  /// No description provided for @noUpdateAvailable.
  ///
  /// In en, this message translates to:
  /// **'You\'re using the latest version'**
  String get noUpdateAvailable;

  /// No description provided for @updateReminder.
  ///
  /// In en, this message translates to:
  /// **'Don\'t forget to update! A new version is available.'**
  String get updateReminder;

  /// Title for the deck details page
  ///
  /// In en, this message translates to:
  /// **'Deck Details'**
  String get deckDetails;

  /// No description provided for @generateFromGoogleDoc.
  ///
  /// In en, this message translates to:
  /// **'Generate from Google Doc'**
  String get generateFromGoogleDoc;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal info'**
  String get personalInfo;

  /// No description provided for @myName.
  ///
  /// In en, this message translates to:
  /// **'My name'**
  String get myName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get yourName;

  /// No description provided for @imageRecorded.
  ///
  /// In en, this message translates to:
  /// **'Image recorded'**
  String get imageRecorded;

  /// No description provided for @errorUploadingImage.
  ///
  /// In en, this message translates to:
  /// **'Error uploading image'**
  String get errorUploadingImage;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @currentVersion.
  ///
  /// In en, this message translates to:
  /// **'Current Version'**
  String get currentVersion;

  /// No description provided for @latestAvailableVersion.
  ///
  /// In en, this message translates to:
  /// **'Latest Available Version'**
  String get latestAvailableVersion;

  /// No description provided for @minimumRequiredVersion.
  ///
  /// In en, this message translates to:
  /// **'Minimum Required Version'**
  String get minimumRequiredVersion;

  /// No description provided for @checkForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for Updates'**
  String get checkForUpdates;

  /// No description provided for @updateSettings.
  ///
  /// In en, this message translates to:
  /// **'Update Settings'**
  String get updateSettings;

  /// No description provided for @automaticUpdateChecks.
  ///
  /// In en, this message translates to:
  /// **'Automatic update checks every 10 minutes'**
  String get automaticUpdateChecks;

  /// No description provided for @versionCheckingWebOnly.
  ///
  /// In en, this message translates to:
  /// **'Version checking is only available on web platform'**
  String get versionCheckingWebOnly;

  /// No description provided for @googleDocLink.
  ///
  /// In en, this message translates to:
  /// **'Google Doc Link'**
  String get googleDocLink;

  /// No description provided for @googleDocHelperText.
  ///
  /// In en, this message translates to:
  /// **'Paste the link to your Google Doc to generate cards from it.'**
  String get googleDocHelperText;

  /// No description provided for @selectGoogleDoc.
  ///
  /// In en, this message translates to:
  /// **'Select Google Doc'**
  String get selectGoogleDoc;

  /// No description provided for @docContentLength.
  ///
  /// In en, this message translates to:
  /// **'Doc content length: {length}'**
  String docContentLength(int length);

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorPrefix(String message);

  /// No description provided for @enterGoogleDocUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter Google Doc URL:'**
  String get enterGoogleDocUrl;

  /// No description provided for @googleDocUrlHint.
  ///
  /// In en, this message translates to:
  /// **'https://docs.google.com/document/d/...'**
  String get googleDocUrlHint;

  /// No description provided for @googleDocUrlExample.
  ///
  /// In en, this message translates to:
  /// **'Example: https://docs.google.com/document/d/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms/edit'**
  String get googleDocUrlExample;

  /// No description provided for @pleaseEnterGoogleDocUrl.
  ///
  /// In en, this message translates to:
  /// **'Please enter a Google Doc URL'**
  String get pleaseEnterGoogleDocUrl;

  /// No description provided for @invalidGoogleDocUrl.
  ///
  /// In en, this message translates to:
  /// **'Invalid Google Doc URL. Please check the URL and try again.'**
  String get invalidGoogleDocUrl;

  /// No description provided for @loadButton.
  ///
  /// In en, this message translates to:
  /// **'Load'**
  String get loadButton;

  /// No description provided for @cancelButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButtonLabel;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @answersLabel.
  ///
  /// In en, this message translates to:
  /// **'Answers:'**
  String get answersLabel;

  /// No description provided for @totalTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Total time:'**
  String get totalTimeLabel;

  /// No description provided for @averageTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Average (s):'**
  String get averageTimeLabel;

  /// Error message shown when collaborators list fails to load.
  ///
  /// In en, this message translates to:
  /// **'Error loading collaborators: {error}'**
  String errorLoadingCollaborators(String error);

  /// Shown when there are no collaborators in the list.
  ///
  /// In en, this message translates to:
  /// **'No collaborators yet'**
  String get noCollaboratorsYet;

  /// Hint shown when there are no collaborators.
  ///
  /// In en, this message translates to:
  /// **'Invite someone to collaborate on your flashcards'**
  String get inviteCollaboratorHint;

  /// No description provided for @answersLabelTooltip.
  ///
  /// In en, this message translates to:
  /// **'Total number of answers (cards reviewed) in the selected period.'**
  String get answersLabelTooltip;

  /// No description provided for @totalTimeLabelTooltip.
  ///
  /// In en, this message translates to:
  /// **'Total time spent reviewing cards in the selected period.'**
  String get totalTimeLabelTooltip;

  /// No description provided for @averageTimeLabelTooltip.
  ///
  /// In en, this message translates to:
  /// **'Average time spent reviewing cards per day in the selected period.'**
  String get averageTimeLabelTooltip;

  /// No description provided for @cardReviewedPerHourTooltip.
  ///
  /// In en, this message translates to:
  /// **'Distribution of card reviews by time of day. Helps you see when you study most.'**
  String get cardReviewedPerHourTooltip;

  /// No description provided for @cardReviewDailyTooltip.
  ///
  /// In en, this message translates to:
  /// **'Number of cards reviewed each day in the selected period.'**
  String get cardReviewDailyTooltip;

  /// No description provided for @countCardsPerDeckChartTooltip.
  ///
  /// In en, this message translates to:
  /// **'Shows how many cards you studied from each deck.'**
  String get countCardsPerDeckChartTooltip;

  /// No description provided for @timePerDeckChartTooltip.
  ///
  /// In en, this message translates to:
  /// **'Shows how much time you spent studying each deck.'**
  String get timePerDeckChartTooltip;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signInTitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @signInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signInButton;

  /// No description provided for @orLabel.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get orLabel;

  /// No description provided for @signInWithGoogleButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogleButton;

  /// No description provided for @signUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get signUpTitle;

  /// No description provided for @signUpButton.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpButton;

  /// No description provided for @signUpWithGoogleButton.
  ///
  /// In en, this message translates to:
  /// **'Sign up with Google'**
  String get signUpWithGoogleButton;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @signUpLink.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUpLink;

  /// No description provided for @signInLink.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInLink;

  /// No description provided for @selectCard.
  ///
  /// In en, this message translates to:
  /// **'Select card'**
  String get selectCard;

  /// No description provided for @deselectCard.
  ///
  /// In en, this message translates to:
  /// **'Deselect card'**
  String get deselectCard;

  /// No description provided for @uploadNewFile.
  ///
  /// In en, this message translates to:
  /// **'Upload new file'**
  String get uploadNewFile;

  /// No description provided for @regenerateFlashcards.
  ///
  /// In en, this message translates to:
  /// **'Regenerate flashcards'**
  String get regenerateFlashcards;

  /// No description provided for @generatedFlashcards.
  ///
  /// In en, this message translates to:
  /// **'Generated Flashcards ({count})'**
  String generatedFlashcards(Object count);

  /// No description provided for @editCards.
  ///
  /// In en, this message translates to:
  /// **'Edit Cards'**
  String get editCards;

  /// No description provided for @saveToDeck.
  ///
  /// In en, this message translates to:
  /// **'Save to Deck'**
  String get saveToDeck;

  /// No description provided for @showContent.
  ///
  /// In en, this message translates to:
  /// **'Show content'**
  String get showContent;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @docLength.
  ///
  /// In en, this message translates to:
  /// **'Doc length: {length}'**
  String docLength(int length);

  /// No description provided for @fileSize.
  ///
  /// In en, this message translates to:
  /// **'File size: {size} bytes'**
  String fileSize(int size);

  /// No description provided for @selectInputSource.
  ///
  /// In en, this message translates to:
  /// **'Select input source'**
  String get selectInputSource;

  /// No description provided for @pasteText.
  ///
  /// In en, this message translates to:
  /// **'Paste text'**
  String get pasteText;

  /// No description provided for @uploadPdf.
  ///
  /// In en, this message translates to:
  /// **'Upload PDF'**
  String get uploadPdf;

  /// No description provided for @uploadImage.
  ///
  /// In en, this message translates to:
  /// **'Upload image'**
  String get uploadImage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @pasteTextHint.
  ///
  /// In en, this message translates to:
  /// **'Paste your text here...'**
  String get pasteTextHint;

  /// No description provided for @textContentLength.
  ///
  /// In en, this message translates to:
  /// **'Text content length: {length}'**
  String textContentLength(int length);

  /// No description provided for @addFrontCardDescription.
  ///
  /// In en, this message translates to:
  /// **'add front of the card description'**
  String get addFrontCardDescription;

  /// No description provided for @addBackCardDescription.
  ///
  /// In en, this message translates to:
  /// **'add back of the card description'**
  String get addBackCardDescription;

  /// No description provided for @addExplanationDescription.
  ///
  /// In en, this message translates to:
  /// **'add answer explanation description'**
  String get addExplanationDescription;

  /// No description provided for @frontCardDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Front of card description'**
  String get frontCardDescriptionLabel;

  /// No description provided for @backCardDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Back of card description'**
  String get backCardDescriptionLabel;

  /// No description provided for @explanationDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Answer explanation description'**
  String get explanationDescriptionLabel;

  /// No description provided for @frontCardDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe what should be on the front of cards in this deck'**
  String get frontCardDescriptionHint;

  /// No description provided for @backCardDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe what should be on the back of cards in this deck'**
  String get backCardDescriptionHint;

  /// No description provided for @explanationDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe what explanations should include for answers in this deck'**
  String get explanationDescriptionHint;

  /// No description provided for @frontCardDescriptionSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Front card description saved'**
  String get frontCardDescriptionSavedMessage;

  /// No description provided for @backCardDescriptionSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Back card description saved'**
  String get backCardDescriptionSavedMessage;

  /// No description provided for @explanationDescriptionSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Explanation description saved'**
  String get explanationDescriptionSavedMessage;

  /// No description provided for @frontCardDescriptionSaveErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error saving front card description'**
  String get frontCardDescriptionSaveErrorMessage;

  /// No description provided for @backCardDescriptionSaveErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error saving back card description'**
  String get backCardDescriptionSaveErrorMessage;

  /// No description provided for @explanationDescriptionSaveErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error saving explanation description'**
  String get explanationDescriptionSaveErrorMessage;

  /// No description provided for @noProvisionaryCardsMessage.
  ///
  /// In en, this message translates to:
  /// **'No card proposals to review'**
  String get noProvisionaryCardsMessage;

  /// No description provided for @noProvisionaryCardsDescription.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any quick notes waiting to be turned into flashcards. Add some by using the quick card creation feature.'**
  String get noProvisionaryCardsDescription;

  /// No description provided for @allProvisionaryCardsReviewedMessage.
  ///
  /// In en, this message translates to:
  /// **'All card proposals reviewed!'**
  String get allProvisionaryCardsReviewedMessage;

  /// No description provided for @allProvisionaryCardsReviewedDescription.
  ///
  /// In en, this message translates to:
  /// **'Great job! You\'ve processed all your quick notes. They\'ve been converted into proper flashcards and are ready for learning.'**
  String get allProvisionaryCardsReviewedDescription;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get goBack;

  /// No description provided for @openDeck.
  ///
  /// In en, this message translates to:
  /// **'Open deck'**
  String get openDeck;

  /// No description provided for @warningTitle.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warningTitle;

  /// No description provided for @finalizeEditingWarning.
  ///
  /// In en, this message translates to:
  /// **'Please save or cancel your edits in all fields before saving the card.'**
  String get finalizeEditingWarning;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @generateCardDescriptions.
  ///
  /// In en, this message translates to:
  /// **'Generate Card Descriptions'**
  String get generateCardDescriptions;

  /// No description provided for @cardDescriptionsGeneratedMessage.
  ///
  /// In en, this message translates to:
  /// **'Card descriptions generated successfully'**
  String get cardDescriptionsGeneratedMessage;

  /// No description provided for @cardDescriptionsGenerationErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error generating card descriptions'**
  String get cardDescriptionsGenerationErrorMessage;

  /// No description provided for @generatedCardDescriptions.
  ///
  /// In en, this message translates to:
  /// **'Generated Card Descriptions'**
  String get generatedCardDescriptions;

  /// No description provided for @confidenceLevel.
  ///
  /// In en, this message translates to:
  /// **'Confidence Level'**
  String get confidenceLevel;

  /// No description provided for @analysis.
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get analysis;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @cardDescriptionsAppliedMessage.
  ///
  /// In en, this message translates to:
  /// **'Card descriptions applied successfully'**
  String get cardDescriptionsAppliedMessage;

  /// No description provided for @cardDescriptionsApplyErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error applying card descriptions'**
  String get cardDescriptionsApplyErrorMessage;

  /// No description provided for @cardDescriptionsConfigured.
  ///
  /// In en, this message translates to:
  /// **'Card descriptions configured'**
  String get cardDescriptionsConfigured;

  /// No description provided for @regenerateCardDescriptions.
  ///
  /// In en, this message translates to:
  /// **'Regenerate descriptions'**
  String get regenerateCardDescriptions;

  /// No description provided for @cardDescriptions.
  ///
  /// In en, this message translates to:
  /// **'Card Descriptions'**
  String get cardDescriptions;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'pl': return AppLocalizationsPl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
