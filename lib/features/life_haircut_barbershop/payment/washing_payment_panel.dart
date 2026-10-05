import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../../../design_system/design_system.dart';
import '../styles/haircut_phrase.dart';
import 'washing_payment_agent.dart';

final class WashingPaymentPanel extends StatelessWidget {
  const WashingPaymentPanel({
    required this.agent,
    this.level,
    super.key,
  });

  final WashingPaymentAgent agent;
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
        glowColor: AppColors.tertiary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'Waschen, Pflege & Kasse',
              languageCode: 'de',
              style: AppTypography.title.copyWith(color: AppColors.tertiary),
            ),
            const SizedBox(height: 6),
            AppDirectionalText(
              'الغسيل والعناية الأساسية والدفع',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
            const SizedBox(height: 12),
            for (var index = 0; index < phrases.length; index += 1) ...[
              _PaymentPhraseTile(phrase: phrases[index]),
              if (index != phrases.length - 1) const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

final class _PaymentPhraseTile extends StatelessWidget {
  const _PaymentPhraseTile({required this.phrase});

  final HaircutPhrase phrase;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.tertiary,
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
