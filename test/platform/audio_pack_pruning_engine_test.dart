import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/platform/audio_pack_pruning_engine.dart';

void main() {
  group('AudioPackPruningEngine Unit Tests (N094)', () {
    const engine = AudioPackPruningEngine(maxCacheBudgetBytes: 1000); // 1000 bytes budget

    test('Prunes oldest accessed non-essential audio assets when over budget', () {
      final cache = [
        const CachedAudioAsset(assetId: 'core_greeting', fileSizeBytes: 400, lastAccessedEpochDays: 1, isCoreEssentialA1: true),
        const CachedAudioAsset(assetId: 'old_story_part1', fileSizeBytes: 500, lastAccessedEpochDays: 2, isCoreEssentialA1: false),
        const CachedAudioAsset(assetId: 'old_story_part2', fileSizeBytes: 500, lastAccessedEpochDays: 10, isCoreEssentialA1: false),
      ]; // Total 1400 bytes (> 1000)

      final pruned = engine.identifyAssetsToPrune(currentCache: cache, availableDiskSpaceMb: 1000);
      expect(pruned, contains('old_story_part1')); // Oldest non-essential
      expect(pruned, isNot(contains('core_greeting'))); // Never prune essential A1 core
    });

    test('Returns empty prune list when storage is within budget and disk space is plenty', () {
      final cache = [
        const CachedAudioAsset(assetId: 'audio1', fileSizeBytes: 200, lastAccessedEpochDays: 5, isCoreEssentialA1: false),
      ];
      final pruned = engine.identifyAssetsToPrune(currentCache: cache, availableDiskSpaceMb: 500);
      expect(pruned, isEmpty);
    });
  });
}
