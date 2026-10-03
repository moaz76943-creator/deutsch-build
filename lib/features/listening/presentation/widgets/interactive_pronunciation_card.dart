import 'package:flutter/material.dart';

import '../../../../design_system/app_colors.dart';
import '../../../../design_system/app_glass_card.dart';
import '../../../../design_system/app_typography.dart';
import '../../domain/listening_models.dart';

class InteractivePronunciationCard extends StatelessWidget {
  const InteractivePronunciationCard({
    required this.feedback,
    required this.isRecording,
    required this.onRecord,
    super.key,
  });

  final PronunciationFeedback? feedback;
  final bool isRecording;
  final VoidCallback? onRecord;

  @override
  Widget build(BuildContext context) {
    final current = feedback;
    final accent = _feedbackColor(current);

    return AppGlassCard(
      borderColor: accent.withAlpha(90),
      glowColor: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text('تدريب النطق', style: AppTypography.title),
              ),
              FilledButton.icon(
                onPressed: isRecording ? null : onRecord,
                icon: isRecording
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.mic_none_rounded),
                label: Text(isRecording ? 'جاري التسجيل' : 'ابدأ'),
              ),
            ],
          ),
          if (current != null) ...<Widget>[
            const SizedBox(height: 14),
            if (current.phonemeAccuracyAvailable) ...<Widget>[
              _AccuracyBar(
                label: 'دقة الفونيمات',
                value: current.accuracy!,
                color: accent,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: current.phonemeMatches
                    .map((match) => _PhonemeChip(match: match))
                    .toList(growable: false),
              ),
            ] else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.info_outline_rounded, color: accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'دقة الفونيمات غير متاحة لهذا القياس.',
                      style: AppTypography.label,
                    ),
                  ),
                ],
              ),
            if (current.textAccuracy != null) ...<Widget>[
              const SizedBox(height: 10),
              _AccuracyBar(
                label: 'مطابقة النص المتعرّف عليه',
                value: current.textAccuracy!,
                color: AppColors.secondary,
              ),
            ],
            const SizedBox(height: 10),
            Text(current.messageArabic, style: AppTypography.body),
          ] else ...<Widget>[
            const SizedBox(height: 10),
            Text(
              'اسمع المقطع أولًا، ثم سجّل نطقك لمقارنة القياسات المتاحة.',
              style: AppTypography.body,
            ),
          ],
        ],
      ),
    );
  }

  Color _feedbackColor(PronunciationFeedback? current) {
    final score = current?.accuracy;
    if (current == null) return AppColors.primary;
    if (score == null) return AppColors.tertiary;
    if (score >= .85) return AppColors.mastery;
    if (score >= .6) return AppColors.xp;
    return AppColors.articleDie;
  }
}

class _AccuracyBar extends StatelessWidget {
  const _AccuracyBar({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final safe = value.clamp(0.0, 1.0).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: Text(label, style: AppTypography.label)),
            Text(
              '${(safe * 100).round()}%',
              style: AppTypography.label.copyWith(color: color),
            ),
          ],
        ),
        const SizedBox(height: 5),
        LinearProgressIndicator(
          value: safe,
          minHeight: 7,
          borderRadius: BorderRadius.circular(8),
          color: color,
        ),
      ],
    );
  }
}

class _PhonemeChip extends StatelessWidget {
  const _PhonemeChip({required this.match});

  final PronunciationPhonemeMatch match;

  @override
  Widget build(BuildContext context) {
    final color = match.matched ? AppColors.mastery : AppColors.articleDie;
    final observed = match.observed;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withAlpha(24),
        border: Border.all(color: color.withAlpha(100)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          observed == null || observed == match.target
              ? match.target
              : '${match.target} → $observed',
          textDirection: TextDirection.ltr,
          style: AppTypography.label.copyWith(color: color),
        ),
      ),
    );
  }
}
