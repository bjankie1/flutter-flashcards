import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/layout/base_layout.dart';
import 'package:flutter_flashcards/src/widgets.dart';
import 'package:go_router/go_router.dart';

class LeftNavigation extends StatelessWidget {
  final PageIndex? currentPage;

  LeftNavigation({this.currentPage});

  @override
  Widget build(BuildContext context) {
    int selectedIndex = currentPage?.index ?? 0;
    return NavigationRail(
      destinations: [
        NavigationRailDestination(
          icon: Icon(Icons.edit_outlined),
          selectedIcon: Icon(
            Icons.edit,
          ),
          label: Text(context.l10n.decks),
        ),
        NavigationRailDestination(
          icon: RepositoryLoader(
              fetcher: (repository) => repository.cardsToReviewCount().then(
                  (value) =>
                      value.values.reduce((total, element) => total + element)),
              builder: (context, count, _) {
                return Badge.count(
                  isLabelVisible: count > 0,
                  count: count,
                  child: const Icon(Icons.school_outlined),
                );
              }),
          selectedIcon: Icon(Icons.school),
          label: Text(context.l10n.learning),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.show_chart_outlined),
          selectedIcon: Icon(Icons.show_chart),
          label: Text(context.l10n.statistics),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.people_alt_outlined),
          selectedIcon: Icon(Icons.people_alt),
          label: Text(context.l10n.collaboration),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: Text(context.l10n.settings),
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
            context.goNamed('collaboration');
          case 4:
            context.goNamed('settings');
        }
      },
    );
  }
}
