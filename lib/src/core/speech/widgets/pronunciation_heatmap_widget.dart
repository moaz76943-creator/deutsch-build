import 'package:flutter/material.dart';
import '../gop_pronunciation_scorer.dart';

/// Interactive UI widget visualizing phoneme-level GoP accuracy through a color heatmap.
class PronunciationHeatmapWidget extends StatelessWidget {
  final PronunciationReport report;
  final void Function(PhonemeScore phoneme)? onPhonemeTap;
  final double fontSize;

  const PronunciationHeatmapWidget({
    super.key,
    required this.report,
    this.onPhonemeTap,
    this.fontSize = 24.0,
  });

  Color _getColorForGrade(PhonemeGrade grade) {
    switch (grade) {
      case PhonemeGrade.excellent:
        return Colors.green;
      case PhonemeGrade.good:
        return Colors.teal;
      case PhonemeGrade.acceptable:
        return Colors.amber.shade700;
      case PhonemeGrade.poor:
        return Colors.redAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Wrap(
          spacing: 4.0,
          runSpacing: 6.0,
          alignment: WrapAlignment.center,
          children: report.phonemeScores.map((p) {
            final color = _getColorForGrade(p.grade);
            return InkWell(
              onTap: onPhonemeTap != null ? () => onPhonemeTap!(p) : null,
              borderRadius: BorderRadius.circular(6.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6.0),
                  border: Border.all(color: color, width: 1.5),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      p.phoneme,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      '${p.score.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: fontSize * 0.45,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8.0),
        Text(
          'الدرجة الكلية: ${report.overallScore.toStringAsFixed(0)}% ${report.isPass ? "✓" : "✗"}',
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
            color: report.isPass ? Colors.green.shade800 : Colors.redAccent,
          ),
        ),
      ],
    );
  }
}
