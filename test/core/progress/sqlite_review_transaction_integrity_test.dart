import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/core/progress/review_transaction_manager.dart';
import 'package:deutsch_bilarabi/core/progress/transaction_persistence_port.dart';
import 'package:deutsch_bilarabi/core/progress/sqlite_review_transaction_port.dart';
import 'package:deutsch_bilarabi/core/srs/review_command_port.dart';

ReviewCommand command(
  String id, {
  String source = 'de',
  String target = 'ar',
  String version = 'v2',
  ReviewRating rating = ReviewRating.good,
}) => ReviewCommand(
  reviewId: id,
  sourceLanguageId: source,
  targetLanguageId: target,
  semanticVersion: version,
  cardId: 'card-1',
  facetKey: 'lexeme',
  pairEpoch: 9,
  rating: rating,
  hinted: false,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  late Directory temp;
  late String file;
  late Database db;
  var throwAfterUpdate = false;

  Future<void> applyReview(Transaction txn, ReviewCommand item) async {
    await txn.execute('''
CREATE TABLE IF NOT EXISTS scoped_progress (
  directed_pair TEXT PRIMARY KEY,
  advance_count INTEGER NOT NULL
)''');
    final pair = '${item.sourceLanguageId}_${item.targetLanguageId}_${item.semanticVersion}';
    await txn.rawInsert(
      '''INSERT INTO scoped_progress (directed_pair,advance_count) VALUES (?,1)
      ON CONFLICT(directed_pair) DO UPDATE SET
      advance_count = advance_count + 1''',
      <Object>[pair],
    );
    if (throwAfterUpdate) throw StateError('simulate worker/process failure');
  }

  Future<int> count(String pair) async {
    final tables = await db.query('sqlite_master', where: 'type = ? AND name = ?',
        whereArgs: <Object>['table', 'scoped_progress']);
    if (tables.isEmpty) return 0;
    final rows = await db.query('scoped_progress',
        where: 'directed_pair = ?', whereArgs: <Object>[pair]);
    return rows.isEmpty ? 0 : rows.first['advance_count'] as int;
  }

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('srs-sqlite-atomic-');
    file = '${temp.path}/learning.sqlite';
    db = await databaseFactoryFfi.openDatabase(file);
    throwAfterUpdate = false;
  });
  tearDown(() async {
    await db.close();
    await temp.delete(recursive: true);
  });

  ReviewTransactionManager manager(Database connection) =>
      ReviewTransactionManager(
        SqliteReviewTransactionPort(database: connection, applyReview: applyReview),
        clock: () => DateTime.utc(2026, 10, 13),
      );

  test('duplicate and process restart never advance twice', () async {
    expect(await manager(db).processTransaction(command('event-1')),
        ReviewCommitResult.committed);
    await db.close();
    db = await databaseFactoryFfi.openDatabase(file);
    expect(await manager(db).processTransaction(command('event-1')),
        ReviewCommitResult.alreadyCommitted);
    expect(await count('de_ar_v2'), 1);
  });

  test('rollback also undoes progress increment and unique event', () async {
    throwAfterUpdate = true;
    await expectLater(
      manager(db).processTransaction(command('event-2')),
      throwsStateError,
    );
    throwAfterUpdate = false;
    expect(await count('de_ar_v2'), 0);
    expect(await manager(db).processTransaction(command('event-2')),
        ReviewCommitResult.committed);
    expect(await count('de_ar_v2'), 1);
  });

  test('directed-pair and version identities never share progress', () async {
    final tx = manager(db);
    await tx.processTransaction(command('a', source: 'de', target: 'ar'));
    await tx.processTransaction(command('b', source: 'ar', target: 'de'));
    await tx.processTransaction(command('c', version: 'v3'));
    expect(await count('de_ar_v2'), 1);
    expect(await count('ar_de_v2'), 1);
    expect(await count('de_ar_v3'), 1);
  });

  test('same review ID with changed rating or pair is rejected', () async {
    final tx = manager(db);
    await tx.processTransaction(command('collision'));
    await expectLater(
      tx.processTransaction(command('collision', rating: ReviewRating.easy)),
      throwsStateError,
    );
    await expectLater(
      tx.processTransaction(command('collision', target: 'en')),
      throwsStateError,
    );
    expect(await count('de_ar_v2'), 1);
    expect(await count('de_en_v2'), 0);
  });

  test('analytics source reads only committed matching directed pair', () async {
    final port = SqliteReviewTransactionPort(database: db, applyReview: applyReview);
    expect(await port.readCommittedReviews(
      sourceLanguageId: 'de', targetLanguageId: 'ar', semanticVersion: 'v2',
    ), isEmpty);
    await manager(db).processTransaction(command('persist-a'));
    await manager(db).processTransaction(command('persist-b', source: 'ar', target: 'de'));
    final persisted = await port.readCommittedReviews(
      sourceLanguageId: 'de', targetLanguageId: 'ar', semanticVersion: 'v2',
    );
    expect(persisted.length, 1);
    expect(persisted.single.languagePairKey, 'de_ar_v2');
    expect(persisted.single.rating, ReviewRating.good.index);
  });

  test('invalid semantic version cannot reach storage', () async {
    await expectLater(manager(db).processTransaction(command('x', version: '')),
        throwsArgumentError);
  });
}
