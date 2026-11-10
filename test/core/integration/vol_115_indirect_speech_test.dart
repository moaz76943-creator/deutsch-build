import 'package:test/test.dart';
import 'package:deutsch_build/src/core/content/german_indirect_speech_engine.dart';
import 'package:deutsch_build/src/ui/bridges/vol_115_wave7_ui_bridge.dart';

void main() {
  group('Volume 115 Task 4893 Indirect Speech Engine Tests', () {
    test('LING-016: 3rd person singular generates pure Konjunktiv I', () {
      final report = GermanIndirectSpeechEngine.reportUtterance(
        speaker: 'Der Arzt',
        verbInfinitive: 'sein',
        directQuote: 'er gesund',
      );

      expect(report.conjugatedVerb, equals('sei'));
      expect(report.appliedMood, equals(ReportedSpeechMood.konjunktiv1));
      expect(report.indirectSentence, equals('Der Arzt sagte, er gesund sei.'));
    });

    test('LING-016: 3rd person plural falls back to Konjunktiv II when ambiguous', () {
      final report = GermanIndirectSpeechEngine.reportUtterance(
        speaker: 'Die Zeugen',
        verbInfinitive: 'haben',
        directQuote: 'sie keine Zeit',
        isPluralSpeaker: true,
      );

      // "sie haben" is ambiguous with indicative -> fallback to "hätten"
      expect(report.conjugatedVerb, equals('hätten'));
      expect(report.appliedMood, equals(ReportedSpeechMood.fallbackKonjunktiv2));
    });

    test('UI Bridge generates accurate Task 4893 diagnostics report', () {
      final bridge = Vol115Wave7UIBridge();
      final report = bridge.getTask4893Diagnostics();

      expect(report['task_id'], equals(4893));
      expect(report['status'], equals('OPERATIONAL_VERIFIED'));
    });
  });
}
