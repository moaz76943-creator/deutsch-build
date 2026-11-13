import 'package:test/test.dart';
import 'package:deutsch_app/src/core/content/german_comma_semantics_orthography_engine.dart';
import 'package:deutsch_app/src/ui/bridges/vol_116_wave78_ui_bridge.dart';

void main() {
  group('CommaSemanticsOrthographyEngine & Wave78UiBridge Tests (Task #4978)', () {
    late CommaSemanticsOrthographyEngine engine;
    late Vol116Wave78UiBridge bridge;

    setUp(() {
      engine = CommaSemanticsOrthographyEngine();
      bridge = Vol116Wave78UiBridge(engine: engine);
    });

    tearDown(() async {
      await bridge.dispose();
    });

    test('covers all 6 engineering domains with 16+ C1-C2 exemplars', () {
      expect(engine.allExemplars.length, greaterThanOrEqualTo(16));
      for (final domain in OrthographyEngineeringDomain.values) {
        expect(engine.getByDomain(domain), isNotEmpty,
            reason: 'Domain $domain should have at least one exemplar');
      }
    });

    test('detects missing mandatory comma before um...zu infinitive clause', () {
      final result = engine.validateOrthographyAndComma(
        'Der Wechselrichter drosselt die Leistung um das Netz zu entlasten.',
      );
      expect(result.isValid, isFalse);
      expect(result.correctedSuggestion, contains('Leistung, um'));
      expect(engine.telemetry.caughtMissingInfinitiveCommas, equals(1));
    });

    test('detects lowercase spelling in fixed nominalized prepositional phrases', () {
      final result = engine.validateOrthographyAndComma(
        'Die Werte werden im voraus rechnerisch abgeglichen.',
      );
      expect(result.isValid, isFalse);
      expect(engine.telemetry.caughtNominalizedCapErrors, equals(1));
    });

    test('detects split spelling of richtigstellen in figurative correction sense', () {
      final result = engine.validateOrthographyAndComma(
        'Der Ingenieur musste die fehlerhafte Kurve im Protokoll richtig stellen.',
      );
      expect(result.isValid, isFalse);
      expect(result.correctedSuggestion, contains('richtigstellen'));
      expect(engine.telemetry.caughtSplitCompoundErrors, equals(1));
    });

    test('accepts valid C1-C2 comma placement and capitalization', () {
      final validInf = engine.validateOrthographyAndComma(
        'Der Wechselrichter drosselt die Leistung, um das Netz zu entlasten.',
      );
      final validCap = engine.validateOrthographyAndComma(
        'Im Folgenden werden die Werte im Voraus abgeglichen.',
      );
      expect(validInf.isValid, isTrue);
      expect(validCap.isValid, isTrue);
    });

    test('UI bridge emits reactive state updates on domain selection and validation', () async {
      final states = <Wave78OrthographyUiState>[];
      final sub = bridge.stateStream.listen(states.add);

      bridge.selectDomain(OrthographyEngineeringDomain.aerospaceAndAviation);
      bridge.submitAttempt('Die Werte werden im folgenden geprüft.');

      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(states.length, equals(2));
      expect(states.first.selectedDomain,
          equals(OrthographyEngineeringDomain.aerospaceAndAviation));
      expect(states.last.lastValidation?.isValid, isFalse);
      await sub.cancel();
    });
  });
}
