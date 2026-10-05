import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../../design_system/design_system.dart';
import '../application/outdoors_master_orchestrator.dart';
import '../domain/outdoors_models.dart';
import 'outdoors_design_tokens.dart';

final class OutdoorsMasterScreen extends StatefulWidget {
  const OutdoorsMasterScreen({
    this.orchestrator,
    super.key,
  });

  final OutdoorsMasterOrchestrator? orchestrator;

  @override
  State<OutdoorsMasterScreen> createState() => _OutdoorsMasterScreenState();
}

final class _OutdoorsMasterScreenState extends State<OutdoorsMasterScreen> {
  late final OutdoorsMasterOrchestrator _orchestrator;
  late final bool _ownsOrchestrator;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _ownsOrchestrator = widget.orchestrator == null;
    _orchestrator = widget.orchestrator ?? OutdoorsMasterOrchestrator();
    _searchController = TextEditingController(text: _orchestrator.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (_ownsOrchestrator) {
      _orchestrator.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      key: const ValueKey<String>('outdoors-arabic-direction'),
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            dark ? AppColors.darkBackground : AppColors.lightBackground,
        body: SafeArea(
          child: ListenableBuilder(
            listenable: _orchestrator,
            builder: (context, _) {
              return SingleChildScrollView(
                padding: OutdoorsDesignTokens.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const _HeaderCard(),
                    const SizedBox(height: OutdoorsDesignTokens.spaceM),
                    _CategoryFilter(
                      orchestrator: _orchestrator,
                      onCategorySelected: _selectCategory,
                    ),
                    const SizedBox(height: OutdoorsDesignTokens.spaceM),
                    _SearchCard(
                      controller: _searchController,
                      onChanged: _orchestrator.setSearchQuery,
                    ),
                    const SizedBox(height: OutdoorsDesignTokens.spaceM),
                    _TrailEtiquetteBar(rules: _orchestrator.trailRules),
                    const SizedBox(height: OutdoorsDesignTokens.spaceL),
                    _PhraseSection(orchestrator: _orchestrator),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _selectCategory(OutdoorsCategory category) {
    if (_orchestrator.category == category) return;
    _orchestrator.switchCategory(category);
    _searchController.clear();
  }
}

final class _HeaderCard extends StatelessWidget {
  const _HeaderCard();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface = dark ? AppColors.darkSurface : AppColors.lightSurface;
    final border =
        dark ? AppColors.glassBorderDark : AppColors.glassBorderLight;

    return AppGlassCard(
      padding: OutdoorsDesignTokens.cardPadding,
      borderRadius: OutdoorsDesignTokens.cardRadius,
      backgroundColor: surface,
      borderColor: border,
      glowColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.terrain,
                color: AppColors.primary,
                size: OutdoorsDesignTokens.iconM,
              ),
              const SizedBox(width: OutdoorsDesignTokens.spaceS),
              Expanded(
                child: Directionality(
                  key: const ValueKey<String>('outdoors-german-direction'),
                  textDirection: TextDirection.ltr,
                  child: Text(
                    'Jugendherberge, Wandern & Naturschutz',
                    style: AppTypography.title.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: OutdoorsDesignTokens.spaceS),
          AppDirectionalText(
            'السفر الداخلي والطبيعة',
            languageCode: 'ar',
            style: AppTypography.title,
          ),
          const SizedBox(height: OutdoorsDesignTokens.spaceXs),
          AppDirectionalText(
            'تدرّب على الإقامة العائلية، المشي في الطبيعة، '
            'قواعد المسارات وحماية الأماكن الطبيعية.',
            languageCode: 'ar',
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }
}

final class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter({
    required this.orchestrator,
    required this.onCategorySelected,
  });

  final OutdoorsMasterOrchestrator orchestrator;
  final ValueChanged<OutdoorsCategory> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface = dark ? AppColors.darkSurface : AppColors.lightSurface;
    final border =
        dark ? AppColors.glassBorderDark : AppColors.glassBorderLight;

    return AppGlassCard(
      padding: OutdoorsDesignTokens.cardPadding,
      backgroundColor: surface,
      borderColor: border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppDirectionalText(
            'الفئة',
            languageCode: 'ar',
            style: AppTypography.title,
          ),
          const SizedBox(height: OutdoorsDesignTokens.spaceS),
          for (final category in OutdoorsCategory.values) ...<Widget>[
            _CategoryCard(
              category: category,
              selected: orchestrator.category == category,
              onTap: () => onCategorySelected(category),
            ),
            if (category != OutdoorsCategory.values.last)
              const SizedBox(height: OutdoorsDesignTokens.spaceS),
          ],
        ],
      ),
    );
  }
}

final class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final OutdoorsCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = category == OutdoorsCategory.accommodation
        ? AppColors.secondary
        : AppColors.mastery;

    return AppGlassCard(
      onTap: selected ? null : onTap,
      padding: OutdoorsDesignTokens.compactCardPadding,
      borderRadius: OutdoorsDesignTokens.compactCardRadius,
      borderColor: selected
          ? accent.withAlpha(OutdoorsDesignTokens.selectedBorderAlpha)
          : Theme.of(context).dividerColor,
      glowColor: selected ? accent : null,
      child: Row(
        children: <Widget>[
          Icon(
            category == OutdoorsCategory.accommodation
                ? Icons.family_restroom
                : Icons.hiking,
            color: accent,
            size: OutdoorsDesignTokens.iconS,
          ),
          const SizedBox(width: OutdoorsDesignTokens.spaceS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AppDirectionalText(
                  category.germanLabel,
                  languageCode: 'de',
                  style: AppTypography.title,
                ),
                AppDirectionalText(
                  category.arabicLabel,
                  languageCode: 'ar',
                  style: AppTypography.label,
                ),
              ],
            ),
          ),
          if (selected)
            Icon(
              Icons.check_circle_outline,
              color: accent,
              size: OutdoorsDesignTokens.iconS,
            ),
        ],
      ),
    );
  }
}

final class _SearchCard extends StatelessWidget {
  const _SearchCard({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface = dark ? AppColors.darkSurface : AppColors.lightSurface;
    final border =
        dark ? AppColors.glassBorderDark : AppColors.glassBorderLight;

    return AppGlassCard(
      padding: OutdoorsDesignTokens.cardPadding,
      backgroundColor: surface,
      borderColor: border,
      glowColor: AppColors.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppDirectionalText(
            'بحث بالكلمة المفتاحية',
            languageCode: 'ar',
            style: AppTypography.title,
          ),
          const SizedBox(height: OutdoorsDesignTokens.spaceS),
          Directionality(
            textDirection: TextDirection.ltr,
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: AppTypography.body,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                labelText: 'Suchen',
                labelStyle: AppTypography.label,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: border),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.secondary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final class _TrailEtiquetteBar extends StatelessWidget {
  const _TrailEtiquetteBar({required this.rules});

  final List<TrailRule> rules;

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      padding: OutdoorsDesignTokens.cardPadding,
      borderColor: AppColors.mastery.withAlpha(
        OutdoorsDesignTokens.selectedBorderAlpha,
      ),
      glowColor: AppColors.mastery,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.eco,
                color: AppColors.mastery,
                size: OutdoorsDesignTokens.iconM,
              ),
              const SizedBox(width: OutdoorsDesignTokens.spaceS),
              Expanded(
                child: Text(
                  'Trail Etiquette · قواعد المسار',
                  style: AppTypography.title,
                ),
              ),
            ],
          ),
          const SizedBox(height: OutdoorsDesignTokens.spaceS),
          for (final rule in rules) ...<Widget>[
            AppGlassCard(
              padding: OutdoorsDesignTokens.compactCardPadding,
              borderRadius: OutdoorsDesignTokens.compactCardRadius,
              borderColor: AppColors.mastery.withAlpha(
                OutdoorsDesignTokens.subtleBorderAlpha,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  AppDirectionalText(
                    rule.german,
                    languageCode: 'de',
                    style: AppTypography.label,
                  ),
                  const SizedBox(height: OutdoorsDesignTokens.spaceXs),
                  AppDirectionalText(
                    rule.arabic,
                    languageCode: 'ar',
                    style: AppTypography.body,
                  ),
                ],
              ),
            ),
            if (rule != rules.last)
              const SizedBox(height: OutdoorsDesignTokens.spaceS),
          ],
        ],
      ),
    );
  }
}

final class _PhraseSection extends StatelessWidget {
  const _PhraseSection({required this.orchestrator});

  final OutdoorsMasterOrchestrator orchestrator;

  @override
  Widget build(BuildContext context) {
    final phrases = orchestrator.visiblePhrases;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: AppDirectionalText(
                'عبارات عملية',
                languageCode: 'ar',
                style: AppTypography.title,
              ),
            ),
            AppDirectionalText(
              orchestrator.category.germanLabel,
              languageCode: 'de',
              style: AppTypography.label.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: OutdoorsDesignTokens.spaceS),
        if (phrases.isEmpty)
          AppGlassCard(
            padding: OutdoorsDesignTokens.cardPadding,
            child: AppDirectionalText(
              'لا توجد عبارات مطابقة لبحثك في هذه الفئة.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          )
        else
          for (final phrase in phrases) ...<Widget>[
            _PhraseCard(phrase: phrase),
            if (phrase != phrases.last)
              const SizedBox(height: OutdoorsDesignTokens.spaceS),
          ],
      ],
    );
  }
}

final class _PhraseCard extends StatelessWidget {
  const _PhraseCard({required this.phrase});

  final OutdoorsPhrase phrase;

  @override
  Widget build(BuildContext context) {
    final accent = phrase.category == OutdoorsCategory.accommodation
        ? AppColors.secondary
        : AppColors.mastery;

    return AppGlassCard(
      padding: OutdoorsDesignTokens.cardPadding,
      borderColor: accent.withAlpha(OutdoorsDesignTokens.subtleBorderAlpha),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppDirectionalText(
            phrase.topic.germanLabel,
            languageCode: 'de',
            style: AppTypography.label.copyWith(color: accent),
          ),
          const SizedBox(height: OutdoorsDesignTokens.spaceXs),
          AppDirectionalText(
            phrase.titleDe,
            languageCode: 'de',
            style: AppTypography.title,
          ),
          const SizedBox(height: OutdoorsDesignTokens.spaceXs),
          AppDirectionalText(
            phrase.textDe,
            languageCode: 'de',
            style: AppTypography.body,
          ),
          const SizedBox(height: OutdoorsDesignTokens.spaceS),
          AppDirectionalText(
            phrase.explanationAr,
            languageCode: 'ar',
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }
}
