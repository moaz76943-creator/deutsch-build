import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../design_system/design_system.dart';
import 'waste_master_orchestrator.dart';
import 'waste_models.dart';

abstract final class WasteUiTokens {
  static const double pageInset = 16;
  static const double bottomInset = 32;
  static const double sectionGap = 18;
  static const double itemGap = 12;
  static const double compactGap = 8;
}

final class WasteRecyclingMasterHub extends StatefulWidget {
  const WasteRecyclingMasterHub({
    this.orchestrator,
    super.key,
  });

  final WasteMasterOrchestrator? orchestrator;

  @override
  State<WasteRecyclingMasterHub> createState() =>
      _WasteRecyclingMasterHubState();
}

final class _WasteRecyclingMasterHubState
    extends State<WasteRecyclingMasterHub> {
  late final WasteMasterOrchestrator _orchestrator;
  late final bool _ownsOrchestrator;

  @override
  void initState() {
    super.initState();
    _ownsOrchestrator = widget.orchestrator == null;
    _orchestrator = widget.orchestrator ?? WasteMasterOrchestrator();
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
              WasteUiTokens.pageInset,
              WasteUiTokens.pageInset,
              WasteUiTokens.pageInset,
              WasteUiTokens.bottomInset,
            ),
            child: AnimatedBuilder(
              animation: _orchestrator,
              builder: (context, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _HeaderCard(dark: dark),
                  const SizedBox(height: WasteUiTokens.sectionGap),
                  _SearchField(orchestrator: _orchestrator),
                  const SizedBox(height: WasteUiTokens.itemGap),
                  _CategorySelector(
                    orchestrator: _orchestrator,
                    dark: dark,
                  ),
                  const SizedBox(height: WasteUiTokens.sectionGap),
                  _QuickSortingLookupBar(
                    orchestrator: _orchestrator,
                    dark: dark,
                  ),
                  const SizedBox(height: WasteUiTokens.sectionGap),
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
              'Mülltrennung, Pfand & Wertstoffhof',
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: WasteUiTokens.compactGap),
            AppDirectionalText(
              'دليل عملي لفرز النفايات والعبوات المرتجعة والنفايات كبيرة الحجم وزيارة مراكز التدوير، مع مراعاة اختلاف القواعد المحلية.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

final class _SearchField extends StatelessWidget {
  const _SearchField({required this.orchestrator});

  final WasteMasterOrchestrator orchestrator;

  @override
  Widget build(BuildContext context) => TextField(
        key: const ValueKey<String>('waste-search'),
        onChanged: orchestrator.setQuery,
        textDirection: TextDirection.ltr,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search),
          labelText: 'Suche · بحث',
          hintText: 'Gelber Sack, Pfand, Sperrmüll, Wertstoffhof ...',
          border: OutlineInputBorder(),
        ),
      );
}

final class _CategorySelector extends StatelessWidget {
  const _CategorySelector({
    required this.orchestrator,
    required this.dark,
  });

  final WasteMasterOrchestrator orchestrator;
  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.secondary.withAlpha(96),
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Wrap(
          spacing: WasteUiTokens.compactGap,
          runSpacing: WasteUiTokens.compactGap,
          children: <Widget>[
            for (final category in WasteCategory.values)
              FilterChip(
                key: ValueKey<String>('waste-category-${category.name}'),
                selected: orchestrator.category == category,
                onSelected: (_) => orchestrator.setCategory(category),
                label: Text(
                  '${category.labelDe} · ${category.labelAr}',
                  style: AppTypography.label,
                ),
              ),
          ],
        ),
      );
}

final class _QuickSortingLookupBar extends StatelessWidget {
  const _QuickSortingLookupBar({
    required this.orchestrator,
    required this.dark,
  });

  final WasteMasterOrchestrator orchestrator;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final result = orchestrator.lookupResult;

    return AppGlassCard(
      glowColor: AppColors.secondary,
      borderColor: AppColors.secondary.withAlpha(96),
      backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppDirectionalText(
            'Wohin gehört das?',
            languageCode: 'de',
            style: AppTypography.title,
          ),
          const SizedBox(height: WasteUiTokens.compactGap),
          AppDirectionalText(
            'اكتب اسم الغرض لتحصل على مسار فرز سريع وآمن. عند اختلاف القواعد بين البلديات ستطلب الأداة الرجوع للتعليمات المحلية.',
            languageCode: 'ar',
            style: AppTypography.body,
          ),
          const SizedBox(height: WasteUiTokens.itemGap),
          TextField(
            key: const ValueKey<String>('waste-lookup'),
            onChanged: orchestrator.setLookupQuery,
            textDirection: TextDirection.ltr,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.recycling_outlined),
              labelText: 'Gegenstand · الغرض',
              hintText: 'Batterie, Zeitung, Glasflasche ...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: WasteUiTokens.compactGap),
          Wrap(
            spacing: WasteUiTokens.compactGap,
            runSpacing: WasteUiTokens.compactGap,
            children: <Widget>[
              for (final example in const <String>[
                'Batterie',
                'Zeitung',
                'Glasflasche',
                'Verpackung',
              ])
                ActionChip(
                  label: Text(example, style: AppTypography.label),
                  onPressed: () => orchestrator.setLookupQuery(example),
                ),
            ],
          ),
          const SizedBox(height: WasteUiTokens.itemGap),
          _LookupResultCard(
            result: result,
            dark: dark,
          ),
        ],
      ),
    );
  }
}

final class _LookupResultCard extends StatelessWidget {
  const _LookupResultCard({
    required this.result,
    required this.dark,
  });

  final WasteLookupResult result;
  final bool dark;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(WasteUiTokens.itemGap),
        decoration: BoxDecoration(
          color: dark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (result.isKnown ? AppColors.primary : AppColors.tertiary)
                .withAlpha(96),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              result.routeDe,
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: WasteUiTokens.compactGap),
            AppDirectionalText(
              result.routeAr,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
            const SizedBox(height: WasteUiTokens.compactGap),
            AppDirectionalText(
              result.noteDe,
              languageCode: 'de',
              style: AppTypography.label,
            ),
            const SizedBox(height: WasteUiTokens.compactGap),
            AppDirectionalText(
              result.noteAr,
              languageCode: 'ar',
              style: AppTypography.label,
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

  final WasteMasterOrchestrator orchestrator;
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
            const SizedBox(height: WasteUiTokens.itemGap),
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

  final WastePhrase phrase;
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
            const SizedBox(height: WasteUiTokens.compactGap),
            AppDirectionalText(
              phrase.german,
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: WasteUiTokens.compactGap),
            AppDirectionalText(
              phrase.arabic,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
            const SizedBox(height: WasteUiTokens.compactGap),
            AppDirectionalText(
              phrase.contextAr,
              languageCode: 'ar',
              style: AppTypography.label,
            ),
          ],
        ),
      );
}
