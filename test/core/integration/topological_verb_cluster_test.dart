import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_app/src/core/content/german_topological_verb_cluster_engine.dart';
import 'package:deutsch_app/src/ui/bridges/vol_116_wave74_ui_bridge.dart';

void main() {
  group('TopologicalVerbClusterEngine & Wave74UiBridge Tests (Task #4974)', () {
    late TopologicalVerbClusterEngine engine;
    late Vol116Wave74UiBridge bridge;

    setUp(() {
      engine = TopologicalVerbClusterEngine();
      bridge = Vol116Wave74UiBridge(engine: engine);
    });

    tearDown(() async {
      await bridge.dispose();
    });

    test('covers all 6 engineering domains with 16+ C1-C2 exemplars', () {
      expect(engine.allExemplars.length, greaterThanOrEqualTo(16));
      for (final domain in TopologicalEngineeringDomain.values) {
        expect(engine.getByDomain(domain), isNotEmpty,
            reason: 'Domain $domain should have at least one exemplar');
      }
    });

    test('detects past participle modal trap instead of Ersatzinfinitiv (IPP)', () {
      final result = engine.validateClusterSyntax(
        'Die Netzbetreiber griffen ein, weil man den Transformator abschalten gemusst hätte.',
      );
      expect(result.isValid, isFalse);
      expect(engine.telemetry.caughtPastParticipleModalTraps, equals(1));
    });

    test('detects delayed auxiliary after double infinitive in subordinate clause', () {
      final result = engine.validateClusterSyntax(
        'Der Testflug wurde verschoben, da die Pumpe kalibriert werden müssen hat.',
      );
      expect(result.isValid, isFalse);
      expect(engine.telemetry.caughtIppOrderErrors, equals(1));
    });

    test('detects mixing wenn with V1 conditional word order', () {
      final result = engine.validateClusterSyntax(
        'Wenn sollte der Wellengang zunehmen, greift das System ein.',
      );
      expect(result.isValid, isFalse);
      expect(engine.telemetry.caughtV1WordOrderErrors, equals(1));
    });

    test('accepts valid Oberfeldumstellung IPP and V1 conditional structures', () {
      final validIpp = engine.validateClusterSyntax(
        'Die Netzbetreiber griffen ein, weil man den Transformator hätte abschalten müssen.',
      );
      final validV1 = engine.validateClusterSyntax(
        'Sollte der Wellengang zunehmen, greift automatisch das Positionierungssystem.',
      );
      expect(validIpp.isValid, isTrue);
      expect(validV1.isValid, isTrue);
    });

    test('UI bridge emits reactive state updates on domain selection and validation', () async {
      final states = <Wave74TopologicalUiState>[];
      final sub = bridge.stateStream.listen(states.add);

      bridge.selectDomain(TopologicalEngineeringDomain.industrialRobotics);
      bridge.submitAttempt(
        'Die Linie lief weiter, obwohl die Steuerung den Arm neu anfahren gelassen hat.',
      );

      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(states.length, equals(2));
      expect(states.first.selectedDomain,
          equals(TopologicalEngineeringDomain.industrialRobotics));
      expect(states.last.lastValidation?.isValid, isFalse);
      await sub.cancel();
    });
  });
}
