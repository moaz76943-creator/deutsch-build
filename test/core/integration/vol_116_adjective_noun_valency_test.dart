import 'package:test/test.dart';
import 'package:deutsch_app/src/core/content/german_adjective_noun_valency_engine.dart';
import 'package:deutsch_app/src/ui/bridges/vol_116_wave71_ui_bridge.dart';

void main() {
  group('Task 4971: German Adjective & Noun Valency Governance Tests', () {
    late GermanAdjectiveNounValencyEngine engine;
    late Vol116Wave71UiBridge bridge;

    setUp(() {
      engine = GermanAdjectiveNounValencyEngine();
      bridge = Vol116Wave71UiBridge(engine: engine);
    });

    tearDown(() {
      bridge.dispose();
    });

    test('Engine initializes complete professional catalog with >= 16 items', () {
      expect(engine.catalog.length, greaterThanOrEqualTo(16));
      for (final item in engine.catalog) {
        expect(item.id, startsWith('VAL-4971-'));
        expect(item.governingLexeme.isNotEmpty, isTrue);
        expect(item.fullGermanSentence.isNotEmpty, isTrue);
        expect(item.ungrammaticalInterferenceExample.isNotEmpty, isTrue);
        expect(item.valencyRuleGerman.isNotEmpty, isTrue);
        expect(item.valencyRuleArabic.isNotEmpty, isTrue);
      }
    });

    test('Engine covers all valency governance categories', () {
      for (final cat in ValencyGovernanceCategory.values) {
        final matches = engine.getByCategory(cat);
        expect(matches.isNotEmpty, isTrue, reason: 'Category ${cat.name} must have at least one exemplar');
      }
    });

    test('Engine covers all governed cases and prepositions', () {
      for (final rek in GovernedCaseOrPreposition.values) {
        final matches = engine.getByRection(rek);
        expect(matches.isNotEmpty, isTrue, reason: 'Rection ${rek.name} must have at least one exemplar');
      }
    });

    test('Validation rejects English interference (*Bedarf für statt an, *überlegen als statt Dativ)', () {
      final invalidRes = engine.validateValencyStructure(
        category: ValencyGovernanceCategory.deverbalNounPrepositionalGovernance,
        expectedRection: GovernedCaseOrPreposition.anPlusDative,
        matchesExpectedCaseAndPreposition: false, // Wrong preposition!
        isComplementFrontedBeforeAttributiveAdjective: true,
      );
      expect(invalidRes.isValid, isFalse);
      expect(invalidRes.issues.first, contains('Rektionsfehler'));
    });

    test('Validation rejects unfronted complements in attributive position', () {
      final invalidRes = engine.validateValencyStructure(
        category: ValencyGovernanceCategory.attributiveDativeAdjunctFronting,
        expectedRection: GovernedCaseOrPreposition.pureDative,
        matchesExpectedCaseAndPreposition: true,
        isComplementFrontedBeforeAttributiveAdjective: false, // Wrong word order!
      );
      expect(invalidRes.isValid, isFalse);
      expect(invalidRes.issues.first, contains('Wortstellungsfehler im Attribut'));
    });

    test('Validation approves compliant adjective/noun valency configuration', () {
      final validRes = engine.validateValencyStructure(
        category: ValencyGovernanceCategory.attributiveDativeAdjunctFronting,
        expectedRection: GovernedCaseOrPreposition.pureDative,
        matchesExpectedCaseAndPreposition: true,
        isComplementFrontedBeforeAttributiveAdjective: true,
      );
      expect(validRes.isValid, isTrue);
      expect(validRes.syntacticNotes.length, equals(2));
    });

    test('UI Bridge correctly handles reactive streaming and filtering', () async {
      expect(bridge.state.isReady, isTrue);
      expect(bridge.state.activeExemplars.length, equals(engine.catalog.length));

      bridge.filterByCategory(ValencyGovernanceCategory.dativeGoverningAdjective);
      expect(bridge.state.selectedCategory, equals(ValencyGovernanceCategory.dativeGoverningAdjective));
      expect(
        bridge.state.activeExemplars.every((v) => v.category == ValencyGovernanceCategory.dativeGoverningAdjective),
        isTrue,
      );

      bridge.resetFilters();
      expect(bridge.state.selectedCategory, isNull);
      expect(bridge.state.activeExemplars.length, equals(engine.catalog.length));
    });

    test('Telemetry generation reflects exact domain and valency distribution', () {
      final telemetry = engine.generateTelemetrySnapshot();
      expect(telemetry['totalExemplars'], equals(engine.catalog.length));
      expect(telemetry['cefrLevel'], contains('C1-C2'));
      expect(telemetry['attributiveCount'], greaterThanOrEqualTo(3));
    });
  });
}
