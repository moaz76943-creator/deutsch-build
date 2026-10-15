import 'package:deutsch_bilarabi/services/pooled_database_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  late PooledDatabaseManager pool;
  final handles = <Database>[];
  final openedCodes = <String>[];
  var maximumSimultaneouslyOpen = 0;

  Future<Database> openTestDatabase(String code) async {
    final db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(singleInstance: false),
    );
    handles.add(db);
    openedCodes.add(code);
    final active = handles.where((item) => item.isOpen).length;
    if (active > maximumSimultaneouslyOpen) {
      maximumSimultaneouslyOpen = active;
    }
    return db;
  }

  setUp(() {
    handles.clear();
    openedCodes.clear();
    maximumSimultaneouslyOpen = 0;
    pool = PooledDatabaseManager(openConnection: openTestDatabase);
  });

  tearDown(() async {
    await pool.closeAll();
    for (final handle in handles) {
      if (handle.isOpen) await handle.close();
    }
  });

  test('opening a fifth language evicts and closes the LRU first', () async {
    final first = await pool.open('en');
    await pool.open('de');
    await pool.open('fr');
    await pool.open('es');
    expect(pool.activeCount, 4);
    await pool.open('it');
    expect(first.isOpen, isFalse);
    expect(pool.leastToMostRecentlyUsed, <String>['de', 'fr', 'es', 'it']);
    expect(maximumSimultaneouslyOpen, 4);
  });

  test('a cache hit refreshes recency without opening a second handle',
      () async {
    final en = await pool.open('en');
    await pool.open('de');
    await pool.open('fr');
    await pool.open('es');
    expect(await pool.open('en'), same(en));
    await pool.open('it');
    expect(en.isOpen, isTrue);
    expect(pool.leastToMostRecentlyUsed, <String>['fr', 'es', 'en', 'it']);
    expect(openedCodes.where((code) => code == 'en'), hasLength(1));
  });

  test('concurrent opens are serialized and never exceed four FDs',
      () async {
    await Future.wait(
      <String>['en', 'de', 'fr', 'es', 'it', 'tr', 'en']
          .map((code) => pool.open(code)),
    );
    expect(pool.activeCount, 4);
    expect(maximumSimultaneouslyOpen, 4);
  });

  test('leased connections cannot be evicted until the work completes',
      () async {
    await pool.withDatabase('en', (en) async {
      await pool.open('de');
      await pool.open('fr');
      await pool.open('es');
      await pool.open('it');
      expect(en.isOpen, isTrue);
      expect(pool.leastToMostRecentlyUsed, contains('en'));
    });
    await pool.open('tr');
    expect(pool.activeCount, 4);
  });

  test('rejects invalid language codes and closes all handles', () async {
    expect(() => pool.open('../de'), throwsArgumentError);
    await pool.open('en');
    await pool.closeAll();
    expect(pool.activeCount, 0);
    expect(handles.every((handle) => !handle.isOpen), isTrue);
  });
}
