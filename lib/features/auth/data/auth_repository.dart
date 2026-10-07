import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException, Supabase;

import '../../../core/cloud/cloud_initializer.dart';
import '../../../core/cloud/push_messaging_service.dart';

/// Repository managing Firebase Authentication for Family Sharing & Caregiver Mode.
class AuthRepository {
  const AuthRepository();

  bool get isAvailable => Firebase.apps.isNotEmpty;

  FirebaseAuth get _auth => FirebaseAuth.instance;

  User? get currentUser => isAvailable ? _auth.currentUser : null;

  Future<void> _ensureAvailable() async {
    if (Firebase.apps.isEmpty) {
      await CloudInitializer.initialize();
    }
    if (!isAvailable) {
      throw const AuthException('Firebase is not initialized.');
    }
  }

  /// Sign-in, sign-out and profile changes (userChanges, not
  /// authStateChanges, so a reload that verifies the email is seen).
  Stream<User?> authStateChanges() {
    if (!isAvailable) {
      return Stream.value(null);
    }
    return _auth.userChanges();
  }

  /// An email/password account whose address isn't confirmed yet. Google
  /// and Apple accounts come verified.
  static bool needsEmailVerification(User user) =>
      !user.emailVerified &&
      user.providerData.any((p) => p.providerId == 'password');

  /// Emails the signed-in user a link that confirms their address.
  Future<void> sendEmailVerification() async {
    await _ensureAvailable();
    await _auth.currentUser?.sendEmailVerification();
  }

  /// Refreshes the user from Firebase (after they tapped the link) and
  /// returns whether the email is now verified.
  Future<bool> reloadAndCheckVerified() async {
    await _ensureAvailable();
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.reload();
    final fresh = _auth.currentUser;
    if (fresh == null || !fresh.emailVerified) return false;
    // New ID token, so the cloud sees email_verified = true straight away.
    await fresh.getIdToken(true);
    return true;
  }

  /// Signs in using Google Sign-In and links to Firebase Auth.
  Future<UserCredential?> signInWithGoogle() async {
    await _ensureAvailable();
    try {
      final googleSignIn = GoogleSignIn(
        clientId: (!kIsWeb && Platform.isIOS)
            ? '918524133674-gajiev6rg9o88ofbf606pm5cbfj7arad.apps.googleusercontent.com'
            : null,
        scopes: const ['email', 'profile'],
        serverClientId:
            '918524133674-annc5hqp9h0847bvpbrrd1irjskt4c2e.apps.googleusercontent.com',
      );
      await googleSignIn.signOut().catchError((_) => null);

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
    await _ensureAvailable();
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
    await _ensureAvailable();
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Registers a new account with Email and Password and optional displayName.
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    await _ensureAvailable();
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    if (displayName != null && displayName.trim().isNotEmpty) {
      try {
        await credential.user?.updateDisplayName(displayName.trim());
      } catch (e) {
        debugPrint('[AuthRepository] Failed to update display name: $e');
      }
    }
    // Family sharing stays locked until the address is confirmed.
    try {
      await credential.user?.sendEmailVerification();
    } catch (e) {
      debugPrint('[AuthRepository] Failed to send verification email: $e');
    }
    return credential;
  }

  /// Sends a password reset email.
  Future<void> sendPasswordResetEmail(String email) async {
    await _ensureAvailable();
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Deletes the currently signed-in user account, and first their cloud
  /// data: once the Firebase account is gone its token can't reach it.
  Future<void> deleteAccount() async {
    if (!isAvailable) return;
    final user = _auth.currentUser;
    if (user != null) {
      if (CloudInitializer.isSupabaseInitialized) {
        await Supabase.instance.client.rpc('delete_my_data');
      }
      await user.delete();
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        await GoogleSignIn(
          clientId: Platform.isIOS
              ? '918524133674-gajiev6rg9o88ofbf606pm5cbfj7arad.apps.googleusercontent.com'
              : null,
        ).signOut().catchError((_) => null);
      }
    }
  }

  /// Signs out of all identity providers.
  Future<void> signOut() async {
    if (!isAvailable) return;
    try {
      // Stop caregiver nudge pushes reaching a signed-out device.
      await PushMessagingService.unregister();
      await _auth.signOut();
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        await GoogleSignIn(
          clientId: Platform.isIOS
              ? '918524133674-gajiev6rg9o88ofbf606pm5cbfj7arad.apps.googleusercontent.com'
              : null,
        ).signOut().catchError((_) => null);
      }
    } catch (e) {
      debugPrint('[AuthRepository] Sign-Out error: $e');
    }
  }

  /// Formats Firebase authentication errors into clear, actionable messages.
  static String formatAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      return switch (error.code) {
        'user-not-found' => 'No account found with this email address.',
        'wrong-password' => 'Incorrect password. Please try again.',
        'email-already-in-use' => 'An account with this email already exists.',
        'invalid-email' => 'Please enter a valid email address.',
        'weak-password' => 'Password must be at least 6 characters.',
        'user-disabled' => 'This account has been disabled.',
        'too-many-requests' => 'Too many attempts. Please try again later.',
        'operation-not-allowed' => 'This sign-in method is not enabled.',
        'network-request-failed' => 'Network error. Please check your connection.',
        'invalid-credential' => 'Invalid email or password. Please check and retry.',
        'requires-recent-login' => 'Please sign out and sign in again before deleting your account.',
        _ => error.message ?? 'Authentication error occurred.',
      };
    }
    if (error is PostgrestException) {
      return 'Could not reach the server to erase your data. Please check your connection and try again.';
    }
    if (error is PlatformException) {
      return 'Google Sign-In failed (${error.code}: ${error.message ?? 'Configuration error'}). You can also create an account with Email & Password below.';
    }
    return error.toString();
  }
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

