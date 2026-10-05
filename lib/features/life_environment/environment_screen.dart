import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../design_system/design_system.dart';
import 'environment_master_orchestrator.dart';
import 'environment_models.dart';

abstract final class EnvironmentUiTokens {
  static const double pageInset = 16;
  static const double bottomInset = 32;
  static const double sectionGap = 18;
  static const double itemGap = 12;
  static const double compactGap = 8;
}

final class EnvironmentMasterHub extends StatefulWidget {
  const EnvironmentMasterHub({
    this.orchestrator,
    super.key,
  });

  final EnvironmentMasterOrchestrator? orchestrator;

  @override
  State<EnvironmentMasterHub> createState() => _EnvironmentMasterHubState();
}

final class _EnvironmentMasterHubState extends State<EnvironmentMasterHub> {
  late final EnvironmentMasterOrchestrator _orchestrator;
  late final bool _ownsOrchestrator;

  @override
  void initState() {
    super.initState();
    _ownsOrchestrator = widget.orchestrator == null;
    _orchestrator = widget.orchestrator ?? EnvironmentMasterOrchestrator();
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
              EnvironmentUiTokens.pageInset,
              EnvironmentUiTokens.pageInset,
              EnvironmentUiTokens.pageInset,
              EnvironmentUiTokens.bottomInset,
            ),
            child: AnimatedBuilder(
              animation: _orchestrator,
              builder: (context, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _HeaderCard(dark: dark),
                  const SizedBox(height: EnvironmentUiTokens.sectionGap),
                  _UrgentWeatherAlertBar(
                    orchestrator: _orchestrator,
                    dark: dark,
                  ),
                  const SizedBox(height: EnvironmentUiTokens.sectionGap),
                  _SearchField(orchestrator: _orchestrator),
                  const SizedBox(height: EnvironmentUiTokens.itemGap),
                  _CategorySelector(
                    orchestrator: _orchestrator,
                    dark: dark,
                  ),
                  const SizedBox(height: EnvironmentUiTokens.sectionGap),
                  _EntryList(
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
              'Wetterwarnung & Gartenpflege',
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: EnvironmentUiTokens.compactGap),
            AppDirectionalText(
              'مفردات عملية لتحذيرات الطقس والعناية بالحديقة والشرفة مع قواعد واضحة للحماية والهدوء.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

final class _UrgentWeatherAlertBar extends StatelessWidget {
  const _UrgentWeatherAlertBar({
    required this.orchestrator,
    required this.dark,
  });

  final EnvironmentMasterOrchestrator orchestrator;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final active = orchestrator.activeUrgentAlert;
    return AppGlassCard(
      glowColor: AppColors.secondary,
      borderColor: AppColors.secondary.withAlpha(112),
      backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppDirectionalText(
            'Urgent Weather Alert Bar',
            languageCode: 'de',
            style: AppTypography.title,
          ),
          const SizedBox(height: EnvironmentUiTokens.compactGap),
          Wrap(
            spacing: EnvironmentUiTokens.compactGap,
            runSpacing: EnvironmentUiTokens.compactGap,
            children: <Widget>[
              for (final alert in orchestrator.urgentAlerts)
                ChoiceChip(
                  key: ValueKey<String>(
                    'environment-alert-${alert.kind.name}',
                  ),
                  selected: active?.kind == alert.kind,
                  onSelected: (_) => orchestrator.selectUrgentAlert(alert.kind),
                  avatar: Icon(
                    alert.kind == UrgentWeatherKind.unwetter
                        ? Icons.thunderstorm_outlined
                        : Icons.ac_unit_outlined,
                  ),
                  label: Text(
                    '${alert.titleDe} · ${alert.titleAr}',
                    style: AppTypography.label,
                  ),
                ),
            ],
          ),
          if (active != null) ...<Widget>[
            const SizedBox(height: EnvironmentUiTokens.itemGap),
            AppDirectionalText(
              active.scriptDe,
              languageCode: 'de',
              style: AppTypography.body,
            ),
            const SizedBox(height: EnvironmentUiTokens.compactGap),
            AppDirectionalText(
              active.scriptAr,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton.icon(
                onPressed: orchestrator.clearUrgentAlert,
                icon: const Icon(Icons.close),
                label: const Text('Schließen'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

final class _SearchField extends StatelessWidget {
  const _SearchField({required this.orchestrator});

  final EnvironmentMasterOrchestrator orchestrator;

  @override
  Widget build(BuildContext context) => TextField(
        key: const ValueKey<String>('environment-search'),
        onChanged: orchestrator.setQuery,
        textDirection: TextDirection.ltr,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search),
          labelText: 'Suche · بحث',
          hintText: 'DWD, Glätte, Balkon, Hecke ...',
          border: OutlineInputBorder(),
        ),
      );
}

final class _CategorySelector extends StatelessWidget {
  const _CategorySelector({
    required this.orchestrator,
    required this.dark,
  });

  final EnvironmentMasterOrchestrator orchestrator;
  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.tertiary.withAlpha(96),
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Wrap(
          spacing: EnvironmentUiTokens.compactGap,
          runSpacing: EnvironmentUiTokens.compactGap,
          children: <Widget>[
            for (final category in EnvironmentCategory.values)
              FilterChip(
                key: ValueKey<String>(
                  'environment-category-${category.name}',
                ),
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

final class _EntryList extends StatelessWidget {
  const _EntryList({
    required this.orchestrator,
    required this.dark,
  });

  final EnvironmentMasterOrchestrator orchestrator;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final entries = orchestrator.visibleEntries;
    if (entries.isEmpty) {
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
        for (var index = 0; index < entries.length; index++) ...<Widget>[
          _EnvironmentEntryCard(entry: entries[index], dark: dark),
          if (index != entries.length - 1)
            const SizedBox(height: EnvironmentUiTokens.itemGap),
        ],
      ],
    );
  }
}

final class _EnvironmentEntryCard extends StatelessWidget {
  const _EnvironmentEntryCard({
    required this.entry,
    required this.dark,
  });

  final EnvironmentEntry entry;
  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.primary.withAlpha(80),
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              entry.titleDe,
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: EnvironmentUiTokens.compactGap),
            AppDirectionalText(
              entry.titleAr,
              languageCode: 'ar',
              style: AppTypography.label,
            ),
            const SizedBox(height: EnvironmentUiTokens.itemGap),
            AppDirectionalText(
              entry.german,
              languageCode: 'de',
              style: AppTypography.body,
            ),
            const SizedBox(height: EnvironmentUiTokens.compactGap),
            AppDirectionalText(
              entry.arabic,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
            const SizedBox(height: EnvironmentUiTokens.itemGap),
            AppDirectionalText(
              entry.contextDe,
              languageCode: 'de',
              style: AppTypography.label,
            ),
            const SizedBox(height: EnvironmentUiTokens.compactGap),
            AppDirectionalText(
              entry.contextAr,
              languageCode: 'ar',
              style: AppTypography.label,
            ),
            if (entry.sourceLabel case final source?) ...<Widget>[
              const SizedBox(height: EnvironmentUiTokens.compactGap),
              Text(
                source,
                textDirection: TextDirection.ltr,
                style: AppTypography.label,
              ),
            ],
          ],
        ),
      );
}
