import 'package:flutter/material.dart';
import 'package:flutter_flashcards/l10n/app_localizations.dart';
import 'package:flutter_flashcards/src/app_state.dart';
import 'package:flutter_flashcards/src/common/avatar.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/version_update_banner.dart';
import 'package:flutter_flashcards/src/layout/UserMenu.dart';
import 'package:flutter_flashcards/src/layout/layout_constraints.dart';
import 'package:flutter_flashcards/src/layout/navigation.dart';
import 'package:flutter_flashcards/src/model/repository.dart';
import 'package:flutter_flashcards/src/model/users_collaboration.dart';
import 'package:flutter_flashcards/src/layout/action_buttons.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

enum PageIndex { cards, statistics, collaboration, learn, settings }

extension PageIndexNavigation on PageIndex {
  void navigate(BuildContext context) {
    switch (this) {
      case PageIndex.cards:
        context.goNamed('cards');
      case PageIndex.statistics:
        context.goNamed('statistics');
      case PageIndex.collaboration:
        context.goNamed('collaboration');
      case PageIndex.learn:
        context.goNamed('learn');
      case PageIndex.settings:
        context.goNamed('settings');
    }
  }
}

/// Base layout for the app.
///
/// This layout is used to wrap the app content and provide a consistent
/// layout for the app.
///
/// It includes a version update banner at the top, a main app content area,
/// and a left navigation menu on desktop.
class BaseLayout extends StatelessWidget {
  final Widget child;

  final Widget title;

  final FloatingActionButton? floatingActionButton;

  final PageIndex? currentPage;

  const BaseLayout({
    /// The main app content.
    required this.child,

    /// The title of the app.
    required this.title,

    /// The floating action button to be displayed on the app.
    this.floatingActionButton,

    /// The current page index.
    this.currentPage,

    /// The key of the widget.
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final layoutData = LayoutConstraintsData(
          constraints: constraints,
          isMobile: isMobile,
        );

        return LayoutConstraints(
          data: layoutData,
          child: Column(
            children: [
              // Version update banner at the top
              const VersionUpdateBanner(),
              // Main app content
              Expanded(
                child: Scaffold(
                  resizeToAvoidBottomInset: true,
                  appBar: AppBar(
                    title: Consumer<AppState>(
                      builder: (context, appState, child) {
                        return Row(
                          children: [
                            Expanded(child: title),
                            if (!isMobile) ...[
                              const ActionButtons(),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: LocaleSelection(),
                              ),
                            ],
                            if (!isMobile)
                              ValueListenableBuilder<UserProfile?>(
                                valueListenable: context.appState.userProfile,
                                builder: (context, userProfile, _) {
                                  final currentTheme =
                                      userProfile?.theme ?? ThemeMode.system;
                                  return SegmentedButton<ThemeMode>(
                                    multiSelectionEnabled: false,
                                    showSelectedIcon: false,
                                    selected: {currentTheme},
                                    segments: [
                                      ButtonSegment(
                                        value: ThemeMode.light,
                                        icon: Icon(Icons.light_mode),
                                        tooltip: context.l10n.switchToLightMode,
                                      ),
                                      ButtonSegment(
                                        value: ThemeMode.dark,
                                        icon: Icon(Icons.dark_mode),
                                        tooltip: context.l10n.switchToDarkMode,
                                      ),
                                    ],
                                    onSelectionChanged:
                                        (Set<ThemeMode> selected) {
                                          Provider.of<AppState>(
                                            context,
                                            listen: false,
                                          ).theme = selected.first;
                                        },
                                  );
                                },
                              ),
                            if (isMobile) ...[
                              ValueListenableBuilder<UserProfile?>(
                                valueListenable: context.appState.userProfile,
                                builder: (context, userProfile, _) =>
                                    IconButton(
                                      icon: Icon(
                                        userProfile?.theme == ThemeMode.light
                                            ? Icons.dark_mode
                                            : Icons.light_mode,
                                      ),
                                      onPressed: () {
                                        Provider.of<AppState>(
                                          context,
                                          listen: false,
                                        ).toggleTheme();
                                      },
                                    ),
                              ),
                              const ActionButtons(),
                            ],
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: UserMenu(child: Avatar(size: 30)),
                            ),
                            Visibility(
                              visible: false,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.refresh),
                                  onPressed: () async {
                                    await context
                                        .read<CardsRepository>()
                                        .updateAllStats();
                                  },
                                ),
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
                      if (!isMobile) LeftNavigation(currentPage: currentPage),
                      Expanded(child: child),
                    ],
                  ),
                  bottomNavigationBar: !isMobile
                      ? null
                      : BottomNavigation(currentPage: currentPage),
                  floatingActionButton: floatingActionButton,
                ),
              ),
            ],
          ),
        );
      },
    );
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
                  (l) => l.languageCode == userProfile.locale.languageCode,
                ),
              }
            : {locales.first};
        return SegmentedButton(
          multiSelectionEnabled: false,
          showSelectedIcon: false,
          selected: selectedIndices,
          segments: locales.map((locale) {
            String tooltip;
            String flag;
            switch (locale.languageCode) {
              case 'en':
                tooltip = context.l10n.switchToEnglish;
                flag = '🇬🇧';
                break;
              case 'pl':
                tooltip = context.l10n.switchToPolish;
                flag = '🇵🇱';
                break;
              default:
                tooltip = '';
                flag = '';
            }
            return ButtonSegment(
              value: locale,
              label: Text(flag),
              tooltip: tooltip,
            );
          }).toList(),
          onSelectionChanged: (index) {
            Logger().i('Locale selected: ${index.first}');
            context.appState.locale = index.first;
          },
        );
      },
    );
  }
}
