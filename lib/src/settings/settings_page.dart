import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/app_info.dart';
import 'package:flutter_flashcards/src/app_state.dart';
import 'package:flutter_flashcards/src/common/assets.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/snackbar_messaging.dart';
import 'package:flutter_flashcards/src/common/themes.dart';
import 'package:flutter_flashcards/src/layout/base_layout.dart';
import 'package:flutter_flashcards/src/model/users_collaboration.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../model/firebase/firebase_storage.dart';

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
          child: Center(
            child: SizedBox(
              width: 500,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ThemeSelector(),
                  PersonalInfo(),
                  Spacer(),
                  AppVersion(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PersonalInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Personal info', style: context.textTheme.headlineMedium),
        SizedBox(height: 20),
        Text('My name', style: context.textTheme.headlineSmall),
        ValueListenableBuilder(
          valueListenable: context.appState.userProfile,
          builder: (context, userProfile, _) {
            return NameInput(userProfile);
          },
        ),
        SizedBox(height: 20),
        Text('Email', style: context.textTheme.headlineSmall),
        ValueListenableBuilder(
          valueListenable: context.appState.userProfile,
          builder: (context, userProfile, _) {
            return Text(userProfile?.email ?? '');
          },
        ),
        SizedBox(height: 20),
        Text('Avatar', style: context.textTheme.headlineSmall),
        UserPhoto(),
      ],
    );
  }
}

class UserPhoto extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      width: 500,
      child: Stack(
        children: [
          Positioned(
            right: 30,
            top: 0,
            child: IconButton(
              onPressed: () {
                _uploadImageWeb(context);
              },
              icon: Icon(Icons.upload),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: context.appState.userAvatarUrl,
            builder: (context, url, _) => CircleAvatar(
              minRadius: 200,
              backgroundImage: url != null ? NetworkImage(url) : randomFace,
            ),
          ),
        ],
      ),
    );
  }

  void _uploadImageWeb(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.count > 0) {
      XFile image = result.files.first.xFile;
      final service = context.read<StorageService>();
      await service.uploadUserAvatar(
        image,
        onSuccess: () async {
          context.showInfoSnackbar('Image recorded');
        },
        onError: () => context.showErrorSnackbar('Error uploading image'),
      );
      context.appState.updateUserProfile(newAvatar: true);
    }
  }
}

class AppVersion extends StatelessWidget {
  const AppVersion({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppInfo>(
      builder: (context, appInfo, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('App Version', style: context.textTheme.headlineSmall),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('${appInfo.version} build ${appInfo.buildNumber}'),
                const SizedBox(width: 16),
                if (kIsWeb) ...[
                  ElevatedButton.icon(
                    onPressed: appInfo.isCheckingForUpdates
                        ? null
                        : appInfo.checkForUpdates,
                    icon: appInfo.isCheckingForUpdates
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                    label: Text(
                      appInfo.isCheckingForUpdates
                          ? context.l10n.checkingForUpdates
                          : 'Check for Updates',
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (appInfo.isUpdateAvailable)
                    ElevatedButton.icon(
                      onPressed: appInfo.isUpdating
                          ? null
                          : appInfo.performUpdate,
                      icon: appInfo.isUpdating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.download),
                      label: Text(
                        appInfo.isUpdating
                            ? context.l10n.updatingApp
                            : context.l10n.updateNow,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                      ),
                    ),
                ],
              ],
            ),
            if (appInfo.isUpdateAvailable) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.system_update,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        appInfo.updateMessage.isNotEmpty
                            ? appInfo.updateMessage
                            : context.l10n.updateAvailableMessage,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (kIsWeb) ...[
              const SizedBox(height: 16),
              Text('Update Settings', style: context.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Automatic update checks every 10 minutes',
                    style: context.textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

class NameInput extends StatefulWidget {
  final UserProfile? userProfile;

  NameInput(this.userProfile);

  @override
  State<NameInput> createState() => _NameInputState();
}

class _NameInputState extends State<NameInput> {
  final _nameController = TextEditingController();
  bool _isChanged = false;

  @override
  void initState() {
    _nameController.text = widget.userProfile?.name ?? '';
    _nameController.addListener(_onTextChanged);
    super.initState();
  }

  void _onTextChanged() {
    setState(() {
      _isChanged =
          _nameController.text !=
          (context.appState.userProfile.value?.name ?? '');
    });
  }

  @override
  void dispose() {
    _nameController.removeListener(
      _onTextChanged,
    ); // Important: Remove listener
    _nameController.dispose(); // Important: Dispose of controller
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _updateNameController();
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant NameInput oldWidget) {
    _updateNameController();
    super.didUpdateWidget(oldWidget);
  }

  void _updateNameController() {
    final newName = context.appState.userProfile.value?.name ?? '';
    if (_nameController.text != newName) {
      _nameController.text = newName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) => Row(
        children: [
          Expanded(
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Your name'),
            ),
          ),
          if (_isChanged)
            IconButton(
              onPressed: () {
                context.appState.updateUserProfile(name: _nameController.text);
                _onTextChanged();
                context.showInfoSnackbar(context.l10n.profileNameChanged);
              },
              icon: Icon(Icons.check),
            ),
        ],
      ),
    );
  }
}
