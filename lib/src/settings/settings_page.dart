import 'dart:html' as html show window;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_flashcards/src/app_state.dart';
import 'package:flutter_flashcards/src/base_layout.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: context.watch<AppState>().appTitle,
      builder: (context, title, _) => BaseLayout(
        title: title,
        currentPage: PageIndex.settings,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              AppVersion(),
              ThemeSelector(),
            ],
          ),
        ),
      ),
    );
  }
}

class AppVersion extends StatelessWidget {
  const AppVersion({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('App version: '),
        ElevatedButton(
            onPressed: () {
              html.window.location.reload();
            },
            child: Text('Reload script')),
      ],
    );
  }
}

class ThemeSelector extends StatelessWidget {
  const ThemeSelector({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: context.watch<AppState>().currentTheme,
      builder: (context, theme, _) => DropdownButton<ThemeMode>(
        // Read the selected themeMode from the controller
        value: theme,
        // Call the updateThemeMode method any time the user selects a theme.
        onChanged: (value) =>
            context.read<AppState>().setTheme(value ?? ThemeMode.system),
        items: const [
          DropdownMenuItem(
            value: ThemeMode.system,
            child: Text('System Theme'),
          ),
          DropdownMenuItem(
            value: ThemeMode.light,
            child: Text('Light Theme'),
          ),
          DropdownMenuItem(
            value: ThemeMode.dark,
            child: Text('Dark Theme'),
          )
        ],
      ),
    );
  }
}
