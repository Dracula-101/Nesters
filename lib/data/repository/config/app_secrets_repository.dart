// ignore_for_file: constant_identifier_names

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'error/app_secrets_error.dart';

class AppSecretsRepository {
  Future<void> init() async {
    await dotenv.load(fileName: ".env");
  }

  String getSecret(AppSecretsKeys secretKey) {
    if (dotenv.isInitialized) {
      return dotenv.get(secretKey.toString().split('.').last);
    }
    throw AppSecretsError.initalizeError();
  }
}

enum AppSecretsKeys {
  SUPABASE_URL,
  SUPABASE_ANON_KEY,
  SUPABASE_SERVICE_ROLE_KEY,
  SUPABASE_JWT_TOKEN,
  GOOGLE_WEB_CLIENT_ID,
  GOOGLE_IOS_CLIENT_ID,
  GOOGLE_ANDROID_CLIENT_ID_DEBUG,
  GOOGLE_ANDROID_CLIENT_ID_RELEASE,
  USER_STATUS_SOCKET_URL,
  CLOUD_FUNCTION_URL
}
