import 'package:test/test.dart';
import 'package:deutsch_build/src/core/content/german_prosodic_intonation_engine.dart';
import 'package:deutsch_build/src/ui/bridges/vol_116_wave20_ui_bridge.dart';

void main() {
  group('Volume 116 Task 4920 Prosodic Intonation Engine Tests', () {
    test('LING-043: Ja/Nein questions trigger rising interrogative contour', () {
      final res = GermanProsodicIntonationEngine.computeIntonationContour('Kommst du morgen mit?');

      expect(res.contourType, equals(IntonationContourType.interrogativeRising));
      expect(res.relativePitchPoints.last, greaterThan(res.relativePitchPoints.first));
      expect(res.arabicProsodicExplanation, contains('صاعدة'));
    });

    test('LING-043: W-Questions trigger terminal falling contour in German', () {
      final res = GermanProsodicIntonationEngine.computeIntonationContour('Wo wohnst du?');

      expect(res.contourType, equals(IntonationContourType.terminalFalling));
      expect(res.relativePitchPoints.last, lessThan(res.relativePitchPoints.first));
      expect(res.arabicProsodicExplanation, contains('W-Frage'));
    });

    test('LING-043: Declarative statements trigger terminal falling pitch track', () {
      final res = GermanProsodicIntonationEngine.computeIntonationContour('Ich lerne heute Deutsch.');

      expect(res.contourType, equals(IntonationContourType.terminalFalling));
      expect(res.relativePitchPoints.last, equals(0.2));
    });

    test('UI Bridge generates accurate Task 4920 diagnostics report', () {
      final bridge = Vol116Wave20UIBridge();
      final report = bridge.getTask4920Diagnostics();

      expect(report['task_id'], equals(4920));
      expect(report['volume'], equals(116));
      expect(report['tasks_remaining_to_5000'], equals(80));
      expect(report['status'], equals('OPERATIONAL_VERIFIED'));
    });
  });
}
