import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nesters/data/repository/config/app_secrets_repository.dart';
import 'package:nesters/domain/models/user/profile/user_profile.dart';
import 'package:nesters/domain/models/user/user.dart';
import 'package:nesters/utils/extensions/exception.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'auth_repository.dart';
import 'error/auth_error.dart';

class SupabaseAuthRepository extends AuthRepository {
  SupabaseAuthRepository({
    required AppSecretsRepository appSecretsRepository,
  }) : _appSecrets = appSecretsRepository;

  final AppSecretsRepository _appSecrets;

  final supabase.SupabaseClient _supabaseClient =
      supabase.Supabase.instance.client;

  late final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: _appSecrets.getSecret(AppSecretsKeys.GOOGLE_IOS_CLIENT_ID),
    serverClientId: _appSecrets.getSecret(AppSecretsKeys.GOOGLE_WEB_CLIENT_ID),
  );

  UserProfile? _userProfile;

  @override
  User? get currentUser {
    final user = _supabaseClient.auth.currentUser;
    if (user != null) {
      String accessToken =
          _supabaseClient.auth.currentSession?.accessToken ?? '';
      return User(
        id: user.id,
        email: user.email ?? "",
        fullName: _userProfile?.fullName ?? user.userMetadata?['name'] ?? '',
        photoUrl: _userProfile?.profileImage ??
            user.userMetadata?['avatar_url'] ??
            '',
        accessToken: accessToken,
      );
    }
    return null;
  }

  @override
  Future<bool> isSignedIn() {
    return Future.value(_supabaseClient.auth.currentUser != null);
  }

  @override
  Future<void> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      return;
    }
    try {
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      if (googleAuth.idToken == null || googleAuth.idToken?.isEmpty == true) {
        throw GoogleSignInFailedException(
          message: 'User id token not found',
          authErrorCode: AuthErrorCode.GOOGLE_USER_ID_TOKEN_FAILED,
        );
      }
      if (googleAuth.accessToken == null ||
          googleAuth.accessToken?.isEmpty == true) {
        throw GoogleSignInFailedException(
          message: 'User access token not found',
          authErrorCode: AuthErrorCode.GOOGLE_USER_TOKEN_FAILED,
        );
      }
      supabase.AuthResponse response =
          await _supabaseClient.auth.signInWithIdToken(
        provider: supabase.OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken ?? '',
      );
      if (response.user == null) {
        throw GoogleSignInFailedException(
          message: 'No user found',
          authErrorCode: AuthErrorCode.GOOGLE_NO_USER_FOUND,
        );
      }
    } on PlatformException catch (_) {
      throw GoogleSignInFailedException(
        message: "Google SHA-1 and SHA-256 keys are not configured properly",
        authErrorCode: AuthErrorCode.GOOGLE_SIGN_IN_FAILED,
      );
    } on Exception catch (error) {
      throw GoogleSignInFailedException(
        message: error.errorMessage,
        authErrorCode: AuthErrorCode.GOOGLE_SIGN_IN_FAILED,
      );
    }
  }

  @override
  Future<void> signInWithApple() async {
    final rawNonce = _supabaseClient.auth.generateRawNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );

    final idToken = credential.identityToken;
    if (idToken == null) return;
    try {
      await _supabaseClient.auth.signInWithIdToken(
        provider: supabase.OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );
    } on Exception catch (error) {
      throw AppleSignInFailedException(
        message: error.errorMessage,
        authErrorCode: AuthErrorCode.APPLE_SIGN_IN_FAILED,
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        _googleSignIn.signOut(),
        _supabaseClient.auth.signOut(),
      ]);
    } on Exception catch (error) {
      throw SignInOutFailedException(
        message: error.errorMessage,
      );
    }
  }

  @override
  Stream<User?> get user {
    return _supabaseClient.auth.onAuthStateChange.asyncMap((event) async {
      if (event.session != null) {
        try {
          _userProfile = await _supabaseClient
              .from('user_details')
              .select()
              .eq('id', event.session!.user.id)
              .single()
              .then((value) => UserProfile.fromJson(value));
        } catch (error) {
          // User is either not found or creating a new user
        }
        return User(
          id: event.session!.user.id,
          email: event.session!.user.email ?? "",
          fullName: _userProfile?.fullName ??
              event.session!.user.userMetadata?['name'] ??
              '',
          photoUrl: _userProfile?.profileImage ??
              event.session!.user.userMetadata?['avatar_url'] ??
              '',
          accessToken: event.session!.accessToken,
        );
      }
      return null;
    });
  }

  @override
  Future<String?> getAccessToken() async {
    return Future.value(_supabaseClient.auth.currentSession?.accessToken);
  }
}
