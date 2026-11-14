import 'package:flutter_test/flutter_test.dart';
import '../../../lib/src/core/content/german_advanced_relatives_engine.dart';
import '../../../lib/src/ui/bridges/vol_116_wave51_ui_bridge.dart';

void main() {
  group('Task 4951: German Advanced Relatives & Genitive Engine Tests', () {
    late GermanAdvancedRelativesEngine engine;
    late Vol116Wave51UiBridge uiBridge;

    setUp(() {
      engine = GermanAdvancedRelativesEngine();
      uiBridge = Vol116Wave51UiBridge(engine: engine);
    });

    tearDown(() {
      uiBridge.dispose();
    });

    test('Engine catalog initializes with rich advanced relative entries', () {
      expect(engine.catalog, isNotEmpty);
      expect(engine.catalog.length, greaterThanOrEqualTo(16));
    });

    test('dessen rules consistently match masculine and neuter singular antecedents', () {
      final dessenEntries = engine.filterByType(RelativeClauseType.genitiveRelativeDessen);
      expect(dessenEntries, isNotEmpty);
      for (final item in dessenEntries) {
        expect(
          item.antecedentGenderNumber == AntecedentGenderNumber.masculineSingular ||
              item.antecedentGenderNumber == AntecedentGenderNumber.neuterSingular,
          isTrue,
        );
        expect(item.relativePronounPhrase, equals('dessen'));
      }
    });

    test('deren rules consistently match feminine singular and plural antecedents', () {
      final derenEntries = engine.filterByType(RelativeClauseType.genitiveRelativeDeren);
      expect(derenEntries, isNotEmpty);
      for (final item in derenEntries) {
        expect(
          item.antecedentGenderNumber == AntecedentGenderNumber.feminineSingular ||
              item.antecedentGenderNumber == AntecedentGenderNumber.pluralAll,
          isTrue,
        );
        expect(item.relativePronounPhrase, equals('deren'));
      }
    });

    test('Validator catches wrong agreement caused by possessed noun interference', () {
      final report = engine.validateGenitiveRelative(
        genderNumber: AntecedentGenderNumber.masculineSingular,
        relativePronounUsed: 'deren',
        containsIllegalArticleAfterPronoun: false,
      );

      expect(report.isValid, isFalse);
      expect(report.isPronounGenderNumberCorrect, isFalse);
      expect(report.issues, anyElement(contains('Kongruenzfehler')));
    });

    test('Validator catches illegal article following genitive relative pronoun', () {
      final report = engine.validateGenitiveRelative(
        genderNumber: AntecedentGenderNumber.masculineSingular,
        relativePronounUsed: 'dessen',
        containsIllegalArticleAfterPronoun: true,
      );

      expect(report.isValid, isFalse);
      expect(report.avoidsPossessedNounInterference, isFalse);
      expect(report.issues, anyElement(contains('Syntaktischer Fehler')));
    });

    test('Validator approves fully compliant genitive relative sentence', () {
      final report = engine.validateGenitiveRelative(
        genderNumber: AntecedentGenderNumber.masculineSingular,
        relativePronounUsed: 'dessen',
        containsIllegalArticleAfterPronoun: false,
      );

      expect(report.isValid, isTrue);
      expect(report.issues, isEmpty);
    });

    test('UI Bridge filters and telemetry snapshot function accurately', () {
      final telemetry = uiBridge.getTelemetrySnapshot();
      expect(telemetry['totalRelativeRules'], greaterThanOrEqualTo(16));
      expect(telemetry['legalLiabilityCompliance'], contains('Zero'));

      uiBridge.setTypeFilter(RelativeClauseType.prepositionalGenitiveRelative);
      expect(
        uiBridge.currentFilteredList.every((e) => e.relativeType == RelativeClauseType.prepositionalGenitiveRelative),
        isTrue,
      );

      uiBridge.clearFilters();
      expect(uiBridge.currentFilteredList.length, equals(engine.catalog.length));
    });
  });
}
