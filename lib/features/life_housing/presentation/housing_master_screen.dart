import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../../design_system/design_system.dart';
import '../application/housing_master_orchestrator.dart';
import '../domain/housing_models.dart';
import 'housing_design_tokens.dart';

final class HousingMasterScreen extends StatefulWidget {
  const HousingMasterScreen({
    this.orchestrator,
    super.key,
  });

  final HousingMasterOrchestrator? orchestrator;

  @override
  State<HousingMasterScreen> createState() => _HousingMasterScreenState();
}

final class _HousingMasterScreenState extends State<HousingMasterScreen> {
  late final HousingMasterOrchestrator _orchestrator;
  late final bool _ownsOrchestrator;

  @override
  void initState() {
    super.initState();
    _ownsOrchestrator = widget.orchestrator == null;
    _orchestrator = widget.orchestrator ?? HousingMasterOrchestrator();
  }

  @override
  void dispose() {
    if (_ownsOrchestrator) _orchestrator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      key: const ValueKey<String>('housing-arabic-direction'),
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('السكن والصيانة · Wohnung & Handwerker'),
        ),
        body: SafeArea(
          child: ListenableBuilder(
            listenable: _orchestrator,
            builder: (context, _) {
              return SingleChildScrollView(
                padding: HousingDesignTokens.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const _HeroCard(),
                    const SizedBox(height: HousingDesignTokens.spaceM),
                    _CategorySwitcher(orchestrator: _orchestrator),
                    const SizedBox(height: HousingDesignTokens.spaceM),
                    _LevelFilter(orchestrator: _orchestrator),
                    const SizedBox(height: HousingDesignTokens.spaceM),
                    _QuickActionBar(orchestrator: _orchestrator),
                    if (_orchestrator.lastQuickActionText != null) ...<Widget>[
                      const SizedBox(height: HousingDesignTokens.spaceM),
                      _QuickActionResult(orchestrator: _orchestrator),
                    ],
                    const SizedBox(height: HousingDesignTokens.spaceL),
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
}

final class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      padding: HousingDesignTokens.cardPadding,
      borderRadius: HousingDesignTokens.cardRadius,
      borderColor: AppColors.primary.withAlpha(HousingDesignTokens.heroBorderAlpha),
      glowColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.home,
                color: AppColors.primary,
                size: HousingDesignTokens.iconM,
              ),
              const SizedBox(width: HousingDesignTokens.spaceS),
              Expanded(
                child: Text(
                  'Housing & Home Maintenance Master Hub',
                  style: AppTypography.title,
                ),
              ),
            ],
          ),
          const SizedBox(height: HousingDesignTokens.spaceS),
          Directionality(
            key: const ValueKey<String>('housing-german-direction'),
            textDirection: TextDirection.ltr,
            child: Text(
              'Wohnungssuche & Handwerker',
              style: AppTypography.title.copyWith(
                color: AppColors.secondary,
              ),
            ),
          ),
          const SizedBox(height: HousingDesignTokens.spaceXs),
          Text(
            'تدرّب على البحث عن شقة والتواصل مع المؤجر، ثم بلاغات '
            'الصيانة الخاصة بالمياه والتدفئة وتركيب الإنترنت.',
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }
}

final class _CategorySwitcher extends StatelessWidget {
  const _CategorySwitcher({required this.orchestrator});

  final HousingMasterOrchestrator orchestrator;

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      padding: HousingDesignTokens.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text('المسار', style: AppTypography.title),
          const SizedBox(height: HousingDesignTokens.spaceS),
          for (final category in HousingCategory.values) ...<Widget>[
            _CategoryCard(
              category: category,
              selected: orchestrator.category == category,
              onTap: () => orchestrator.switchCategory(category),
            ),
            if (category != HousingCategory.values.last)
              const SizedBox(height: HousingDesignTokens.spaceS),
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

  final HousingCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = category == HousingCategory.apartmentHunting
        ? AppColors.primary
        : AppColors.secondary;

    return AppGlassCard(
      onTap: selected ? null : onTap,
      padding: HousingDesignTokens.compactCardPadding,
      borderRadius: HousingDesignTokens.compactCardRadius,
      borderColor: selected ? accent : Theme.of(context).dividerColor,
      glowColor: selected ? accent : null,
      child: Row(
        children: <Widget>[
          Icon(
            category == HousingCategory.apartmentHunting
                ? Icons.apartment
                : Icons.build,
            color: accent,
            size: HousingDesignTokens.iconM,
          ),
          const SizedBox(width: HousingDesignTokens.spaceS),
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
            const Icon(
              Icons.check_circle_outline,
              color: AppColors.mastery,
              size: HousingDesignTokens.iconS,
            ),
        ],
      ),
    );
  }
}

final class _LevelFilter extends StatelessWidget {
  const _LevelFilter({required this.orchestrator});

  final HousingMasterOrchestrator orchestrator;

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      padding: HousingDesignTokens.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text('المستوى', style: AppTypography.title),
          const SizedBox(height: HousingDesignTokens.spaceS),
          Wrap(
            spacing: HousingDesignTokens.spaceS,
            runSpacing: HousingDesignTokens.spaceS,
            children: <Widget>[
              for (final level in HousingLevel.values)
                ChoiceChip(
                  label: Text(
                    level.label,
                    textDirection: TextDirection.ltr,
                    style: AppTypography.label,
                  ),
                  selected: orchestrator.level == level,
                  selectedColor: AppColors.primary.withAlpha(HousingDesignTokens.selectedFillAlpha),
                  side: BorderSide(
                    color: orchestrator.level == level
                        ? AppColors.primary
                        : Theme.of(context).dividerColor,
                  ),
                  onSelected: (_) => orchestrator.setLevel(level),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

final class _QuickActionBar extends StatelessWidget {
  const _QuickActionBar({required this.orchestrator});

  final HousingMasterOrchestrator orchestrator;

  @override
  Widget build(BuildContext context) {
    final actions = orchestrator.availableQuickActions;

    return AppGlassCard(
      padding: HousingDesignTokens.cardPadding,
      borderColor: AppColors.tertiary.withAlpha(HousingDesignTokens.accentBorderAlpha),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text('إجراءات سريعة', style: AppTypography.title),
          const SizedBox(height: HousingDesignTokens.spaceXs),
          Text(
            'اختر موقفًا للحصول على صياغة ألمانية جاهزة ومحترمة.',
            style: AppTypography.label,
          ),
          const SizedBox(height: HousingDesignTokens.spaceS),
          LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: HousingDesignTokens.spaceS,
                runSpacing: HousingDesignTokens.spaceS,
                children: <Widget>[
                  for (final action in actions)
                    SizedBox(
                      width: constraints.maxWidth,
                      child: AppGlassCard(
                        onTap: () => orchestrator.runQuickAction(action),
                        padding: HousingDesignTokens.compactCardPadding,
                        borderRadius: HousingDesignTokens.compactCardRadius,
                        borderColor: AppColors.tertiary.withAlpha(HousingDesignTokens.accentBorderAlpha),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              _quickActionIcon(action),
                              color: AppColors.tertiary,
                              size: HousingDesignTokens.iconS,
                            ),
                            const SizedBox(width: HousingDesignTokens.spaceS),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  AppDirectionalText(
                                    action.germanLabel,
                                    languageCode: 'de',
                                    style: AppTypography.label,
                                  ),
                                  AppDirectionalText(
                                    action.arabicLabel,
                                    languageCode: 'ar',
                                    style: AppTypography.label,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  IconData _quickActionIcon(HousingQuickAction action) => switch (action) {
        HousingQuickAction.contactLandlord => Icons.mail,
        HousingQuickAction.askAboutKaution => Icons.receipt,
        HousingQuickAction.reportPlumbing => Icons.water_drop,
        HousingQuickAction.reportHeating => Icons.thermostat,
        HousingQuickAction.arrangeInternet => Icons.wifi,
      };
}

final class _QuickActionResult extends StatelessWidget {
  const _QuickActionResult({required this.orchestrator});

  final HousingMasterOrchestrator orchestrator;

  @override
  Widget build(BuildContext context) {
    final action = orchestrator.lastQuickAction!;
    final text = orchestrator.lastQuickActionText!;

    return AppGlassCard(
      padding: HousingDesignTokens.cardPadding,
      borderColor: AppColors.mastery.withAlpha(HousingDesignTokens.strongBorderAlpha),
      glowColor: AppColors.mastery,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.flash_on,
                color: AppColors.mastery,
                size: HousingDesignTokens.iconS,
              ),
              const SizedBox(width: HousingDesignTokens.spaceS),
              Expanded(
                child: AppDirectionalText(
                  action.germanLabel,
                  languageCode: 'de',
                  style: AppTypography.title,
                ),
              ),
              IconButton(
                onPressed: orchestrator.clearQuickAction,
                icon: const Icon(Icons.close),
                tooltip: 'إغلاق',
              ),
            ],
          ),
          const SizedBox(height: HousingDesignTokens.spaceS),
          AppDirectionalText(
            text,
            languageCode: 'de',
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }
}

final class _PhraseSection extends StatelessWidget {
  const _PhraseSection({required this.orchestrator});

  final HousingMasterOrchestrator orchestrator;

  @override
  Widget build(BuildContext context) {
    final phrases = orchestrator.visiblePhrases;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'تدريب ' + orchestrator.level.label,
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
        const SizedBox(height: HousingDesignTokens.spaceS),
        for (final phrase in phrases) ...<Widget>[
          _PhraseCard(phrase: phrase),
          if (phrase != phrases.last)
            const SizedBox(height: HousingDesignTokens.spaceS),
        ],
      ],
    );
  }
}

final class _PhraseCard extends StatelessWidget {
  const _PhraseCard({required this.phrase});

  final HousingPhrase phrase;

  @override
  Widget build(BuildContext context) {
    final accent = phrase.category == HousingCategory.apartmentHunting
        ? AppColors.primary
        : AppColors.secondary;

    return AppGlassCard(
      padding: HousingDesignTokens.cardPadding,
      borderColor: accent.withAlpha(HousingDesignTokens.subtleBorderAlpha),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppDirectionalText(
            phrase.titleDe,
            languageCode: 'de',
            style: AppTypography.label.copyWith(color: accent),
          ),
          const SizedBox(height: HousingDesignTokens.spaceXs),
          AppDirectionalText(
            phrase.textDe,
            languageCode: 'de',
            style: AppTypography.title,
          ),
          const SizedBox(height: HousingDesignTokens.spaceS),
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
