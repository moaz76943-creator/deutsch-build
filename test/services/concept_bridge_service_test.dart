import 'dart:async';

import 'package:deutsch_bilarabi/services/concept_bridge_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _QueryDatabase extends Fake implements Database {
  _QueryDatabase(
    this.onQuery, {
    this.open = true,
  });

  final Future<List<Map<String, Object?>>> Function(
    String sql,
    List<Object?>? arguments,
  ) onQuery;
  final bool open;

  @override
  bool get isOpen => open;

  @override
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) =>
      onQuery(sql, arguments);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(sqfliteFfiInit);

  final databases = <Database>[];

  Future<Database> openConcepts(Map<String, String> concepts) async {
    final db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(singleInstance: false),
    );
    databases.add(db);
    await db.execute(
      'CREATE TABLE concepts ('
      'concept_id TEXT PRIMARY KEY, '
      'surface TEXT NOT NULL)',
    );
    for (final entry in concepts.entries) {
      await db.insert('concepts', <String, Object?>{
        'concept_id': entry.key,
        'surface': entry.value,
      });
    }
    return db;
  }

  tearDown(() async {
    for (final db in databases) {
      if (db.isOpen) await db.close();
    }
    databases.clear();
  });

  group('ConceptBridgeService', () {
    test('finds the same concept across open installed packs only', () async {
      final german = await openConcepts({'tree': 'Baum'});
      final french = await openConcepts({'tree': 'arbre'});
      final spanish = await openConcepts({'tree': 'árbol'});
      final italian = await openConcepts({'house': 'casa'});

      final bridge = ConceptBridgeService(openPackConnections: {
        'de': german,
        'fr': french,
        'es': spanish,
        'it': italian,
      });

      expect(
        await bridge.findTranslations(
          conceptId: 'tree',
          activeLanguageCode: 'de-DE',
        ),
        {'fr': 'arbre', 'es': 'árbol'},
      );
    });

    test('binds the concept ID as a parameter instead of interpolating it',
        () async {
      const maliciousId = "tree' OR 1=1 --";
      late String sql;
      late List<Object?>? arguments;

      final bridge = ConceptBridgeService(openPackConnections: {
        'fr': _QueryDatabase((query, values) async {
          sql = query;
          arguments = values;
          return <Map<String, Object?>>[];
        }),
      });

      expect(
        await bridge.findTranslations(
          conceptId: maliciousId,
          activeLanguageCode: 'de',
        ),
        isEmpty,
      );
      expect(sql, contains('WHERE concept_id = ?'));
      expect(arguments, <Object?>[maliciousId]);
    });

    test('returns fast matches by 50ms despite a blocked database',
        () async {
      final blocked = Completer<List<Map<String, Object?>>>();
      final bridge = ConceptBridgeService(openPackConnections: {
        'fr': _QueryDatabase((_, __) async => [
              <String, Object?>{'surface': 'arbre'},
            ]),
        'es': _QueryDatabase((_, __) => blocked.future),
      });

      final stopwatch = Stopwatch()..start();
      final result = await bridge
          .findTranslations(conceptId: 'tree', activeLanguageCode: 'de')
          .timeout(const Duration(seconds: 2));
      stopwatch.stop();

      expect(result, {'fr': 'arbre'});
      expect(stopwatch.elapsed, lessThan(const Duration(milliseconds: 500)));

      blocked.complete([
        <String, Object?>{'surface': 'árbol'},
      ]);
      await Future<void>.delayed(Duration.zero);
      expect(result, {'fr': 'arbre'}, reason: 'Late rows must not mutate results');
    });

    test('ignores closed and failing packs without hiding healthy matches',
        () async {
      final bridge = ConceptBridgeService(openPackConnections: {
        'fr': _QueryDatabase((_, __) async => [
              <String, Object?>{'surface': 'arbre'},
            ]),
        'es': _QueryDatabase(
          (_, __) => Future<List<Map<String, Object?>>>.error(
            StateError('database is locked'),
          ),
        ),
        'it': _QueryDatabase(
          (_, __) => throw StateError('Closed database was queried'),
          open: false,
        ),
      });

      expect(
        await bridge.findTranslations(
          conceptId: 'tree',
          activeLanguageCode: 'de',
        ),
        {'fr': 'arbre'},
      );
    });

    test('reflects registered and unregistered open connections', () async {
      final bridge = ConceptBridgeService();
      final french = _QueryDatabase((_, __) async => [
            <String, Object?>{'surface': 'arbre'},
          ]);

      expect(
        await bridge.findTranslations(
          conceptId: 'tree',
          activeLanguageCode: 'de',
        ),
        isEmpty,
      );

      bridge.registerOpenPack('fr-FR', french);
      expect(
        await bridge.findTranslations(
          conceptId: 'tree',
          activeLanguageCode: 'de',
        ),
        {'fr-fr': 'arbre'},
      );

      bridge.unregisterOpenPack('fr-FR', connection: french);
      expect(
        await bridge.findTranslations(
          conceptId: 'tree',
          activeLanguageCode: 'de',
        ),
        isEmpty,
      );
    });

    test('does not query for a blank concept ID', () async {
      final bridge = ConceptBridgeService(openPackConnections: {
        'fr': _QueryDatabase(
          (_, __) => throw StateError('Unexpected query'),
        ),
      });

      expect(
        await bridge.findTranslations(
          conceptId: '   ',
          activeLanguageCode: 'de',
        ),
        isEmpty,
      );
    });
  });
}
