import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_app/src/core/content/german_modal_particles_intersubjectivity_engine.dart';
import 'package:deutsch_app/src/ui/bridges/vol_116_wave55_ui_bridge.dart';

void main() {
  group('Task 4955: German Modal Particles & Intersubjectivity Architecture Tests', () {
    late GermanModalParticlesIntersubjectivityEngine engine;
    late Vol116Wave55UiBridge bridge;

    setUp(() {
      engine = GermanModalParticlesIntersubjectivityEngine();
      bridge = Vol116Wave55UiBridge(engine: engine);
    });

    tearDown(() {
      bridge.dispose();
    });

    test('Engine initializes complete professional catalog with >= 16 items', () {
      expect(engine.catalog.length, greaterThanOrEqualTo(16));
      for (final item in engine.catalog) {
        expect(item.id, startsWith('PART-4955-'));
        expect(item.modulatedSentence, contains(item.targetParticleChain));
        expect(item.pragmaticEffectGerman.isNotEmpty, isTrue);
        expect(item.pragmaticEffectArabic.isNotEmpty, isTrue);
        expect(item.commonGroundPresupposition.isNotEmpty, isTrue);
        expect(item.isUnaccentedMittelfeld, isTrue);
        expect(item.allowsVorfeldPlacement, isFalse);
      }
    });

    test('Engine covers all essential modal particles (ja, doch, denn, halt, eben, wohl, mal, schon, bloss, etwa)', () {
      for (final p in ModalParticleType.values) {
        final matches = engine.getByParticle(p);
        expect(matches.isNotEmpty, isTrue, reason: 'Particle ${p.name} must have at least one exemplar');
      }
    });

    test('Engine covers combinatorial particle chains (ja doch, halt eben, denn eigentlich, etc.)', () {
      final chains = engine.catalog.where((e) => e.targetParticleChain.contains(' ')).toList();
      expect(chains.length, greaterThanOrEqualTo(4));
    });

    test('Validation rejects modal particles placed in Vorfeld', () {
      final res = engine.validateParticleUsage(
        sentence: 'Ja wissen wir das.',
        particle: ModalParticleType.ja,
        isQuestion: false,
        isVorfeld: true,
      );
      expect(res.isValid, isFalse);
      expect(res.errorMessages.first, contains('Topologischer Verstoß'));
    });

    test('Validation enforces question requirement for modal etwa', () {
      final res = engine.validateParticleUsage(
        sentence: 'Sie haben etwa den Sensor getauscht.',
        particle: ModalParticleType.etwa,
        isQuestion: false,
        isVorfeld: false,
      );
      expect(res.isValid, isFalse);
      expect(res.errorMessages.first, contains('Entscheidungsfrage'));
    });

    test('Validation accepts valid unaccented Mittelfeld question with denn', () {
      final res = engine.validateParticleUsage(
        sentence: 'Wann beginnen denn die Schweißarbeiten?',
        particle: ModalParticleType.denn,
        isQuestion: true,
        isVorfeld: false,
      );
      expect(res.isValid, isTrue);
      expect(res.pragmaticNotes.isNotEmpty, isTrue);
    });

    test('UI Bridge correctly handles reactive streaming and filtering', () async {
      expect(bridge.state.isReady, isTrue);
      expect(bridge.state.activeExemplars.length, equals(engine.catalog.length));

      bridge.filterByParticle(ModalParticleType.doch);
      expect(bridge.state.selectedFilter, equals(ModalParticleType.doch));
      expect(bridge.state.activeExemplars.every((e) => e.particle == ModalParticleType.doch), isTrue);

      bridge.resetFilters();
      expect(bridge.state.selectedFilter, isNull);
      expect(bridge.state.activeExemplars.length, equals(engine.catalog.length));
    });

    test('Telemetry generation reflects exact domain and particle distribution', () {
      final telemetry = engine.generateTelemetrySnapshot();
      expect(telemetry['totalExemplars'], equals(engine.catalog.length));
      expect(telemetry['cefrLevel'], contains('C1-C2'));
      expect(telemetry['chainsCount'], greaterThanOrEqualTo(4));
    });
  });
}
