import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../../design_system/design_system.dart';
import 'notdienst_phrase_bank.dart';
import 'urgent_medical_terms.dart';

abstract final class NotdienstUiTokens {
  static const double pageInset = 16;
  static const double sectionGap = 16;
  static const double itemGap = 12;
  static const double compactGap = 8;
}

final class NotdienstDoctorScreen extends StatelessWidget {
  const NotdienstDoctorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final background =
        dark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = dark ? AppColors.darkSurface : AppColors.lightSurface;
    final border =
        dark ? AppColors.glassBorderDark : AppColors.glassBorderLight;
    const terms = UrgentMedicalTerms();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(NotdienstUiTokens.pageInset),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AppGlassCard(
                  backgroundColor: surface,
                  borderColor: AppColors.secondary,
                  glowColor: AppColors.secondary,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      AppDirectionalText(
                        '116 117 & Apotheken-Notdienst',
                        languageCode: 'de',
                        style: AppTypography.title.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(height: NotdienstUiTokens.compactGap),
                      AppDirectionalText(
                        'الطبيب والصيدلية المناوبة',
                        languageCode: 'ar',
                        style: AppTypography.title,
                      ),
                      const SizedBox(height: NotdienstUiTokens.compactGap),
                      AppDirectionalText(
                        '116 117 ist für dringende, nicht lebensbedrohliche Beschwerden außerhalb der regulären Sprechzeiten.',
                        languageCode: 'de',
                        style: AppTypography.body,
                      ),
                      AppDirectionalText(
                        'خدمة 116117 للحالات العاجلة غير المهددة للحياة خارج أوقات العيادات. عند الخطر المهدد للحياة اتصل بـ112.',
                        languageCode: 'ar',
                        style: AppTypography.body,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: NotdienstUiTokens.sectionGap),
                AppDirectionalText(
                  'Schnelle Sätze',
                  languageCode: 'de',
                  style: AppTypography.title,
                ),
                const SizedBox(height: NotdienstUiTokens.itemGap),
                for (var index = 0;
                    index < NotdienstPhraseBank.items.length;
                    index++) ...<Widget>[
                  _PhraseCard(
                    index: index,
                    surface: surface,
                    border: border,
                  ),
                  if (index != NotdienstPhraseBank.items.length - 1)
                    const SizedBox(height: NotdienstUiTokens.itemGap),
                ],
                const SizedBox(height: NotdienstUiTokens.sectionGap),
                AppGlassCard(
                  backgroundColor: surface,
                  borderColor: AppColors.tertiary,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      AppDirectionalText(
                        'Schmerzskala 0–10',
                        languageCode: 'de',
                        style: AppTypography.title,
                      ),
                      AppDirectionalText(
                        terms.painScalePhraseDe(8),
                        languageCode: 'de',
                        style: AppTypography.body,
                      ),
                      AppDirectionalText(
                        terms.painScalePhraseAr(8),
                        languageCode: 'ar',
                        style: AppTypography.body,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: NotdienstUiTokens.sectionGap),
                AppDirectionalText(
                  'Dringende medizinische Begriffe',
                  languageCode: 'de',
                  style: AppTypography.title,
                ),
                const SizedBox(height: NotdienstUiTokens.itemGap),
                for (var index = 0; index < terms.entries.length; index++) ...[
                  _TermCard(
                    entry: terms.entries[index],
                    surface: surface,
                    border: border,
                  ),
                  if (index != terms.entries.length - 1)
                    const SizedBox(height: NotdienstUiTokens.itemGap),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _PhraseCard extends StatelessWidget {
  const _PhraseCard({
    required this.index,
    required this.surface,
    required this.border,
  });

  final int index;
  final Color surface;
  final Color border;

  @override
  Widget build(BuildContext context) {
    final item = NotdienstPhraseBank.items[index];

    return AppGlassCard(
      backgroundColor: surface,
      borderColor: border,
      glowColor: AppColors.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppDirectionalText(
            item.titleDe,
            languageCode: 'de',
            style: AppTypography.title,
          ),
          AppDirectionalText(
            item.titleAr,
            languageCode: 'ar',
            style: AppTypography.label,
          ),
          const SizedBox(height: NotdienstUiTokens.compactGap),
          AppDirectionalText(
            item.german,
            languageCode: 'de',
            style: AppTypography.body,
          ),
          AppDirectionalText(
            item.arabic,
            languageCode: 'ar',
            style: AppTypography.body,
          ),
          const SizedBox(height: NotdienstUiTokens.compactGap),
          AppDirectionalText(
            item.explanationAr,
            languageCode: 'ar',
            style: AppTypography.label,
          ),
        ],
      ),
    );
  }
}

final class _TermCard extends StatelessWidget {
  const _TermCard({
    required this.entry,
    required this.surface,
    required this.border,
  });

  final UrgentMedicalTermEntry entry;
  final Color surface;
  final Color border;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        backgroundColor: surface,
        borderColor: border,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              entry.labelDe,
              languageCode: 'de',
              style: AppTypography.label.copyWith(
                color: AppColors.primary,
              ),
            ),
            AppDirectionalText(
              entry.labelAr,
              languageCode: 'ar',
              style: AppTypography.label,
            ),
            const SizedBox(height: NotdienstUiTokens.compactGap),
            AppDirectionalText(
              entry.exampleDe,
              languageCode: 'de',
              style: AppTypography.body,
            ),
            AppDirectionalText(
              entry.exampleAr,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}
