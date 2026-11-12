import 'package:test/test.dart';
import '../../../lib/src/core/content/german_parenthesis_intercalation_engine.dart';
import '../../../lib/src/ui/bridges/vol_116_wave40_ui_bridge.dart';

void main() {
  group('Task 4940: German Parenthesis and Intercalation Engine Tests', () {
    late GermanParenthesisIntercalationEngine engine;
    late Vol116Wave40UiBridge uiBridge;

    setUp(() {
      engine = GermanParenthesisIntercalationEngine();
      uiBridge = Vol116Wave40UiBridge(engine: engine);
    });

    tearDown(() {
      uiBridge.dispose();
    });

    test('Engine catalog initializes with rich C1-C2 parenthetical entries', () {
      expect(engine.catalog, isNotEmpty);
      expect(engine.catalog.length, greaterThanOrEqualTo(12));
    });

    test('Every entry has valid structural components and bilingual documentation', () {
      for (final item in engine.catalog) {
        expect(item.fullCombinedSentence, isNotEmpty);
        expect(item.arabicTranslation, isNotEmpty);
        expect(item.grammaticalAnalysisArabic, isNotEmpty);
        expect(item.grammaticalAnalysisGerman, isNotEmpty);
        expect(item.topologicalIntegrityRule, isNotEmpty);
      }
    });

    test('Paired Dashes entries contain proper dash markers', () {
      final dashItems = engine.filterByStyle(PunctuationStyle.pairedDashes);
      expect(dashItems, isNotEmpty);
      for (final item in dashItems) {
        expect(item.fullCombinedSentence, contains('–'));
      }
    });

    test('Validation catches asymmetrical dashes when inner sentence insertion is incomplete', () {
      final report = engine.validateStructure(
        fullSentence: 'Die Maschine – ein Wunderwerk funktioniert tadellos.',
        style: PunctuationStyle.pairedDashes,
        isSentenceEndAttachment: false,
      );

      expect(report.isValid, isFalse);
      expect(report.hasSymmetricalPunctuation, isFalse);
      expect(report.errorList, anyElement(contains('Asymmetrische Gedankenstriche')));
    });

    test('Validation accepts symmetrical paired dashes', () {
      final report = engine.validateStructure(
        fullSentence: 'Die Maschine – ein Wunderwerk – funktioniert tadellos.',
        style: PunctuationStyle.pairedDashes,
        isSentenceEndAttachment: false,
      );

      expect(report.isValid, isTrue);
      expect(report.hasSymmetricalPunctuation, isTrue);
      expect(report.errorList, isEmpty);
    });

    test('Validation catches unmatched brackets', () {
      final report = engine.validateStructure(
        fullSentence: 'Der Entwurf (einschließlich Anlagen wurde genehmigt.',
        style: PunctuationStyle.parenthesesBrackets,
        isSentenceEndAttachment: false,
      );

      expect(report.isValid, isFalse);
      expect(report.errorList, anyElement(contains('Asymmetrische Klammern')));
    });

    test('UI Bridge filters and telemetry function with high precision', () {
      final telemetry = uiBridge.getTelemetrySnapshot();
      expect(telemetry['totalParenthesisRules'], greaterThanOrEqualTo(12));
      expect(telemetry['legalLiabilityCompliance'], contains('Zero'));

      uiBridge.setTypeFilter(IntercalationType.verbalSchaltsatz);
      expect(
        uiBridge.currentFilteredList.every((e) => e.intercalationType == IntercalationType.verbalSchaltsatz),
        isTrue,
      );

      uiBridge.clearFilters();
      expect(uiBridge.currentFilteredList.length, equals(engine.catalog.length));
    });
  });
}
