import 'dart:io';
import 'package:test/test.dart';
import '../../../lib/src/core/polyglot/polyglot_unified_core.dart';
import '../../../lib/src/core/polyglot/polyglot_srs_and_pack_loader.dart';
import '../../../lib/src/core/polyglot/modules/german_real_world_dialogues_pack.dart';

void main() {
  group('Task #4986: Offline SM-2 SRS, JSON Pack Loader & Real-World Dialogues Tests', () {
    late PolyglotUnifiedRegistry registry;
    late PolyglotSrsScheduler srs;

    setUp(() {
      registry = PolyglotUnifiedRegistry();
      registry.registerModule(GermanRealWorldDialoguesPack());
      srs = PolyglotSrsScheduler();
    });

    test('Loads Real-World Dialogues across Medicine, Engineering, Business & Daily Life', () {
      expect(registry.queryUnits(domainId: 'medicine').length, greaterThanOrEqualTo(3));
      expect(registry.queryUnits(domainId: 'engineering').length, greaterThanOrEqualTo(2));
      expect(registry.queryUnits(domainId: 'business').length, greaterThanOrEqualTo(2));
      expect(registry.queryUnits(domainId: 'daily_life').length, greaterThanOrEqualTo(3));
    });

    test('SM-2 scheduler computes intervals, tracks lapses, and serializes/restores offline JSON', () {
      final t0 = DateTime.utc(2026, 11, 14, 12, 0);
      final r1 = srs.recordReview('dlg_med_01', 5, now: t0);
      expect(r1.intervalDays, equals(1));
      expect(r1.repetitions, equals(1));

      final r2 = srs.recordReview('dlg_med_01', 5, now: t0.add(const Duration(days: 1)));
      expect(r2.intervalDays, equals(6));
      expect(r2.repetitions, equals(2));

      final exported = srs.exportProgressJson();
      final restoredSrs = PolyglotSrsScheduler();
      final count = restoredSrs.importProgressJson(exported);
      expect(count, equals(1));
      expect(restoredSrs.stateOf('dlg_med_01')?.intervalDays, equals(6));
    });

    test('JSON Pack Loader imports declarative language packs without Dart boilerplate', () {
      final rawJson = File('assets/packs/de_everyday_starter_pack.json').readAsStringSync();
      final loaded = PolyglotJsonPackLoader.loadIntoRegistry(registry, rawJson);
      expect(loaded, equals(2));
      expect(registry.queryUnits(searchQuery: 'Wären Sie so freundlich'), isNotEmpty);
    });
  });
}
