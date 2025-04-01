import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nesters/data/repository/config/app_secrets_repository.dart';
import 'package:nesters/domain/models/user/profile/user_info.dart';
import 'package:nesters/domain/models/user/user.dart';
import 'package:nesters/utils/extensions/exception.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'auth_repository.dart';
import 'error/auth_error.dart';

class SupabaseAuthRepository extends AuthRepository {
  SupabaseAuthRepository({
    required AppSecretsRepository appSecretsRepository,
  }) : _appSecrets = appSecretsRepository {
    _init();
  }

  final AppSecretsRepository _appSecrets;

  final supabase.SupabaseClient _supabaseClient =
      supabase.Supabase.instance.client;
  final firebase.FirebaseAuth _firebaseAuth = firebase.FirebaseAuth.instance;

  late final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: _appSecrets.getSecret(AppSecretsKeys.GOOGLE_IOS_CLIENT_ID),
    serverClientId: _appSecrets.getSecret(AppSecretsKeys.GOOGLE_WEB_CLIENT_ID),
  );

  UserInfo? _userInfo;
  User? _currentUser;
  final BehaviorSubject<User?> _userController = BehaviorSubject<User?>();
  final BehaviorSubject<UserInfo?> _userInfoController =
      BehaviorSubject<UserInfo?>.seeded(null);

  _init() {
    _supabaseClient.auth.onAuthStateChange.listen((event) async {
      _setupFirebaseAuth(event.event);
      if (event.session?.user != null) {
        try {
          //  constraint user_details_college_fkey foreign KEY (college) references universities (id) on update CASCADE on delete set null
          _userInfo = await _getUserInfo(event.session!.user.id);
          _currentUser = currentUser;
          _userInfoController.add(_userInfo);
          _userController.add(_currentUser);
        } catch (error) {
          _currentUser = currentUser;
          _userController.add(_currentUser);
          _userInfo = null;
        }
      } else {
        _currentUser = null;
        _userInfoController.add(null);
        _userController.add(_currentUser);
        _userInfo = null;
      }
    });
  }

  Future<UserInfo?> _getUserInfo(String userId) async {
    try {
      return await _supabaseClient
          .from('user_details')
          .select("'*, const.universities!user_details_college_fkey!inner(*)'")
          .eq('id', userId)
          .single()
          .then((value) => UserInfo.fromJson(value));
    } catch (error) {
      return null;
    }
  }

  @override
  User? get currentUser {
    final user = _supabaseClient.auth.currentUser;
    if (user != null) {
      String accessToken =
          _supabaseClient.auth.currentSession?.accessToken ?? '';
      return User(
        id: user.id,
        email: user.email ?? "",
        fullName: _userInfo?.fullName ??
            user.userMetadata?['name'] ??
            user.email
                ?.split('@')[0]
                .replaceAll(RegExp(r'[^a-zA-Z0-9]'), ' ') ??
            'Unknown',
        photoUrl:
            _userInfo?.profileImage ?? user.userMetadata?['avatar_url'] ?? '',
        accessToken: accessToken,
      );
    }
    return null;
  }

  @override
  Stream<User?> get user {
    return _userController.stream.asBroadcastStream();
  }

  @override
  UserInfo? get currentUserInfo => _userInfo;

  @override
  Stream<UserInfo?> get userInfo {
    return _userInfoController.stream.asBroadcastStream();
  }

  @override
  Future<bool> isSignedIn() {
    return Future.value(_supabaseClient.auth.currentUser != null);
  }

  void _setupFirebaseAuth(supabase.AuthChangeEvent event) async {
    if (event == supabase.AuthChangeEvent.signedIn) {
      await _firebaseAuth.signInAnonymously();
    } else if (event == supabase.AuthChangeEvent.signedOut) {
      await _firebaseAuth.signOut();
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      return Future.value();
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
        message:
            "Google SHA-1 keys are not configured properly in Firebase Console",
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
  Future<String?> getAccessToken() async {
    return Future.value(_supabaseClient.auth.currentSession?.accessToken);
  }

  @override
  Future<void> updateUserInfo(UserInfo? user) async {
    try {
      UserInfo? userInfo = user ??
          (await _supabaseClient
              .from('user_details')
              .select()
              .eq('id', _currentUser!.id)
              .single()
              .then((value) => UserInfo.fromJson(value)));
      _userInfo = userInfo;
      _userInfoController.add(_userInfo);
    } catch (error) {}
    return Future.value();
  }
}
