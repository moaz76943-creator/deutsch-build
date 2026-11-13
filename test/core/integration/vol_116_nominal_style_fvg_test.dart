import 'package:test/test.dart';
import 'package:deutsch_app/src/core/content/german_nominal_style_fvg_engine.dart';
import 'package:deutsch_app/src/ui/bridges/vol_116_wave64_ui_bridge.dart';

void main() {
  group('Task 4964: German Nominal Style & FVG Deconstruction Architecture Tests', () {
    late GermanNominalStyleFvgEngine engine;
    late Vol116Wave64UiBridge bridge;

    setUp(() {
      engine = GermanNominalStyleFvgEngine();
      bridge = Vol116Wave64UiBridge(engine: engine);
    });

    tearDown(() {
      bridge.dispose();
    });

    test('Engine initializes complete professional catalog with >= 16 items', () {
      expect(engine.catalog.length, greaterThanOrEqualTo(16));
      for (final item in engine.catalog) {
        expect(item.id, startsWith('FVG-4964-'));
        expect(item.fvgExpression.isNotEmpty, isTrue);
        expect(item.baseVerbEquivalent.isNotEmpty, isTrue);
        expect(item.nominalStyleSentence.isNotEmpty, isTrue);
        expect(item.verbalizedPlainSentence.isNotEmpty, isTrue);
        expect(item.operationalContextGerman.isNotEmpty, isTrue);
        expect(item.operationalContextArabic.isNotEmpty, isTrue);
        expect(item.prepositionalRektionRule.isNotEmpty, isTrue);
      }
    });

    test('Engine covers all essential FVG Aktionsart types (Inchoativ, Durativ, Terminativ, etc.)', () {
      for (final akt in FvgAktionsartType.values) {
        final matches = engine.getByAktionsart(akt);
        expect(matches.isNotEmpty, isTrue, reason: 'Aktionsart ${akt.name} must have at least one exemplar');
      }
    });

    test('Engine covers various prepositional rections (in+Akk, in+Dat, zu+Dat, unter+Dat, etc.)', () {
      for (final rek in PrepositionalRektionCase.values) {
        final matches = engine.getByRektionCase(rek);
        expect(matches.isNotEmpty, isTrue, reason: 'Rektion ${rek.name} must have at least one exemplar');
      }
    });

    test('Validation rejects incorrect prepositional rections', () {
      final invalidRes = engine.validateFvgStructure(
        fvgExpression: 'in Beweis stellen', // Illegal! Must be "unter Beweis stellen"
        rektionCase: PrepositionalRektionCase.inPlusAccusative,
        isPrepositionCorrect: false,
        isVerbalAlternativeEquipollent: true,
      );
      expect(invalidRes.isValid, isFalse);
      expect(invalidRes.issues.first, contains('Rektionsfehler'));
    });

    test('Validation approves compliant FVG and verbalization pairing', () {
      final validRes = engine.validateFvgStructure(
        fvgExpression: 'in Betrieb nehmen',
        rektionCase: PrepositionalRektionCase.inPlusAccusative,
        isPrepositionCorrect: true,
        isVerbalAlternativeEquipollent: true,
      );
      expect(validRes.isValid, isTrue);
      expect(validRes.stylisticNotes.isNotEmpty, isTrue);
    });

    test('UI Bridge correctly handles reactive streaming and filtering', () async {
      expect(bridge.state.isReady, isTrue);
      expect(bridge.state.activeExemplars.length, equals(engine.catalog.length));

      bridge.filterByAktionsart(FvgAktionsartType.inchoativeStateEntry);
      expect(bridge.state.selectedAktionsart, equals(FvgAktionsartType.inchoativeStateEntry));
      expect(
        bridge.state.activeExemplars.every((f) => f.aktionsartType == FvgAktionsartType.inchoativeStateEntry),
        isTrue,
      );

      bridge.resetFilters();
      expect(bridge.state.selectedAktionsart, isNull);
      expect(bridge.state.activeExemplars.length, equals(engine.catalog.length));
    });

    test('Telemetry generation reflects exact domain and FVG distribution', () {
      final telemetry = engine.generateTelemetrySnapshot();
      expect(telemetry['totalExemplars'], equals(engine.catalog.length));
      expect(telemetry['cefrLevel'], contains('C1-C2'));
      expect(telemetry['aktionsartDistribution'], isA<Map>());
    });
  });
}
