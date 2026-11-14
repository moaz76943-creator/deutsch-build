import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_app/src/core/content/german_partitive_genitive_apposition_engine.dart';
import 'package:deutsch_app/src/ui/bridges/vol_116_wave69_ui_bridge.dart';

void main() {
  group('Task 4969: German Partitive Genitive & Apposition Architecture Tests', () {
    late GermanPartitiveGenitiveAppositionEngine engine;
    late Vol116Wave69UiBridge bridge;

    setUp(() {
      engine = GermanPartitiveGenitiveAppositionEngine();
      bridge = Vol116Wave69UiBridge(engine: engine);
    });

    tearDown(() {
      bridge.dispose();
    });

    test('Engine initializes complete professional catalog with >= 16 items', () {
      expect(engine.catalog.length, greaterThanOrEqualTo(16));
      for (final item in engine.catalog) {
        expect(item.id, startsWith('PART-4969-'));
        expect(item.carrierNounPhrase.isNotEmpty, isTrue);
        expect(item.headNoun.isNotEmpty, isTrue);
        expect(item.fullGermanSentence.isNotEmpty, isTrue);
        expect(item.ungrammaticalMismatchExample.isNotEmpty, isTrue);
        expect(item.grammaticalRuleGerman.isNotEmpty, isTrue);
        expect(item.grammaticalRuleArabic.isNotEmpty, isTrue);
      }
    });

    test('Engine covers all partitive and apposition categories', () {
      for (final cat in PartitiveAppositionCategory.values) {
        final matches = engine.getByCategory(cat);
        expect(matches.isNotEmpty, isTrue, reason: 'Category ${cat.name} must have at least one exemplar');
      }
    });

    test('Engine covers all case governance modes', () {
      for (final gov in AdjectiveMeasureCaseGovernance.values) {
        final matches = engine.getByGovernance(gov);
        expect(matches.isNotEmpty, isTrue, reason: 'Governance ${gov.name} must have at least one exemplar');
      }
    });

    test('Validation enforces case attraction in loose apposition', () {
      final invalidRes = engine.validatePartitiveStructure(
        category: PartitiveAppositionCategory.looseAppositionCaseAttraction,
        hasCaseAttractionAgreement: false, // Illegal mismatch!
        doesOnlyHeadNounInflectInCloseApposition: true,
        isFractionalVerbAgreementCorrect: true,
      );
      expect(invalidRes.isValid, isFalse);
      expect(invalidRes.issues.first, contains('Kongruenzfehler in lockerer Apposition'));

      final validRes = engine.validatePartitiveStructure(
        category: PartitiveAppositionCategory.looseAppositionCaseAttraction,
        hasCaseAttractionAgreement: true,
        doesOnlyHeadNounInflectInCloseApposition: true,
        isFractionalVerbAgreementCorrect: true,
      );
      expect(validRes.isValid, isTrue);
      expect(validRes.syntacticNotes.isNotEmpty, isTrue);
    });

    test('Validation prohibits double genitive inflection in close apposition', () {
      final invalidRes = engine.validatePartitiveStructure(
        category: PartitiveAppositionCategory.closeAppositionTitleName,
        hasCaseAttractionAgreement: true,
        doesOnlyHeadNounInflectInCloseApposition: false, // Illegal *des Elements Titans!
        isFractionalVerbAgreementCorrect: true,
      );
      expect(invalidRes.isValid, isFalse);
      expect(invalidRes.issues.first, contains('Flexionsfehler in enger Apposition'));
    });

    test('Validation enforces fractional verb agreement with plural partitive complements', () {
      final invalidRes = engine.validatePartitiveStructure(
        category: PartitiveAppositionCategory.fractionalPartitiveVerbAgreement,
        hasCaseAttractionAgreement: true,
        doesOnlyHeadNounInflectInCloseApposition: true,
        isFractionalVerbAgreementCorrect: false, // Mismatched number!
      );
      expect(invalidRes.isValid, isFalse);
      expect(invalidRes.issues.first, contains('Numeruskongruenz-Fehler bei Bruchpartitiv'));
    });

    test('UI Bridge correctly handles reactive streaming and filtering', () async {
      expect(bridge.state.isReady, isTrue);
      expect(bridge.state.activeExemplars.length, equals(engine.catalog.length));

      bridge.filterByCategory(PartitiveAppositionCategory.fractionalPartitiveVerbAgreement);
      expect(bridge.state.selectedCategory, equals(PartitiveAppositionCategory.fractionalPartitiveVerbAgreement));
      expect(
        bridge.state.activeExemplars.every((p) => p.category == PartitiveAppositionCategory.fractionalPartitiveVerbAgreement),
        isTrue,
      );

      bridge.resetFilters();
      expect(bridge.state.selectedCategory, isNull);
      expect(bridge.state.activeExemplars.length, equals(engine.catalog.length));
    });

    test('Telemetry generation reflects exact domain and category distribution', () {
      final telemetry = engine.generateTelemetrySnapshot();
      expect(telemetry['totalExemplars'], equals(engine.catalog.length));
      expect(telemetry['cefrLevel'], contains('C1-C2'));
      expect(telemetry['categoryDistribution'], isA<Map>());
    });
  });
}
