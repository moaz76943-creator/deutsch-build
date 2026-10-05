import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../design_system/design_system.dart';
import 'cycling_master_orchestrator.dart';
import 'cycling_models.dart';

abstract final class CyclingUiTokens {
  static const double pageInset = 16;
  static const double bottomInset = 32;
  static const double sectionGap = 18;
  static const double itemGap = 12;
  static const double compactGap = 8;
  static const int borderAlpha = 88;
}

final class CyclingMasterHub extends StatefulWidget {
  const CyclingMasterHub({
    this.orchestrator,
    super.key,
  });

  final CyclingMasterOrchestrator? orchestrator;

  @override
  State<CyclingMasterHub> createState() => _CyclingMasterHubState();
}

final class _CyclingMasterHubState extends State<CyclingMasterHub> {
  late final CyclingMasterOrchestrator _orchestrator;
  late final bool _ownsOrchestrator;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _ownsOrchestrator = widget.orchestrator == null;
    _orchestrator = widget.orchestrator ?? CyclingMasterOrchestrator();
    _searchController = TextEditingController(text: _orchestrator.query);
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (_ownsOrchestrator) _orchestrator.dispose();
    super.dispose();
  }

  void _selectCategory(CyclingCategory category) {
    _orchestrator.setCategory(category);
    if (_searchController.text.isNotEmpty) _searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      key: const ValueKey<String>('cycling-german-direction'),
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor:
            dark ? AppColors.darkBackground : AppColors.lightBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              CyclingUiTokens.pageInset,
              CyclingUiTokens.pageInset,
              CyclingUiTokens.pageInset,
              CyclingUiTokens.bottomInset,
            ),
            child: AnimatedBuilder(
              animation: _orchestrator,
              builder: (context, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _HeaderCard(dark: dark),
                  const SizedBox(height: CyclingUiTokens.sectionGap),
                  _SafetyChecklistBar(
                    items: _orchestrator.safetyChecklist,
                    dark: dark,
                  ),
                  const SizedBox(height: CyclingUiTokens.sectionGap),
                  _CategorySelector(
                    orchestrator: _orchestrator,
                    onSelected: _selectCategory,
                    dark: dark,
                  ),
                  const SizedBox(height: CyclingUiTokens.itemGap),
                  _SearchField(
                    orchestrator: _orchestrator,
                    controller: _searchController,
                  ),
                  const SizedBox(height: CyclingUiTokens.sectionGap),
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
        borderColor:
            AppColors.primary.withAlpha(CyclingUiTokens.borderAlpha),
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'Fahrradverkehr, StVO & Reparatur',
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: CyclingUiTokens.compactGap),
            Directionality(
              key: const ValueKey<String>('cycling-arabic-direction'),
              textDirection: TextDirection.rtl,
              child: AppDirectionalText(
                'مركز عملي للتنقل بالدراجة: قواعد المرور، تجهيزات السلامة ومفردات الإصلاح والورشة.',
                languageCode: 'ar',
                style: AppTypography.body,
              ),
            ),
          ],
        ),
      );
}

final class _SafetyChecklistBar extends StatelessWidget {
  const _SafetyChecklistBar({
    required this.items,
    required this.dark,
  });

  final List<BikeSafetyCheckItem> items;
  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        glowColor: AppColors.tertiary,
        borderColor:
            AppColors.tertiary.withAlpha(CyclingUiTokens.borderAlpha),
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'Bike Safety Checklist · Verkehrssicheres Fahrrad',
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: CyclingUiTokens.compactGap),
            Directionality(
              textDirection: TextDirection.rtl,
              child: AppDirectionalText(
                'التجهيزات هنا مبنية على StVZO، بينما قواعد السير أدناه مبنية على StVO.',
                languageCode: 'ar',
                style: AppTypography.label,
              ),
            ),
            const SizedBox(height: CyclingUiTokens.itemGap),
            for (var index = 0; index < items.length; index++) ...<Widget>[
              _ChecklistItem(item: items[index]),
              if (index != items.length - 1)
                const SizedBox(height: CyclingUiTokens.compactGap),
            ],
          ],
        ),
      );
}

final class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({required this.item});

  final BikeSafetyCheckItem item;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(
            Icons.check_circle_outline,
            color: AppColors.mastery,
            size: 20,
          ),
          const SizedBox(width: CyclingUiTokens.compactGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AppDirectionalText(
                  item.labelDe,
                  languageCode: 'de',
                  style: AppTypography.body,
                ),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: AppDirectionalText(
                    item.labelAr,
                    languageCode: 'ar',
                    style: AppTypography.label,
                  ),
                ),
                AppDirectionalText(
                  item.legalBasis,
                  languageCode: 'de',
                  style: AppTypography.label.copyWith(
                    color: AppColors.tertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}

final class _CategorySelector extends StatelessWidget {
  const _CategorySelector({
    required this.orchestrator,
    required this.onSelected,
    required this.dark,
  });

  final CyclingMasterOrchestrator orchestrator;
  final ValueChanged<CyclingCategory> onSelected;
  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor:
            AppColors.secondary.withAlpha(CyclingUiTokens.borderAlpha),
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Wrap(
          spacing: CyclingUiTokens.compactGap,
          runSpacing: CyclingUiTokens.compactGap,
          children: <Widget>[
            for (final category in CyclingCategory.values)
              FilterChip(
                key: ValueKey<String>('cycling-category-${category.name}'),
                selected: orchestrator.category == category,
                onSelected: (_) => onSelected(category),
                label: Text(
                  '${category.labelDe} · ${category.labelAr}',
                  style: AppTypography.label,
                ),
              ),
          ],
        ),
      );
}

final class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.orchestrator,
    required this.controller,
  });

  final CyclingMasterOrchestrator orchestrator;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => TextField(
        key: const ValueKey<String>('cycling-search'),
        controller: controller,
        onChanged: orchestrator.setQuery,
        textDirection: TextDirection.ltr,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          suffixIcon: orchestrator.query.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    controller.clear();
                    orchestrator.clearSearch();
                  },
                  tooltip: 'Clear search',
                  icon: const Icon(Icons.close),
                ),
          labelText: 'Suche · بحث',
          hintText: 'Radweg, Handzeichen, Reifen, Kette ...',
          border: const OutlineInputBorder(),
        ),
      );

}

final class _PhraseList extends StatelessWidget {
  const _PhraseList({
    required this.orchestrator,
    required this.dark,
  });

  final CyclingMasterOrchestrator orchestrator;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final phrases = orchestrator.visiblePhrases;

    if (phrases.isEmpty) {
      return AppGlassCard(
        borderColor:
            AppColors.tertiary.withAlpha(CyclingUiTokens.borderAlpha),
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: AppDirectionalText(
            'لا توجد نتائج مطابقة في هذا القسم.',
            languageCode: 'ar',
            style: AppTypography.body,
          ),
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
            const SizedBox(height: CyclingUiTokens.itemGap),
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

  final CyclingPhrase phrase;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final accent = phrase.category == CyclingCategory.trafficSafety
        ? AppColors.primary
        : AppColors.secondary;

    return AppGlassCard(
      borderColor: accent.withAlpha(CyclingUiTokens.borderAlpha),
      backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppDirectionalText(
            phrase.topic.labelDe,
            languageCode: 'de',
            style: AppTypography.label.copyWith(color: accent),
          ),
          const SizedBox(height: CyclingUiTokens.compactGap),
          AppDirectionalText(
            phrase.titleDe,
            languageCode: 'de',
            style: AppTypography.title,
          ),
          const SizedBox(height: CyclingUiTokens.compactGap),
          AppDirectionalText(
            phrase.german,
            languageCode: 'de',
            style: AppTypography.body,
          ),
          const SizedBox(height: CyclingUiTokens.compactGap),
          Directionality(
            textDirection: TextDirection.rtl,
            child: AppDirectionalText(
              phrase.arabic,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ),
        ],
      ),
    );
  }
}
