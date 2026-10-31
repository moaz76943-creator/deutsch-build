import 'package:flutter/material.dart';

import '../../../../design_system/app_colors.dart';
import '../../../../design_system/app_glass_card.dart';
import '../../../../design_system/app_typography.dart';

class ExplainWhyFeedbackCard extends StatelessWidget {
  const ExplainWhyFeedbackCard({
    required this.explanation,
    required this.reasonCode,
    required this.correct,
    super.key,
  });

  final String explanation;
  final String reasonCode;
  final bool correct;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        key: const Key('explain-why-feedback-card'),
        glowColor: correct ? AppColors.mastery : AppColors.tertiary,
        child: Semantics(
          container: true,
          label: 'لماذا؟ $explanation',
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                correct
                    ? Icons.check_circle_rounded
                    : Icons.lightbulb_outline_rounded,
                color: correct ? AppColors.mastery : AppColors.tertiary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    AppDirectionalText(
                      'لماذا؟',
                      languageCode: 'ar',
                      style: AppTypography.label.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    AppDirectionalText(
                      explanation,
                      languageCode: 'ar',
                      style: AppTypography.body,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
