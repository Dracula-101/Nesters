import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:nesters/data/repository/network/network_checker_repository.dart';
import 'package:rxdart/rxdart.dart';

class NetworkCheckerRepositoryImpl implements NetworkCheckerRepository {
  final Connectivity _connectivity = Connectivity();

  @override
  bool get isConnected => _networkStatus.values.last.isOnline;

  final ReplaySubject<NetworkStatus> _networkStatus =
      ReplaySubject<NetworkStatus>(sync: true);

  @override
  Stream<NetworkStatus> get networkStatusStream => _networkStatus.stream;

  StreamSubscription? _connectivitySubscription;

  @override
  void init() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        for (ConnectivityResult result in results) {
          NetworkData networkData = NetworkData.UNKNOWN;
          if (result == ConnectivityResult.mobile ||
              result == ConnectivityResult.bluetooth) {
            networkData = NetworkData.MOBILE_DATA;
          } else if (result == ConnectivityResult.wifi) {
            networkData = NetworkData.WIFI;
          } else if (result == ConnectivityResult.none) {
            networkData = NetworkData.OFFFLINE;
          }
          _networkStatus.add(
            NetworkStatus(
              isOnline: result != ConnectivityResult.none,
              networkData: networkData,
            ),
          );
        }
      },
    );
  }

  @override
  Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
    await _networkStatus.close();
    return Future.value();
  }
}
