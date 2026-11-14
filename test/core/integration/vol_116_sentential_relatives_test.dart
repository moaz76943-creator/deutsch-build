import 'package:flutter_test/flutter_test.dart';
import '../../../lib/src/core/content/german_sentential_relatives_engine.dart';
import '../../../lib/src/ui/bridges/vol_116_wave38_ui_bridge.dart';

void main() {
  group('Task 4938: German Sentential Relative Clauses Engine Tests', () {
    late GermanSententialRelativesEngine engine;
    late Vol116Wave38UiBridge uiBridge;

    setUp(() {
      engine = GermanSententialRelativesEngine();
      uiBridge = Vol116Wave38UiBridge(engine: engine);
    });

    tearDown(() {
      uiBridge.dispose();
    });

    test('Engine initializes with complete catalog of C1-C2 sentential structures', () {
      expect(engine.catalog, isNotEmpty);
      expect(engine.catalog.length, greaterThanOrEqualTo(12));
    });

    test('Every entry contains punctuation comma and complete bilingual explanation', () {
      for (final item in engine.catalog) {
        expect(item.fullCombinedSentence, contains(','));
        expect(item.arabicTranslation, isNotEmpty);
        expect(item.grammaticalAnalysisArabic, isNotEmpty);
        expect(item.grammaticalAnalysisGerman, isNotEmpty);
      }
    });

    test('Propositional "was" entries correctly reference entire preceding clauses', () {
      final wasItems = engine.filterByType(SententialRelativeType.propositionalWas);
      expect(wasItems, isNotEmpty);
      for (final item in wasItems) {
        expect(item.relativeConnector, equals('was'));
        expect(item.prescriptiveNote, contains('was'));
      }
    });

    test('Pronominal Adverbs contain wo(r)- formations and formal register', () {
      final pronominalItems =
          engine.filterByType(SententialRelativeType.pronominalAdverbRelative);
      expect(pronominalItems, isNotEmpty);
      for (final item in pronominalItems) {
        expect(item.relativeConnector.startsWith('wo'), isTrue);
      }
    });

    test('Validator catches erroneous use of "das" when referring to sentence', () {
      final report = engine.validateSententialSentence(
        text: 'Er half uns sofort, das wir schätzten.',
        connectorUsed: 'das',
        hasPrecedingComma: true,
        finiteVerbAtEnd: true,
      );

      expect(report.isValid, isFalse);
      expect(report.errorList, anyElement(contains('Fehlerhafter Konnektor')));
    });

    test('Validator catches missing verb-final topology in relative clause', () {
      final report = engine.validateSententialSentence(
        text: 'Der Flug fiel aus, weshalb wir mussten warten.',
        connectorUsed: 'weshalb',
        hasPrecedingComma: true,
        finiteVerbAtEnd: false,
      );

      expect(report.isValid, isFalse);
      expect(report.errorList, anyElement(contains('Falsche Wortstellung')));
    });

    test('Validator catches missing comma preceding sentential relative', () {
      final report = engine.validateSententialSentence(
        text: 'Alles was er sagte war wahr.',
        connectorUsed: 'was',
        hasPrecedingComma: false,
        finiteVerbAtEnd: true,
      );

      expect(report.isValid, isFalse);
      expect(report.errorList, anyElement(contains('Fehlendes Komma')));
    });

    test('UI Bridge telemetry and filtering function seamlessly', () {
      final telemetry = uiBridge.getDiagnosticTelemetry();
      expect(telemetry['totalSententialRules'], greaterThanOrEqualTo(12));
      expect(telemetry['privacyPolicy'], contains('Zero PII'));

      uiBridge.setTypeFilter(SententialRelativeType.causalConsecutiveRelative);
      expect(uiBridge.currentItems.every((e) => e.type == SententialRelativeType.causalConsecutiveRelative), isTrue);

      uiBridge.clearFilters();
      expect(uiBridge.currentItems.length, equals(engine.catalog.length));
    });
  });
}
