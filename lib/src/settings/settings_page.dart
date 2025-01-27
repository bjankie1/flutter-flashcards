import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/app_info.dart';
import 'package:flutter_flashcards/src/settings/theme_selector.dart';
import 'package:provider/provider.dart';

import 'package:flutter_flashcards/src/app_state.dart';
import 'package:flutter_flashcards/src/layout/base_layout.dart';

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
        title: Text(title),
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
    final appInfo = Provider.of<AppInfo>(context);

    return Row(
      spacing: 20,
      children: [
        Text('${appInfo.version} build ${appInfo.buildNumber}'),
        if (kIsWeb)
          ElevatedButton(
              onPressed: () {
                // html.window.location.reload();
              },
              child: Text('Reload script')),
      ],
    );
  }
}

class NameInput extends StatelessWidget {
  final nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) => TextField(
        controller: nameController,
        decoration: const InputDecoration(labelText: 'Your name'),
      ),
    );
  }
}
