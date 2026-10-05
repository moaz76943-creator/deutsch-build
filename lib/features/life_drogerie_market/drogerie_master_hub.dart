import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../design_system/design_system.dart';
import 'drogerie_master_orchestrator.dart';
import 'drogerie_models.dart';

abstract final class _Ui {
  static const double inset = 16;
  static const double gap = 12;
  static const double bottom = 36;
}

final class DrogerieMasterHub extends StatefulWidget {
  const DrogerieMasterHub({required this.orchestrator, super.key});
  final DrogerieMasterOrchestrator orchestrator;

  @override
  State<DrogerieMasterHub> createState() => _State();
}

final class _State extends State<DrogerieMasterHub> {
  DrogerieCategory? _category;
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
                        'Drogeriemarkt',
                        languageCode: 'de',
                        style: AppTypography.title.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      AppDirectionalText(
                        'dm / ROSSMANN: المنظفات والعناية الشخصية ولغة النقاط والكوبونات والبطاقة الرقمية.',
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
                        hintText: 'Waschmittel / Shampoo / PAYBACK / Coupon',
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
                          item.brand.label,
                          languageCode: 'de',
                          style: AppTypography.label.copyWith(
                            color: AppColors.secondary,
                          ),
                        ),
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
