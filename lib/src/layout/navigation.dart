import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/layout/base_layout.dart';
import 'package:flutter_flashcards/src/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

class Destinations {
  final BuildContext context;

  Destinations({required this.context});

  List<NavigationDestination> get destinations => [
    NavigationDestination(
      icon: Icon(Icons.home),
      selectedIcon: Icon(Icons.home_filled),
      label: context.l10n.decks,
    ),
    NavigationDestination(
      icon: Icon(Icons.show_chart_outlined),
      selectedIcon: Icon(Icons.show_chart),
      label: context.l10n.statistics,
    ),
    NavigationDestination(
      icon: Icon(Icons.people_alt_outlined),
      selectedIcon: Icon(Icons.people_alt),
      label: context.l10n.collaboration,
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: context.l10n.settings,
    ),
  ];

  List<NavigationRailDestination> get navigationRailDestinations => destinations
      .map(
        (d) => NavigationRailDestination(
          icon: d.icon,
          selectedIcon: d.selectedIcon,
          label: Text(d.label),
        ),
      )
      .toList();

  void navigate(int index) {
    switch (index) {
      case 0:
        context.goNamed('decks');
      case 1:
        context.goNamed('statistics');
      case 2:
        context.goNamed('collaboration');
      case 3:
        context.goNamed('settings');
    }
  }
}

class LeftNavigation extends StatelessWidget {
  final PageIndex? currentPage;

  LeftNavigation({this.currentPage});

  @override
  Widget build(BuildContext context) {
    int selectedIndex = currentPage?.index ?? 0;
    Logger().d('LeftNavigation page $currentPage index $selectedIndex');
    final destinations = Destinations(context: context);
    return NavigationRail(
      destinations: destinations.navigationRailDestinations,
      selectedIndex: selectedIndex,
      groupAlignment: -0.8,
      labelType: NavigationRailLabelType.all,
      onDestinationSelected: destinations.navigate,
    );
  }
}

/// Bottom navigation to be used in case of mobile devices (<600 effective
/// pixels).
class BottomNavigation extends StatelessWidget {
  final PageIndex? currentPage;

  const BottomNavigation({super.key, this.currentPage});

  @override
  Widget build(BuildContext context) {
    int selectedIndex = currentPage?.index ?? 0;
    final destinations = Destinations(context: context);
    return NavigationBar(
      selectedIndex: selectedIndex,
      destinations: destinations.destinations,
      onDestinationSelected: destinations.navigate,
    );
  }
}
