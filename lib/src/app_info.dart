import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:js' as js;
import 'model/firebase/remote_config.dart';

class AppInfo extends ChangeNotifier {
  final _log = Logger();
  final RemoteConfigProvider _remoteConfig = RemoteConfigProvider();

  String? _version = '1.0.0';
  String? _buildNumber = '30';
  String? _packageName = '';
  String? _appName = '';

  // Version checking state
  bool _isUpdateAvailable = false;
  bool _isCheckingForUpdates = false;
  bool _isUpdating = false;
  String _updateMessage = '';
  Timer? _updateCheckTimer;
  static const Duration _checkInterval = Duration(minutes: 10);

  String? get version => _version;
  String? get buildNumber => _buildNumber;
  String? get packageName => _packageName;
  String? get appName => _appName;

  // Version checking getters
  bool get isUpdateAvailable => _isUpdateAvailable;
  bool get isCheckingForUpdates => _isCheckingForUpdates;
  bool get isUpdating => _isUpdating;
  String get updateMessage => _updateMessage;

  Future<void> init() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      _appName = packageInfo.appName;
      _packageName = packageInfo.packageName;
      _version = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;

      _log.i('App info initialized: $_appName v$_version+$_buildNumber');

      // Initialize remote config
      await _remoteConfig.init();

      // Start periodic version checking (only for web)
      if (kIsWeb) {
        _startPeriodicUpdateCheck();
      }
    } on Exception catch (e) {
      _log.e('Error loading app information', error: e);
    }
  }

  /// Start periodic update checking
  void _startPeriodicUpdateCheck() {
    _updateCheckTimer?.cancel();
    _updateCheckTimer = Timer.periodic(_checkInterval, (timer) {
      checkForUpdates();
    });
    _log.i(
      'Started periodic update checking every ${_checkInterval.inMinutes} minutes',
    );
  }

  /// Stop periodic update checking
  void stopPeriodicUpdateCheck() {
    _updateCheckTimer?.cancel();
    _updateCheckTimer = null;
    _log.i('Stopped periodic update checking');
  }

  /// Check for updates manually
  Future<bool> checkForUpdates() async {
    if (_isCheckingForUpdates) {
      _log.d('Update check already in progress');
      return false;
    }

    _isCheckingForUpdates = true;
    notifyListeners();

    try {
      _log.d('Checking for updates...');

      // Force fetch latest remote config
      final fetchSuccess = await _remoteConfig.forceFetch();
      if (!fetchSuccess) {
        _log.w('Failed to fetch remote config');
        return false;
      }

      // Check if new version is available
      final hasUpdate = _remoteConfig.isNewVersionAvailable(
        _version ?? '1.0.0',
        _buildNumber ?? '1',
      );

      _isUpdateAvailable = hasUpdate;
      _updateMessage = hasUpdate ? _remoteConfig.getUpdateMessage() : '';

      if (hasUpdate) {
        _log.i(
          'Update available: $_version+$_buildNumber -> ${_remoteConfig.latest_version}+${_remoteConfig.latest_build_number}',
        );
      } else {
        _log.d('No update available');
      }

      return hasUpdate;
    } catch (e) {
      _log.e('Error checking for updates', error: e);
      return false;
    } finally {
      _isCheckingForUpdates = false;
      notifyListeners();
    }
  }

  /// Perform the update (reload the app)
  Future<void> performUpdate() async {
    if (!_isUpdateAvailable || _isUpdating) {
      return;
    }

    _isUpdating = true;
    notifyListeners();

    try {
      _log.i('Performing app update...');

      // For web, reload the page
      if (kIsWeb) {
        // Add a small delay to show the updating state
        await Future.delayed(const Duration(milliseconds: 500));

        // Reload the page to get the new version
        // This will be handled by the service worker or browser cache
        _reloadApp();
      }
    } catch (e) {
      _log.e('Error performing update', error: e);
      _isUpdating = false;
      notifyListeners();
    }
  }

  /// Reload the web app
  void _reloadApp() {
    if (kIsWeb) {
      // Use JavaScript to reload the page
      try {
        js.context.callMethod('reloadApp');
        _log.i('Reloading web app via JavaScript...');
      } catch (e) {
        _log.e('Failed to reload app via JavaScript', error: e);
        // Fallback to direct reload
        js.context.callMethod('eval', ['window.location.reload()']);
      }
    }
  }

  /// Dismiss the update notification
  void dismissUpdate() {
    _isUpdateAvailable = false;
    _updateMessage = '';
    notifyListeners();
    _log.d('Update notification dismissed');
  }

  @override
  void dispose() {
    stopPeriodicUpdateCheck();
    super.dispose();
  }
}
