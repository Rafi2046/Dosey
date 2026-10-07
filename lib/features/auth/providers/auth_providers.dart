import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';

/// Provides the [AuthRepository] instance.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return const AuthRepository();
});

/// Watches the Firebase user, including profile changes such as the email
/// becoming verified after a reload.
final authStateProvider = StreamProvider<User?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges();
});

/// Whoever is signed in, verified or not. Only the sign-in sheet needs this
/// (to ask an unverified user to confirm their email).
final signedInUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value;
});

/// The signed-in user once their email is confirmed, or null. Family sharing
/// only ever uses this one, so an unverified email can't link to anyone.
final currentUserProvider = Provider<User?>((ref) {
  final user = ref.watch(signedInUserProvider);
  if (user == null || AuthRepository.needsEmailVerification(user)) return null;
  return user;
});
