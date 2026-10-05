import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Repository managing Firebase Authentication for Family Sharing & Caregiver Mode.
class AuthRepository {
  const AuthRepository();

  bool get isAvailable => Firebase.apps.isNotEmpty;

  FirebaseAuth get _auth => FirebaseAuth.instance;

  User? get currentUser => isAvailable ? _auth.currentUser : null;

  Stream<User?> authStateChanges() {
    if (!isAvailable) {
      return Stream.value(null);
    }
    return _auth.authStateChanges();
  }

  /// Signs in using Google Sign-In and links to Firebase Auth.
  Future<UserCredential?> signInWithGoogle() async {
    if (!isAvailable) {
      throw const AuthException('Firebase is not initialized.');
    }
    try {
      final googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return null; // User cancelled
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('[AuthRepository] Google Sign-In error: $e');
      rethrow;
    }
  }

  /// Signs in using Sign in with Apple (iOS / macOS / Web).
  Future<UserCredential?> signInWithApple() async {
    if (!isAvailable) {
      throw const AuthException('Firebase is not initialized.');
    }
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final OAuthProvider oAuthProvider = OAuthProvider('apple.com');
      final AuthCredential credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('[AuthRepository] Apple Sign-In error: $e');
      rethrow;
    }
  }

  /// Signs in with Email and Password.
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (!isAvailable) {
      throw const AuthException('Firebase is not initialized.');
    }
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Registers a new account with Email and Password.
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) async {
    if (!isAvailable) {
      throw const AuthException('Firebase is not initialized.');
    }
    return _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Signs out of all identity providers.
  Future<void> signOut() async {
    if (!isAvailable) return;
    try {
      await _auth.signOut();
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        await GoogleSignIn().signOut().catchError((_) => null);
      }
    } catch (e) {
      debugPrint('[AuthRepository] Sign-Out error: $e');
    }
  }
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}
