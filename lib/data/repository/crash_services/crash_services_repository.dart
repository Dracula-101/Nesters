import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class CrashServiceRepository {
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;
  void recordError(Exception error,
      {StackTrace? stackTrace, String? message, String? key}) {
    if (!_crashlytics.isCrashlyticsCollectionEnabled) {
      return;
    }
    _crashlytics.recordError(error, stackTrace,
        reason: message, information: key != null ? [key] : []);
  }
}
