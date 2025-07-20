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
        child: CustomScrollView(
          slivers: [
            // Avatar sliver that shrinks when scrolled
            UserPhoto(),

            // Main content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: SizedBox(
                    width: 500,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PersonalInfo(),
                        SizedBox(height: 40),
                        Divider(),
                        SizedBox(height: 40),
                        AppVersion(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
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
        SizedBox(height: 20),
        ValueListenableBuilder(
          valueListenable: context.appState.userProfile,
          builder: (context, userProfile, _) {
            return NameInput(userProfile);
          },
        ),
        SizedBox(height: 20),
        ValueListenableBuilder(
          valueListenable: context.appState.userProfile,
          builder: (context, userProfile, _) {
            return Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.email,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      userProfile?.email ?? '',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class UserPhoto extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: false,
      delegate: _AvatarSliverDelegate(
        minHeight: 32,
        maxHeight: 350,
        child: ValueListenableBuilder(
          valueListenable: context.appState.userAvatarUrl,
          builder: (context, url, _) => CircleAvatar(
            backgroundImage: url != null ? NetworkImage(url) : randomFace,
            child: Stack(
              children: [
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {
                        _uploadImageWeb(context);
                      },
                      icon: Icon(Icons.upload, size: 16),
                      padding: EdgeInsets.all(4),
                      constraints: BoxConstraints(minWidth: 24, minHeight: 24),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
          context.showInfoSnackbar(context.l10n.imageRecorded);
        },
        onError: () =>
            context.showErrorSnackbar(context.l10n.errorUploadingImage),
      );
      context.appState.updateUserProfile(newAvatar: true);
    }
  }
}

class _AvatarSliverDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _AvatarSliverDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final progress = shrinkOffset / (maxHeight - minHeight);
    final avatarSize = maxHeight - (progress * (maxHeight - minHeight));

    return SizedBox(
      height: avatarSize,
      width: double.infinity,
      child: Center(
        child: SizedBox(width: avatarSize, height: avatarSize, child: child),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return oldDelegate != this;
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
            Text(
              context.l10n.appVersion,
              style: context.textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            // Current version information
            _VersionInfoCard(
              title: context.l10n.currentVersion,
              version: '${appInfo.version}',
              buildNumber: '${appInfo.buildNumber}',
              icon: Icons.info_outline,
              color: Theme.of(context).colorScheme.primaryContainer,
            ),

            const SizedBox(height: 12),

            // Latest available version
            if (kIsWeb) ...[
              _VersionInfoCard(
                title: context.l10n.latestAvailableVersion,
                version: appInfo.isUpdateAvailable
                    ? _getLatestVersion(appInfo)
                    : '${appInfo.version}',
                buildNumber: appInfo.isUpdateAvailable
                    ? _getLatestBuildNumber(appInfo)
                    : '${appInfo.buildNumber}',
                icon: Icons.system_update,
                color: appInfo.isUpdateAvailable
                    ? Theme.of(context).colorScheme.secondaryContainer
                    : Theme.of(context).colorScheme.surfaceVariant,
              ),

              const SizedBox(height: 12),

              // Minimum required version
              _VersionInfoCard(
                title: context.l10n.minimumRequiredVersion,
                version: _getMinimumVersion(appInfo),
                buildNumber: _getMinimumBuildNumber(appInfo),
                icon: Icons.warning_outlined,
                color: Theme.of(context).colorScheme.errorContainer,
              ),

              const SizedBox(height: 16),

              // Update actions
              Row(
                children: [
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
                          : context.l10n.checkForUpdates,
                    ),
                  ),
                  const SizedBox(width: 12),
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
              ),

              if (appInfo.isUpdateAvailable) ...[
                const SizedBox(height: 12),
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
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
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

              const SizedBox(height: 16),
              Text(
                context.l10n.updateSettings,
                style: context.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    context.l10n.automaticUpdateChecks,
                    style: context.textTheme.bodyMedium,
                  ),
                ],
              ),
            ] else ...[
              // For non-web platforms, show basic version info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  context.l10n.versionCheckingWebOnly,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  String _getLatestVersion(AppInfo appInfo) {
    return appInfo.getLatestVersion();
  }

  String _getLatestBuildNumber(AppInfo appInfo) {
    return appInfo.getLatestBuildNumber();
  }

  String _getMinimumVersion(AppInfo appInfo) {
    return appInfo.getMinimumVersion();
  }

  String _getMinimumBuildNumber(AppInfo appInfo) {
    return appInfo.getMinimumBuildNumber();
  }
}

class _VersionInfoCard extends StatelessWidget {
  final String title;
  final String version;
  final String buildNumber;
  final IconData icon;
  final Color color;

  const _VersionInfoCard({
    required this.title,
    required this.version,
    required this.buildNumber,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  '$version build $buildNumber',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
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
    _nameController.removeListener(_onTextChanged);
    _nameController.dispose();
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
              decoration: InputDecoration(
                labelText: context.l10n.yourName,
                prefixIcon: Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.primary,
                ),
                suffixIcon: Icon(
                  Icons.edit,
                  color: Theme.of(context).colorScheme.primary,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
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
