import 'package:flutter/material.dart';
import 'package:flutter_flashcards/l10n/app_localizations.dart';
import 'package:flutter_flashcards/src/app_state.dart';
import 'package:flutter_flashcards/src/common/avatar.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/layout/UserMenu.dart';
import 'package:flutter_flashcards/src/layout/left_navigation.dart';
import 'package:flutter_flashcards/src/model/repository.dart';
import 'package:flutter_flashcards/src/model/users_collaboration.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

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
                  ValueListenableBuilder<UserProfile?>(
                    valueListenable: context.appState.userProfile,
                    builder: (context, userProfile, _) => IconButton(
                      icon: Icon(// Your icon based on current theme
                          userProfile?.theme == ThemeMode.light
                              ? Icons.dark_mode
                              : Icons.light_mode),
                      onPressed: () {
                        Provider.of<AppState>(context, listen: false)
                            .toggleTheme();
                      },
                    ),
                  ),
                  LocaleSelection(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: UserMenu(
                        child: Avatar(
                      size: 30,
                    )),
                  ),
                  Visibility(
                    visible: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () async {
                          await context
                              .read<CardsRepository>()
                              .updateAllStats();
                        },
                      ),
                    ),
                  )
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
        valueListenable: context.appState.userProfile,
        builder: (context, userProfile, _) {
          final locales = AppLocalizations.supportedLocales;
          final selectedIndices = userProfile != null
              ? {
                  locales.firstWhere(
                      (l) => l.languageCode == userProfile.locale.languageCode)
                }
              : {locales.first}; // Calculate selected here
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
              context.appState.locale = index.first;
            },
          );
        });
  }
}