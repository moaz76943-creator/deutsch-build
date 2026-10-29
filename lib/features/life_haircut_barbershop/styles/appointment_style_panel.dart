import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../../../design_system/design_system.dart';
import 'appointment_style_agent.dart';
import 'haircut_phrase.dart';

final class AppointmentStylePanel extends StatelessWidget {
  const AppointmentStylePanel({
    required this.agent,
    this.level,
    super.key,
  });

  final AppointmentStyleAgent agent;
  final HaircutLevel? level;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface = dark ? AppColors.darkSurface : AppColors.lightSurface;
    final border =
        dark ? AppColors.glassBorderDark : AppColors.glassBorderLight;
    final phrases = agent.search('', level: level);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AppGlassCard(
        backgroundColor: surface,
        borderColor: border,
        glowColor: AppColors.secondary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'Termin & klassischer Schnitt',
              languageCode: 'de',
              style: AppTypography.title.copyWith(color: AppColors.secondary),
            ),
            const SizedBox(height: 6),
            AppDirectionalText(
              'الموعد، القصة الكلاسيكية وتنسيق المظهر',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
            const SizedBox(height: 12),
            for (var index = 0; index < phrases.length; index += 1) ...[
              _PhraseTile(phrase: phrases[index]),
              if (index != phrases.length - 1) const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

final class _PhraseTile extends StatelessWidget {
  const _PhraseTile({required this.phrase});

  final HaircutPhrase phrase;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.secondary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              phrase.german,
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: 6),
            AppDirectionalText(
              phrase.arabic,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
            const SizedBox(height: 4),
            AppDirectionalText(
              '${phrase.level.label} · ${phrase.noteArabic}',
              languageCode: 'ar',
              style: AppTypography.label,
            ),
          ],
        ),
      );
}
