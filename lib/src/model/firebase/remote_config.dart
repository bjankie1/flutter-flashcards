import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class RemoteConfigProvider {
  final remoteConfig = FirebaseRemoteConfig.instance;
  final _log = Logger();

  Future<void> init() async {
    try {
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );
      await remoteConfig.fetchAndActivate();
      _log.i('Remote config initialized successfully');
    } catch (e) {
      _log.e('Failed to initialize remote config', error: e);
    }
  }

  String get latest_version => remoteConfig.getString('app_version');

  String get latest_build_number => remoteConfig.getString('app_build_number');

  String get update_message => remoteConfig.getString('update_message');

  String get update_required => remoteConfig.getString('update_required');

  bool get isUpdateRequired => update_required.toLowerCase() == 'true';

  /// Check if there's a newer version available
  /// Returns true if current version is older than remote version
  bool isNewVersionAvailable(String currentVersion, String currentBuildNumber) {
    try {
      final remoteVersion = latest_version;
      final remoteBuildNumber = latest_build_number;

      if (remoteVersion.isEmpty || remoteBuildNumber.isEmpty) {
        _log.w('Remote version or build number is empty');
        return false;
      }

      // Compare versions (e.g., "1.0.2" vs "1.0.3")
      final currentVersionParts = currentVersion.split('.');
      final remoteVersionParts = remoteVersion.split('.');

      if (currentVersionParts.length != 3 || remoteVersionParts.length != 3) {
        _log.w(
          'Invalid version format: current=$currentVersion, remote=$remoteVersion',
        );
        return false;
      }

      // Compare major, minor, patch versions
      for (int i = 0; i < 3; i++) {
        final current = int.tryParse(currentVersionParts[i]) ?? 0;
        final remote = int.tryParse(remoteVersionParts[i]) ?? 0;

        if (remote > current) {
          _log.i('New version available: $currentVersion -> $remoteVersion');
          return true;
        } else if (remote < current) {
          return false;
        }
      }

      // If versions are equal, compare build numbers
      final currentBuild = int.tryParse(currentBuildNumber) ?? 0;
      final remoteBuild = int.tryParse(remoteBuildNumber) ?? 0;

      if (remoteBuild > currentBuild) {
        _log.i(
          'New build available: $currentBuildNumber -> $remoteBuildNumber',
        );
        return true;
      }

      return false;
    } catch (e) {
      _log.e('Error comparing versions', error: e);
      return false;
    }
  }

  /// Force fetch latest remote config
  Future<bool> forceFetch() async {
    try {
      final result = await remoteConfig.fetchAndActivate();
      _log.i('Remote config force fetch result: $result');
      return result;
    } catch (e) {
      _log.e('Failed to force fetch remote config', error: e);
      return false;
    }
  }

  /// Get custom update message or fallback to default
  String getUpdateMessage() {
    final message = update_message;
    if (message.isNotEmpty) {
      return message;
    }
    return kDebugMode
        ? 'Debug: Update available'
        : 'A new version is available';
  }
}
