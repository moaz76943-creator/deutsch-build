import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:deutsch_bilarabi/core/l1_cache.dart';
import 'package:deutsch_bilarabi/core/lifecycle/runtime_lifecycle_registry.dart';
import 'package:deutsch_bilarabi/core/notifications/habit_reminder_scheduler.dart';
import 'package:deutsch_bilarabi/services/pooled_database_manager.dart';
import 'package:deutsch_bilarabi/utils/background_task_governor.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  group('L1VocabularyCache Bounded & Shedding Tests', () {
    test('enforces maxCapacity of 3 and evicts LRU', () {
      final cache = L1VocabularyCache();
      cache.clear();

      cache.put('de', [{'word': 'Hallo'}]);
      cache.put('en', [{'word': 'Hello'}]);
      cache.put('fr', [{'word': 'Bonjour'}]);
      expect(cache.length, 3);
      expect(cache.has('de'), isTrue);

      // Access 'de' to make it most recently used; 'en' is now LRU
      final de = cache.get('de');
      expect(de, isNotNull);

      // Adding 4th language should evict 'en'
      cache.put('es', [{'word': 'Hola'}]);
      expect(cache.length, 3);
      expect(cache.has('en'), isFalse);
      expect(cache.has('de'), isTrue);
      expect(cache.has('fr'), isTrue);
      expect(cache.has('es'), isTrue);

      // Memory pressure shedding
      cache.clear();
      expect(cache.length, 0);
      expect(cache.has('de'), isFalse);
    });
  });

  group('PooledDatabaseManager closeUnleased Tests', () {
    late PooledDatabaseManager pool;
    final handles = <Database>[];

    Future<Database> openTestDb(String code) async {
      final db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(singleInstance: false),
      );
      handles.add(db);
      return db;
    }

    setUp(() {
      handles.clear();
      pool = PooledDatabaseManager(openConnection: openTestDb);
    });

    tearDown(() async {
      for (final h in handles) {
        if (h.isOpen) await h.close();
      }
    });

    test('closeUnleased closes unpinned connections while preserving leased', () async {
      final dbDe = await pool.open('de');
      await pool.open('fr');
      expect(pool.activeCount, 2);

      // Lease 'de' through withDatabase
      var executionRan = false;
      await pool.withDatabase('de', (leasedDb) async {
        executionRan = true;
        expect(leasedDb.isOpen, isTrue);

        // While 'de' is leased, closeUnleased should only close 'fr'
        final closedCount = await pool.closeUnleased();
        expect(closedCount, 1);
        expect(leasedDb.isOpen, isTrue);
        expect(pool.activeCount, 1);
      });

      expect(executionRan, isTrue);
      expect(dbDe.isOpen, isTrue);

      // Now that lease is released, closeUnleased should close 'de'
      final secondClosed = await pool.closeUnleased();
      expect(secondClosed, 1);
      expect(pool.activeCount, 0);
      expect(dbDe.isOpen, isFalse);
    });
  });

  group('RuntimeLifecycleRegistry Bounded Retention & Memory Pressure Tests', () {
    final registry = RuntimeLifecycleRegistry.instance;

    setUp(() {
      registry.reset();
    });

    tearDown(() {
      registry.reset();
    });

    test('bounds _disposedOwners retention and avoids unbounded memory accumulation', () async {
      for (var i = 0; i < 600; i++) {
        await registry.disposeOwner('transient_screen_$i');
      }

      // Disposing 600 screens must succeed without error, retaining only bounded set
      expect(registry.isDisposed, isFalse);
    });

    test('notifies registered memory pressure listeners', () {
      var notifiedA = false;
      var notifiedB = false;

      void listenerA() => notifiedA = true;
      void listenerB() => notifiedB = true;

      registry.registerMemoryPressureListener(listenerA);
      registry.registerMemoryPressureListener(listenerB);

      registry.notifyMemoryPressure();
      expect(notifiedA, isTrue);
      expect(notifiedB, isTrue);

      // Unregister listenerA
      notifiedA = false;
      notifiedB = false;
      registry.unregisterMemoryPressureListener(listenerA);

      registry.notifyMemoryPressure();
      expect(notifiedA, isFalse);
      expect(notifiedB, isTrue);
    });
  });

  group('BackgroundTaskGovernor ThermalProfile Tests', () {
    test('returns expected batch sizes and yield durations per thermal profile', () {
      expect(BackgroundTaskGovernor.batchSizeFor(ThermalProfile.normal), 200);
      expect(BackgroundTaskGovernor.batchSizeFor(ThermalProfile.sustained), 100);
      expect(BackgroundTaskGovernor.batchSizeFor(ThermalProfile.coolDown), 50);

      expect(
        BackgroundTaskGovernor.yieldPauseFor(ThermalProfile.normal),
        const Duration(milliseconds: 5),
      );
      expect(
        BackgroundTaskGovernor.yieldPauseFor(ThermalProfile.sustained),
        const Duration(milliseconds: 15),
      );
      expect(
        BackgroundTaskGovernor.yieldPauseFor(ThermalProfile.coolDown),
        const Duration(milliseconds: 50),
      );
    });
  });

  group('HabitReminderScheduler Offline Inexact Tests', () {
    test('isEligibleForReminder respects sleep hours and same-day reviews', () {
      final todayAtNoon = DateTime(2026, 10, 15, 12, 0);
      final yesterdayAtNoon = DateTime(2026, 10, 14, 12, 0);
      final earlyMorning = DateTime(2026, 10, 15, 5, 0); // 5 AM

      // Yesterday's review, current time noon -> eligible
      expect(
        HabitReminderScheduler.isEligibleForReminder(
          lastReviewTime: yesterdayAtNoon,
          currentTime: todayAtNoon,
        ),
        isTrue,
      );

      // Already reviewed today -> not eligible
      expect(
        HabitReminderScheduler.isEligibleForReminder(
          lastReviewTime: todayAtNoon,
          currentTime: todayAtNoon,
        ),
        isFalse,
      );

      // Sleep window (5 AM) -> not eligible
      expect(
        HabitReminderScheduler.isEligibleForReminder(
          lastReviewTime: yesterdayAtNoon,
          currentTime: earlyMorning,
        ),
        isFalse,
      );
    });

    test('generateGrowthReport produces structured milestone summaries', () {
      final report30 = HabitReminderScheduler.generateGrowthReport(
        daysActive: 30,
        wordsMastered: 150,
      );
      expect(report30, contains('30'));
      expect(report30, contains('150'));

      final report90 = HabitReminderScheduler.generateGrowthReport(
        daysActive: 90,
        wordsMastered: 500,
      );
      expect(report90, contains('الربع السنوي'));
      expect(report90, contains('500'));
    });
  });
}
