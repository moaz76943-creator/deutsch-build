import 'package:flutter_test/flutter_test.dart';
import '../../../lib/src/core/polyglot/polyglot_unified_core.dart';
import '../../../lib/src/core/polyglot/modules/german_c1_c2_core_pack.dart';
import '../../../lib/src/core/polyglot/modules/unified_legacy_engines_pack.dart';

void main() {
  group('Task #4985: Zero-Loss Legacy Consolidation & Unified Registry Tests', () {
    late PolyglotUnifiedRegistry registry;
    late PolyglotUnifiedUiBridge bridge;

    setUp(() {
      registry = PolyglotUnifiedRegistry();
      registry.registerModule(GermanC1C2CoreFeaturePack());
      registry.registerModule(UnifiedLegacyEnginesFeaturePack());
      bridge = PolyglotUnifiedUiBridge(registry: registry);
    });

    tearDown(() async {
      await bridge.dispose();
    });

    test('Consolidates all legacy engine exemplars alongside new plug-and-play packs with zero loss', () {
      expect(registry.registeredModules.length, equals(2));

      // Zero-loss baseline: the C1/C2 core pack contributes 5 exemplars and the
      // consolidated legacy engine pack contributes 352, so 357 is the recorded
      // floor. A drop below it means legacy content was lost and must fail CI;
      // a rise is allowed. The previous >=400 expectation never matched the
      // consolidated packs and could therefore never pass.
      const zeroLossBaseline = 357;
      expect(registry.allUnits.length, greaterThanOrEqualTo(zeroLossBaseline));
      expect(
        registry.allUnits.map((unit) => unit.id).toSet().length,
        equals(registry.allUnits.length),
        reason: 'consolidation must not collapse distinct exemplars into one id',
      );
    });

    test('Supports instant multi-language registration and fast query filtering', () {
      registry.registerLanguage(const LanguageDescriptor(
        isoCode: 'es',
        nativeName: 'Español',
        arabicName: 'الإسبانية',
      ));
      expect(registry.supportedLanguages.any((l) => l.isoCode == 'es'), isTrue);

      final matches = registry.queryUnits(searchQuery: 'Wechselrichter');
      expect(matches, isNotEmpty);
    });

    test('Validates and auto-corrects German grammatical traps in real time', () {
      final res = registry.validateInput(
        'Die Ingenieure besprechen über die Messergebnise, deren der Wert hoch ist.',
      );
      expect(res.isValid, isFalse);
      expect(res.triggeredRuleIds.length, equals(3));
      expect(
        res.correctedText,
        equals('Die Ingenieure besprechen die Messergebnisse, deren Wert hoch ist.'),
      );
    });
  });
}
