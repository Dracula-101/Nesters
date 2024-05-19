import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nesters/data/repository/auth/error/auth_error.dart';
import 'package:nesters/domain/models/user/user.dart';

import 'auth_repository.dart';

class FirebaseAuthRepository extends AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  User? get currentUser {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) {
      return null;
    }
    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? "",
      fullName: firebaseUser.displayName ?? "",
      photoUrl: firebaseUser.photoURL ?? '',
    );
  }

  @override
  Future<void> signInWithGoogle() {
    return _googleSignIn.signIn().then((googleSignInAccount) {
      if (googleSignInAccount == null) {
        throw GoogleSignInFailedException('Google sign in cancelled.');
      }
      return googleSignInAccount.authentication;
    }).then((googleSignInAuthentication) {
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      return _firebaseAuth.signInWithCredential(credential);
    }).catchError((error) {
      throw GoogleSignInFailedException.fromCode(error.code);
    });
  }

  @override
  Future<void> signOut() {
    return Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  @override
  Future<bool> isSignedIn() {
    return Future.value(_firebaseAuth.currentUser != null);
  }

  @override
  Stream<User?> get user {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) {
        return null;
      }
      return User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? "",
        fullName: firebaseUser.displayName ?? "",
        photoUrl: firebaseUser.photoURL ?? '',
      );
    });
  }
}
