import 'dart:async';
import 'package:flutter/foundation.dart';

/// Memory pressure urgency level reported by Android OS.
enum MemoryPressureLevel {
  moderate, // TRIM_MEMORY_RUNNING_MODERATE
  low,      // TRIM_MEMORY_RUNNING_LOW
  critical, // TRIM_MEMORY_RUNNING_CRITICAL
}

/// Advisory hint for POSIX madvise call.
enum MadviseHint {
  madvCold,     // MADV_COLD (mark pages as cold / reclaimable)
  madvDontNeed, // MADV_DONTNEED (purge memory immediately)
}

/// Low-level abstraction for native memory reclamation calls.
abstract class NativeMemoryReclaimer {
  Future<bool> invokeMadvise(MadviseHint hint);
  Future<void> shrinkDatabaseMemory();
  Future<int> getCurrentRssBytes();
}

/// Governor proactively managing RAM usage to prevent Android LMK (Signal 9) kills.
class LowRamMemoryGovernor {
  final NativeMemoryReclaimer reclaimer;
  final int maxTargetRssBytes; // Target ceiling (default 120MB)

  int _reclaimCount = 0;
  bool _isReclaiming = false;

  LowRamMemoryGovernor({
    required this.reclaimer,
    this.maxTargetRssBytes = 120 * 1024 * 1024,
  });

  int get reclaimCount => _reclaimCount;
  bool get isReclaiming => _isReclaiming;

  /// Handles OS memory trim events proactively.
  Future<bool> handleMemoryPressure(MemoryPressureLevel level) async {
    if (_isReclaiming) return false;
    _isReclaiming = true;

    try {
      debugPrint('[LowRamMemoryGovernor] Handling pressure level: ${level.name}');

      // 1. Shrink SQLite page caches
      await reclaimer.shrinkDatabaseMemory();

      // 2. Invoke appropriate madvise kernel hint
      final hint = (level == MemoryPressureLevel.critical)
          ? MadviseHint.madvDontNeed
          : MadviseHint.madvCold;
      await reclaimer.invokeMadvise(hint);

      _reclaimCount++;
      return true;
    } finally {
      _isReclaiming = false;
    }
  }

  /// Checks current RSS and triggers reclamation if threshold is exceeded.
  Future<bool> auditAndEnforceBudget() async {
    final currentRss = await reclaimer.getCurrentRssBytes();
    if (currentRss > maxTargetRssBytes) {
      debugPrint('[LowRamMemoryGovernor] RSS $currentRss exceeds ceiling $maxTargetRssBytes; enforcing budget.');
      return await handleMemoryPressure(MemoryPressureLevel.low);
    }
    return false;
  }
}
