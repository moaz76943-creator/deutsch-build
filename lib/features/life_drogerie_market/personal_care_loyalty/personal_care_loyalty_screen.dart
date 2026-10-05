import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../../design_system/design_system.dart';
import '../drogerie_models.dart';
import 'personal_care_loyalty_agent.dart';

abstract final class _Ui {
  static const double inset = 16;
  static const double gap = 12;
  static const double bottom = 36;
}

final class PersonalCareLoyaltyScreen extends StatefulWidget {
  const PersonalCareLoyaltyScreen({required this.agent, super.key});
  final PersonalCareLoyaltyAgent agent;

  @override
  State<PersonalCareLoyaltyScreen> createState() => _State();
}

final class _State extends State<PersonalCareLoyaltyScreen> {
  DrogerieBrand? _brand;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface = dark ? AppColors.darkSurface : AppColors.lightSurface;
    final border =
        dark ? AppColors.glassBorderDark : AppColors.glassBorderLight;
    final items = widget.agent.search(_query, brand: _brand);

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
                        'Körperpflege & Vorteile',
                        languageCode: 'de',
                        style: AppTypography.title.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      AppDirectionalText(
                        'العناية الشخصية مع لغة برامج العملاء: PAYBACK لدى dm وكوبونات وعروض الولاء في تطبيق ROSSMANN.',
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
                    children: <Widget>[
                      ChoiceChip(
                        label: const Text('Alle'),
                        selected: _brand == null,
                        onSelected: (_) => setState(() => _brand = null),
                      ),
                      ChoiceChip(
                        label: const Text('dm'),
                        selected: _brand == DrogerieBrand.dm,
                        onSelected: (_) =>
                            setState(() => _brand = DrogerieBrand.dm),
                      ),
                      ChoiceChip(
                        label: const Text('ROSSMANN'),
                        selected: _brand == DrogerieBrand.rossmann,
                        onSelected: (_) =>
                            setState(() => _brand = DrogerieBrand.rossmann),
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
                        hintText: 'Shampoo / PAYBACK / Coupon / Treueaktion',
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
