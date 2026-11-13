import 'package:test/test.dart';
import 'package:deutsch_app/src/core/content/german_evidentiality_epistemic_modals_engine.dart';
import 'package:deutsch_app/src/ui/bridges/vol_116_wave56_ui_bridge.dart';

void main() {
  group('Task 4956: German Evidentiality & Epistemic Modals Architecture Tests', () {
    late GermanEvidentialityEpistemicModalsEngine engine;
    late Vol116Wave56UiBridge bridge;

    setUp(() {
      engine = GermanEvidentialityEpistemicModalsEngine();
      bridge = Vol116Wave56UiBridge(engine: engine);
    });

    tearDown(() {
      bridge.dispose();
    });

    test('Engine initializes complete professional catalog with >= 16 items', () {
      expect(engine.catalog.length, greaterThanOrEqualTo(16));
      for (final item in engine.catalog) {
        expect(item.id, startsWith('EVID-4956-'));
        expect(item.fullGermanSentence.isNotEmpty, isTrue);
        expect(item.epistemicCarrierPhrase.isNotEmpty, isTrue);
        expect(item.nonEpistemicParaphrase.isNotEmpty, isTrue);
        expect(item.speakerStanceGerman.isNotEmpty, isTrue);
        expect(item.speakerStanceArabic.isNotEmpty, isTrue);
        expect(item.technicalEvidenceBasis.isNotEmpty, isTrue);
        expect(item.speakerConfidenceDegree, inInclusiveRange(0.0, 1.0));
      }
    });

    test('Engine covers all evidentiality categories', () {
      for (final type in EvidentialityType.values) {
        final matches = engine.getByType(type);
        expect(matches.isNotEmpty, isTrue, reason: 'Type ${type.name} must have at least one exemplar');
      }
    });

    test('Engine covers all communicative engineering domains without PII or liability', () {
      for (final domain in CommunicativeDomain.values) {
        final matches = engine.getByDomain(domain);
        expect(matches.isNotEmpty, isTrue, reason: 'Domain ${domain.name} must have at least one exemplar');
      }
    });

    test('Validation detects illegal "zu" with modal verbs (sollen, wollen, müssen)', () {
      final res = engine.validateEvidentialConstruction(
        governingAuxiliary: 'sollen',
        infinitiveAspect: EpistemicInfinitiveAspect.infinitiveIActive,
        containsZuParticle: true,
        isThirdPartySubject: true,
      );
      expect(res.isValid, isFalse);
      expect(res.issues.first, contains('reinen Infinitiv ohne "zu"'));
    });

    test('Validation enforces obligatory "zu" with semi-auxiliaries (drohen zu, scheinen zu)', () {
      final res = engine.validateEvidentialConstruction(
        governingAuxiliary: 'drohen zu',
        infinitiveAspect: EpistemicInfinitiveAspect.infinitiveIActive,
        containsZuParticle: false,
        isThirdPartySubject: true,
      );
      expect(res.isValid, isFalse);
      expect(res.issues.first, contains('erfordert zwingend den Infinitiv mit "zu"'));
    });

    test('Validation accepts compliant semi-auxiliary construction', () {
      final res = engine.validateEvidentialConstruction(
        governingAuxiliary: 'scheinen',
        infinitiveAspect: EpistemicInfinitiveAspect.infinitiveIActive,
        containsZuParticle: true,
        isThirdPartySubject: true,
      );
      expect(res.isValid, isTrue);
      expect(res.normativeNotes.isNotEmpty, isTrue);
    });

    test('UI Bridge correctly handles reactive streaming and filtering', () async {
      expect(bridge.state.isReady, isTrue);
      expect(bridge.state.activeExemplars.length, equals(engine.catalog.length));

      bridge.filterByType(EvidentialityType.hearsayAttribution);
      expect(bridge.state.selectedType, equals(EvidentialityType.hearsayAttribution));
      expect(bridge.state.activeExemplars.every((e) => e.evidentialityType == EvidentialityType.hearsayAttribution), isTrue);

      bridge.resetFilters();
      expect(bridge.state.selectedType, isNull);
      expect(bridge.state.activeExemplars.length, equals(engine.catalog.length));
    });

    test('Telemetry generation reflects exact domain and type distribution', () {
      final telemetry = engine.generateTelemetrySnapshot();
      expect(telemetry['totalExemplars'], equals(engine.catalog.length));
      expect(telemetry['cefrLevel'], contains('C1-C2'));
      expect(telemetry['averageConfidenceDegree'], isA<double>());
    });
  });
}
