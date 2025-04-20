import 'package:flutter/material.dart';
import 'package:flutter_flashcards/l10n/app_localizations.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/themes.dart';
import 'package:flutter_flashcards/src/model/users_collaboration.dart';

import 'app_router.dart';

/// The Widget that configures your application.
class FlashcardsApp extends StatelessWidget {
  const FlashcardsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserProfile?>(
        valueListenable: context.appState.userProfile,
        builder: (context, userProfile, _) => MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: 'Flashcards',
              theme: getLightThemeFlexColor(),
              darkTheme: getDarkThemeFlexColor(),
              themeMode: userProfile?.theme ?? ThemeMode.system,
              routerConfig: router,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: userProfile?.locale,
            ));
  }
}