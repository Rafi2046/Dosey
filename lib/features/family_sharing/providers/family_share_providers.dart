import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';
import '../data/family_share_repository.dart';
import '../domain/family_share.dart';

final familyShareRepositoryProvider = Provider<FamilyShareRepository>((ref) {
  return const FamilyShareRepository();
});

final patientSharesProvider =
    FutureProvider.autoDispose<List<FamilyShare>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final repo = ref.watch(familyShareRepositoryProvider);
  return repo.getPatientShares(user.uid);
});

final caregiverSharesProvider =
    FutureProvider.autoDispose<List<FamilyShare>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final repo = ref.watch(familyShareRepositoryProvider);
  return repo.getCaregiverShares(user.uid);
});
