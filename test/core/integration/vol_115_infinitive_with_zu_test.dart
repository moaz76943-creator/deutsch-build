import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/content/german_infinitive_with_zu_engine.dart';
import 'package:deutsch_build/src/ui/bridges/vol_115_wave13_ui_bridge.dart';

void main() {
  group('Volume 115 Task 4899 Infinitive with "zu" Engine Tests', () {
    test('LING-022: Standard verbs format with separate "zu"', () {
      final formatted = GermanInfinitiveWithZuEngine.formatVerbWithZu('lernen');
      expect(formatted, equals('zu lernen'));

      final res = GermanInfinitiveWithZuEngine.buildClause(
        matrixClause: 'Ich habe vor',
        infinitiveVerb: 'lernen',
        complement: 'Deutsch',
        type: InfinitiveConstructionType.standardZu,
      );
      expect(res.fullSentence, equals('Ich habe vor, Deutsch zu lernen.'));
      expect(res.isSeparable, isFalse);
    });

    test('LING-022: Separable verbs embed "zu" between prefix and stem', () {
      final formattedEinladen = GermanInfinitiveWithZuEngine.formatVerbWithZu('einladen');
      expect(formattedEinladen, equals('einzuladen'));

      final formattedAufstehen = GermanInfinitiveWithZuEngine.formatVerbWithZu('aufstehen');
      expect(formattedAufstehen, equals('aufzustehen'));

      final res = GermanInfinitiveWithZuEngine.buildClause(
        matrixClause: 'Er freut sich darauf',
        infinitiveVerb: 'einladen',
        complement: 'seine Freunde',
        type: InfinitiveConstructionType.standardZu,
      );
      expect(res.fullSentence, equals('Er freut sich darauf, seine Freunde einzuladen.'));
      expect(res.isSeparable, isTrue);
    });

    test('LING-022: Purpose clauses construct "um ... zu" correctly', () {
      final res = GermanInfinitiveWithZuEngine.buildClause(
        matrixClause: 'Ich lerne fleißig',
        infinitiveVerb: 'bestehen',
        complement: 'die Prüfung',
        type: InfinitiveConstructionType.purposeUmZu,
      );

      expect(res.fullSentence, equals('Ich lerne fleißig, um die Prüfung zu bestehen.'));
      expect(res.type, equals(InfinitiveConstructionType.purposeUmZu));
    });

    test('UI Bridge generates accurate Task 4899 diagnostics report', () {
      final bridge = Vol115Wave13UIBridge();
      final report = bridge.getTask4899Diagnostics();

      expect(report['task_id'], equals(4899));
      expect(report['status'], equals('OPERATIONAL_VERIFIED'));
      expect(report['separable_zu_embedding'], equals('ACTIVE'));
    });
  });
}
