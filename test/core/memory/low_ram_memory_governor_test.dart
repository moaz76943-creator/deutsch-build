import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/memory/low_ram_memory_governor.dart';

class MockMemoryReclaimer implements NativeMemoryReclaimer {
  MadviseHint? lastHint;
  bool databaseShrunk = false;
  int currentRss = 80 * 1024 * 1024; // 80 MB initial

  @override
  Future<bool> invokeMadvise(MadviseHint hint) async {
    lastHint = hint;
    currentRss = (currentRss * 0.7).round(); // 30% reduction simulation
    return true;
  }

  @override
  Future<void> shrinkDatabaseMemory() async {
    databaseShrunk = true;
  }

  @override
  Future<int> getCurrentRssBytes() async => currentRss;
}

void main() {
  group('LowRamMemoryGovernor Tests', () {
    late MockMemoryReclaimer reclaimer;
    late LowRamMemoryGovernor governor;

    setUp(() {
      reclaimer = MockMemoryReclaimer();
      governor = LowRamMemoryGovernor(reclaimer: reclaimer);
    });

    test('Shrinks database and applies madvCold on low memory pressure', () async {
      final success = await governor.handleMemoryPressure(MemoryPressureLevel.low);

      expect(success, isTrue);
      expect(reclaimer.databaseShrunk, isTrue);
      expect(reclaimer.lastHint, equals(MadviseHint.madvCold));
      expect(governor.reclaimCount, equals(1));
    });

    test('Applies madvDontNeed on critical memory pressure', () async {
      final success = await governor.handleMemoryPressure(MemoryPressureLevel.critical);

      expect(success, isTrue);
      expect(reclaimer.lastHint, equals(MadviseHint.madvDontNeed));
    });

    test('Enforces budget when RSS exceeds ceiling', () async {
      reclaimer.currentRss = 150 * 1024 * 1024; // 150 MB (exceeds 120MB target)
      final enforced = await governor.auditAndEnforceBudget();

      expect(enforced, isTrue);
      expect(reclaimer.currentRss, lessThanOrEqualTo(120 * 1024 * 1024));
    });
  });
}
