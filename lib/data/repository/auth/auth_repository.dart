import 'package:nesters/domain/models/user/user.dart';

abstract class AuthRepository {
  //Auth Listener
  Stream<User?> get user;

  // Current User
  User? get currentUser;

  // Sign in with providers (Google, Apple)
  Future<void> signInWithGoogle();

  Future<void> signInWithApple();

  // Sign out
  Future<void> signOut();

  // Check if user is signed in
  Future<bool> isSignedIn();

  // Get the access token
  Future<String?> getAccessToken();
}
