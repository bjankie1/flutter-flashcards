import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/app_state.dart';
import 'package:flutter_flashcards/src/base_layout.dart';
import 'package:provider/provider.dart';

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
          // Glue the SettingsController to the theme selection DropdownButton.
          //
          // When a user selects a theme from the dropdown list, the
          // SettingsController is updated, which rebuilds the MaterialApp.
          child: ValueListenableBuilder(
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
          ),
        ),
      ),
    );
  }
}
