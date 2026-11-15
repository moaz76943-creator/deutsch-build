import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_app/src/core/content/german_temporal_subordination_aspect_engine.dart';
import 'package:deutsch_app/src/ui/bridges/vol_116_wave60_ui_bridge.dart';

void main() {
  group('Task 4960: German Complex Temporal Subordination Architecture Tests', () {
    late GermanTemporalSubordinationAspectEngine engine;
    late Vol116Wave60UiBridge bridge;

    setUp(() {
      engine = GermanTemporalSubordinationAspectEngine();
      bridge = Vol116Wave60UiBridge(engine: engine);
    });

    tearDown(() {
      bridge.dispose();
    });

    test('Engine initializes complete professional catalog with >= 16 items', () {
      expect(engine.catalog.length, greaterThanOrEqualTo(16));
      for (final item in engine.catalog) {
        expect(item.id, startsWith('TEMP-4960-'));
        expect(item.fullGermanSentence.isNotEmpty, isTrue);
        expect(item.subordinateClause.isNotEmpty, isTrue);
        expect(item.mainClause.isNotEmpty, isTrue);
        expect(item.aspectualAnchoringExplanationGerman.isNotEmpty, isTrue);
        expect(item.aspectualAnchoringExplanationArabic.isNotEmpty, isTrue);
        expect(item.safetySequenceRelevance.isNotEmpty, isTrue);
      }
    });

    test('Engine covers all temporal relation types (Vorzeitigkeit, Gleichzeitigkeit, etc.)', () {
      for (final rel in TemporalRelationType.values) {
        final matches = engine.getByRelation(rel);
        expect(matches.isNotEmpty, isTrue, reason: 'Relation ${rel.name} must have at least one exemplar');
      }
    });

    test('Engine covers essential consecutio temporum combinations', () {
      for (final c in ConsecutioTemporumPair.values) {
        final matches = engine.getByConsecutio(c);
        expect(matches.isNotEmpty, isTrue, reason: 'Consecutio ${c.name} must have at least one exemplar');
      }
    });

    test('Validation enforces Plusquamperfekt with nachdem when main clause is in Präteritum', () {
      final invalidRes = engine.validateConsecutioTemporum(
        subordinator: 'nachdem',
        subordinateTense: 'praeteritum', // Illegal!
        mainTense: 'praeteritum',
      );
      expect(invalidRes.isValid, isFalse);
      expect(invalidRes.issues.first, contains('Zeitenfolge-Verstoß'));

      final validRes = engine.validateConsecutioTemporum(
        subordinator: 'nachdem',
        subordinateTense: 'plusquamperfekt',
        mainTense: 'praeteritum',
      );
      expect(validRes.isValid, isTrue);
      expect(validRes.grammarNotes.isNotEmpty, isTrue);
    });

    test('Validation enforces tense identity for während / solange', () {
      final invalidRes = engine.validateConsecutioTemporum(
        subordinator: 'während',
        subordinateTense: 'praeteritum',
        mainTense: 'praesens', // Tense mismatch!
      );
      expect(invalidRes.isValid, isFalse);
      expect(invalidRes.issues.first, contains('Gleichzeitigkeits-Fehler'));

      final validRes = engine.validateConsecutioTemporum(
        subordinator: 'während',
        subordinateTense: 'praeteritum',
        mainTense: 'praeteritum',
      );
      expect(validRes.isValid, isTrue);
    });

    test('Validation prohibits Plusquamperfekt with bevor / ehe', () {
      final invalidRes = engine.validateConsecutioTemporum(
        subordinator: 'bevor',
        subordinateTense: 'plusquamperfekt',
        mainTense: 'praeteritum',
      );
      expect(invalidRes.isValid, isFalse);
      expect(invalidRes.issues.first, contains('Nachzeitigkeits-Fehler'));
    });

    test('UI Bridge correctly handles reactive streaming and filtering', () async {
      expect(bridge.state.isReady, isTrue);
      expect(bridge.state.activeExemplars.length, equals(engine.catalog.length));

      bridge.filterByRelation(TemporalRelationType.anteriorityVorzeitigkeit);
      expect(bridge.state.selectedRelation, equals(TemporalRelationType.anteriorityVorzeitigkeit));
      expect(
        bridge.state.activeExemplars.every((t) => t.temporalRelation == TemporalRelationType.anteriorityVorzeitigkeit),
        isTrue,
      );

      bridge.resetFilters();
      expect(bridge.state.selectedRelation, isNull);
      expect(bridge.state.activeExemplars.length, equals(engine.catalog.length));
    });

    test('Telemetry generation reflects exact domain and temporal distribution', () {
      final telemetry = engine.generateTelemetrySnapshot();
      expect(telemetry['totalExemplars'], equals(engine.catalog.length));
      expect(telemetry['cefrLevel'], contains('C1-C2'));
      expect(telemetry['relationDistribution'], isA<Map>());
    });
  });
}
