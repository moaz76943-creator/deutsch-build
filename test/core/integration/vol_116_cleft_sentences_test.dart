import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_app/src/core/content/german_cleft_sentences_engine.dart';
import 'package:deutsch_app/src/ui/bridges/vol_116_wave59_ui_bridge.dart';

void main() {
  group('Task 4959: German Cleft & Pseudo-Cleft Architecture Tests', () {
    late GermanCleftSentencesEngine engine;
    late Vol116Wave59UiBridge bridge;

    setUp(() {
      engine = GermanCleftSentencesEngine();
      bridge = Vol116Wave59UiBridge(engine: engine);
    });

    tearDown(() {
      bridge.dispose();
    });

    test('Engine initializes complete professional catalog with >= 16 items', () {
      expect(engine.catalog.length, greaterThanOrEqualTo(16));
      for (final item in engine.catalog) {
        expect(item.id, startsWith('CLEFT-4959-'));
        expect(item.baseUncleftSentence.isNotEmpty, isTrue);
        expect(item.cleftedGermanSentence.isNotEmpty, isTrue);
        expect(item.cleftFocusConstituent.isNotEmpty, isTrue);
        expect(item.relativeClausePresupposition.isNotEmpty, isTrue);
        expect(item.pragmaticExhaustivityGerman.isNotEmpty, isTrue);
        expect(item.pragmaticExhaustivityArabic.isNotEmpty, isTrue);
        expect(item.copulaNumberAgreementRule.isNotEmpty, isTrue);
      }
    });

    test('Engine covers all cleft construction types', () {
      for (final type in CleftConstructionType.values) {
        final matches = engine.getByType(type);
        expect(matches.isNotEmpty, isTrue, reason: 'Type ${type.name} must have at least one exemplar');
      }
    });

    test('Engine covers all focus categories', () {
      for (final cat in CleftFocusCategory.values) {
        final matches = engine.getByFocusCategory(cat);
        expect(matches.isNotEmpty, isTrue, reason: 'Category ${cat.name} must have at least one exemplar');
      }
    });

    test('Engine includes plural-focus clefts verifying copula agreement', () {
      final pluralClefts = engine.catalog.where((c) => c.isPluralFocus).toList();
      expect(pluralClefts.length, greaterThanOrEqualTo(4));
      for (final pc in pluralClefts) {
        expect(
          pc.cleftedGermanSentence.contains('sind') || pc.cleftedGermanSentence.contains('waren'),
          isTrue,
          reason: 'Plural cleft must use plural copula (sind/waren)',
        );
      }
    });

    test('Validation rejects singular copula for plural focus in it-clefts', () {
      final res = engine.validateCleftStructure(
        type: CleftConstructionType.itCleftClassicalSpaltsatz,
        isPluralFocus: true,
        copulaIsPlural: false,
        relativePronounAgreementCompliant: true,
      );
      expect(res.isValid, isFalse);
      expect(res.issues.first, contains('Kongruenzfehler'));
    });

    test('Validation rejects relative pronoun mismatch', () {
      final res = engine.validateCleftStructure(
        type: CleftConstructionType.itCleftClassicalSpaltsatz,
        isPluralFocus: false,
        copulaIsPlural: false,
        relativePronounAgreementCompliant: false,
      );
      expect(res.isValid, isFalse);
      expect(res.issues.first, contains('Relativpronomen-Fehler'));
    });

    test('Validation approves fully compliant cleft configuration', () {
      final res = engine.validateCleftStructure(
        type: CleftConstructionType.itCleftClassicalSpaltsatz,
        isPluralFocus: true,
        copulaIsPlural: true,
        relativePronounAgreementCompliant: true,
      );
      expect(res.isValid, isTrue);
      expect(res.syntaxNotes.isNotEmpty, isTrue);
    });

    test('UI Bridge correctly handles reactive streaming and filtering', () async {
      expect(bridge.state.isReady, isTrue);
      expect(bridge.state.activeExemplars.length, equals(engine.catalog.length));

      bridge.filterByType(CleftConstructionType.whPseudoCleftFreeRelative);
      expect(bridge.state.selectedType, equals(CleftConstructionType.whPseudoCleftFreeRelative));
      expect(
        bridge.state.activeExemplars.every((c) => c.constructionType == CleftConstructionType.whPseudoCleftFreeRelative),
        isTrue,
      );

      bridge.resetFilters();
      expect(bridge.state.selectedType, isNull);
      expect(bridge.state.activeExemplars.length, equals(engine.catalog.length));
    });

    test('Telemetry generation reflects exact domain and cleft distribution', () {
      final telemetry = engine.generateTelemetrySnapshot();
      expect(telemetry['totalExemplars'], equals(engine.catalog.length));
      expect(telemetry['cefrLevel'], contains('C1-C2'));
      expect(telemetry['pluralFocusCount'], greaterThanOrEqualTo(4));
    });
  });
}
