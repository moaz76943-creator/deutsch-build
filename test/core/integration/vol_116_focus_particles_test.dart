import 'package:flutter_test/flutter_test.dart';
import '../../../lib/src/core/content/german_focus_particles_engine.dart';
import '../../../lib/src/ui/bridges/vol_116_wave45_ui_bridge.dart';

void main() {
  group('Task 4945: German Focus Particles & Scope Topography Engine Tests', () {
    late GermanFocusParticlesEngine engine;
    late Vol116Wave45UiBridge uiBridge;

    setUp(() {
      engine = GermanFocusParticlesEngine();
      uiBridge = Vol116Wave45UiBridge(engine: engine);
    });

    tearDown(() {
      uiBridge.dispose();
    });

    test('Engine catalog initializes with rich focus particle entries', () {
      expect(engine.catalog, isNotEmpty);
      expect(engine.catalog.length, greaterThanOrEqualTo(14));
    });

    test('Temporal scalar contrast accurately distinguishes erst vs. schon', () {
      final temporalEntries = engine.filterByCategory(FocusParticleCategory.temporalScalarContrast);
      expect(temporalEntries, isNotEmpty);
      final hasErst = temporalEntries.any((e) => e.particle == 'erst');
      final hasSchon = temporalEntries.any((e) => e.particle == 'schon');
      expect(hasErst, isTrue);
      expect(hasSchon, isTrue);
    });

    test('Negative polarity items enforce strict preceding negation', () {
      final npiEntries = engine.filterByCategory(FocusParticleCategory.negativePolarityScalar);
      expect(npiEntries, isNotEmpty);
      for (final item in npiEntries) {
        expect(item.polarityRequirementNote, contains('Negation'));
      }
    });

    test('Validator catches unnegated antecedent in geschweige denn', () {
      final report = engine.validateFocusConstruction(
        particleUsed: 'geschweige denn',
        isAntecedentNegated: false,
        isPlacedDirectlyBeforeFocus: true,
      );

      expect(report.isValid, isFalse);
      expect(report.respectsPolarityCondition, isFalse);
      expect(report.issues, anyElement(contains('Negationslizenzierung')));
    });

    test('Validator catches non-adjacent focus placement', () {
      final report = engine.validateFocusConstruction(
        particleUsed: 'sogar',
        isAntecedentNegated: true,
        isPlacedDirectlyBeforeFocus: false,
      );

      expect(report.isValid, isFalse);
      expect(report.isScopeAdjacencyCorrect, isFalse);
      expect(report.issues, anyElement(contains('Skopusplatzierung')));
    });

    test('Validator approves compliant focus particle construction', () {
      final report = engine.validateFocusConstruction(
        particleUsed: 'geschweige denn',
        isAntecedentNegated: true,
        isPlacedDirectlyBeforeFocus: true,
      );

      expect(report.isValid, isTrue);
      expect(report.issues, isEmpty);
    });

    test('UI Bridge filters and telemetry snapshot function accurately', () {
      final telemetry = uiBridge.getTelemetrySnapshot();
      expect(telemetry['totalFocusRules'], greaterThanOrEqualTo(14));
      expect(telemetry['legalLiabilityCompliance'], contains('Zero'));

      uiBridge.setCategoryFilter(FocusParticleCategory.additiveScalar);
      expect(
        uiBridge.currentFilteredList.every((e) => e.category == FocusParticleCategory.additiveScalar),
        isTrue,
      );

      uiBridge.clearFilters();
      expect(uiBridge.currentFilteredList.length, equals(engine.catalog.length));
    });
  });
}
