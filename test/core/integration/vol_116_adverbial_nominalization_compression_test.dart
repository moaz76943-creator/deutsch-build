import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_app/src/core/content/german_adverbial_nominalization_compression_engine.dart';
import 'package:deutsch_app/src/ui/bridges/vol_116_wave70_ui_bridge.dart';

void main() {
  group('Task 4970: German Adverbial-to-Nominal Compression Architecture Tests', () {
    late GermanAdverbialNominalizationCompressionEngine engine;
    late Vol116Wave70UiBridge bridge;

    setUp(() {
      engine = GermanAdverbialNominalizationCompressionEngine();
      bridge = Vol116Wave70UiBridge(engine: engine);
    });

    tearDown(() {
      bridge.dispose();
    });

    test('Engine initializes complete professional catalog with >= 16 items', () {
      expect(engine.catalog.length, greaterThanOrEqualTo(16));
      for (final item in engine.catalog) {
        expect(item.id, startsWith('NOM-4970-'));
        expect(item.verbalSubordinateClause.isNotEmpty, isTrue);
        expect(item.compressedNominalPhrase.isNotEmpty, isTrue);
        expect(item.fullNominalizedSentence.isNotEmpty, isTrue);
        expect(item.fullVerbalizedSentence.isNotEmpty, isTrue);
        expect(item.compressionPreposition.isNotEmpty, isTrue);
        expect(item.syntacticTransformationRuleGerman.isNotEmpty, isTrue);
        expect(item.syntacticTransformationRuleArabic.isNotEmpty, isTrue);
      }
    });

    test('Engine covers all semantic compression relations', () {
      for (final rel in AdverbialCompressionRelation.values) {
        final matches = engine.getByRelation(rel);
        expect(matches.isNotEmpty, isTrue, reason: 'Relation ${rel.name} must have at least one exemplar');
      }
    });

    test('Engine covers all preposition-governed cases', () {
      for (final gc in PrepositionGovernedCase.values) {
        final matches = engine.getByCase(gc);
        expect(matches.isNotEmpty, isTrue, reason: 'Case ${gc.name} must have at least one exemplar');
      }
    });

    test('Validation rejects wrong case after Genitiv preposition', () {
      final invalidRes = engine.validateCompression(
        expectedCase: PrepositionGovernedCase.genitiveStrict,
        isNounPhraseInExpectedCase: false, // Colloquial dative instead of strict Genitiv!
        isMainClauseVerbSecondInverted: true,
        retainsAllSemanticArguments: true,
      );
      expect(invalidRes.isValid, isFalse);
      expect(invalidRes.issues.first, contains('Rektionsfehler'));
    });

    test('Validation rejects missing V2 inversion after fronted PP', () {
      final invalidRes = engine.validateCompression(
        expectedCase: PrepositionGovernedCase.dativeStrict,
        isNounPhraseInExpectedCase: true,
        isMainClauseVerbSecondInverted: false, // Missing V2 inversion!
        retainsAllSemanticArguments: true,
      );
      expect(invalidRes.isValid, isFalse);
      expect(invalidRes.issues.first, contains('Topologie-Fehler'));
    });

    test('Validation approves fully compliant nominal compression', () {
      final validRes = engine.validateCompression(
        expectedCase: PrepositionGovernedCase.genitiveStrict,
        isNounPhraseInExpectedCase: true,
        isMainClauseVerbSecondInverted: true,
        retainsAllSemanticArguments: true,
      );
      expect(validRes.isValid, isTrue);
      expect(validRes.syntacticNotes.length, equals(3));
    });

    test('UI Bridge correctly handles reactive streaming and filtering', () async {
      expect(bridge.state.isReady, isTrue);
      expect(bridge.state.activeExemplars.length, equals(engine.catalog.length));

      bridge.filterByRelation(AdverbialCompressionRelation.causalCompression);
      expect(bridge.state.selectedRelation, equals(AdverbialCompressionRelation.causalCompression));
      expect(
        bridge.state.activeExemplars.every((m) => m.relation == AdverbialCompressionRelation.causalCompression),
        isTrue,
      );

      bridge.resetFilters();
      expect(bridge.state.selectedRelation, isNull);
      expect(bridge.state.activeExemplars.length, equals(engine.catalog.length));
    });

    test('Telemetry generation reflects exact domain and relation distribution', () {
      final telemetry = engine.generateTelemetrySnapshot();
      expect(telemetry['totalExemplars'], equals(engine.catalog.length));
      expect(telemetry['cefrLevel'], contains('C1-C2'));
      expect(telemetry['relationDistribution'], isA<Map>());
    });
  });
}
