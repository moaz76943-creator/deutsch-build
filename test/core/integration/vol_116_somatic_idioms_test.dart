import 'package:test/test.dart';
import 'package:deutsch_build/src/core/content/german_somatic_idioms_engine.dart';
import 'package:deutsch_build/src/ui/bridges/vol_116_wave21_ui_bridge.dart';

void main() {
  group('Volume 116 Task 4921 Somatic Idioms Engine Tests', () {
    test('LING-044: Kopf idioms identified and translated accurately', () {
      final matches = GermanSomaticIdiomsEngine.detectIdioms(
        'In stressigen Momenten muss man einen kühlen Kopf bewahren.',
      );

      expect(matches.length, equals(1));
      expect(matches.first.bodyPart, equals(SomaticBodyPart.head));
      expect(matches.first.arabicEquivalence, contains('رباطة جأشه'));
      expect(matches.first.figurativeGermanMeaning, contains('ruhig'));
    });

    test('LING-044: Auge idioms convey leniency / tolerance', () {
      final matches = GermanSomaticIdiomsEngine.detectIdioms(
        'Der Prüfer wollte ein Auge zudrücken.',
      );

      expect(matches.length, equals(1));
      expect(matches.first.bodyPart, equals(SomaticBodyPart.eye));
      expect(matches.first.arabicEquivalence, contains('يغض الطرف'));
    });

    test('LING-044: Heart somatic idioms map emotional stances', () {
      final heartIdioms = GermanSomaticIdiomsEngine.getIdiomsByBodyPart(SomaticBodyPart.heart);
      expect(heartIdioms.length, greaterThanOrEqualTo(2));
      expect(heartIdioms.any((i) => i.germanIdiom.contains('gold')), isTrue);
    });

    test('UI Bridge generates accurate Task 4921 diagnostics report', () {
      final bridge = Vol116Wave21UIBridge();
      final report = bridge.getTask4921Diagnostics();

      expect(report['task_id'], equals(4921));
      expect(report['volume'], equals(116));
      expect(report['tasks_remaining_to_5000'], equals(79));
      expect(report['status'], equals('OPERATIONAL_VERIFIED'));
    });
  });
}
