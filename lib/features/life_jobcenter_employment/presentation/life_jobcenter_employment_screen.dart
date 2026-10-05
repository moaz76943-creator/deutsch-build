import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../../design_system/design_system.dart';
import '../application/jobcenter_master_orchestrator.dart';
import '../domain/jobcenter_models.dart';

abstract final class _JobcenterUiTokens {
  static const double pageInset = 16;
  static const double topInset = 18;
  static const double bottomInset = 32;
  static const double sectionGap = 14;
  static const double contentGap = 10;
  static const double smallGap = 7;
  static const double chipHorizontal = 12;
  static const double chipVertical = 9;
}

final class LifeJobcenterEmploymentScreen extends StatefulWidget {
  const LifeJobcenterEmploymentScreen({
    required this.orchestrator,
    this.onOpenRoute,
    super.key,
  });

  final JobcenterMasterOrchestrator orchestrator;
  final ValueChanged<JobcenterRouteSpec>? onOpenRoute;

  @override
  State<LifeJobcenterEmploymentScreen> createState() =>
      _LifeJobcenterEmploymentScreenState();
}

final class _LifeJobcenterEmploymentScreenState
    extends State<LifeJobcenterEmploymentScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  JobcenterMasterOrchestrator get orchestrator =>
      widget.orchestrator;

  @override
  void initState() {
    super.initState();
    orchestrator.addListener(_refresh);
  }

  @override
  void didUpdateWidget(
    covariant LifeJobcenterEmploymentScreen oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orchestrator == orchestrator) return;
    oldWidget.orchestrator.removeListener(_refresh);
    orchestrator.addListener(_refresh);
    _searchController.text = orchestrator.query;
  }

  @override
  void dispose() {
    orchestrator.removeListener(_refresh);
    _searchController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _selectSection(JobcenterSection section) {
    _searchController.clear();
    orchestrator.setSection(section);
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    final surface =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border = isDark
        ? AppColors.glassBorderDark
        : AppColors.glassBorderLight;
    final activeRoute = orchestrator.activeRoute;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.darkBackground
            : AppColors.lightBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              _JobcenterUiTokens.pageInset,
              _JobcenterUiTokens.topInset,
              _JobcenterUiTokens.pageInset,
              _JobcenterUiTokens.bottomInset,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _HeaderCard(surface: surface, border: border),
                const SizedBox(
                  height: _JobcenterUiTokens.sectionGap,
                ),
                _ProtectionNote(
                  surface: surface,
                  border: border,
                ),
                const SizedBox(
                  height: _JobcenterUiTokens.sectionGap,
                ),
                _SectionSelector(
                  activeSection: orchestrator.activeSection,
                  surface: surface,
                  border: border,
                  onSelected: _selectSection,
                ),
                const SizedBox(
                  height: _JobcenterUiTokens.sectionGap,
                ),
                _SearchCard(
                  controller: _searchController,
                  query: orchestrator.query,
                  surface: surface,
                  border: border,
                  onChanged: orchestrator.setQuery,
                  onClear: () {
                    _searchController.clear();
                    orchestrator.clearSearch();
                  },
                ),
                const SizedBox(
                  height: _JobcenterUiTokens.sectionGap,
                ),
                if (orchestrator.activeSection ==
                    JobcenterSection.overview) ...<Widget>[
                  _SharedModelsCard(
                    orchestrator: orchestrator,
                    surface: surface,
                    border: border,
                  ),
                  const SizedBox(
                    height: _JobcenterUiTokens.sectionGap,
                  ),
                ],
                _EntriesSection(
                  entries: orchestrator.visibleEntries,
                  surface: surface,
                  border: border,
                ),
                if (activeRoute != null) ...<Widget>[
                  const SizedBox(
                    height: _JobcenterUiTokens.sectionGap,
                  ),
                  _RouteCard(
                    route: activeRoute,
                    surface: surface,
                    border: border,
                    onOpen: widget.onOpenRoute,
                  ),
                ],
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
              'Jobcenter & Agentur für Arbeit',
              languageCode: 'de',
              style: AppTypography.title.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: _JobcenterUiTokens.smallGap),
            AppDirectionalText(
              'مركز التوظيف والدعم',
              languageCode: 'ar',
              style: AppTypography.title,
            ),
            const SizedBox(height: _JobcenterUiTokens.smallGap),
            AppDirectionalText(
              'تنظيم لغوي لطلبات Bürgergeld، دورات اللغة والاندماج، ومواعيد الاستشارة دون افتراض الموافقة أو الاستحقاق.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

final class _ProtectionNote extends StatelessWidget {
  const _ProtectionNote({
    required this.surface,
    required this.border,
  });

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
              'Schützender Hinweis',
              languageCode: 'de',
              style: AppTypography.label.copyWith(
                color: AppColors.tertiary,
              ),
            ),
            const SizedBox(height: _JobcenterUiTokens.smallGap),
            AppDirectionalText(
              'المهل والمستندات والمبالغ قد تختلف حسب حالتك والإشعار الرسمي. استخدم العبارات للتحضير، وراجع دائماً Bescheid أو تعليمات الجهة المختصة.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

final class _SectionSelector extends StatelessWidget {
  const _SectionSelector({
    required this.activeSection,
    required this.surface,
    required this.border,
    required this.onSelected,
  });

  final JobcenterSection activeSection;
  final Color surface;
  final Color border;
  final ValueChanged<JobcenterSection> onSelected;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: _JobcenterUiTokens.contentGap,
        runSpacing: _JobcenterUiTokens.contentGap,
        children: <Widget>[
          for (final section in JobcenterSection.values)
            AppGlassCard(
              onTap: () => onSelected(section),
              backgroundColor: surface,
              borderColor: section == activeSection
                  ? AppColors.secondary
                  : border,
              glowColor: section == activeSection
                  ? AppColors.secondary
                  : null,
              padding: const EdgeInsets.symmetric(
                horizontal: _JobcenterUiTokens.chipHorizontal,
                vertical: _JobcenterUiTokens.chipVertical,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  AppDirectionalText(
                    section.labelDe,
                    languageCode: 'de',
                    style: AppTypography.label,
                  ),
                  AppDirectionalText(
                    section.labelAr,
                    languageCode: 'ar',
                    style: AppTypography.label,
                  ),
                ],
              ),
            ),
        ],
      );
}

final class _SearchCard extends StatelessWidget {
  const _SearchCard({
    required this.controller,
    required this.query,
    required this.surface,
    required this.border,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final String query;
  final Color surface;
  final Color border;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        backgroundColor: surface,
        borderColor: border,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'Suche · بحث',
              languageCode: 'de',
              style: AppTypography.label,
            ),
            const SizedBox(height: _JobcenterUiTokens.smallGap),
            Directionality(
              textDirection: TextDirection.ltr,
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  hintText:
                      'Bürgergeld, Sprachkurs, Bescheid ...',
                  suffixIcon: query.isEmpty
                      ? const Icon(Icons.search_rounded)
                      : IconButton(
                          onPressed: onClear,
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
              ),
            ),
          ],
        ),
      );
}

final class _SharedModelsCard extends StatelessWidget {
  const _SharedModelsCard({
    required this.orchestrator,
    required this.surface,
    required this.border,
  });

  final JobcenterMasterOrchestrator orchestrator;
  final Color surface;
  final Color border;

  @override
  Widget build(BuildContext context) {
    final benefit = orchestrator.benefitRequests.first;
    final course = orchestrator.courseRequests.first;
    final appointment = orchestrator.appointments.first;

    return AppGlassCard(
      backgroundColor: surface,
      borderColor: border,
      glowColor: AppColors.achievement,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppDirectionalText(
            'Gemeinsame Vorgangsmodelle',
            languageCode: 'de',
            style: AppTypography.title.copyWith(
              color: AppColors.achievement,
            ),
          ),
          const SizedBox(height: _JobcenterUiTokens.contentGap),
          _ModelRow(
            titleDe: benefit.programNameDe,
            titleAr: benefit.programNameAr,
            statusDe: benefit.status.labelDe,
            statusAr: benefit.status.labelAr,
          ),
          const SizedBox(height: _JobcenterUiTokens.contentGap),
          _ModelRow(
            titleDe: course.courseNameDe,
            titleAr: course.courseNameAr,
            statusDe: course.status.labelDe,
            statusAr: course.status.labelAr,
          ),
          const SizedBox(height: _JobcenterUiTokens.contentGap),
          _ModelRow(
            titleDe: appointment.officeNameDe,
            titleAr: appointment.officeNameAr,
            statusDe: appointment.status.labelDe,
            statusAr: appointment.status.labelAr,
          ),
        ],
      ),
    );
  }
}

final class _ModelRow extends StatelessWidget {
  const _ModelRow({
    required this.titleDe,
    required this.titleAr,
    required this.statusDe,
    required this.statusAr,
  });

  final String titleDe;
  final String titleAr;
  final String statusDe;
  final String statusAr;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppDirectionalText(
            titleDe,
            languageCode: 'de',
            style: AppTypography.label,
          ),
          AppDirectionalText(
            titleAr,
            languageCode: 'ar',
            style: AppTypography.body,
          ),
          const SizedBox(height: _JobcenterUiTokens.smallGap),
          AppDirectionalText(
            '$statusDe · $statusAr',
            languageCode: 'de',
            style: AppTypography.label,
          ),
        ],
      );
}

final class _EntriesSection extends StatelessWidget {
  const _EntriesSection({
    required this.entries,
    required this.surface,
    required this.border,
  });

  final List<JobcenterHubEntry> entries;
  final Color surface;
  final Color border;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return AppGlassCard(
        backgroundColor: surface,
        borderColor: AppColors.tertiary,
        child: AppDirectionalText(
          'لا توجد نتائج في هذا القسم. جرّب كلمة أخرى.',
          languageCode: 'ar',
          style: AppTypography.body,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (var index = 0; index < entries.length; index++) ...<Widget>[
          AppGlassCard(
            backgroundColor: surface,
            borderColor: border,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AppDirectionalText(
                  entries[index].titleDe,
                  languageCode: 'de',
                  style: AppTypography.title,
                ),
                const SizedBox(
                  height: _JobcenterUiTokens.smallGap,
                ),
                AppDirectionalText(
                  entries[index].titleAr,
                  languageCode: 'ar',
                  style: AppTypography.label,
                ),
                const SizedBox(
                  height: _JobcenterUiTokens.smallGap,
                ),
                AppDirectionalText(
                  entries[index].bodyDe,
                  languageCode: 'de',
                  style: AppTypography.body,
                ),
                const SizedBox(
                  height: _JobcenterUiTokens.smallGap,
                ),
                AppDirectionalText(
                  entries[index].bodyAr,
                  languageCode: 'ar',
                  style: AppTypography.body,
                ),
              ],
            ),
          ),
          if (index != entries.length - 1)
            const SizedBox(
              height: _JobcenterUiTokens.contentGap,
            ),
        ],
      ],
    );
  }
}

final class _RouteCard extends StatelessWidget {
  const _RouteCard({
    required this.route,
    required this.surface,
    required this.border,
    required this.onOpen,
  });

  final JobcenterRouteSpec route;
  final Color surface;
  final Color border;
  final ValueChanged<JobcenterRouteSpec>? onOpen;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        onTap: onOpen == null ? null : () => onOpen!(route),
        backgroundColor: surface,
        borderColor: AppColors.primary,
        glowColor: AppColors.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              route.labelDe,
              languageCode: 'de',
              style: AppTypography.title,
            ),
            AppDirectionalText(
              route.labelAr,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
            const SizedBox(height: _JobcenterUiTokens.smallGap),
            AppDirectionalText(
              route.path,
              languageCode: 'de',
              style: AppTypography.label,
            ),
          ],
        ),
      );
}
