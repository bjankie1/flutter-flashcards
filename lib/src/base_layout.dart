import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, GoogleAuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/app_state.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import 'authentication.dart';
import 'package:go_router/go_router.dart';

enum PageIndex { cards, learning, statistics, settings }

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
    }
  }
}

class BaseLayout extends StatelessWidget {
  final Widget child;

  final String title;

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
          leading: ModalRoute.of(context)?.canPop ==
                  true // Check if there's a previous route
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                )
              : null,
          title: Consumer<AppState>(
            builder: (context, appState, child) {
              return Row(
                children: [
                  Text(appState.title),
                  Spacer(),
                  Consumer<AppState>(
                    builder: (context, appState, _) => AuthFunc(
                        loggedIn: appState.loggedIn,
                        signOut: () {
                          FirebaseAuth.instance.signOut();
                        }),
                  ),
                ],
              );
            },
          ),
        ),
        body: Row(
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

class LeftNavigation extends StatelessWidget {
  final PageIndex? currentPage;

  final _log = Logger();

  LeftNavigation({this.currentPage});

  @override
  Widget build(BuildContext context) {
    _log.i('Page index is $currentPage');
    int selectedIndex = currentPage?.index ?? 0;

    return NavigationRail(
      destinations: [
        NavigationRailDestination(
          icon: Icon(Icons.edit_outlined),
          selectedIcon: Icon(
            Icons.edit,
          ),
          label: Text('Decks'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.school_outlined),
          selectedIcon: Icon(Icons.school),
          label: Text('Learning'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.show_chart_outlined),
          selectedIcon: Icon(Icons.show_chart),
          label: Text('Statistics'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: Text('Settings'),
        ),
      ],
      selectedIndex: selectedIndex,
      groupAlignment: -0.8,
      labelType: NavigationRailLabelType.all,
      onDestinationSelected: (int index) {
        switch (index) {
          case 0:
            context.goNamed('decks');
          case 1:
            context.goNamed('study');
          case 2:
            context.goNamed('statistics');
          case 3:
            context.goNamed('settings');
        }
      },
    );
  }
}
