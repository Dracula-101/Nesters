import 'package:nesters/domain/models/user/profile/user_info.dart';
import 'package:nesters/domain/models/user/user.dart';

abstract class AuthRepository {
  //Auth Listener
  Stream<User?> get user;

  // Current User
  User? get currentUser;

  Stream<UserInfo?> get userInfo;

  UserInfo? get currentUserInfo;

  // Sign in with providers (Google, Apple)
  Future<void> signInWithGoogle();

  Future<void> signInWithApple();

  // Sign out
  Future<void> signOut();

  // Check if user is signed in
  Future<bool> isSignedIn();

  // Get the access token
  Future<String?> getAccessToken();

  // Update user info
  Future<void> updateUserInfo(UserInfo? user);
}
