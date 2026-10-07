import 'package:dosey/core/database/app_database.dart';
import 'package:dosey/features/family_sharing/data/remote_prescription_repository.dart';
import 'package:dosey/features/family_sharing/domain/remote_prescription.dart';
import 'package:dosey/features/family_sharing/domain/remote_prescription_sync_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Serves a fixed cloud list instead of Supabase.
class _FakeRemoteRepo extends RemotePrescriptionRepository {
  List<RemotePrescription> cloud = [];

  @override
  bool get isAvailable => true;

  @override
  Future<List<RemotePrescription>> fetchPatientPrescriptions(
    String patientUid, {
    bool includeInactive = false,
  }) async => [
    for (final p in cloud)
      if (includeInactive || p.isActive) p,
  ];
}

void main() {
  late AppDatabase db;
  late _FakeRemoteRepo repo;
  late RemotePrescriptionSyncService sync;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = _FakeRemoteRepo();
    sync = RemotePrescriptionSyncService(db, repo);
  });
  tearDown(() => db.close());

  RemotePrescription napa({
    List<String> times = const ['08:00'],
    bool active = true,
    DateTime? updatedAt,
  }) => RemotePrescription(
    id: 'cloud-napa',
    patientUid: 'patient',
    name: 'Napa',
    times: times,
    startDate: DateTime(2026, 10, 1),
    updatedAt: updatedAt ?? DateTime(2026, 10, 2),
    isActive: active,
  );

  Future<List<Medicine>> medicines() => db.select(db.medicines).get();
  Future<List<Reminder>> reminders() => db.select(db.reminders).get();

  test(
    'a medicine the caregiver removes leaves the patient\'s phone',
    () async {
      repo.cloud = [napa()];
      await sync.syncPatientFromCloud(patientUid: 'patient');
      expect((await medicines()).single.cloudId, 'cloud-napa');

      repo.cloud = [napa(active: false, updatedAt: DateTime(2030))];
      await sync.syncPatientFromCloud(patientUid: 'patient');
      expect(await medicines(), isEmpty);
    },
  );

  test('a removed cloud medicine never deletes the patient\'s own one of the '
      'same name', () async {
    await db
        .into(db.medicines)
        .insert(
          MedicinesCompanion.insert(
            name: 'Napa',
            startDate: DateTime(2026, 10, 1),
          ),
        );
    repo.cloud = [napa(active: false)];
    await sync.syncPatientFromCloud(patientUid: 'patient');
    expect((await medicines()).single.cloudId, isNull);
  });

  test('moving a time (same number of doses) moves the alarm', () async {
    repo.cloud = [
      napa(times: ['08:00']),
    ];
    await sync.syncPatientFromCloud(patientUid: 'patient');
    expect((await reminders()).single.startAt.hour, 8);

    repo.cloud = [
      napa(times: ['09:30'], updatedAt: DateTime(2030)),
    ];
    await sync.syncPatientFromCloud(patientUid: 'patient');
    final moved = (await reminders()).single;
    expect((moved.startAt.hour, moved.startAt.minute), (9, 30));
  });
}
