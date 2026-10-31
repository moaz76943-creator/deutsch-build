import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../../design_system/design_system.dart';
import '../application/safety_master_orchestrator.dart';
import '../domain/safety_models.dart';

final class SafetyMasterScreen extends StatefulWidget {
  const SafetyMasterScreen({
    required this.orchestrator,
    super.key,
  });

  final SafetyMasterOrchestrator orchestrator;

  @override
  State<SafetyMasterScreen> createState() => _SafetyMasterScreenState();
}

final class _SafetyMasterScreenState extends State<SafetyMasterScreen> {
  SafetyCategory? _category;
  String _query = '';

  List<SafetyLearningItem> get _visibleItems {
    if (_query.trim().isNotEmpty) {
      return widget.orchestrator.search(_query, category: _category);
    }
    if (_category != null) {
      return widget.orchestrator.itemsForCategory(_category!);
    }
    return widget.orchestrator.allItems;
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface = dark ? AppColors.darkSurface : AppColors.lightSurface;
    final border =
        dark ? AppColors.glassBorderDark : AppColors.glassBorderLight;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            dark ? AppColors.darkBackground : AppColors.lightBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _HeaderCard(surface: surface, border: border),
                Divider(color: border),
                _PanicBar(
                  actions: widget.orchestrator.panicActions,
                  surface: surface,
                  border: border,
                ),
                Divider(color: border),
                _CategorySwitcher(
                  selected: _category,
                  surface: surface,
                  border: border,
                  onSelected: (category) =>
                      setState(() => _category = category),
                  onClear: () => setState(() => _category = null),
                ),
                Divider(color: border),
                _SearchCard(
                  surface: surface,
                  border: border,
                  onChanged: (value) => setState(() => _query = value),
                ),
                Divider(color: border),
                for (final category in SafetyCategory.values)
                  if (_category == null || _category == category)
                    _CategorySection(
                      category: category,
                      items: _visibleItems
                          .where((item) => item.category == category)
                          .toList(growable: false),
                      surface: surface,
                      border: border,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.surface,
    required this.border,
  });

  final Color surface;
  final Color border;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        backgroundColor: surface,
        borderColor: border,
        glowColor: AppColors.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'Pannenhilfe & Notfall',
              languageCode: 'de',
              style: AppTypography.title.copyWith(color: AppColors.primary),
            ),
            AppDirectionalText(
              'مركز لغوي للسلامة على الطريق، المساعدة عند الأعطال، والبلاغات الرسمية.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
            AppDirectionalText(
              'Im akuten Notfall zuerst die passende Notrufnummer wählen.',
              languageCode: 'de',
              style: AppTypography.label.copyWith(color: AppColors.tertiary),
            ),
          ],
        ),
      );
}

final class _PanicBar extends StatelessWidget {
  const _PanicBar({
    required this.actions,
    required this.surface,
    required this.border,
  });

  final List<SafetyPanicAction> actions;
  final Color surface;
  final Color border;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        key: const ValueKey<String>('safety-panic-bar'),
        backgroundColor: surface,
        borderColor: AppColors.tertiary,
        glowColor: AppColors.tertiary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'Soforthilfe · مساعدة فورية',
              languageCode: 'de',
              style: AppTypography.title.copyWith(color: AppColors.tertiary),
            ),
            AppDirectionalText(
              'اختر الرقم المناسب فقط عند وجود حالة طارئة فعلية، ثم استخدم النص الألماني المختصر لشرح الموقف والموقع.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
            for (final action in actions)
              AppGlassCard(
                backgroundColor: surface,
                borderColor: border,
                glowColor: AppColors.tertiary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    AppDirectionalText(
                      action.phoneNumber,
                      languageCode: 'de',
                      style: AppTypography.display.copyWith(
                        color: AppColors.tertiary,
                      ),
                    ),
                    AppDirectionalText(
                      action.authorityGerman,
                      languageCode: 'de',
                      style: AppTypography.label,
                    ),
                    AppDirectionalText(
                      action.authorityArabic,
                      languageCode: 'ar',
                      style: AppTypography.label,
                    ),
                    AppDirectionalText(
                      action.germanScript,
                      languageCode: 'de',
                      style: AppTypography.body,
                    ),
                    AppDirectionalText(
                      action.arabicGuide,
                      languageCode: 'ar',
                      style: AppTypography.body,
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
}

final class _CategorySwitcher extends StatelessWidget {
  const _CategorySwitcher({
    required this.selected,
    required this.surface,
    required this.border,
    required this.onSelected,
    required this.onClear,
  });

  final SafetyCategory? selected;
  final Color surface;
  final Color border;
  final ValueChanged<SafetyCategory> onSelected;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => AppGlassCard(
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
            Wrap(
              children: <Widget>[
                AppGlassCard(
                  key: const ValueKey<String>('safety-category-all'),
                  onTap: onClear,
                  backgroundColor: surface,
                  borderColor: selected == null ? AppColors.primary : border,
                  glowColor: selected == null ? AppColors.primary : null,
                  child: AppDirectionalText(
                    'Alle',
                    languageCode: 'de',
                    style: AppTypography.label,
                  ),
                ),
                for (final category in SafetyCategory.values)
                  AppGlassCard(
                    key: ValueKey<String>('safety-category-${category.name}'),
                    onTap: () => onSelected(category),
                    backgroundColor: surface,
                    borderColor:
                        selected == category ? AppColors.primary : border,
                    glowColor:
                        selected == category ? AppColors.primary : null,
                    child: Column(
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
                  ),
              ],
            ),
          ],
        ),
      );
}

final class _SearchCard extends StatelessWidget {
  const _SearchCard({
    required this.surface,
    required this.border,
    required this.onChanged,
  });

  final Color surface;
  final Color border;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        backgroundColor: surface,
        borderColor: border,
        glowColor: AppColors.secondary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'ابحث في عبارات السلامة والبلاغات',
              languageCode: 'ar',
              style: AppTypography.title,
            ),
            Directionality(
              textDirection: TextDirection.ltr,
              child: TextField(
                key: const ValueKey<String>('safety-search-field'),
                onChanged: onChanged,
                style: AppTypography.body,
                decoration: InputDecoration(
                  label: AppDirectionalText(
                    'Suchen',
                    languageCode: 'de',
                    style: AppTypography.label,
                  ),
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

final class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.category,
    required this.items,
    required this.surface,
    required this.border,
  });

  final SafetyCategory category;
  final List<SafetyLearningItem> items;
  final Color surface;
  final Color border;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        backgroundColor: surface,
        borderColor: border,
        glowColor: category == SafetyCategory.roadsideAssistance
            ? AppColors.secondary
            : AppColors.achievement,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              category.german,
              languageCode: 'de',
              style: AppTypography.title,
            ),
            AppDirectionalText(
              category.arabic,
              languageCode: 'ar',
              style: AppTypography.label,
            ),
            if (items.isEmpty)
              AppDirectionalText(
                'لا توجد عبارات مطابقة.',
                languageCode: 'ar',
                style: AppTypography.body,
              )
            else
              for (final item in items)
                _LearningCard(
                  item: item,
                  surface: surface,
                  border: border,
                ),
          ],
        ),
      );
}

final class _LearningCard extends StatelessWidget {
  const _LearningCard({
    required this.item,
    required this.surface,
    required this.border,
  });

  final SafetyLearningItem item;
  final Color surface;
  final Color border;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        backgroundColor: surface,
        borderColor: border,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              item.topic.german,
              languageCode: 'de',
              style: AppTypography.label.copyWith(color: AppColors.primary),
            ),
            AppDirectionalText(
              item.german,
              languageCode: 'de',
              style: AppTypography.title,
            ),
            AppDirectionalText(
              item.arabic,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}
