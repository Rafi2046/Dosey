import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';
import '../data/family_share_repository.dart';
import '../domain/family_share.dart';

final familyShareRepositoryProvider = Provider<FamilyShareRepository>((ref) {
  return const FamilyShareRepository();
});

final patientSharesProvider =
    StreamProvider.autoDispose<List<FamilyShare>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  final repo = ref.watch(familyShareRepositoryProvider);
  return repo.watchPatientShares(user.uid);
});

final caregiverSharesProvider =
    StreamProvider.autoDispose<List<FamilyShare>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  final repo = ref.watch(familyShareRepositoryProvider);
  return repo.watchCaregiverShares(user.uid);
});
