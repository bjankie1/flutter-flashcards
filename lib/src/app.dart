import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/app_state.dart';
import 'package:provider/provider.dart';
import 'package:flutter_flashcards/l10n/app_localizations.dart';

import 'app_router.dart';

extension ContextLocalization on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
  MaterialLocalizations get ml10n => MaterialLocalizations.of(this);
}

/// The Widget that configures your application.
class FlashcardsApp extends StatelessWidget {
  const FlashcardsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp.router(
        title: 'Flashcards',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }
}
