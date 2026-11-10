import 'package:test/test.dart';
import 'package:deutsch_build/src/core/content/german_passive_voice_engine.dart';
import 'package:deutsch_build/src/ui/bridges/vol_115_wave6_ui_bridge.dart';

void main() {
  group('Volume 115 Task 4892 Passive Voice Engine Tests', () {
    test('LING-015: Vorgangspassiv Präsens transforms accurately with agent', () {
      final res = GermanPassiveVoiceEngine.transform(
        subject: 'dem Lehrer',
        directObject: 'Das Buch',
        verbInfinitive: 'lesen',
        partizipTwo: 'gelesen',
        type: PassiveType.vorgangspassiv,
        tense: PassiveTense.praesens,
      );

      expect(res.passiveSentence, equals('Das Buch wird von dem Lehrer gelesen.'));
    });

    test('LING-015: Vorgangspassiv Präteritum constructs wurde cluster', () {
      final res = GermanPassiveVoiceEngine.transform(
        subject: 'den Schülern',
        directObject: 'Die Aufgabe',
        verbInfinitive: 'erklären',
        partizipTwo: 'erklärt',
        type: PassiveType.vorgangspassiv,
        tense: PassiveTense.praeteritum,
      );

      expect(res.passiveSentence, equals('Die Aufgabe wurde von den Schülern erklärt.'));
    });

    test('LING-015: Zustandspassiv constructs static condition accurately', () {
      final res = GermanPassiveVoiceEngine.transform(
        subject: '',
        directObject: 'Das Fenster',
        verbInfinitive: 'schließen',
        partizipTwo: 'geschlossen',
        type: PassiveType.zustandspassiv,
        tense: PassiveTense.praesens,
        includeAgent: false,
      );

      expect(res.passiveSentence, equals('Das Fenster ist geschlossen.'));
    });

    test('UI Bridge generates accurate Task 4892 diagnostics report', () {
      final bridge = Vol115Wave6UIBridge();
      final report = bridge.getTask4892Diagnostics();

      expect(report['task_id'], equals(4892));
      expect(report['status'], equals('OPERATIONAL_VERIFIED'));
    });
  });
}
