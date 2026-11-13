import 'package:test/test.dart';
import '../../../lib/src/core/content/german_n_declension_engine.dart';
import '../../../lib/src/ui/bridges/vol_116_wave43_ui_bridge.dart';

void main() {
  group('Task 4943: German N-Declension Morphology Engine Tests', () {
    late GermanNDeclensionEngine engine;
    late Vol116Wave43UiBridge uiBridge;

    setUp(() {
      engine = GermanNDeclensionEngine();
      uiBridge = Vol116Wave43UiBridge(engine: engine);
    });

    tearDown(() {
      uiBridge.dispose();
    });

    test('Engine catalog initializes with rich N-declension paradigm entries', () {
      expect(engine.catalog, isNotEmpty);
      expect(engine.catalog.length, greaterThanOrEqualTo(14));
    });

    test('All pure weak masculine nouns on -e gain -n in oblique cases', () {
      final weakOnE = engine.filterByClass(NDeclensionClass.pureWeakOnE);
      expect(weakOnE, isNotEmpty);
      for (final item in weakOnE) {
        expect(item.nominativeForm.endsWith('e'), isTrue);
        expect(item.accusativeForm.endsWith('en'), isTrue);
        expect(item.dativeForm.endsWith('en'), isTrue);
        expect(item.genitiveForm.endsWith('en'), isTrue);
      }
    });

    test('Mixed class nouns strictly require -ns in the genitive singular', () {
      final mixedClass = engine.filterByClass(NDeclensionClass.mixedClassWithNs);
      expect(mixedClass, isNotEmpty);
      for (final item in mixedClass) {
        expect(item.requiresNsInGenitive, isTrue);
        expect(item.genitiveForm.endsWith('ns'), isTrue);
        expect(item.dativeForm.endsWith('n'), isTrue);
      }
    });

    test('Irregular neuter "das Herz" maintains endungslos Nom/Akk and -ens Genitiv', () {
      final herz = engine.catalog.firstWhere((e) => e.baseLemma == 'das Herz');
      expect(herz.nominativeForm, equals('das Herz'));
      expect(herz.accusativeForm, equals('das Herz'));
      expect(herz.dativeForm, equals('dem Herzen'));
      expect(herz.genitiveForm, equals('des Herzens'));
    });

    test('Automatic inflection generates exact forms across all 4 cases', () {
      expect(engine.inflectNoun('der Kollege', GermanCase.accusative), equals('den Kollegen'));
      expect(engine.inflectNoun('der Kollege', GermanCase.dative), equals('dem Kollegen'));
      expect(engine.inflectNoun('der Name', GermanCase.genitive), equals('des Namens'));
      expect(engine.inflectNoun('der Herr', GermanCase.dative), equals('dem Herrn'));
    });

    test('Validator catches uninflected weak noun error in accusative', () {
      final report = engine.validateSentenceNoun(
        baseLemma: 'der Kollege',
        writtenNounForm: 'Kollege',
        targetCase: GermanCase.accusative,
        isPlural: false,
      );

      expect(report.isValid, isFalse);
      expect(report.isNAppliedCorrectly, isFalse);
      expect(report.issues, anyElement(contains('Morphologische Diskrepanz')));
    });

    test('Validator accepts correct N-declension inflection', () {
      final report = engine.validateSentenceNoun(
        baseLemma: 'der Kollege',
        writtenNounForm: 'Kollegen',
        targetCase: GermanCase.accusative,
        isPlural: false,
      );

      expect(report.isValid, isTrue);
      expect(report.isNAppliedCorrectly, isTrue);
      expect(report.issues, isEmpty);
    });

    test('UI Bridge filters and telemetry snapshot function accurately', () {
      final telemetry = uiBridge.getTelemetrySnapshot();
      expect(telemetry['totalNounEntries'], greaterThanOrEqualTo(14));
      expect(telemetry['legalLiabilityCompliance'], contains('Zero'));

      uiBridge.setClassFilter(NDeclensionClass.mixedClassWithNs);
      expect(
        uiBridge.currentFilteredList.every((e) => e.declensionClass == NDeclensionClass.mixedClassWithNs),
        isTrue,
      );

      uiBridge.clearFilters();
      expect(uiBridge.currentFilteredList.length, equals(engine.catalog.length));
    });
  });
}
