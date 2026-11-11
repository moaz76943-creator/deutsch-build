import 'package:test/test.dart';
import 'package:deutsch_build/src/core/content/german_phonological_auditor_engine.dart';
import 'package:deutsch_build/src/ui/bridges/vol_116_wave19_ui_bridge.dart';

void main() {
  group('Volume 116 Task 4919 Phonological Auditor Engine Tests', () {
    test('LING-042: Auslautverhärtung converts terminal d into t', () {
      final res = GermanPhonologicalAuditorEngine.auditPronunciation('Hund');

      expect(res.hasTerminalDevoicing, isTrue);
      expect(res.appliedRules.contains(PhonologicalRuleType.auslautverhaertungDevoicing), isTrue);
      expect(res.phoneticIpaTranscription, equals('[hunt]'));
      expect(res.arabicPronunciationGuidance, contains('تحول صوت (d) في نهاية الكلمة إلى (t)'));
    });

    test('LING-042: Auslautverhärtung converts terminal g into k and b into p', () {
      final resTag = GermanPhonologicalAuditorEngine.auditPronunciation('Tag');
      expect(resTag.phoneticIpaTranscription, equals('[tak]'));

      final resAb = GermanPhonologicalAuditorEngine.auditPronunciation('ab');
      expect(resAb.hasTerminalDevoicing, isTrue);
      expect(resAb.hasGlottalStop, isTrue); // Starts with vowel -> Knacklaut
      expect(resAb.phoneticIpaTranscription, equals('[ʔap]'));
    });

    test('LING-042: Knacklaut correctly added before initial vowel', () {
      final resApfel = GermanPhonologicalAuditorEngine.auditPronunciation('Apfel');
      expect(resApfel.hasGlottalStop, isTrue);
      expect(resApfel.phoneticIpaTranscription.startsWith('[ʔ'), isTrue);
      expect(resApfel.arabicPronunciationGuidance, contains('همزة قطع'));
    });

    test('UI Bridge generates accurate Task 4919 diagnostics report', () {
      final bridge = Vol116Wave19UIBridge();
      final report = bridge.getTask4919Diagnostics();

      expect(report['task_id'], equals(4919));
      expect(report['volume'], equals(116));
      expect(report['audit_mode'], equals('STRICT_CRITICAL_PHONETIC_VERIFICATION'));
      expect(report['tasks_remaining_to_5000'], equals(81));
      expect(report['status'], equals('OPERATIONAL_VERIFIED'));
    });
  });
}
