import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/app_state.dart';
import 'package:flutter_flashcards/src/common/custom_theme.dart';
import 'package:provider/provider.dart';
import 'package:flutter_flashcards/l10n/app_localizations.dart';

import 'app_router.dart';

/// The Widget that configures your application.
class FlashcardsApp extends StatelessWidget {
  const FlashcardsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
        valueListenable: context.watch<AppState>().currentTheme,
        builder: (context, currentTheme, _) => ValueListenableBuilder<Locale>(
              // Add this ValueListenableBuilder
              valueListenable: context.watch<AppState>().currentLocale,
              builder: (context, currentLocale, _) => MaterialApp.router(
                title: 'Flashcards ${currentLocale.languageCode}',
                theme: getLightThemeFlexColor(),
                darkTheme: getDarkThemeFlexColor(),
                themeMode: currentTheme,
                routerConfig: router,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                locale: currentLocale,
              ),
            ));
  }
}
