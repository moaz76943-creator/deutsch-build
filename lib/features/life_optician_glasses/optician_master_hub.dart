import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../design_system/design_system.dart';
import 'optician_master_orchestrator.dart';
import 'optician_models.dart';

abstract final class _Ui {
  static const double inset = 16;
  static const double gap = 12;
  static const double bottom = 36;
}

final class OpticianMasterHub extends StatefulWidget {
  const OpticianMasterHub({required this.orchestrator, super.key});

  final OpticianMasterOrchestrator orchestrator;

  @override
  State<OpticianMasterHub> createState() => _OpticianMasterHubState();
}

final class _OpticianMasterHubState extends State<OpticianMasterHub> {
  OpticianCategory? _category;
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
                        'Optiker & Brille',
                        languageCode: 'de',
                        style: AppTypography.title.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: _Ui.gap),
                      AppDirectionalText(
                        'تدريب لغوي لفحص النظر وقياسات العدسات واختيار النظارة وتفصيلها.',
                        languageCode: 'ar',
                        style: AppTypography.body,
                      ),
                      AppDirectionalText(
                        'Sprachtraining – keine augenärztliche Diagnose.',
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
                        hintText: 'Sehtest / Pupillendistanz / عدسات',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: _Ui.gap),
                for (final item in items) ...<Widget>[
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
