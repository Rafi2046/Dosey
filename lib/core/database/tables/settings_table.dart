import 'package:drift/drift.dart';

/// Small key/value store for app preferences (e.g. the chosen language).
/// Lives in the DB so background isolates (notifications) can read it too.
@DataClassName('AppSetting')
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
