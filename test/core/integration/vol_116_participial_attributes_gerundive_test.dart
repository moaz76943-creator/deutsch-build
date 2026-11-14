import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_app/src/core/content/german_participial_attributes_gerundive_engine.dart';
import 'package:deutsch_app/src/ui/bridges/vol_116_wave61_ui_bridge.dart';

void main() {
  group('Task 4961: German Extended Participial Attributes & Gerundive Architecture Tests', () {
    late GermanParticipialAttributesGerundiveEngine engine;
    late Vol116Wave61UiBridge bridge;

    setUp(() {
      engine = GermanParticipialAttributesGerundiveEngine();
      bridge = Vol116Wave61UiBridge(engine: engine);
    });

    tearDown(() {
      bridge.dispose();
    });

    test('Engine initializes complete professional catalog with >= 16 items', () {
      expect(engine.catalog.length, greaterThanOrEqualTo(16));
      for (final item in engine.catalog) {
        expect(item.id, startsWith('PART-4961-'));
        expect(item.extendedAttributePhrase.isNotEmpty, isTrue);
        expect(item.headNoun.isNotEmpty, isTrue);
        expect(item.fullGermanSentence.isNotEmpty, isTrue);
        expect(item.relativeClauseTransformation.isNotEmpty, isTrue);
        expect(item.modalParaphrase.isNotEmpty, isTrue);
        expect(item.embeddedComplements.isNotEmpty, isTrue);
        expect(item.pragmaticTechnicalContextGerman.isNotEmpty, isTrue);
        expect(item.pragmaticTechnicalContextArabic.isNotEmpty, isTrue);
      }
    });

    test('Engine covers all participial and gerundive construction types', () {
      for (final type in ParticipialConstructionType.values) {
        final matches = engine.getByType(type);
        expect(matches.isNotEmpty, isTrue, reason: 'Type ${type.name} must have at least one exemplar');
      }
    });

    test('Engine includes substantial Gerundive exemplars (necessity and possibility)', () {
      final gerundives = engine.catalog.where((p) =>
          p.constructionType == ParticipialConstructionType.gerundiveNecessity ||
          p.constructionType == ParticipialConstructionType.gerundivePossibility).toList();
      expect(gerundives.length, greaterThanOrEqualTo(8));
      for (final g in gerundives) {
        expect(g.extendedAttributePhrase.contains('zu '), isTrue);
        expect(g.isTransitiveVerb, isTrue);
      }
    });

    test('Validation rejects Gerundiv formed from intransitive verbs', () {
      final res = engine.validateParticipialStructure(
        type: ParticipialConstructionType.gerundiveNecessity,
        isVerbTransitive: false, // Illegal for Gerundiv!
        hasInnerZuForSeparable: true,
        caseAgreementCompliant: true,
      );
      expect(res.isValid, isFalse);
      expect(res.issues.first, contains('Valenzfehler'));
    });

    test('Validation rejects missing inner "zu" in separable verbs', () {
      final res = engine.validateParticipialStructure(
        type: ParticipialConstructionType.gerundivePossibility,
        isVerbTransitive: true,
        hasInnerZuForSeparable: false, // Illegal!
        caseAgreementCompliant: true,
      );
      expect(res.isValid, isFalse);
      expect(res.issues.first, contains('Morphologie-Fehler'));
    });

    test('Validation approves fully compliant participial attribute', () {
      final res = engine.validateParticipialStructure(
        type: ParticipialConstructionType.gerundiveNecessity,
        isVerbTransitive: true,
        hasInnerZuForSeparable: true,
        caseAgreementCompliant: true,
      );
      expect(res.isValid, isTrue);
      expect(res.syntacticNotes.isNotEmpty, isTrue);
    });

    test('UI Bridge correctly handles reactive streaming and filtering', () async {
      expect(bridge.state.isReady, isTrue);
      expect(bridge.state.activeExemplars.length, equals(engine.catalog.length));

      bridge.filterByType(ParticipialConstructionType.gerundiveNecessity);
      expect(bridge.state.selectedType, equals(ParticipialConstructionType.gerundiveNecessity));
      expect(
        bridge.state.activeExemplars.every((p) => p.constructionType == ParticipialConstructionType.gerundiveNecessity),
        isTrue,
      );

      bridge.resetFilters();
      expect(bridge.state.selectedType, isNull);
      expect(bridge.state.activeExemplars.length, equals(engine.catalog.length));
    });

    test('Telemetry generation reflects exact domain and participial distribution', () {
      final telemetry = engine.generateTelemetrySnapshot();
      expect(telemetry['totalExemplars'], equals(engine.catalog.length));
      expect(telemetry['cefrLevel'], contains('C1-C2'));
      expect(telemetry['gerundiveCount'], greaterThanOrEqualTo(8));
    });
  });
}
