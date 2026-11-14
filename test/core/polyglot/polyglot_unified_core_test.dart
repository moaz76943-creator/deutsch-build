import 'package:test/test.dart';
import '../../../lib/src/core/polyglot/polyglot_unified_core.dart';
import '../../../lib/src/core/polyglot/modules/german_c1_c2_core_pack.dart';

void main() {
  group('Task #4984: Unified Plug-and-Play Polyglot Architecture Tests', () {
    late PolyglotUnifiedRegistry registry;
    late PolyglotUnifiedUiBridge bridge;

    setUp(() {
      registry = PolyglotUnifiedRegistry();
      registry.registerModule(GermanC1C2CoreFeaturePack());
      bridge = PolyglotUnifiedUiBridge(registry: registry);
    });

    tearDown(() async {
      await bridge.dispose();
    });

    test('Registers plug-and-play modules and supports multi-language expansion', () {
      expect(registry.registeredModules.length, equals(1));
      expect(registry.allUnits.length, greaterThanOrEqualTo(5));

      registry.registerLanguage(const LanguageDescriptor(
        isoCode: 'fr',
        nativeName: 'Français',
        arabicName: 'الفرنسية',
      ));
      expect(registry.supportedLanguages.length, equals(3));
    });

    test('Validates and auto-corrects German grammatical traps through unified rule engine', () {
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

    test('Reactive UI bridge filters by level, domain, and search query without boilerplate', () async {
      final emissions = <List<PolyglotLearningUnit>>[];
      final sub = bridge.unitsStream.listen(emissions.add);

      bridge.applyFilter(level: CefrProficiencyLevel.c2);
      expect(bridge.currentUnits.every((u) => u.level == CefrProficiencyLevel.c2), isTrue);

      bridge.resetFilters();
      expect(bridge.currentUnits.length, equals(registry.allUnits.length));

      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(emissions.length, equals(2));
      await sub.cancel();
    });
  });
}
