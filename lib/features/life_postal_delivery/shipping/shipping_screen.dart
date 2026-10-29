import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../../design_system/design_system.dart';
import 'shipping_models.dart';
import 'shipping_orchestrator.dart';

abstract final class ShippingUiTokens {
  static const double pageInset = 16;
  static const double bottomInset = 32;
  static const double sectionGap = 18;
  static const double itemGap = 12;
  static const double compactGap = 8;
}

final class ShippingSendReceiveScreen extends StatefulWidget {
  const ShippingSendReceiveScreen({
    this.orchestrator,
    super.key,
  });

  final ShippingOrchestrator? orchestrator;

  @override
  State<ShippingSendReceiveScreen> createState() =>
      _ShippingSendReceiveScreenState();
}

final class _ShippingSendReceiveScreenState
    extends State<ShippingSendReceiveScreen> {
  late final ShippingOrchestrator _orchestrator;
  late final bool _ownsOrchestrator;

  @override
  void initState() {
    super.initState();
    _ownsOrchestrator = widget.orchestrator == null;
    _orchestrator = widget.orchestrator ?? ShippingOrchestrator();
  }

  @override
  void dispose() {
    if (_ownsOrchestrator) _orchestrator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor:
            dark ? AppColors.darkBackground : AppColors.lightBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              ShippingUiTokens.pageInset,
              ShippingUiTokens.pageInset,
              ShippingUiTokens.pageInset,
              ShippingUiTokens.bottomInset,
            ),
            child: AnimatedBuilder(
              animation: _orchestrator,
              builder: (context, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _HeaderCard(dark: dark),
                  const SizedBox(height: ShippingUiTokens.sectionGap),
                  _SearchField(orchestrator: _orchestrator),
                  const SizedBox(height: ShippingUiTokens.itemGap),
                  _ScenarioSelector(
                    orchestrator: _orchestrator,
                    dark: dark,
                  ),
                  const SizedBox(height: ShippingUiTokens.sectionGap),
                  _PhraseList(
                    orchestrator: _orchestrator,
                    dark: dark,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        glowColor: AppColors.primary,
        borderColor: AppColors.primary.withAlpha(96),
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'Versenden & Abholen',
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: ShippingUiTokens.compactGap),
            AppDirectionalText(
              'إرسال واستلام الطرود والرسائل المسجلة',
              languageCode: 'ar',
              style: AppTypography.title,
            ),
          ],
        ),
      );
}

final class _SearchField extends StatelessWidget {
  const _SearchField({required this.orchestrator});

  final ShippingOrchestrator orchestrator;

  @override
  Widget build(BuildContext context) => TextField(
        key: const ValueKey<String>('shipping-search'),
        onChanged: orchestrator.setQuery,
        textDirection: TextDirection.ltr,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search),
          labelText: 'Suche · بحث',
          hintText: 'Rückschein, Versicherung, Paketshop, Ausweis ...',
          border: OutlineInputBorder(),
        ),
      );
}

final class _ScenarioSelector extends StatelessWidget {
  const _ScenarioSelector({
    required this.orchestrator,
    required this.dark,
  });

  final ShippingOrchestrator orchestrator;
  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.secondary.withAlpha(96),
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Wrap(
          spacing: ShippingUiTokens.compactGap,
          runSpacing: ShippingUiTokens.compactGap,
          children: <Widget>[
            for (final scenario in ShippingScenario.values)
              FilterChip(
                key: ValueKey<String>('shipping-scenario-${scenario.name}'),
                selected: orchestrator.scenario == scenario,
                onSelected: (_) => orchestrator.setScenario(scenario),
                label: Text(
                  '${scenario.labelDe} · ${scenario.labelAr}',
                  style: AppTypography.label,
                ),
              ),
          ],
        ),
      );
}

final class _PhraseList extends StatelessWidget {
  const _PhraseList({
    required this.orchestrator,
    required this.dark,
  });

  final ShippingOrchestrator orchestrator;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final phrases = orchestrator.visiblePhrases;

    if (phrases.isEmpty) {
      return AppGlassCard(
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: AppDirectionalText(
          'لا توجد عبارات مطابقة. جرّب كلمة بحث أخرى.',
          languageCode: 'ar',
          style: AppTypography.body,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (var index = 0; index < phrases.length; index++) ...<Widget>[
          _PhraseCard(phrase: phrases[index], dark: dark),
          if (index != phrases.length - 1)
            const SizedBox(height: ShippingUiTokens.itemGap),
        ],
      ],
    );
  }
}

final class _PhraseCard extends StatelessWidget {
  const _PhraseCard({
    required this.phrase,
    required this.dark,
  });

  final ShippingPhrase phrase;
  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.primary.withAlpha(80),
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              phrase.contextDe,
              languageCode: 'de',
              style: AppTypography.label,
            ),
            const SizedBox(height: ShippingUiTokens.compactGap),
            AppDirectionalText(
              phrase.german,
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: ShippingUiTokens.compactGap),
            AppDirectionalText(
              phrase.arabic,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
            const SizedBox(height: ShippingUiTokens.compactGap),
            AppDirectionalText(
              phrase.contextAr,
              languageCode: 'ar',
              style: AppTypography.label,
            ),
            const SizedBox(height: ShippingUiTokens.compactGap),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Wrap(
                spacing: ShippingUiTokens.compactGap,
                runSpacing: ShippingUiTokens.compactGap,
                children: <Widget>[
                  for (final carrier in phrase.carriers)
                    Chip(
                      label: Text(
                        carrier.labelDe,
                        style: AppTypography.label,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
}
