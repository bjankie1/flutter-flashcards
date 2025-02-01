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

  /// No description provided for @addCard.
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
