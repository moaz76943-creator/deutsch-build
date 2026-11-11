import 'package:test/test.dart';
import 'package:deutsch_build/src/core/content/german_directional_adverbs_engine.dart';
import 'package:deutsch_build/src/ui/bridges/vol_116_wave25_ui_bridge.dart';

void main() {
  group('Volume 116 Task 4925 Directional Adverbs Engine Tests', () {
    test('LING-048: herein represents motion inward towards speaker', () {
      final res = GermanDirectionalAdverbsEngine.computeDirectionalCompound(
        orientation: DeicticOrientation.towardsSpeaker,
        trajectory: SpatialTrajectory.inward,
        subject: 'Komm',
        movementVerb: 'bitte',
      );

      expect(res.formalStandardForm, equals('herein'));
      expect(res.spokenContraction, equals('rein'));
      expect(res.sampleSentence, equals('Komm bitte herein.'));
      expect(res.arabicEquivalence, contains('ادخل إلى هنا'));
    });

    test('LING-048: hinaus represents motion outward away from speaker', () {
      final res = GermanDirectionalAdverbsEngine.computeDirectionalCompound(
        orientation: DeicticOrientation.awayFromSpeaker,
        trajectory: SpatialTrajectory.outward,
        subject: 'Geh',
        movementVerb: 'sofort',
      );

      expect(res.formalStandardForm, equals('hinaus'));
      expect(res.spokenContraction, equals('raus'));
      expect(res.sampleSentence, equals('Geh sofort hinaus.'));
      expect(res.arabicEquivalence, contains('اخرج إلى هناك'));
    });

    test('LING-048: Upward trajectory generates herauf vs hinauf correctly', () {
      final herauf = GermanDirectionalAdverbsEngine.computeDirectionalCompound(
        orientation: DeicticOrientation.towardsSpeaker,
        trajectory: SpatialTrajectory.upward,
      );
      expect(herauf.formalStandardForm, equals('herauf'));

      final hinauf = GermanDirectionalAdverbsEngine.computeDirectionalCompound(
        orientation: DeicticOrientation.awayFromSpeaker,
        trajectory: SpatialTrajectory.upward,
      );
      expect(hinauf.formalStandardForm, equals('hinauf'));
    });

    test('UI Bridge generates accurate Task 4925 diagnostics report', () {
      final bridge = Vol116Wave25UIBridge();
      final report = bridge.getTask4925Diagnostics();

      expect(report['task_id'], equals(4925));
      expect(report['volume'], equals(116));
      expect(report['tasks_remaining_to_5000'], equals(75));
      expect(report['status'], equals('OPERATIONAL_VERIFIED'));
    });
  });
}
