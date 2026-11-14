import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/dialogue/cefr_dialogue_classifier.dart';

void main() {
  group('CefrDialogueClassifier Tests', () {
    const classifier = CefrDialogueClassifier();

    test('Classifies basic A1 greeting sentence', () {
      final res = classifier.classifyUtterance('Hallo, ich heiße Thomas und komme aus Deutschland.');

      expect(res.detectedLevel, equals(CefrGrade.a1));
      expect(res.structuralComplexityScore, lessThanOrEqualTo(1.5));
    });

    test('Identifies B1 subordinate clause construction with "weil"', () {
      final res = classifier.classifyUtterance('Ich kann heute nicht kommen, weil ich arbeiten muss.');

      expect(res.detectedLevel, equals(CefrGrade.b1));
      expect(res.detectedGrammarMarkers.any((m) => m.contains('B1 Subordinate')), isTrue);
    });

    test('Detects B2 Konjunktiv and passive voice complexity', () {
      final res = classifier.classifyUtterance('Obwohl das Paket gestern verschickt wurde, wäre eine frühere Benachrichtigung besser gewesen.');

      expect(res.detectedLevel, equals(CefrGrade.b2));
      expect(res.structuralComplexityScore, greaterThanOrEqualTo(3.5));
    });

    test('Detects C1 academic discourse connectors', () {
      final res = classifier.classifyUtterance('Infolgedessen sei darauf hingewiesen, dass die Vereinbarung zustande gekommen ist.');

      expect(res.detectedLevel, equals(CefrGrade.c1));
      expect(res.detectedGrammarMarkers.any((m) => m.contains('C1')), isTrue);
    });
  });
}
