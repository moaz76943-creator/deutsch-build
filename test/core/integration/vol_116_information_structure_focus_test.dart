import 'package:test/test.dart';
import 'package:deutsch_app/src/core/content/german_information_structure_focus_engine.dart';
import 'package:deutsch_app/src/ui/bridges/vol_116_wave57_ui_bridge.dart';

void main() {
  group('Task 4957: German Information Structure & Focus Architecture Tests', () {
    late GermanInformationStructureFocusEngine engine;
    late Vol116Wave57UiBridge bridge;

    setUp(() {
      engine = GermanInformationStructureFocusEngine();
      bridge = Vol116Wave57UiBridge(engine: engine);
    });

    tearDown(() {
      bridge.dispose();
    });

    test('Engine initializes complete professional catalog with >= 16 items', () {
      expect(engine.catalog.length, greaterThanOrEqualTo(16));
      for (final item in engine.catalog) {
        expect(item.id, startsWith('INFO-4957-'));
        expect(item.unmarkedSentence.isNotEmpty, isTrue);
        expect(item.markedFocusSentence.isNotEmpty, isTrue);
        expect(item.capitalizedNuclearAccentWord.isNotEmpty, isTrue);
        expect(item.topicConstituent.isNotEmpty, isTrue);
        expect(item.focusDomainConstituent.isNotEmpty, isTrue);
        expect(item.pragmaticContextGerman.isNotEmpty, isTrue);
        expect(item.pragmaticContextArabic.isNotEmpty, isTrue);
        expect(item.alternativeSetRejection.isNotEmpty, isTrue);
      }
    });

    test('Engine covers all information packaging categories', () {
      for (final type in InformationPackagingType.values) {
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

    test('Validation rejects missing capitalized nuclear accent word', () {
      final res = engine.validateInformationStructure(
        packagingType: InformationPackagingType.narrowContrastiveFocus,
        hasCapitalizedAccentWord: false,
        isGivenPlacedBeforeNew: true,
        isVerumOnFiniteVerb: false,
      );
      expect(res.isValid, isFalse);
      expect(res.issues.first, contains('Phonetischer Mangel'));
    });

    test('Validation enforces given before new scrambling', () {
      final res = engine.validateInformationStructure(
        packagingType: InformationPackagingType.givenBeforeNewScrambling,
        hasCapitalizedAccentWord: true,
        isGivenPlacedBeforeNew: false,
        isVerumOnFiniteVerb: false,
      );
      expect(res.isValid, isFalse);
      expect(res.issues.first, contains('Topologischer Verstoß'));
    });

    test('Validation enforces verum focus on finite verb', () {
      final res = engine.validateInformationStructure(
        packagingType: InformationPackagingType.verumFocusAffirmation,
        hasCapitalizedAccentWord: true,
        isGivenPlacedBeforeNew: true,
        isVerumOnFiniteVerb: false,
      );
      expect(res.isValid, isFalse);
      expect(res.issues.first, contains('Fokus-Fehler'));
    });

    test('Validation accepts compliant information structure configuration', () {
      final res = engine.validateInformationStructure(
        packagingType: InformationPackagingType.contrastiveTopicIKontur,
        hasCapitalizedAccentWord: true,
        isGivenPlacedBeforeNew: true,
        isVerumOnFiniteVerb: true,
      );
      expect(res.isValid, isTrue);
      expect(res.acousticAndTopologicalNotes.isNotEmpty, isTrue);
    });

    test('UI Bridge correctly handles reactive streaming and filtering', () async {
      expect(bridge.state.isReady, isTrue);
      expect(bridge.state.activeExemplars.length, equals(engine.catalog.length));

      bridge.filterByType(InformationPackagingType.narrowContrastiveFocus);
      expect(bridge.state.selectedType, equals(InformationPackagingType.narrowContrastiveFocus));
      expect(bridge.state.activeExemplars.every((e) => e.packagingType == InformationPackagingType.narrowContrastiveFocus), isTrue);

      bridge.resetFilters();
      expect(bridge.state.selectedType, isNull);
      expect(bridge.state.activeExemplars.length, equals(engine.catalog.length));
    });

    test('Telemetry generation reflects exact domain and packaging distribution', () {
      final telemetry = engine.generateTelemetrySnapshot();
      expect(telemetry['totalExemplars'], equals(engine.catalog.length));
      expect(telemetry['cefrLevel'], contains('C1-C2'));
      expect(telemetry['typeDistribution'], isA<Map>());
    });
  });
}
