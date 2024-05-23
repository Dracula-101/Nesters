abstract class DeviceInfoRepository {
  String get appName;
  String get packageName;
  String get version;
  String get buildNumber;

  Future<void> init();
  Future<void> saveDeviceInfo(String userId);
  Future<void> intializeAppCheck();
}
