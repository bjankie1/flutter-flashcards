import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';

class ThemeSelector extends StatelessWidget {
  const ThemeSelector({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: context.appState.userProfile,
      builder: (context, userProfile, _) => DropdownButton<ThemeMode>(
        // Read the selected themeMode from the controller
        value: userProfile?.theme ?? ThemeMode.system,
        // Call the updateThemeMode method any time the user selects a theme.
        onChanged: (value) =>
            context.appState.theme = (value ?? ThemeMode.system),
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