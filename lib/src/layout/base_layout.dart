import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, GoogleAuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_flashcards/l10n/app_localizations.dart';
import 'package:flutter_flashcards/src/app_state.dart';
import 'package:flutter_flashcards/src/layout/left_navigation.dart';
import 'package:flutter_flashcards/src/model/repository.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../authentication.dart';
import 'package:go_router/go_router.dart';

enum PageIndex { cards, learning, statistics, settings, collaboration }

extension PageIndexNavigation on PageIndex {
  void navigate(BuildContext context) {
    switch (this) {
      case PageIndex.cards:
        context.goNamed('cards');
      case PageIndex.learning:
        context.goNamed('learning');
      case PageIndex.statistics:
        context.goNamed('statistics');
      case PageIndex.settings:
        context.goNamed('settings');
      case PageIndex.collaboration:
        context.goNamed('collaboration');
    }
  }
}

class BaseLayout extends StatelessWidget {
  final Widget child;

  final Widget title;

  final FloatingActionButton? floatingActionButton;

  final PageIndex? currentPage;

  const BaseLayout(
      {required this.child,
      required this.title,
      this.floatingActionButton,
      this.currentPage,
      super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        appBar: AppBar(
          // leading: ModalRoute.of(context)?.canPop ==
          //         true // Check if there's a previous route
          //     ? IconButton(
          //         icon: const Icon(Icons.arrow_back),
          //         onPressed: () => Navigator.of(context).pop(),
          //       )
          //     : null,
          title: Consumer<AppState>(
            builder: (context, appState, child) {
              return Row(
                children: [
                  title,
                  Spacer(),
                  ValueListenableBuilder<ThemeMode>(
                    valueListenable: context.watch<AppState>().currentTheme,
                    builder: (context, currentTheme, _) => IconButton(
                      icon: Icon(// Your icon based on current theme
                          currentTheme == ThemeMode.light
                              ? Icons.dark_mode
                              : Icons.light_mode),
                      onPressed: () {
                        Provider.of<AppState>(context, listen: false)
                            .toggleTheme();
                      },
                    ),
                  ),
                  LocaleSelection(),
                  Consumer<AppState>(
                    builder: (context, appState, _) => AuthFunc(
                        loggedIn: appState.loggedIn,
                        signOut: () {
                          FirebaseAuth.instance.signOut();
                          context.go('/');
                        }),
                  ),
                  Visibility(
                    visible: false,
                    child: IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () async {
                        await context.read<CardsRepository>().updateAllStats();
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LeftNavigation(
              currentPage: currentPage,
            ),
            Expanded(child: child)
          ],
        ),
        floatingActionButton: floatingActionButton,
      );
    });
  }
}

class LocaleSelection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: context.watch<AppState>().currentLocale,
        builder: (context, locale, _) {
          final locales = AppLocalizations.supportedLocales;
          final selectedIndices = {
            locales.firstWhere((l) => l.languageCode == locale.languageCode)
          }; // Calculate selected here
          return SegmentedButton(
            multiSelectionEnabled: false,
            selected: selectedIndices,
            segments: locales
                .map((locale) => ButtonSegment(
                    value: locale,
                    label: Text(locale.languageCode.toUpperCase())))
                .toList(),
            onSelectionChanged: (index) {
              Logger().i('Locale selected: ${index.first}');
              context.read<AppState>().locale = index.first;
            },
          );
        });
  }
}
