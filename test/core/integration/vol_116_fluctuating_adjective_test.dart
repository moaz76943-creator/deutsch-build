import 'package:flutter_test/flutter_test.dart';
import '../../../lib/src/core/content/german_fluctuating_adjective_declension_engine.dart';
import '../../../lib/src/ui/bridges/vol_116_wave44_ui_bridge.dart';

void main() {
  group('Task 4944: German Fluctuating Adjective Declension Engine Tests', () {
    late GermanFluctuatingAdjectiveDeclensionEngine engine;
    late Vol116Wave44UiBridge uiBridge;

    setUp(() {
      engine = GermanFluctuatingAdjectiveDeclensionEngine();
      uiBridge = Vol116Wave44UiBridge(engine: engine);
    });

    tearDown(() {
      uiBridge.dispose();
    });

    test('Engine catalog initializes with rich determiner inflection rules', () {
      expect(engine.catalog, isNotEmpty);
      expect(engine.catalog.length, greaterThanOrEqualTo(14));
    });

    test('Definite-like determiners enforce weak endings in plural', () {
      final weakEntries = engine.filterByClass(DeterminerClass.definiteLikeWeak);
      expect(weakEntries, isNotEmpty);
      for (final item in weakEntries) {
        expect(item.expectedAdjectiveEnding, contains('-en'));
      }
    });

    test('Zahladjektive like "viele" enforce parallel strong ending -e in plural nominative', () {
      final viele = engine.catalog.firstWhere((e) => e.determinerWord == 'viele');
      expect(viele.determinerClass, equals(DeterminerClass.adjectiveLikeParallelStrong));
      expect(viele.expectedAdjectiveEnding, equals('-e'));
    });

    test('Undeclined determiners like "allerlei" and "etwas" force strong adjective endings', () {
      final uninflected = engine.filterByClass(DeterminerClass.uninflectedDeterminers);
      expect(uninflected, isNotEmpty);
      for (final item in uninflected) {
        expect(item.expectedAdjectiveEnding, isNot(equals('-en')));
      }
    });

    test('Validator catches wrong strong ending after "sämtliche"', () {
      final report = engine.validateAdjectivePhrase(
        determiner: 'sämtliche',
        writtenAdjectiveEnding: '-e',
        targetCase: GrammaticalCase.nominative,
        gender: GrammaticalGender.plural,
      );

      expect(report.isValid, isFalse);
      expect(report.issues, anyElement(contains('Inkorrekte Adjektivendung')));
    });

    test('Validator accepts correct weak ending after "sämtliche"', () {
      final report = engine.validateAdjectivePhrase(
        determiner: 'sämtliche',
        writtenAdjectiveEnding: '-en',
        targetCase: GrammaticalCase.nominative,
        gender: GrammaticalGender.plural,
      );

      expect(report.isValid, isTrue);
      expect(report.issues, isEmpty);
    });

    test('UI Bridge filters and telemetry snapshot function accurately', () {
      final telemetry = uiBridge.getTelemetrySnapshot();
      expect(telemetry['totalAdjectiveRules'], greaterThanOrEqualTo(14));
      expect(telemetry['legalLiabilityCompliance'], contains('Zero'));

      uiBridge.setClassFilter(DeterminerClass.adjectiveLikeParallelStrong);
      expect(
        uiBridge.currentFilteredList.every((e) => e.determinerClass == DeterminerClass.adjectiveLikeParallelStrong),
        isTrue,
      );

      uiBridge.clearFilters();
      expect(uiBridge.currentFilteredList.length, equals(engine.catalog.length));
    });
  });
}
