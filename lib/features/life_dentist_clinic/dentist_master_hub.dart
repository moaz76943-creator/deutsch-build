import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../design_system/design_system.dart';
import 'dentist_master_orchestrator.dart';
import 'dentist_models.dart';

abstract final class _Ui {
  static const double inset = 16;
  static const double gap = 12;
  static const double bottom = 36;
}

final class DentistMasterHub extends StatefulWidget {
  const DentistMasterHub({required this.orchestrator, super.key});
  final DentistMasterOrchestrator orchestrator;

  @override
  State<DentistMasterHub> createState() => _DentistMasterHubState();
}

final class _DentistMasterHubState extends State<DentistMasterHub> {
  DentistCategory? _category;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface = dark ? AppColors.darkSurface : AppColors.lightSurface;
    final border =
        dark ? AppColors.glassBorderDark : AppColors.glassBorderLight;
    final items = widget.orchestrator.search(_query, category: _category);

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
                        'Zahnarztpraxis',
                        languageCode: 'de',
                        style: AppTypography.title.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      AppDirectionalText(
                        'تدريب لغوي للفحص الدوري وتنظيف الجير وتنظيم المواعيد في عيادة الأسنان.',
                        languageCode: 'ar',
                        style: AppTypography.body,
                      ),
                      AppDirectionalText(
                        'Sprachtraining – keine zahnärztliche Beratung.',
                        languageCode: 'de',
                        style: AppTypography.label.copyWith(
                          color: AppColors.tertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: _Ui.gap),
                AppGlassCard(
                  backgroundColor: surface,
                  borderColor: border,
                  child: Wrap(
                    spacing: _Ui.gap,
                    runSpacing: _Ui.gap,
                    children: <Widget>[
                      ChoiceChip(
                        label: const Text('Alle'),
                        selected: _category == null,
                        onSelected: (_) => setState(() => _category = null),
                      ),
                      for (final category in widget.orchestrator.categories)
                        ChoiceChip(
                          label: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              AppDirectionalText(
                                category.german,
                                languageCode: 'de',
                                style: AppTypography.label,
                              ),
                              AppDirectionalText(
                                category.arabic,
                                languageCode: 'ar',
                                style: AppTypography.label,
                              ),
                            ],
                          ),
                          selected: _category == category,
                          onSelected: (_) =>
                              setState(() => _category = category),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: _Ui.gap),
                AppGlassCard(
                  backgroundColor: surface,
                  borderColor: border,
                  glowColor: AppColors.secondary,
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: TextField(
                      onChanged: (value) => setState(() => _query = value),
                      style: AppTypography.body,
                      decoration: const InputDecoration(
                        hintText: 'Kontrolle / Zahnstein / Termin',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: _Ui.gap),
                for (final DentistPhrase item in items) ...<Widget>[
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
