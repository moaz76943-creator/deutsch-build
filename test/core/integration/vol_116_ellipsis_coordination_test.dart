import 'package:test/test.dart';
import '../../../lib/src/core/content/german_ellipsis_coordination_engine.dart';
import '../../../lib/src/ui/bridges/vol_116_wave41_ui_bridge.dart';

void main() {
  group('Task 4941: German Sentence Ellipsis & Coordination Engine Tests', () {
    late GermanEllipsisCoordinationEngine engine;
    late Vol116Wave41UiBridge uiBridge;

    setUp(() {
      engine = GermanEllipsisCoordinationEngine();
      uiBridge = Vol116Wave41UiBridge(engine: engine);
    });

    tearDown(() {
      uiBridge.dispose();
    });

    test('Engine catalog initializes with rich C1-C2 elliptical entries', () {
      expect(engine.catalog, isNotEmpty);
      expect(engine.catalog.length, greaterThanOrEqualTo(12));
    });

    test('Every entry contains complete sentences, omissions, and bilingual analyses', () {
      for (final item in engine.catalog) {
        expect(item.fullOvertSentence, isNotEmpty);
        expect(item.reducedEllipticSentence, isNotEmpty);
        expect(item.omittedElement, isNotEmpty);
        expect(item.arabicTranslation, isNotEmpty);
        expect(item.grammaticalAnalysisArabic, isNotEmpty);
        expect(item.grammaticalAnalysisGerman, isNotEmpty);
        expect(item.valenceIntegrityRule, isNotEmpty);
      }
    });

    test('Gapping entries correctly omit identical finite verbs', () {
      final gappingItems = engine.filterByType(EllipsisType.prädikatsellipseGapping);
      expect(gappingItems, isNotEmpty);
      for (final item in gappingItems) {
        expect(item.reducedEllipticSentence.length, lessThan(item.fullOvertSentence.length));
      }
    });

    test('Engine correctly flags blocked valence clash (Zeugma)', () {
      final zeugmaEntries = engine.filterByFeasibility(SyntacticFeasibility.blockedByValenceConflict);
      expect(zeugmaEntries, isNotEmpty);
      for (final item in zeugmaEntries) {
        expect(item.reducedEllipticSentence.startsWith('*'), isTrue);
      }
    });

    test('Validation catches valence conflict between Dative and Accusative verbs', () {
      final report = engine.validateCoordination(
        firstVerb: 'vertrauen (Dativ)',
        secondVerb: 'überprüfen (Akkusativ)',
        sameValenceCase: false,
        sameSubjectNumber: true,
      );

      expect(report.isValid, isFalse);
      expect(report.avoidsValenceZeugma, isFalse);
      expect(report.issues, anyElement(contains('Zeugma')));
    });

    test('Validation confirms sound coordination when valence and number match', () {
      final report = engine.validateCoordination(
        firstVerb: 'einspeisen (Akkusativ)',
        secondVerb: 'einspeisen (Akkusativ)',
        sameValenceCase: true,
        sameSubjectNumber: true,
      );

      expect(report.isValid, isTrue);
      expect(report.avoidsValenceZeugma, isTrue);
      expect(report.issues, isEmpty);
    });

    test('UI Bridge filters and telemetry function with high precision', () {
      final telemetry = uiBridge.getTelemetrySnapshot();
      expect(telemetry['totalEllipsisRules'], greaterThanOrEqualTo(12));
      expect(telemetry['legalLiabilityCompliance'], contains('Zero'));

      uiBridge.setTypeFilter(EllipsisType.prädikatsellipseGapping);
      expect(
        uiBridge.currentFilteredList.every((e) => e.ellipsisType == EllipsisType.prädikatsellipseGapping),
        isTrue,
      );

      uiBridge.clearFilters();
      expect(uiBridge.currentFilteredList.length, equals(engine.catalog.length));
    });
  });
}
