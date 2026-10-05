import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../design_system/design_system.dart';
import 'laundry_master_orchestrator.dart';
import 'laundry_models.dart';

abstract final class LaundryUiTokens {
  static const double pageInset = 16;
  static const double bottomInset = 32;
  static const double sectionGap = 18;
  static const double itemGap = 12;
  static const double compactGap = 8;
}

final class LaundryMasterHub extends StatefulWidget {
  const LaundryMasterHub({
    this.orchestrator,
    super.key,
  });

  final LaundryMasterOrchestrator? orchestrator;

  @override
  State<LaundryMasterHub> createState() => _LaundryMasterHubState();
}

final class _LaundryMasterHubState extends State<LaundryMasterHub> {
  late final LaundryMasterOrchestrator _orchestrator;
  late final bool _ownsOrchestrator;

  @override
  void initState() {
    super.initState();
    _ownsOrchestrator = widget.orchestrator == null;
    _orchestrator = widget.orchestrator ?? LaundryMasterOrchestrator();
  }

  @override
  void dispose() {
    if (_ownsOrchestrator) {
      _orchestrator.dispose();
    }
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
              LaundryUiTokens.pageInset,
              LaundryUiTokens.pageInset,
              LaundryUiTokens.pageInset,
              LaundryUiTokens.bottomInset,
            ),
            child: AnimatedBuilder(
              animation: _orchestrator,
              builder: (context, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _HeaderCard(dark: dark),
                  const SizedBox(height: LaundryUiTokens.sectionGap),
                  _SearchField(orchestrator: _orchestrator),
                  const SizedBox(height: LaundryUiTokens.itemGap),
                  _DomainSelector(
                    orchestrator: _orchestrator,
                    dark: dark,
                  ),
                  const SizedBox(height: LaundryUiTokens.sectionGap),
                  _FabricCareGuide(
                    key: const ValueKey<String>(
                      'laundry-care-symbols-guide',
                    ),
                    orchestrator: _orchestrator,
                    dark: dark,
                  ),
                  const SizedBox(height: LaundryUiTokens.sectionGap),
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
              'Waschsalon & Chemische Reinigung',
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: LaundryUiTokens.compactGap),
            AppDirectionalText(
              'عبارات عملية للمغسلة الذاتية والتنظيف الاحترافي والكيّ، مع دليل سريع لرموز العناية بالأقمشة.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );

}

final class _SearchField extends StatelessWidget {
  const _SearchField({required this.orchestrator});

  final LaundryMasterOrchestrator orchestrator;

  @override
  Widget build(BuildContext context) => TextField(
        key: const ValueKey<String>('laundry-search'),
        onChanged: orchestrator.setQuery,
        textDirection: TextDirection.ltr,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search),
          labelText: 'Suche · بحث',
          hintText: 'Waschmarken, Feinwäsche, Trockner, Abholschein ...',
          border: OutlineInputBorder(),
        ),
      );
}

final class _DomainSelector extends StatelessWidget {
  const _DomainSelector({
    required this.orchestrator,
    required this.dark,
  });

  final LaundryMasterOrchestrator orchestrator;
  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.secondary.withAlpha(96),
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Wrap(
          spacing: LaundryUiTokens.compactGap,
          runSpacing: LaundryUiTokens.compactGap,
          children: <Widget>[
            for (final domain in LaundryDomain.values)
              FilterChip(
                key: ValueKey<String>('laundry-domain-${domain.name}'),
                selected: orchestrator.domain == domain,
                onSelected: (_) => orchestrator.setDomain(domain),
                label: Text(
                  '${domain.labelDe} · ${domain.labelAr}',
                  style: AppTypography.label,
                ),
              ),
          ],
        ),
      );
}

final class _FabricCareGuide extends StatelessWidget {
  const _FabricCareGuide({
    required this.orchestrator,
    required this.dark,
    super.key,
  });

  final LaundryMasterOrchestrator orchestrator;
  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        glowColor: AppColors.secondary,
        borderColor: AppColors.secondary.withAlpha(96),
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'Waschsymbole verstehen · Fabric Care Guide',
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: LaundryUiTokens.compactGap),
            AppDirectionalText(
              'اقرأ بطاقة العناية أولًا. هذه العبارات تشرح الرموز الشائعة قبل اختيار الغسيل أو التجفيف أو الكيّ أو التنظيف الاحترافي.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
            const SizedBox(height: LaundryUiTokens.itemGap),
            for (final symbol in orchestrator.fabricCareSymbols) ...<Widget>[
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 72,
                      padding: const EdgeInsets.symmetric(
                        horizontal: LaundryUiTokens.compactGap,
                        vertical: LaundryUiTokens.compactGap,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.secondary.withAlpha(100),
                        ),
                      ),
                      child: Text(
                        symbol.symbol,
                        textAlign: TextAlign.center,
                        style: AppTypography.label,
                      ),
                    ),
                    const SizedBox(width: LaundryUiTokens.itemGap),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          AppDirectionalText(
                            symbol.german,
                            languageCode: 'de',
                            style: AppTypography.label,
                          ),
                          const SizedBox(height: LaundryUiTokens.compactGap),
                          AppDirectionalText(
                            symbol.arabic,
                            languageCode: 'ar',
                            style: AppTypography.body,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: LaundryUiTokens.itemGap),
            ],
          ],
        ),
      );
}

final class _PhraseList extends StatelessWidget {
  const _PhraseList({
    required this.orchestrator,
    required this.dark,
  });

  final LaundryMasterOrchestrator orchestrator;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final phrases = orchestrator.visiblePhrases;

    if (phrases.isEmpty) {
      return AppGlassCard(
        borderColor: AppColors.tertiary.withAlpha(96),
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: AppDirectionalText(
          'لا توجد نتائج في هذا القسم. جرّب كلمة بحث أخرى.',
          languageCode: 'ar',
          style: AppTypography.body,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (var index = 0; index < phrases.length; index++) ...<Widget>[
          _PhraseCard(
            phrase: phrases[index],
            dark: dark,
          ),
          if (index != phrases.length - 1)
            const SizedBox(height: LaundryUiTokens.itemGap),
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

  final LaundryPhrase phrase;
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
            const SizedBox(height: LaundryUiTokens.compactGap),
            AppDirectionalText(
              phrase.german,
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: LaundryUiTokens.compactGap),
            AppDirectionalText(
              phrase.arabic,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
            const SizedBox(height: LaundryUiTokens.compactGap),
            AppDirectionalText(
              phrase.contextAr,
              languageCode: 'ar',
              style: AppTypography.label,
            ),
          ],
        ),
      );
}
