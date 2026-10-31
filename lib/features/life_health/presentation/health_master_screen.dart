import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../../design_system/design_system.dart';
import '../application/health_master_orchestrator.dart';
import '../domain/health_models.dart';

final class HealthMasterScreen extends StatefulWidget {
  const HealthMasterScreen({
    required this.orchestrator,
    super.key,
  });

  final HealthMasterOrchestrator orchestrator;

  @override
  State<HealthMasterScreen> createState() => _HealthMasterScreenState();
}

final class _HealthMasterScreenState extends State<HealthMasterScreen> {
  HealthLevel? _level;
  String _query = '';

  List<HealthLearningItem> get _visibleItems {
    if (_query.trim().isNotEmpty) {
      return widget.orchestrator.searchSymptoms(_query, level: _level);
    }
    if (_level != null) {
      return widget.orchestrator.filterByLevel(_level!);
    }
    return widget.orchestrator.allItems;
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface = dark ? AppColors.darkSurface : AppColors.lightSurface;
    final border =
        dark ? AppColors.glassBorderDark : AppColors.glassBorderLight;
    final items = _visibleItems;

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
                _EmergencyBar(
                  actions: widget.orchestrator.emergencyActions,
                  surface: surface,
                  border: border,
                ),
                Divider(color: border),
                _LevelFilter(
                  selected: _level,
                  surface: surface,
                  border: border,
                  onSelected: (level) => setState(() => _level = level),
                  onClear: () => setState(() => _level = null),
                ),
                Divider(color: border),
                _SearchCard(
                  surface: surface,
                  border: border,
                  onChanged: (value) => setState(() => _query = value),
                ),
                Divider(color: border),
                _ServiceSection(
                  service: HealthService.pharmacy,
                  items: items
                      .where(
                        (item) => item.service == HealthService.pharmacy,
                      )
                      .toList(growable: false),
                  surface: surface,
                  border: border,
                ),
                Divider(color: border),
                _ServiceSection(
                  service: HealthService.hausarzt,
                  items: items
                      .where(
                        (item) => item.service == HealthService.hausarzt,
                      )
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
              'Apotheke & Hausarzt',
              languageCode: 'de',
              style: AppTypography.title.copyWith(color: AppColors.primary),
            ),
            AppDirectionalText(
              'مركز لغوي للخدمات الصحية: الصيدلية، طبيب الأسرة، وصف الأعراض والمواعيد.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
            AppDirectionalText(
              'Sprachtraining – keine medizinische Beratung.',
              languageCode: 'de',
              style: AppTypography.label.copyWith(color: AppColors.tertiary),
            ),
          ],
        ),
      );
}

final class _EmergencyBar extends StatelessWidget {
  const _EmergencyBar({
    required this.actions,
    required this.surface,
    required this.border,
  });

  final List<EmergencyQuickAction> actions;
  final Color surface;
  final Color border;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        backgroundColor: surface,
        borderColor: AppColors.tertiary,
        glowColor: AppColors.tertiary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'Notfall · طوارئ',
              languageCode: 'de',
              style: AppTypography.title.copyWith(color: AppColors.tertiary),
            ),
            for (final action in actions)
              AppGlassCard(
                backgroundColor: surface,
                borderColor: border,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    AppDirectionalText(
                      action.german,
                      languageCode: 'de',
                      style: AppTypography.body,
                    ),
                    AppDirectionalText(
                      action.arabic,
                      languageCode: 'ar',
                      style: AppTypography.body,
                    ),
                    AppDirectionalText(
                      action.phoneNumber,
                      languageCode: 'de',
                      style: AppTypography.title.copyWith(
                        color: AppColors.tertiary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
}

final class _LevelFilter extends StatelessWidget {
  const _LevelFilter({
    required this.selected,
    required this.surface,
    required this.border,
    required this.onSelected,
    required this.onClear,
  });

  final HealthLevel? selected;
  final Color surface;
  final Color border;
  final ValueChanged<HealthLevel> onSelected;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        backgroundColor: surface,
        borderColor: border,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'المستوى',
              languageCode: 'ar',
              style: AppTypography.title,
            ),
            Wrap(
              children: <Widget>[
                AppGlassCard(
                  onTap: onClear,
                  backgroundColor: surface,
                  borderColor:
                      selected == null ? AppColors.primary : border,
                  glowColor: selected == null ? AppColors.primary : null,
                  child: AppDirectionalText(
                    'Alle',
                    languageCode: 'de',
                    style: AppTypography.label,
                  ),
                ),
                for (final level in HealthLevel.values)
                  AppGlassCard(
                    onTap: () => onSelected(level),
                    backgroundColor: surface,
                    borderColor:
                        selected == level ? AppColors.primary : border,
                    glowColor:
                        selected == level ? AppColors.primary : null,
                    child: Column(
                      children: <Widget>[
                        AppDirectionalText(
                          level.german,
                          languageCode: 'de',
                          style: AppTypography.label,
                        ),
                        AppDirectionalText(
                          level.arabic,
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
              'ابحث عن لغة الأعراض',
              languageCode: 'ar',
              style: AppTypography.title,
            ),
            Directionality(
              textDirection: TextDirection.ltr,
              child: TextField(
                onChanged: onChanged,
                style: AppTypography.body,
                decoration: InputDecoration(
                  label: AppDirectionalText(
                    'Symptom suchen',
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

final class _ServiceSection extends StatelessWidget {
  const _ServiceSection({
    required this.service,
    required this.items,
    required this.surface,
    required this.border,
  });

  final HealthService service;
  final List<HealthLearningItem> items;
  final Color surface;
  final Color border;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        backgroundColor: surface,
        borderColor: border,
        glowColor: service == HealthService.pharmacy
            ? AppColors.secondary
            : AppColors.achievement,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              service.german,
              languageCode: 'de',
              style: AppTypography.title,
            ),
            AppDirectionalText(
              service.arabic,
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

  final HealthLearningItem item;
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
              item.level.german,
              languageCode: 'de',
              style: AppTypography.label.copyWith(
                color: AppColors.primary,
              ),
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
