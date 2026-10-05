import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../../design_system/design_system.dart';
import '../application/driving_master_orchestrator.dart';
import '../domain/driving_models.dart';

abstract final class _DrivingUiTokens {
  static const double spaceXs = 6;
  static const double spaceS = 10;
  static const double spaceM = 14;
  static const double spaceL = 18;
  static const double spaceXl = 28;
  static const double cardRadius = 24;
  static const double compactRadius = 20;
  static const int subtleAlpha = 72;
  static const int activeAlpha = 42;

  static const EdgeInsetsDirectional screenPadding =
      EdgeInsetsDirectional.fromSTEB(spaceM, spaceM, spaceM, spaceXl);
  static const EdgeInsets cardPadding = EdgeInsets.all(spaceM);
  static const EdgeInsets compactPadding =
      EdgeInsets.symmetric(horizontal: spaceM, vertical: spaceS);
}

final class DrivingMasterScreen extends StatefulWidget {
  const DrivingMasterScreen({
    this.orchestrator,
    super.key,
  });

  final DrivingMasterOrchestrator? orchestrator;

  @override
  State<DrivingMasterScreen> createState() => _DrivingMasterScreenState();
}

final class _DrivingMasterScreenState extends State<DrivingMasterScreen> {
  late final DrivingMasterOrchestrator _orchestrator;
  late final bool _ownsOrchestrator;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _ownsOrchestrator = widget.orchestrator == null;
    _orchestrator = widget.orchestrator ?? DrivingMasterOrchestrator();
    _searchController = TextEditingController(text: _orchestrator.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (_ownsOrchestrator) _orchestrator.dispose();
    super.dispose();
  }

  void _switchCategory(DrivingCategory category) {
    _orchestrator.switchCategory(category);
    if (_searchController.text.isNotEmpty) {
      _searchController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      key: const ValueKey<String>('driving-arabic-direction'),
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkBackground
            : AppColors.lightBackground,
        appBar: AppBar(
          title: const Text('القيادة والمركبة · Fahrschule & Kfz'),
        ),
        body: SafeArea(
          child: ListenableBuilder(
            listenable: _orchestrator,
            builder: (context, _) {
              return SingleChildScrollView(
                padding: _DrivingUiTokens.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const _HeroCard(),
                    const SizedBox(height: _DrivingUiTokens.spaceM),
                    _QuickExamPrepBar(
                      items: _orchestrator.quickExamPrep,
                    ),
                    const SizedBox(height: _DrivingUiTokens.spaceM),
                    _CategorySwitcher(
                      selected: _orchestrator.category,
                      onSelected: _switchCategory,
                    ),
                    const SizedBox(height: _DrivingUiTokens.spaceM),
                    _SearchCard(
                      controller: _searchController,
                      query: _orchestrator.searchQuery,
                      onChanged: _orchestrator.setSearchQuery,
                      onClear: () {
                        _searchController.clear();
                        _orchestrator.clearSearch();
                      },
                    ),
                    const SizedBox(height: _DrivingUiTokens.spaceL),
                    _LearningSection(
                      category: _orchestrator.category,
                      items: _orchestrator.visibleItems,
                    ),
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
      padding: _DrivingUiTokens.cardPadding,
      borderRadius: _DrivingUiTokens.cardRadius,
      borderColor: AppColors.primary.withAlpha(_DrivingUiTokens.subtleAlpha),
      glowColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.directions_car, color: AppColors.primary),
              const SizedBox(width: _DrivingUiTokens.spaceS),
              Expanded(
                child: Text(
                  'Driving School & Vehicle Registration Master Hub',
                  style: AppTypography.title,
                ),
              ),
            ],
          ),
          const SizedBox(height: _DrivingUiTokens.spaceS),
          Directionality(
            key: const ValueKey<String>('driving-german-direction'),
            textDirection: TextDirection.ltr,
            child: AppDirectionalText(
              'Fahrschule, TÜV & Kfz-Zulassung',
              languageCode: 'de',
              style: AppTypography.title.copyWith(color: AppColors.secondary),
            ),
          ),
          const SizedBox(height: _DrivingUiTokens.spaceXs),
          AppDirectionalText(
            'تدريب عملي على مدرسة القيادة، أوامر الدرس العملي، تسجيل المركبة '
            'والفحص الدوري والمصطلحات البيئية.',
            languageCode: 'ar',
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }
}

final class _QuickExamPrepBar extends StatelessWidget {
  const _QuickExamPrepBar({required this.items});

  final List<DrivingExamPrepItem> items;

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      padding: _DrivingUiTokens.cardPadding,
      borderColor: AppColors.tertiary.withAlpha(_DrivingUiTokens.subtleAlpha),
      glowColor: AppColors.tertiary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.bolt, color: AppColors.tertiary),
              const SizedBox(width: _DrivingUiTokens.spaceS),
              Expanded(
                child: Text('تحضير سريع للامتحان', style: AppTypography.title),
              ),
            ],
          ),
          const SizedBox(height: _DrivingUiTokens.spaceS),
          for (final item in items) ...<Widget>[
            AppGlassCard(
              padding: _DrivingUiTokens.compactPadding,
              borderRadius: _DrivingUiTokens.compactRadius,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  AppDirectionalText(
                    item.focusDe,
                    languageCode: 'de',
                    style: AppTypography.label.copyWith(
                      color: AppColors.tertiary,
                    ),
                  ),
                  const SizedBox(height: _DrivingUiTokens.spaceXs),
                  AppDirectionalText(
                    item.german,
                    languageCode: 'de',
                    style: AppTypography.body,
                  ),
                  AppDirectionalText(
                    item.arabic,
                    languageCode: 'ar',
                    style: AppTypography.label,
                  ),
                ],
              ),
            ),
            if (item != items.last)
              const SizedBox(height: _DrivingUiTokens.spaceS),
          ],
        ],
      ),
    );
  }
}

final class _CategorySwitcher extends StatelessWidget {
  const _CategorySwitcher({
    required this.selected,
    required this.onSelected,
  });

  final DrivingCategory selected;
  final ValueChanged<DrivingCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      padding: _DrivingUiTokens.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text('المسار', style: AppTypography.title),
          const SizedBox(height: _DrivingUiTokens.spaceS),
          for (final category in DrivingCategory.values) ...<Widget>[
            _CategoryCard(
              category: category,
              selected: selected == category,
              onTap: () => onSelected(category),
            ),
            if (category != DrivingCategory.values.last)
              const SizedBox(height: _DrivingUiTokens.spaceS),
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

  final DrivingCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = category == DrivingCategory.fahrschule
        ? AppColors.primary
        : AppColors.secondary;

    return AppGlassCard(
      onTap: selected ? null : onTap,
      padding: _DrivingUiTokens.compactPadding,
      borderRadius: _DrivingUiTokens.compactRadius,
      borderColor: selected
          ? accent
          : Theme.of(context).dividerColor.withAlpha(
                _DrivingUiTokens.subtleAlpha,
              ),
      glowColor: selected ? accent : null,
      backgroundColor:
          selected ? (accent.withAlpha(_DrivingUiTokens.activeAlpha)) : Colors.transparent,
      child: Row(
        children: <Widget>[
          Icon(
            category == DrivingCategory.fahrschule
                ? Icons.school_outlined
                : Icons.fact_check_outlined,
            color: accent,
          ),
          const SizedBox(width: _DrivingUiTokens.spaceS),
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
            const Icon(Icons.check_circle_outline, color: AppColors.mastery),
        ],
      ),
    );
  }
}

final class _SearchCard extends StatelessWidget {
  const _SearchCard({
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      padding: _DrivingUiTokens.cardPadding,
      borderColor: AppColors.secondary.withAlpha(_DrivingUiTokens.subtleAlpha),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text('بحث', style: AppTypography.title),
          const SizedBox(height: _DrivingUiTokens.spaceS),
          TextField(
            key: const ValueKey<String>('driving-search'),
            controller: controller,
            onChanged: onChanged,
            style: AppTypography.body,
            decoration: InputDecoration(
              hintText: 'TÜV، Fahrschule، Umweltplakette...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: query.isEmpty
                  ? null
                  : IconButton(
                      onPressed: onClear,
                      tooltip: 'مسح البحث',
                      icon: const Icon(Icons.close),
                    ),
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}

final class _LearningSection extends StatelessWidget {
  const _LearningSection({
    required this.category,
    required this.items,
  });

  final DrivingCategory category;
  final List<DrivingLearningItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text('عبارات ومصطلحات', style: AppTypography.title),
            ),
            AppDirectionalText(
              category.germanLabel,
              languageCode: 'de',
              style: AppTypography.label.copyWith(color: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: _DrivingUiTokens.spaceS),
        if (items.isEmpty)
          AppGlassCard(
            padding: _DrivingUiTokens.cardPadding,
            child: AppDirectionalText(
              'لا توجد نتائج مطابقة للبحث في هذا المسار.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          )
        else
          for (final item in items) ...<Widget>[
            _LearningCard(item: item),
            if (item != items.last)
              const SizedBox(height: _DrivingUiTokens.spaceS),
          ],
      ],
    );
  }
}

final class _LearningCard extends StatelessWidget {
  const _LearningCard({required this.item});

  final DrivingLearningItem item;

  @override
  Widget build(BuildContext context) {
    final accent = item.category == DrivingCategory.fahrschule
        ? AppColors.primary
        : AppColors.secondary;

    return AppGlassCard(
      padding: _DrivingUiTokens.cardPadding,
      borderColor: accent.withAlpha(_DrivingUiTokens.subtleAlpha),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppDirectionalText(
            item.topic.germanLabel,
            languageCode: 'de',
            style: AppTypography.label.copyWith(color: accent),
          ),
          const SizedBox(height: _DrivingUiTokens.spaceXs),
          AppDirectionalText(
            item.titleDe,
            languageCode: 'de',
            style: AppTypography.title,
          ),
          const SizedBox(height: _DrivingUiTokens.spaceXs),
          AppDirectionalText(
            item.german,
            languageCode: 'de',
            style: AppTypography.body,
          ),
          const SizedBox(height: _DrivingUiTokens.spaceS),
          AppDirectionalText(
            item.arabic,
            languageCode: 'ar',
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }
}
