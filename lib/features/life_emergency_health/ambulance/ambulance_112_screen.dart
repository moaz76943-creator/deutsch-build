import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../../design_system/design_system.dart';
import 'ambulance_112_phrase_bank.dart';
import 'ambulance_112_w_questions.dart';

abstract final class Ambulance112UiTokens {
  static const double pageInset = 16;
  static const double sectionGap = 16;
  static const double itemGap = 12;
  static const double compactGap = 8;
}

final class Ambulance112Screen extends StatelessWidget {
  const Ambulance112Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final background =
        dark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = dark ? AppColors.darkSurface : AppColors.lightSurface;
    final border =
        dark ? AppColors.glassBorderDark : AppColors.glassBorderLight;
    const guide = Ambulance112WQuestions();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Ambulance112UiTokens.pageInset),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AppGlassCard(
                  backgroundColor: surface,
                  borderColor: AppColors.tertiary,
                  glowColor: AppColors.tertiary,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      AppDirectionalText(
                        'Notruf 112: klar und kurz sprechen',
                        languageCode: 'de',
                        style: AppTypography.title.copyWith(
                          color: AppColors.tertiary,
                        ),
                      ),
                      const SizedBox(height: Ambulance112UiTokens.compactGap),
                      AppDirectionalText(
                        'اتصال الإسعاف 112',
                        languageCode: 'ar',
                        style: AppTypography.title,
                      ),
                      const SizedBox(height: Ambulance112UiTokens.compactGap),
                      AppDirectionalText(
                        'Bei Lebensgefahr oder schweren Unfällen: 112. Bleiben Sie am Telefon und folgen Sie den Fragen der Leitstelle.',
                        languageCode: 'de',
                        style: AppTypography.body,
                      ),
                      AppDirectionalText(
                        'عند وجود خطر يهدد الحياة أو حادث شديد: اتصل بـ112 وابقَ على الهاتف واتبع أسئلة مركز الطوارئ.',
                        languageCode: 'ar',
                        style: AppTypography.body,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Ambulance112UiTokens.sectionGap),
                AppGlassCard(
                  backgroundColor: surface,
                  borderColor: border,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      AppDirectionalText(
                        'Anrufer nennen',
                        languageCode: 'de',
                        style: AppTypography.label,
                      ),
                      AppDirectionalText(
                        guide.callerIdentityDe,
                        languageCode: 'de',
                        style: AppTypography.body,
                      ),
                      AppDirectionalText(
                        guide.callerIdentityAr,
                        languageCode: 'ar',
                        style: AppTypography.body,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Ambulance112UiTokens.sectionGap),
                AppDirectionalText(
                  '5 W-Fragen',
                  languageCode: 'de',
                  style: AppTypography.title,
                ),
                const SizedBox(height: Ambulance112UiTokens.itemGap),
                for (var index = 0; index < guide.questions.length; index++) ...[
                  _WQuestionCard(
                    question: guide.questions[index],
                    surface: surface,
                    border: border,
                  ),
                  if (index != guide.questions.length - 1)
                    const SizedBox(height: Ambulance112UiTokens.itemGap),
                ],
                const SizedBox(height: Ambulance112UiTokens.sectionGap),
                AppDirectionalText(
                  'Akute Situationen',
                  languageCode: 'de',
                  style: AppTypography.title,
                ),
                const SizedBox(height: Ambulance112UiTokens.itemGap),
                for (var index = 0;
                    index < Ambulance112PhraseBank.items.length;
                    index++) ...[
                  _PhraseCard(
                    index: index,
                    surface: surface,
                    border: border,
                  ),
                  if (index != Ambulance112PhraseBank.items.length - 1)
                    const SizedBox(height: Ambulance112UiTokens.itemGap),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _WQuestionCard extends StatelessWidget {
  const _WQuestionCard({
    required this.question,
    required this.surface,
    required this.border,
  });

  final AmbulanceWQuestion question;
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
              question.keywordDe,
              languageCode: 'de',
              style: AppTypography.title.copyWith(
                color: AppColors.primary,
              ),
            ),
            AppDirectionalText(
              question.promptDe,
              languageCode: 'de',
              style: AppTypography.body,
            ),
            AppDirectionalText(
              question.promptAr,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
            const SizedBox(height: Ambulance112UiTokens.compactGap),
            AppDirectionalText(
              question.exampleDe,
              languageCode: 'de',
              style: AppTypography.label,
            ),
            AppDirectionalText(
              question.exampleAr,
              languageCode: 'ar',
              style: AppTypography.label,
            ),
          ],
        ),
      );
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
    final item = Ambulance112PhraseBank.items[index];

    return AppGlassCard(
      backgroundColor: surface,
      borderColor: border,
      glowColor: AppColors.tertiary,
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
          const SizedBox(height: Ambulance112UiTokens.compactGap),
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
          const SizedBox(height: Ambulance112UiTokens.compactGap),
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
