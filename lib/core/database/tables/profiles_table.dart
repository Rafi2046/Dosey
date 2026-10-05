import 'package:drift/drift.dart';

/// A person whose medicines and records Dosey keeps: the user, and family
/// they look after ("Ammu", "Abbu"). Profile 1 always exists; data from
/// before profiles belongs to it. Doctors are shared by everyone.
@DataClassName('Profile')
class Profiles extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Empty for the first profile until named: shown as "Me".
  TextColumn get name => text().withLength(max: 60)();

  /// Index into the card colour cycle, for the avatar.
  IntColumn get colorIndex => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
