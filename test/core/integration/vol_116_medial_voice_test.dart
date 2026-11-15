import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/content/german_medial_voice_engine.dart';
import 'package:deutsch_build/src/ui/bridges/vol_116_wave32_ui_bridge.dart';

void main() {
  group('Volume 116 Task 4932 Medial Voice Engine Tests', () {
    test('LING-055: Facilitive medial converts to modal passive accurately', () {
      final res = GermanMedialVoiceEngine.constructMedial(
        subject: 'Das Buch',
        verbInfinitive: 'lesen',
        conjugatedVerb3rd: 'liest',
        partizipTwo: 'gelesen',
        qualifyingAdverb: 'leicht',
        type: MedialConstructionType.facilitiveMedial,
      );

      expect(res.medialSentence, equals('Das Buch liest sich leicht.'));
      expect(res.passiveModalParaphrase, equals('Das Buch kann leicht gelesen werden.'));
      expect(res.arabicEquivalence, contains('قابلية الفعل وسهولته'));
    });

    test('LING-055: Automatic inanimate medial constructs von selbst correctly', () {
      final res = GermanMedialVoiceEngine.constructMedial(
        subject: 'Die Tür',
        verbInfinitive: 'schließen',
        conjugatedVerb3rd: 'schließt',
        partizipTwo: 'geschlossen',
        qualifyingAdverb: 'von selbst',
        type: MedialConstructionType.automaticInanimate,
      );

      expect(res.medialSentence, equals('Die Tür schließt sich von selbst.'));
      expect(res.passiveModalParaphrase, contains('ohne äußeren Eingriff'));
    });

    test('LING-055: Impersonal evaluative medial constructs man-paraphrase', () {
      final res = GermanMedialVoiceEngine.constructMedial(
        subject: 'Hier',
        verbInfinitive: 'leben',
        conjugatedVerb3rd: 'lebt',
        partizipTwo: 'gelebt',
        qualifyingAdverb: 'angenehm',
        type: MedialConstructionType.impersonalEvaluative,
      );

      expect(res.medialSentence, equals('Hier lebt es sich angenehm.'));
      expect(res.passiveModalParaphrase, equals('Hier kann man angenehm leben.'));
    });

    test('UI Bridge generates accurate Task 4932 diagnostics report', () {
      final bridge = Vol116Wave32UIBridge();
      final report = bridge.getTask4932Diagnostics();

      expect(report['task_id'], equals(4932));
      expect(report['volume'], equals(116));
      expect(report['tasks_remaining_to_5000'], equals(68));
      expect(report['status'], equals('OPERATIONAL_VERIFIED'));
    });
  });
}
