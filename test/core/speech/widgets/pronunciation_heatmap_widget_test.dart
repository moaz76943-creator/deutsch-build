import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/speech/gop_pronunciation_scorer.dart';
import 'package:deutsch_build/src/core/speech/widgets/pronunciation_heatmap_widget.dart';

void main() {
  group('PronunciationHeatmapWidget Tests', () {
    testWidgets('Renders all phonemes with appropriate color grading and triggers callback', (tester) async {
      PhonemeScore? tapped;
      const report = PronunciationReport(
        targetWord: 'Tag',
        overallScore: 82.0,
        isPass: true,
        phonemeScores: [
          PhonemeScore(phoneme: 't', score: 90.0, grade: PhonemeGrade.excellent),
          PhonemeScore(phoneme: 'aː', score: 85.0, grade: PhonemeGrade.excellent),
          PhonemeScore(phoneme: 'k', score: 71.0, grade: PhonemeGrade.good),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PronunciationHeatmapWidget(
              report: report,
              onPhonemeTap: (p) => tapped = p,
            ),
          ),
        ),
      );

      expect(find.text('t'), findsOneWidget);
      expect(find.text('aː'), findsOneWidget);
      expect(find.text('k'), findsOneWidget);
      expect(find.textContaining('82%'), findsOneWidget);

      await tester.tap(find.text('aː'));
      expect(tapped?.phoneme, equals('aː'));
    });
  });
}
