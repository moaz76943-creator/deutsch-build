import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/core/progress/sqlite_review_transaction_port.dart';
import 'package:deutsch_bilarabi/core/progress/review_transaction_manager.dart';
import 'package:deutsch_bilarabi/core/progress/transaction_persistence_port.dart';
import 'package:deutsch_bilarabi/core/srs/review_command_port.dart';

ReviewCommand review(String eventId, {
  String source = 'de', String target = 'ar', String card = 'house',
}) => ReviewCommand(
  reviewId: eventId, sourceLanguageId: source,
  targetLanguageId: target, cardId: card, facetKey: 'word',
  pairEpoch: 1, rating: ReviewRating.good, hinted: false,
);

void main() {
  sqfliteFfiInit();
  final factory = databaseFactoryFfi;
  late Directory tmp;
  late Database database;
  late String path;
  var mutations = 0;

  Future<void> apply(Transaction tx, ReviewCommand command) async {
    await tx.execute(
      'CREATE TABLE IF NOT EXISTS test_progress ('
      'card_id TEXT NOT NULL, source TEXT NOT NULL, target TEXT NOT NULL, '
      'reviews INTEGER NOT NULL, PRIMARY KEY(card_id,source,target))');
    await tx.rawInsert(
      'INSERT INTO test_progress(card_id,source,target,reviews) VALUES(?,?,?,1) '
      'ON CONFLICT(card_id,source,target) DO UPDATE SET reviews=reviews+1',
      [command.cardId, command.sourceLanguageId, command.targetLanguageId],
    );
    mutations++;
  }

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('srs_atomic_');
    path = tmp.path + '/learning.sqlite';
    database = await factory.openDatabase(path);
    mutations = 0;
  });
  tearDown(() async {
    await database.close();
    await tmp.delete(recursive: true);
  });

  test('reopen after committed review does not advance state twice', () async {
    final first = ReviewTransactionManager(
      SqliteReviewTransactionPort(database, applyReview: apply));
    expect(await first.processTransaction(review('ev-1')),
        TransactionCommitOutcome.applied);
    await database.close();
    database = await factory.openDatabase(path);
    final second = ReviewTransactionManager(
      SqliteReviewTransactionPort(database, applyReview: apply));
    expect(await second.processTransaction(review('ev-1')),
        TransactionCommitOutcome.alreadyCommitted);
    final count = Sqflite.firstIntValue(
      await database.rawQuery('SELECT reviews FROM test_progress LIMIT 1'));
    expect(count, 1);
    expect(mutations, 1);
  });

  test('reusing ID with opposite language direction fails closed', () async {
    final manager = ReviewTransactionManager(
      SqliteReviewTransactionPort(database, applyReview: apply));
    await manager.processTransaction(review('collision'));
    await expectLater(
      manager.processTransaction(review('collision', source: 'ar', target: 'de')),
      throwsStateError,
    );
    expect(mutations, 1);
  });

  test('failed state update rolls back event marker and state', () async {
    var firstTime = true;
    Future<void> flaky(Transaction tx, ReviewCommand command) async {
      await tx.execute('CREATE TABLE IF NOT EXISTS test_fail (n INTEGER)');
      await tx.insert('test_fail', {'n': 1});
      if (firstTime) {
        firstTime = false;
        throw StateError('interrupted');
      }
    }
    final manager = ReviewTransactionManager(
      SqliteReviewTransactionPort(database, applyReview: flaky));
    await expectLater(manager.processTransaction(review('retry')), throwsStateError);
    expect(await manager.processTransaction(review('retry')),
        TransactionCommitOutcome.applied);
    final count = Sqflite.firstIntValue(
      await database.rawQuery('SELECT count(*) FROM test_fail'));
    expect(count, 1);
  });

  test('different directed pairs are stored separately', () async {
    final manager = ReviewTransactionManager(
      SqliteReviewTransactionPort(database, applyReview: apply));
    await manager.processTransaction(review('de-ar'));
    await manager.processTransaction(review('ar-de', source: 'ar', target: 'de'));
    final rows = await database.rawQuery(
        'SELECT source,target,reviews FROM test_progress ORDER BY source');
    expect(rows.length, 2);
    expect(rows.every((row) => row['reviews'] == 1), isTrue);
  });
}
