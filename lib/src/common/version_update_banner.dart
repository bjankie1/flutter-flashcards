import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'build_context_extensions.dart';
import '../app_info.dart';

/// A banner widget that displays when a new version of the app is available
class VersionUpdateBanner extends StatelessWidget {
  const VersionUpdateBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppInfo>(
      builder: (context, appInfo, child) {
        if (!appInfo.isUpdateAvailable) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          color: Theme.of(context).colorScheme.primaryContainer,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.system_update,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          context.l10n.updateAvailable,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                        ),
                      ),
                      IconButton(
                        onPressed: appInfo.dismissUpdate,
                        icon: Icon(
                          Icons.close,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                        tooltip: context.l10n.updateLater,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    appInfo.updateMessage.isNotEmpty
                        ? appInfo.updateMessage
                        : context.l10n.updateAvailableMessage,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: appInfo.isUpdating
                              ? null
                              : appInfo.performUpdate,
                          icon: appInfo.isUpdating
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.download),
                          label: Text(
                            appInfo.isUpdating
                                ? context.l10n.updatingApp
                                : context.l10n.updateNow,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: appInfo.dismissUpdate,
                        child: Text(context.l10n.updateLater),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A smaller notification widget that can be used in the app bar or other areas
class VersionUpdateNotification extends StatelessWidget {
  const VersionUpdateNotification({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppInfo>(
      builder: (context, appInfo, child) {
        if (!appInfo.isUpdateAvailable) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.error,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.system_update,
                size: 16,
                color: Theme.of(context).colorScheme.onError,
              ),
              const SizedBox(width: 4),
              Text(
                context.l10n.updateAvailable,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onError,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A widget that shows update checking status
class UpdateCheckingIndicator extends StatelessWidget {
  const UpdateCheckingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppInfo>(
      builder: (context, appInfo, child) {
        if (!appInfo.isCheckingForUpdates) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                context.l10n.checkingForUpdates,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
