import 'package:test/test.dart';
import 'package:deutsch_build/src/core/content/german_passive_substitutes_engine.dart';
import 'package:deutsch_build/src/ui/bridges/vol_116_wave5_ui_bridge.dart';

void main() {
  group('Volume 116 Task 4905 Passive Voice Substitutes Engine Tests', () {
    test('LING-028: sein + zu + Infinitiv converts to modal passive accurately', () {
      final res = GermanPassiveSubstitutesEngine.construct(
        subject: 'Die Aufgabe',
        verbInfinitive: 'lösen',
        partizipTwo: 'gelöst',
        type: PassiveSubstituteType.seinPlusZu,
        modal: UnderlyingModalMeaning.obligationMuss,
      );

      expect(res.substituteSentence, equals('Die Aufgabe ist zu lösen.'));
      expect(res.modalPassiveEquivalent, equals('Die Aufgabe muss gelöst werden.'));
      expect(res.arabicExplanation, contains('الوجوب'));
    });

    test('LING-028: sich lassen + Infinitiv conveys possibility', () {
      final res = GermanPassiveSubstitutesEngine.construct(
        subject: 'Das Problem',
        verbInfinitive: 'beheben',
        partizipTwo: 'behoben',
        type: PassiveSubstituteType.sichLassen,
        modal: UnderlyingModalMeaning.possibilityKann,
      );

      expect(res.substituteSentence, equals('Das Problem lässt sich beheben.'));
      expect(res.modalPassiveEquivalent, equals('Das Problem kann behoben werden.'));
    });

    test('LING-028: Adjectives ending in -bar convey passive potentiality', () {
      final res = GermanPassiveSubstitutesEngine.construct(
        subject: 'Der Text',
        verbInfinitive: 'übersetzen',
        partizipTwo: 'übersetzt',
        type: PassiveSubstituteType.adjectiveSuffix,
        modal: UnderlyingModalMeaning.possibilityKann,
        adjectiveRoot: 'übersetzbar',
      );

      expect(res.substituteSentence, equals('Der Text ist übersetzbar.'));
      expect(res.modalPassiveEquivalent, equals('Der Text kann übersetzt werden.'));
    });

    test('UI Bridge generates accurate Task 4905 diagnostics report', () {
      final bridge = Vol116Wave5UIBridge();
      final report = bridge.getTask4905Diagnostics();

      expect(report['task_id'], equals(4905));
      expect(report['volume'], equals(116));
      expect(report['tasks_remaining_to_5000'], equals(95));
      expect(report['status'], equals('OPERATIONAL_VERIFIED'));
    });
  });
}
