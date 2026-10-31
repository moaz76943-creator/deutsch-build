import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../../design_system/design_system.dart';
import '../drogerie_models.dart';
import 'household_cleaning_agent.dart';

abstract final class _Ui {
  static const double inset = 16;
  static const double gap = 12;
  static const double bottom = 36;
}

final class HouseholdCleaningScreen extends StatefulWidget {
  const HouseholdCleaningScreen({required this.agent, super.key});
  final HouseholdCleaningAgent agent;

  @override
  State<HouseholdCleaningScreen> createState() => _State();
}

final class _State extends State<HouseholdCleaningScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface = dark ? AppColors.darkSurface : AppColors.lightSurface;
    final border =
        dark ? AppColors.glassBorderDark : AppColors.glassBorderLight;
    final items = widget.agent.search(_query);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            dark ? AppColors.darkBackground : AppColors.lightBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              _Ui.inset,
              _Ui.inset,
              _Ui.inset,
              _Ui.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AppGlassCard(
                  backgroundColor: surface,
                  borderColor: border,
                  glowColor: AppColors.primary,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      AppDirectionalText(
                        'Haushalt & Reinigung',
                        languageCode: 'de',
                        style: AppTypography.title.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      AppDirectionalText(
                        'لغة عملية لاختيار منظفات الغسيل والتنظيف ومزيلات التكلس وقراءة تعليمات الجرعة وإعادة التعبئة.',
                        languageCode: 'ar',
                        style: AppTypography.body,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: _Ui.gap),
                AppGlassCard(
                  backgroundColor: surface,
                  borderColor: border,
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: TextField(
                      onChanged: (value) => setState(() => _query = value),
                      style: AppTypography.body,
                      decoration: const InputDecoration(
                        hintText: 'Waschmittel / Entkalker / Dosierung',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: _Ui.gap),
                for (final DrogeriePhrase item in items) ...<Widget>[
                  AppGlassCard(
                    backgroundColor: surface,
                    borderColor: border,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        AppDirectionalText(
                          item.german,
                          languageCode: 'de',
                          style: AppTypography.body,
                        ),
                        const SizedBox(height: _Ui.gap),
                        AppDirectionalText(
                          item.arabic,
                          languageCode: 'ar',
                          style: AppTypography.body,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: _Ui.gap),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
