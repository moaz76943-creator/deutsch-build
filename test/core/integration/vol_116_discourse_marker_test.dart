import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/content/german_discourse_marker_engine.dart';
import 'package:deutsch_build/src/ui/bridges/vol_116_wave11_ui_bridge.dart';

void main() {
  group('Volume 116 Task 4911 Discourse Marker Engine Tests', () {
    test('LING-034: also in Position 0 sets up conversational summary', () {
      final res = GermanDiscourseMarkerEngine.applyMarker(
        marker: 'Also',
        utterance: 'wir treffen uns heute um fünf Uhr.',
        position: MarkerPosition.preFieldZero,
      );

      expect(res.function, equals(DiscourseMarkerFunction.conversationalSummary));
      expect(res.pragmaticUtterance, equals('Also, wir treffen uns heute um fünf Uhr.'));
      expect(res.arabicEquivalence, contains('إذن'));
    });

    test('LING-034: na ja conveys qualified hesitation', () {
      final res = GermanDiscourseMarkerEngine.applyMarker(
        marker: 'Na ja',
        utterance: 'ganz zufrieden bin ich nicht.',
        position: MarkerPosition.preFieldZero,
      );

      expect(res.function, equals(DiscourseMarkerFunction.qualifiedHesitation));
      expect(res.pragmaticUtterance, equals('Na ja, ganz zufrieden bin ich nicht.'));
    });

    test('LING-034: sozusagen in Mittelfeld modifies predicate approximation', () {
      final res = GermanDiscourseMarkerEngine.applyMarker(
        marker: 'sozusagen',
        utterance: 'Er ist der Kopf der Gruppe.',
        position: MarkerPosition.middleField,
      );

      expect(res.function, equals(DiscourseMarkerFunction.metaphoricalApproximation));
      expect(res.pragmaticUtterance, equals('Er ist sozusagen der Kopf der Gruppe.'));
    });

    test('UI Bridge generates accurate Task 4911 diagnostics report', () {
      final bridge = Vol116Wave11UIBridge();
      final report = bridge.getTask4911Diagnostics();

      expect(report['task_id'], equals(4911));
      expect(report['volume'], equals(116));
      expect(report['tasks_remaining_to_5000'], equals(89));
      expect(report['status'], equals('OPERATIONAL_VERIFIED'));
    });
  });
}
