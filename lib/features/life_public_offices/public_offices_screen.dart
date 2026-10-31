import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../design_system/app_colors.dart';
import '../../design_system/app_glass_card.dart';
import '../../design_system/app_typography.dart' hide AppDirectionalText;
import 'public_office_models.dart';
import 'public_offices_master_orchestrator.dart';

abstract final class _PublicOfficeUiTokens {
  static const double pageInset = 16;
  static const double sectionGap = 14;
  static const double itemGap = 10;
  static const double controlGap = 8;
}

class PublicOfficesMasterHub extends StatefulWidget {
  const PublicOfficesMasterHub({
    this.orchestrator,
    this.onRouteSelected,
    super.key,
  });

  final PublicOfficesMasterOrchestrator? orchestrator;
  final ValueChanged<PublicOfficeRouteDescriptor>? onRouteSelected;

  @override
  State<PublicOfficesMasterHub> createState() => _PublicOfficesMasterHubState();
}

class _PublicOfficesMasterHubState extends State<PublicOfficesMasterHub> {
  late final PublicOfficesMasterOrchestrator _orchestrator;
  late final bool _ownsOrchestrator;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _ownsOrchestrator = widget.orchestrator == null;
    _orchestrator = widget.orchestrator ?? PublicOfficesMasterOrchestrator();
    _searchController = TextEditingController(text: _orchestrator.query);
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
    return AnimatedBuilder(
      animation: _orchestrator,
      builder: (context, _) {
        final routes = _orchestrator.visibleRoutes;

        return Scaffold(
          appBar: AppBar(
            title: AppDirectionalText(
              'Behörden & Verwaltung',
              languageCode: 'de',
              style: AppTypography.title,
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(_PublicOfficeUiTokens.pageInset),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const _IntroCard(),
                  const SizedBox(height: _PublicOfficeUiTokens.sectionGap),
                  _OfficeFilter(orchestrator: _orchestrator),
                  const SizedBox(height: _PublicOfficeUiTokens.sectionGap),
                  _SearchCard(
                    orchestrator: _orchestrator,
                    controller: _searchController,
                  ),
                  const SizedBox(height: _PublicOfficeUiTokens.sectionGap),
                  if (routes.isEmpty)
                    const _EmptyState()
                  else
                    for (final route in routes) ...<Widget>[
                      _RouteCard(
                        route: route,
                        dependency:
                            _orchestrator.dependencyFor(route.id) != null,
                        onTap: widget.onRouteSelected == null
                            ? null
                            : () => widget.onRouteSelected!(route),
                      ),
                      const SizedBox(height: _PublicOfficeUiTokens.itemGap),
                    ],
                  if (_orchestrator.appointments.isNotEmpty) ...<Widget>[
                    const SizedBox(height: _PublicOfficeUiTokens.sectionGap),
                    _AppointmentsCard(
                      appointments: _orchestrator.appointments,
                    ),
                  ],
                  if (_orchestrator.documents.isNotEmpty) ...<Widget>[
                    const SizedBox(height: _PublicOfficeUiTokens.sectionGap),
                    _DocumentsCard(documents: _orchestrator.documents),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

final class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return AppGlassCard(
      glowColor: AppColors.primary,
      borderColor: AppColors.primary.withAlpha(76),
      backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppDirectionalText(
            'Öffentliche Stellen sicher vorbereiten',
            languageCode: 'de',
            style: AppTypography.title.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: _PublicOfficeUiTokens.controlGap),
          AppDirectionalText(
            'مركز موحد لتجهيز المعاملات الرسمية والمواعيد والوثائق قبل زيارة الدائرة.',
            languageCode: 'ar',
            style: AppTypography.body,
          ),
          const SizedBox(height: _PublicOfficeUiTokens.controlGap),
          AppDirectionalText(
            'Lokale Anforderungen können je nach Behörde und Anliegen abweichen. Angaben vor dem Termin bei der zuständigen Stelle prüfen.',
            languageCode: 'de',
            style: AppTypography.label,
          ),
        ],
      ),
    );
  }
}

final class _OfficeFilter extends StatelessWidget {
  const _OfficeFilter({required this.orchestrator});

  final PublicOfficesMasterOrchestrator orchestrator;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return AppGlassCard(
      borderColor: AppColors.secondary.withAlpha(72),
      backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppDirectionalText(
            'Behörde wählen',
            languageCode: 'de',
            style: AppTypography.title,
          ),
          const SizedBox(height: _PublicOfficeUiTokens.controlGap),
          Wrap(
            spacing: _PublicOfficeUiTokens.controlGap,
            runSpacing: _PublicOfficeUiTokens.controlGap,
            children: <Widget>[
              for (final office in PublicOfficeType.values)
                ChoiceChip(
                  key: ValueKey<String>('public-office-' + office.name),
                  selected: orchestrator.office == office,
                  onSelected: (_) => orchestrator.setOffice(office),
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      AppDirectionalText(
                        office.labelDe,
                        languageCode: 'de',
                        style: AppTypography.label,
                      ),
                      AppDirectionalText(
                        office.labelAr,
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
}

final class _SearchCard extends StatelessWidget {
  const _SearchCard({
    required this.orchestrator,
    required this.controller,
  });

  final PublicOfficesMasterOrchestrator orchestrator;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return AppGlassCard(
      borderColor: AppColors.primary.withAlpha(64),
      backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
      child: TextField(
        key: const ValueKey<String>('public-office-search'),
        controller: controller,
        onChanged: orchestrator.setQuery,
        textDirection: TextDirection.rtl,
        style: AppTypography.body,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search_rounded),
          label: AppDirectionalText(
            'ابحث بالألمانية أو العربية',
            languageCode: 'ar',
            style: AppTypography.label,
          ),
          suffixIcon: orchestrator.query.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Suche löschen',
                  onPressed: () {
                    controller.clear();
                    orchestrator.setQuery('');
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
        ),
      ),
    );
  }
}

final class _RouteCard extends StatelessWidget {
  const _RouteCard({
    required this.route,
    required this.dependency,
    required this.onTap,
  });

  final PublicOfficeRouteDescriptor route;
  final bool dependency;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return AppGlassCard(
      onTap: onTap,
      glowColor: AppColors.secondary,
      borderColor: AppColors.secondary.withAlpha(70),
      backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.account_balance_rounded,
                color: AppColors.secondary,
              ),
              const SizedBox(width: _PublicOfficeUiTokens.controlGap),
              Expanded(
                child: AppDirectionalText(
                  route.titleDe,
                  languageCode: 'de',
                  style: AppTypography.title,
                ),
              ),
              Icon(
                dependency
                    ? Icons.link_rounded
                    : Icons.arrow_forward_ios_rounded,
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: _PublicOfficeUiTokens.controlGap),
          AppDirectionalText(
            route.titleAr,
            languageCode: 'ar',
            style: AppTypography.label,
          ),
          const SizedBox(height: _PublicOfficeUiTokens.controlGap),
          AppDirectionalText(
            route.descriptionDe,
            languageCode: 'de',
            style: AppTypography.body,
          ),
          const SizedBox(height: _PublicOfficeUiTokens.controlGap),
          AppDirectionalText(
            route.descriptionAr,
            languageCode: 'ar',
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }
}

final class _AppointmentsCard extends StatelessWidget {
  const _AppointmentsCard({required this.appointments});

  final List<OfficialAppointment> appointments;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return AppGlassCard(
      borderColor: AppColors.tertiary.withAlpha(72),
      backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppDirectionalText(
            'Termine',
            languageCode: 'de',
            style: AppTypography.title,
          ),
          const SizedBox(height: _PublicOfficeUiTokens.controlGap),
          for (final appointment in appointments) ...<Widget>[
            AppDirectionalText(
              appointment.purposeDe,
              languageCode: 'de',
              style: AppTypography.body,
            ),
            AppDirectionalText(
              appointment.purposeAr,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
            const SizedBox(height: _PublicOfficeUiTokens.controlGap),
          ],
        ],
      ),
    );
  }
}

final class _DocumentsCard extends StatelessWidget {
  const _DocumentsCard({required this.documents});

  final List<OfficialDocument> documents;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return AppGlassCard(
      borderColor: AppColors.primary.withAlpha(72),
      backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppDirectionalText(
            'Dokumente',
            languageCode: 'de',
            style: AppTypography.title,
          ),
          const SizedBox(height: _PublicOfficeUiTokens.controlGap),
          for (final document in documents) ...<Widget>[
            AppDirectionalText(
              document.titleDe,
              languageCode: 'de',
              style: AppTypography.body,
            ),
            AppDirectionalText(
              document.titleAr,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
            const SizedBox(height: _PublicOfficeUiTokens.controlGap),
          ],
        ],
      ),
    );
  }
}

final class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return AppGlassCard(
      borderColor: AppColors.secondary.withAlpha(64),
      backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
      child: AppDirectionalText(
        'لا توجد نتائج مطابقة. غيّر الدائرة أو عبارة البحث.',
        languageCode: 'ar',
        style: AppTypography.body,
        textAlign: TextAlign.center,
      ),
    );
  }
}
