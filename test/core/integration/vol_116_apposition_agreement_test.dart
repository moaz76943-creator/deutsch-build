import 'package:test/test.dart';
import '../../../lib/src/core/content/german_apposition_agreement_engine.dart';
import '../../../lib/src/ui/bridges/vol_116_wave37_ui_bridge.dart';

void main() {
  group('Task 4937: German Appositive Agreement Engine Tests', () {
    late GermanAppositionAgreementEngine engine;
    late Vol116Wave37UiBridge uiBridge;

    setUp(() {
      engine = GermanAppositionAgreementEngine();
      uiBridge = Vol116Wave37UiBridge(engine: engine);
    });

    tearDown(() {
      uiBridge.dispose();
    });

    test('Engine initializes with comprehensive rules catalog', () {
      expect(engine.rulesCatalog, isNotEmpty);
      expect(engine.rulesCatalog.length, greaterThanOrEqualTo(10));
    });

    test('Loose Appositions require strict case agreement and commas', () {
      final looseRules = engine.getByType(AppositionType.looseApposition);
      expect(looseRules, isNotEmpty);
      for (final rule in looseRules) {
        expect(rule.appositionType, equals(AppositionType.looseApposition));
        expect(rule.fullSentence, contains(','));
        expect(rule.punctuationRule, isNotEmpty);
      }
    });

    test('Close Appositions have no commas and handle title-name inflection', () {
      final closeRules = engine.getByType(AppositionType.closeApposition);
      expect(closeRules, isNotEmpty);
      for (final rule in closeRules) {
        expect(rule.appositionType, equals(AppositionType.closeApposition));
        expect(rule.hasPunctuationError, isFalse);
      }
    });

    test('Validation detects missing commas in loose apposition', () {
      final report = engine.validateApposition(
        antecedentCase: GermanCase.dative,
        appositionCase: GermanCase.dative,
        type: AppositionType.looseApposition,
        containsPairCommas: false,
      );

      expect(report.isValid, isFalse);
      expect(report.issues, anyElement(contains('Fehlende Kommasetzung')));
    });

    test('Validation detects illegal commas in close apposition', () {
      final report = engine.validateApposition(
        antecedentCase: GermanCase.nominative,
        appositionCase: GermanCase.nominative,
        type: AppositionType.closeApposition,
        containsPairCommas: true,
      );

      expect(report.isValid, isFalse);
      expect(report.issues, anyElement(contains('Unzulässige Kommasetzung')));
    });

    test('Validation verifies als/wie case congruence', () {
      final validReport = engine.validateApposition(
        antecedentCase: GermanCase.accusative,
        appositionCase: GermanCase.accusative,
        type: AppositionType.appositionWithAlsWie,
        containsPairCommas: false,
      );
      expect(validReport.isValid, isTrue);

      final invalidReport = engine.validateApposition(
        antecedentCase: GermanCase.accusative,
        appositionCase: GermanCase.nominative,
        type: AppositionType.appositionWithAlsWie,
        containsPairCommas: false,
      );
      expect(invalidReport.isValid, isFalse);
      expect(invalidReport.issues, anyElement(contains('als/wie')));
    });

    test('UI Bridge filters and telemetry function flawlessly', () {
      final telemetry = uiBridge.getTelemetrySnapshot();
      expect(telemetry['totalRules'], greaterThanOrEqualTo(10));
      expect(telemetry['complianceRate'], contains('Sharia'));

      uiBridge.setFilterType(AppositionType.appositionWithAlsWie);
      expect(uiBridge.currentFilteredList.every((e) => e.appositionType == AppositionType.appositionWithAlsWie), isTrue);

      uiBridge.clearFilters();
      expect(uiBridge.currentFilteredList.length, equals(engine.rulesCatalog.length));
    });
  });
}
