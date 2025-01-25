import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:nesters/data/repository/config/app_secrets_repository.dart';
import 'package:nesters/domain/models/user/profile/user_profile.dart';
import 'package:nesters/domain/models/user/user.dart';
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
        fullName: user.userMetadata?['fullName'] ?? '',
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
      throw GoogleSignInFailedException();
    }
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    supabase.AuthResponse response = await _supabaseClient.auth
        .signInWithIdToken(
          provider: supabase.OAuthProvider.google,
          idToken: googleAuth.idToken ?? '',
          accessToken: googleAuth.accessToken ?? '',
        )
        .catchError((error) => throw AuthSignInError(error.toString()));

    if (response.user == null) {
      throw AuthSignInError('Couldn\'t sign in with Google. Please try again');
    }
  }

  @override
  Future<void> signOut() {
    return Future.wait([
      _googleSignIn.signOut(),
      _supabaseClient.auth.signOut(),
    ]);
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
          return null;
        }
        return User(
          id: event.session!.user.id,
          email: event.session!.user.email ?? "",
          fullName: event.session!.user.userMetadata?['name'] ?? '',
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
