import 'package:test/test.dart';
import 'package:deutsch_build/src/core/gamification/cultural_relics_vault.dart';

void main() {
  group('CulturalRelicsVault Tests', () {
    late CulturalRelicsVault vault;

    setUp(() {
      vault = CulturalRelicsVault()..initialize();
    });

    test('Unlocks relics progressively as learner mastery points increase', () {
      expect(vault.unlockedRelics, isEmpty);

      // 600 points unlocks Brandenburg Gate (requires 500)
      final unlocked1 = vault.evaluateUnlocks(600);
      expect(unlocked1.length, equals(1));
      expect(unlocked1.first.id, equals('relic_brandenburg'));
      expect(vault.unlockedRelics.length, equals(1));

      // 1200 points unlocks Astrolabe (requires 1000)
      final unlocked2 = vault.evaluateUnlocks(1200);
      expect(unlocked2.length, equals(1));
      expect(unlocked2.first.id, equals('relic_astrolabe'));
      expect(vault.unlockedRelics.length, equals(2));
    });
  });
}
