import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppInfo {
  final _log = Logger();

  String? _version = '1.0.0';

  String? _buildNumber = '30';

  String? _packageName = '';

  String? _appName = '';

  String? get version => _version;

  String? get buildNumber => _buildNumber;

  String? get packageName => _packageName;

  String? get appName => _appName;

  Future<void> init() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      _appName = packageInfo.appName;
      _packageName = packageInfo.packageName;
      _version = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;
    } on Exception catch (e) {
      _log.e('Error loading app information', error: e);
    }
  }
}
