import 'package:flutter_test/flutter_test.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/services/local_heatmap_store.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('LocalHeatmapStore', () {
    late LocalHeatmapStore store;

    setUp(() async {
      store = LocalHeatmapStore.instance;
      // Clear database before each test
      final db = await store.database;
      await db.execute('DELETE FROM study_activity');
    });

    test('logActivity inserts new record', () async {
      final date = DateTime(2023, 10, 15);
      await store.logActivity(date, count: 5);

      final activity = await store.getYearlyActivity(2023);
      expect(activity[date], equals(5));
    });

    test('logActivity updates existing record', () async {
      final date = DateTime(2023, 10, 15);
      await store.logActivity(date, count: 2);
      await store.logActivity(date, count: 3);

      final activity = await store.getYearlyActivity(2023);
      expect(activity[date], equals(5));
    });

    test('getYearlyActivity returns only specific year', () async {
      await store.logActivity(DateTime(2022, 12, 31), count: 1);
      await store.logActivity(DateTime(2023, 1, 1), count: 2);
      await store.logActivity(DateTime(2023, 12, 31), count: 3);
      await store.logActivity(DateTime(2024, 1, 1), count: 4);

      final activity = await store.getYearlyActivity(2023);
      expect(activity.length, equals(2));
      expect(activity[DateTime(2023, 1, 1)], equals(2));
      expect(activity[DateTime(2023, 12, 31)], equals(3));
    });
  });
}
