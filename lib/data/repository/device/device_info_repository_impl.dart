import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:nesters/data/repository/device/device_info_repository.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

class DeviceInfoRepositoryImpl implements DeviceInfoRepository {
  PackageInfo? packageInfo;
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo? androidInfo;
  IosDeviceInfo? iosInfo;
  final FirebaseFirestore _store = FirebaseFirestore.instance;
  @override
  String get appName => packageInfo?.appName ?? 'Nesters';

  @override
  String get buildNumber => packageInfo?.buildNumber ?? '1';

  @override
  String get packageName => packageInfo?.packageName ?? 'com.nesters.app';

  @override
  String get version => packageInfo?.version ?? '1.0.0';

  @override
  Future<void> init() async {
    packageInfo = await PackageInfo.fromPlatform();
    if (Platform.isAndroid) {
      androidInfo = await deviceInfo.androidInfo;
    } else if (Platform.isIOS) {
      iosInfo = await deviceInfo.iosInfo;
    } else {
      throw UnimplementedError();
    }
  }

  @override
  Future<void> saveDeviceInfo(String userId) {
    Map<String, dynamic>? deviceInfo;
    if (Platform.isAndroid) {
      deviceInfo = {
        'deviceType': 'android',
        'deviceInfo': {
          'id': androidInfo?.id ?? 'unknown',
          'name': androidInfo?.model ?? 'unknown',
          'board': androidInfo?.board ?? 'unknown',
          'device': androidInfo?.device ?? 'unknown',
          'version': {
            'baseOS': androidInfo?.version.baseOS ?? 'unknown',
            'codename': androidInfo?.version.codename ?? 'unknown',
            'release': androidInfo?.version.release ?? 'unknown',
            'sdkInt': androidInfo?.version.sdkInt ?? 'unknown',
            'securityPatch': androidInfo?.version.securityPatch ?? 'unknown'
          },
          'brand': androidInfo?.brand ?? 'unknown',
          'hardware': androidInfo?.hardware ?? 'unknown',
          'bootloader': androidInfo?.bootloader ?? 'unknown',
          'display': {
            'model': androidInfo?.display ?? 'unknown',
            'metrics': androidInfo?.displayMetrics.toMap(),
          },
          'host': androidInfo?.host ?? 'unknown',
          'serialNumber': androidInfo?.serialNumber ?? 'unknown',
          'manufacturer': androidInfo?.manufacturer ?? 'unknown',
          'appVersion': version,
          'appBuildNumber': buildNumber
        }
      };
    } else if (Platform.isIOS) {
      deviceInfo = {
        'deviceType': 'ios',
        'deviceInfo': {
          'name': iosInfo?.name ?? 'unknown',
          'system': {
            'name': iosInfo?.systemName ?? 'unknown',
            'version': iosInfo?.systemVersion ?? 'unknown'
          },
          'model': iosInfo?.model ?? 'unknown',
          'localizedModel': iosInfo?.localizedModel ?? 'unknown',
          'identifierForVendor': iosInfo?.identifierForVendor ?? 'unknown',
          'isPhysicalDevice': iosInfo?.isPhysicalDevice ?? 'unknown',
          'utsname': {
            'sysname': iosInfo?.utsname.sysname ?? 'unknown',
            'nodename': iosInfo?.utsname.nodename ?? 'unknown',
            'release': iosInfo?.utsname.release ?? 'unknown',
            'version': iosInfo?.utsname.version ?? 'unknown',
            'machine': iosInfo?.utsname.machine ?? 'unknown'
          },
          'appVersion': version,
          'appBuildNumber': buildNumber
        }
      };
    } else {
      String? deviceType;
      deviceType = Platform.isFuchsia
          ? 'fuchsia'
          : Platform.isLinux
              ? 'linux'
              : Platform.isMacOS
                  ? 'macos'
                  : Platform.isWindows
                      ? 'windows'
                      : 'unknown';
      deviceInfo = {'deviceType': deviceType};
    }

    return _store.collection('devices').doc(userId).set(deviceInfo);
  }

  @override
  Future<void> intializeAppCheck() async {
    await FirebaseAppCheck.instance.activate(
      androidProvider:
          kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
      appleProvider: kDebugMode
          ? AppleProvider.debug
          : AppleProvider.appAttestWithDeviceCheckFallback,
    );
    await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);
  }
}
