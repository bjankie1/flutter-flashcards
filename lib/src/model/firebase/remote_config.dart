import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigProvider {
  final remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> init() async {
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1),
    ));
    await remoteConfig.fetchAndActivate();
  }

  String get latest_version => remoteConfig.getString('app_version');
}
