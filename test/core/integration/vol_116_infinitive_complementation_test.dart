import 'package:test/test.dart';
import '../../../lib/src/core/content/german_infinitive_complementation_engine.dart';
import '../../../lib/src/ui/bridges/vol_116_wave52_ui_bridge.dart';

void main() {
  group('Task 4952: German Infinitive Complementation & AcI Engine Tests', () {
    late GermanInfinitiveComplementationEngine engine;
    late Vol116Wave52UiBridge uiBridge;

    setUp(() {
      engine = GermanInfinitiveComplementationEngine();
      uiBridge = Vol116Wave52UiBridge(engine: engine);
    });

    tearDown(() {
      uiBridge.dispose();
    });

    test('Engine catalog initializes with rich infinitive complementation entries', () {
      expect(engine.catalog, isNotEmpty);
      expect(engine.catalog.length, greaterThanOrEqualTo(16));
    });

    test('Perception verbs strictly prohibit "zu" and trigger Ersatzinfinitiv in perfect', () {
      final perceptionEntries = engine.filterByType(InfinitiveGovernmentType.pureInfinitivePerception);
      expect(perceptionEntries, isNotEmpty);
      for (final item in perceptionEntries) {
        expect(item.allowsZu, isFalse);
        expect(item.requiresZu, isFalse);
        expect(item.triggersErsatzinfinitivInPerfect, isTrue);
      }
    });

    test('Obligatory zu-verbs strictly require "zu"', () {
      final obligatoryZu = engine.filterByType(InfinitiveGovernmentType.obligatoryZuInfinitive);
      expect(obligatoryZu, isNotEmpty);
      for (final item in obligatoryZu) {
        expect(item.requiresZu, isTrue);
        expect(item.allowsZu, isTrue);
      }
    });

    test('Validator catches illegal "zu" insertion with perception verb', () {
      final report = engine.validateInfinitiveUsage(
        governingVerb: 'sehen',
        usedZu: true,
        isSeparableVerb: false,
        infinitiveWord: 'zu steigen',
        isPerfectTense: false,
        usedErsatzinfinitiv: false,
      );

      expect(report.isValid, isFalse);
      expect(report.isZuCorrectlyApplied, isFalse);
      expect(report.issues, anyElement(contains('Ullzulässige Infinitivpartikel')));
    });

    test('Validator catches missing "zu" with control verb beabsichtigen', () {
      final report = engine.validateInfinitiveUsage(
        governingVerb: 'beabsichtigen',
        usedZu: false,
        isSeparableVerb: false,
        infinitiveWord: 'beschleunigen',
        isPerfectTense: false,
        usedErsatzinfinitiv: false,
      );

      expect(report.isValid, isFalse);
      expect(report.isZuCorrectlyApplied, isFalse);
      expect(report.issues, anyElement(contains('Fehlende Infinitivpartikel')));
    });

    test('Validator catches missing Ersatzinfinitiv in Perfect tense', () {
      final report = engine.validateInfinitiveUsage(
        governingVerb: 'sehen',
        usedZu: false,
        isSeparableVerb: false,
        infinitiveWord: 'steigen',
        isPerfectTense: true,
        usedErsatzinfinitiv: false,
      );

      expect(report.isValid, isFalse);
      expect(report.isErsatzinfinitivCompliant, isFalse);
      expect(report.issues, anyElement(contains('Fehlender Ersatzinfinitiv')));
    });

    test('Validator approves fully compliant AcI construction in Perfect tense', () {
      final report = engine.validateInfinitiveUsage(
        governingVerb: 'sehen',
        usedZu: false,
        isSeparableVerb: false,
        infinitiveWord: 'steigen',
        isPerfectTense: true,
        usedErsatzinfinitiv: true,
      );

      expect(report.isValid, isTrue);
      expect(report.issues, isEmpty);
    });

    test('UI Bridge filters and telemetry snapshot function accurately', () {
      final telemetry = uiBridge.getTelemetrySnapshot();
      expect(telemetry['totalInfinitiveRules'], greaterThanOrEqualTo(16));
      expect(telemetry['legalLiabilityCompliance'], contains('Zero'));

      uiBridge.setTypeFilter(InfinitiveGovernmentType.pureInfinitiveCausativePermissive);
      expect(
        uiBridge.currentFilteredList.every((e) => e.governmentType == InfinitiveGovernmentType.pureInfinitiveCausativePermissive),
        isTrue,
      );

      uiBridge.clearFilters();
      expect(uiBridge.currentFilteredList.length, equals(engine.catalog.length));
    });
  });
}
