import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/collaboration/collaboration_page.dart';
import 'package:flutter_flashcards/src/decks/card_edit_page.dart';
import 'package:flutter_flashcards/src/decks/cards_list/deck_details_page.dart';
// Removed import for deck_generate_from_google_doc_page.dart - now using generic deck_generate_page.dart
import 'package:flutter_flashcards/src/decks/deck_generate_page.dart';
import 'package:flutter_flashcards/src/decks/deck_groups/deck_groups_page.dart';
import 'package:flutter_flashcards/src/decks/provisionary_cards/provisionary_card_complete.dart';
import 'package:flutter_flashcards/src/settings/settings_page.dart';
import 'package:flutter_flashcards/src/statistics/statistics_page.dart';
import 'package:flutter_flashcards/src/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:flutter_flashcards/src/app.dart' show appNavigatorKey;

import 'reviews/study_cards_page.dart';
import 'package:flutter_flashcards/src/login/login_screen.dart';
import 'package:flutter_flashcards/src/signup/signup_screen.dart';

final _log = Logger();

enum NamedRoute {
  quickCards,
  learn,
  generateCards,
  generateFromGoogleDoc,
  decks,
  addCard,
  editCard,
  statistics,
  settings,
  collaboration,
}

/// Navigation service to encapsulate navigation logic
class AppNavigation {
  /// Navigate to learn page with deck ID
  static void goToLearn(BuildContext context, String deckId) {
    context.go('/learn?deckId=$deckId');
  }

  /// Navigate to learn page with deck ID and deck group ID
  static void goToLearnWithGroup(
    BuildContext context,
    String deckId,
    String deckGroupId,
  ) {
    context.go('/learn?deckId=$deckId&deckGroupId=$deckGroupId');
  }

  /// Navigate to deck details page
  static void goToDeck(BuildContext context, String deckId) {
    context.go('/decks/$deckId');
  }

  /// Navigate to add card page
  static void goToAddCard(BuildContext context, String deckId) {
    context.go('/decks/$deckId/add');
  }

  /// Navigate to edit card page
  static void goToEditCard(BuildContext context, String deckId, String cardId) {
    context.go('/decks/$deckId/cards/$cardId');
  }

  /// Navigate to generate cards page
  static void goToGenerateCards(BuildContext context, {String? deckId}) {
    final queryParams = deckId != null ? '?deckId=$deckId' : '';
    context.go('/generate$queryParams');
  }

  /// Navigate to generate from Google Doc page (deprecated, use goToGenerateCards)
  static void goToGenerateFromGoogleDoc(
    BuildContext context, {
    String? deckId,
  }) {
    goToGenerateCards(context, deckId: deckId);
  }

  /// Navigate to quick cards page
  static void goToQuickCards(BuildContext context) {
    context.go('/quick-cards');
  }

  /// Navigate to statistics page
  static void goToStatistics(BuildContext context) {
    context.go('/statistics');
  }

  /// Navigate to settings page
  static void goToSettings(BuildContext context) {
    context.go('/settings');
  }

  /// Navigate to collaboration page
  static void goToCollaboration(BuildContext context) {
    context.go('/collaboration');
  }

  /// Navigate to sign in page
  static void goToSignIn(BuildContext context) {
    context.go('/sign-in');
  }

  /// Navigate to sign up page
  static void goToSignUp(BuildContext context) {
    context.go('/sign-up');
  }

  /// Navigate to profile page
  static void goToProfile(BuildContext context) {
    context.go('/profile');
  }

  /// Navigate to home page
  static void goToHome(BuildContext context) {
    context.go('/');
  }
}

// Add GoRouter configuration outside the App class
final router = GoRouter(
  navigatorKey: appNavigatorKey,
  // Add a top-level redirect based on authentication state
  redirect: (context, state) {
    final loggedIn = FirebaseAuth.instance.currentUser != null;
    final loggingIn = state.uri.path == '/sign-in';
    if (!loggedIn && !loggingIn) {
      return '/sign-in';
    }
    if (loggedIn && loggingIn) {
      return '/';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      redirect: (context, state) {
        final bool loggedIn =
            FirebaseAuth.instance.currentUser != null; // Check login state
        if (!loggedIn) {
          return '/sign-in'; // Redirect to sign-in if not logged in
        }
        return null; // Proceed with normal navigation if logged in
      },
      builder: (context, state) => const DeckGroupsPage(),
      routes: [
        GoRoute(
          path: 'sign-in',
          builder: (context, state) {
            return const LoginScreen();
          },
          routes: [
            GoRoute(
              path: 'forgot-password',
              builder: (context, state) {
                final arguments = state.uri.queryParameters;
                return ForgotPasswordScreen(
                  email: arguments['email'],
                  headerMaxExtent: 200,
                );
              },
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) {
        return ProfileScreen(
          providers: const [],
          actions: [
            SignedOutAction((context) {
              context.go('/sign-in');
            }),
          ],
        );
      },
    ),
    GoRoute(
      path: '/decks/:deckId',
      name: 'deck',
      builder: (context, state) {
        final deckId = state.pathParameters['deckId'];
        if (deckId == null) {
          return const DeckGroupsPage();
        }
        return RepositoryLoader(
          fetcher: (repository) async => await repository.loadDeck(deckId),
          builder: (context, deck, _) {
            if (deck == null) {
              _log.d('Deck $deckId not found');
              return Text('Deck not found');
            }
            return DeckDetailsPage(deck: deck);
          },
        );
      },
      routes: [
        GoRoute(
          path: '/cards/:cardId',
          name: NamedRoute.editCard.name,
          builder: (context, state) {
            final deckId = state.pathParameters['deckId'];
            if (deckId == null) {
              return const DeckGroupsPage();
            }
            final cardId = state.pathParameters['cardId'];

            return RepositoryLoader(
              fetcher: (repository) async =>
                  cardId != null && cardId != 'create'
                  ? await repository.loadCard(cardId)
                  : null,
              builder: (context, card, _) {
                if (cardId != null && card == null) {
                  return Text('Card not found');
                }
                return CardEditPage(card: card, deckId: deckId);
              },
            );
          },
        ),
        GoRoute(
          path: 'add',
          name: NamedRoute.addCard.name,
          builder: (context, state) {
            Logger().i('Creating card');
            final deckId = state.pathParameters['deckId'];
            if (deckId == null) {
              return const DeckGroupsPage();
            }
            return CardEditPage(deckId: deckId);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/decks',
      name: NamedRoute.decks.name,
      builder: (context, state) {
        return const DeckGroupsPage();
      },
      routes: [],
    ),
    GoRoute(
      path: '/generate',
      name: NamedRoute.generateCards.name,
      builder: (context, state) {
        final deckId = state.uri.queryParameters['deckId'];
        Logger().i('Creating deck from text');
        return DeckGeneratePage(deckId: deckId);
      },
    ),
    // Removed Google Doc specific route - now handled by generic generate route
    GoRoute(
      path: '/quick-cards',
      name: NamedRoute.quickCards.name,
      builder: (context, state) {
        return ProvisionaryCardsReviewPage();
      },
    ),
    GoRoute(
      path: '/learn',
      name: NamedRoute.learn.name,
      builder: (context, state) {
        final deckId = state.uri.queryParameters['deckId'];
        final deckGroupId = state.uri.queryParameters['deckGroupId'];
        return StudyCardsPage(deckId: deckId, deckGroupId: deckGroupId);
      },
    ),
    GoRoute(
      path: '/statistics',
      name: NamedRoute.statistics.name,
      builder: (context, state) {
        return StudyStatisticsPage();
      },
    ),
    GoRoute(
      path: '/settings',
      name: NamedRoute.settings.name,
      builder: (context, state) {
        return SettingsPage();
      },
    ),
    GoRoute(
      path: '/collaboration',
      name: NamedRoute.collaboration.name,
      builder: (context, state) {
        return CollaborationPage();
      },
    ),
    GoRoute(
      path: '/sign-up',
      builder: (context, state) => const SignupScreen(),
    ),
  ],
);
