import 'package:flutter_test/flutter_test.dart';
import '../../../lib/src/core/content/german_verb_polysemy_rection_engine.dart';
import '../../../lib/src/ui/bridges/vol_116_wave46_ui_bridge.dart';

void main() {
  group('Task 4946: German Verb Polysemy Rection Shifts Engine Tests', () {
    late GermanVerbPolysemyRectionEngine engine;
    late Vol116Wave46UiBridge uiBridge;

    setUp(() {
      engine = GermanVerbPolysemyRectionEngine();
      uiBridge = Vol116Wave46UiBridge(engine: engine);
    });

    tearDown(() {
      uiBridge.dispose();
    });

    test('Engine catalog initializes with rich polysemous rection variants', () {
      expect(engine.catalog, isNotEmpty);
      expect(engine.catalog.length, greaterThanOrEqualTo(16));
    });

    test('Verb "bestehen" correctly distinguishes auf, aus, and in', () {
      final bestehenVariants = engine.filterByVerb(BaseVerbGroup.bestehen);
      expect(bestehenVariants.length, greaterThanOrEqualTo(3));
      final hasAuf = bestehenVariants.any((v) => v.rectionPreposition == RectionPreposition.aufDat);
      final hasAus = bestehenVariants.any((v) => v.rectionPreposition == RectionPreposition.ausDat);
      final hasIn = bestehenVariants.any((v) => v.rectionPreposition == RectionPreposition.inDat);
      expect(hasAuf, isTrue);
      expect(hasAus, isTrue);
      expect(hasIn, isTrue);
    });

    test('Verb "ankommen" distinguishes spatial in vs. conditional auf vs. resonance bei', () {
      final ankommenVariants = engine.filterByVerb(BaseVerbGroup.ankommen);
      expect(ankommenVariants.length, greaterThanOrEqualTo(3));
      final hasAuf = ankommenVariants.any((v) => v.rectionPreposition == RectionPreposition.aufAkk);
      final hasIn = ankommenVariants.any((v) => v.rectionPreposition == RectionPreposition.inDat);
      final hasBei = ankommenVariants.any((v) => v.rectionPreposition == RectionPreposition.beiDat);
      expect(hasAuf, isTrue);
      expect(hasIn, isTrue);
      expect(hasBei, isTrue);
    });

    test('Validator catches erroneous preposition pairing', () {
      final report = engine.validateRection(
        verb: BaseVerbGroup.bestehen,
        selectedPreposition: RectionPreposition.inDat,
        intendedMeaning: SemanticShiftCategory.materialComposition,
      );

      expect(report.isValid, isFalse);
      expect(report.issues, anyElement(contains('Rektions- und Bedeutungsdivergenz')));
    });

    test('Validator confirms correct rection match for insistence', () {
      final report = engine.validateRection(
        verb: BaseVerbGroup.bestehen,
        selectedPreposition: RectionPreposition.aufDat,
        intendedMeaning: SemanticShiftCategory.dogmaticInsistence,
      );

      expect(report.isValid, isTrue);
      expect(report.issues, isEmpty);
    });

    test('UI Bridge filters and telemetry snapshot function accurately', () {
      final telemetry = uiBridge.getTelemetrySnapshot();
      expect(telemetry['totalRectionRules'], greaterThanOrEqualTo(16));
      expect(telemetry['legalLiabilityCompliance'], contains('Zero'));

      uiBridge.setVerbFilter(BaseVerbGroup.halten);
      expect(
        uiBridge.currentFilteredList.every((e) => e.baseVerb == BaseVerbGroup.halten),
        isTrue,
      );

      uiBridge.clearFilters();
      expect(uiBridge.currentFilteredList.length, equals(engine.catalog.length));
    });
  });
}
