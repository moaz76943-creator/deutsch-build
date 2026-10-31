import 'package:test/test.dart';
import '../../lib/src/content/sovereign_sqlite_pack_builder.dart';

void main() {
  group('SovereignSqlitePackBuilder Unit Tests (L081)', () {
    final builder = SovereignSqlitePackBuilder();

    test('Generates valid SQLite DDL script with standard relational tables', () {
      final ddl = builder.generateMasterDdl();
      expect(ddl, contains('CREATE TABLE IF NOT EXISTS lexical_entries'));
      expect(ddl, contains('CREATE TABLE IF NOT EXISTS dialogue_turns'));
      expect(ddl, contains('CREATE TABLE IF NOT EXISTS bitext_pairs'));
      expect(ddl, contains('PRIMARY KEY AUTOINCREMENT'));
    });
  });
}
