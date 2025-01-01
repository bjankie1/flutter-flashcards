import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/decks/cards_page.dart';
import 'package:flutter_flashcards/src/decks/decks_page.dart';
import 'package:flutter_flashcards/src/reviews/rewiews_landing_page.dart';
import 'package:flutter_flashcards/src/settings/settings_page.dart';
import 'package:flutter_flashcards/src/statistics/statistics_page.dart';
import 'package:flutter_flashcards/src/widgets.dart';
import 'package:go_router/go_router.dart';

import '../firebase_options.dart';
import 'reviews/study_cards_page.dart';

// Add GoRouter configuration outside the App class
final router = GoRouter(
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
      builder: (context, state) => DecksPage(),
      routes: [
        GoRoute(
          path: 'sign-in',
          builder: (context, state) {
            return SignInScreen(
              providers: [
                EmailAuthProvider(),
                GoogleProvider(
                    clientId: DefaultFirebaseOptions.GOOGLE_CLIENT_ID),
              ],
              actions: [
                ForgotPasswordAction(((context, email) {
                  final uri = Uri(
                    path: '/sign-in/forgot-password',
                    queryParameters: <String, String?>{
                      'email': email,
                    },
                  );
                  context.push(uri.toString());
                })),
                AuthStateChangeAction(((context, state) {
                  final user = switch (state) {
                    SignedIn state => state.user,
                    UserCreated state => state.credential.user,
                    _ => null
                  };
                  if (user == null) {
                    return;
                  }
                  if (state is UserCreated) {
                    user.updateDisplayName(user.email!.split('@')[0]);
                  }
                  if (!user.emailVerified) {
                    user.sendEmailVerification();
                    const snackBar = SnackBar(
                        content: Text(
                            'Please check your email to verify your email address'));
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                  context.go('/');
                })),
              ],
            );
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
        GoRoute(
          path: 'profile',
          builder: (context, state) {
            return ProfileScreen(
              providers: const [],
              actions: [
                SignedOutAction((context) {
                  context.go('/');
                }),
              ],
            );
          },
        ),
        GoRoute(
          path: 'decks/:deckId',
          name: 'deck',
          builder: (context, state) {
            final deckId = state.pathParameters['deckId'];
            if (deckId == null) {
              return DecksPage();
            }
            return RepositoryLoader(
                fetcher: (repository) async =>
                    await repository.loadDeck(deckId),
                builder: (context, deck, _) {
                  if (deck == null) {
                    return Text('Deck not found');
                  }
                  return CardsPage(
                    deck: deck,
                  );
                });
          },
        ),
        GoRoute(
          path: 'decks',
          name: 'decks',
          builder: (context, state) {
            return DecksPage();
          },
        ),
        GoRoute(
            path: 'study',
            name: 'study',
            builder: (context, state) {
              return ReviewsPage();
            },
            routes: [
              GoRoute(
                path: 'learn',
                name: 'learn',
                builder: (context, state) {
                  final deckId = state.uri.queryParameters['deckId'];
                  return StudyCardsPage(
                    deckId: deckId,
                  );
                },
              ),
            ]),
        GoRoute(
          path: 'statistics',
          name: 'statistics',
          builder: (context, state) {
            return StudyStatisticsPage();
          },
        ),
        GoRoute(
          path: 'settings',
          name: 'settings',
          builder: (context, state) {
            return SettingsPage();
          },
        ),
      ],
    ),
  ],
);
