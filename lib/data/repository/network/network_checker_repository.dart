// ignore_for_file: constant_identifier_names

abstract class NetworkCheckerRepository {
  void init();
  Future<void> dispose();
  bool get isConnected;
  Stream<NetworkStatus> get networkStatusStream;
}

class NetworkStatus {
  bool isOnline;
  NetworkData networkData;
  DateTime lastUpdated = DateTime.now();

  NetworkStatus({
    required this.isOnline,
    required this.networkData,
  });
}

enum NetworkData {
  OFFFLINE,
  MOBILE_DATA,
  WIFI,
  UNKNOWN,
}
