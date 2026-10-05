import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../design_system/design_system.dart';
import 'postal_logistics_sub_agent.dart';
import 'services_master_orchestrator.dart';
import 'telecom_sub_agent.dart';

abstract final class _ServicesUiTokens {
  static const double pageInset = 16;
  static const double sectionGap = 14;
  static const double itemGap = 10;
  static const double compactGap = 8;
  static const double fieldRadius = 18;
  static const double iconSize = 22;
  static const int softBorderAlpha = 88;
  static const int subtleBorderAlpha = 56;
  static const int selectedAlpha = 34;
}

final class ServicesMasterHubScreen extends StatefulWidget {
  const ServicesMasterHubScreen({
    this.orchestrator,
    this.postalAgent = const PostalLogisticsSubAgent(),
    this.telecomAgent = const TelecomSubAgent(),
    super.key,
  });

  final ServicesMasterOrchestrator? orchestrator;
  final PostalLogisticsSubAgent postalAgent;
  final TelecomSubAgent telecomAgent;

  @override
  State<ServicesMasterHubScreen> createState() =>
      _ServicesMasterHubScreenState();
}

final class _ServicesMasterHubScreenState
    extends State<ServicesMasterHubScreen> {
  late final ServicesMasterOrchestrator _orchestrator;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _orchestrator = widget.orchestrator ??
        ServicesMasterOrchestrator(
          entries: <ServicePhrase>[
            ...PostalLogisticsSubAgent.entries,
            ...TelecomSubAgent.entries,
          ],
        );
    _searchController = TextEditingController(text: _orchestrator.query);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  TextDirection get _searchDirection =>
      RegExp(r'[ء-ي]').hasMatch(_searchController.text)
          ? TextDirection.rtl
          : TextDirection.ltr;

  Color _surface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkSurface
          : AppColors.lightSurface;

  void _setQuery(String value) {
    setState(() {
      _orchestrator.setQuery(value);
    });
  }

  void _toggleCategory(ServiceCategory category) {
    setState(() {
      _orchestrator.toggleCategory(category);
    });
  }

  void _setTrackingStatus(PackageTrackingStatus status) {
    setState(() {
      _orchestrator.setTrackingStatus(status);
    });
  }

  void _activateMissingPackage() {
    setState(() {
      _orchestrator.activateMissingPackagePanic();
    });
  }

  void _dismissMissingPackage() {
    setState(() {
      _orchestrator.dismissMissingPackagePanic();
    });
  }

  @override
  Widget build(BuildContext context) {
    final entries = _orchestrator.visibleEntries;
    final surface = _surface(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(_ServicesUiTokens.pageInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _HeaderCard(surface: surface),
              const SizedBox(height: _ServicesUiTokens.sectionGap),
              _TrackingCard(
                surface: surface,
                current: _orchestrator.trackingStatus,
                guidance: _orchestrator.trackingGuidance,
                onChanged: _setTrackingStatus,
              ),
              const SizedBox(height: _ServicesUiTokens.sectionGap),
              _CategoryCard(
                surface: surface,
                selected: _orchestrator.selectedCategories,
                onToggle: _toggleCategory,
              ),
              const SizedBox(height: _ServicesUiTokens.sectionGap),
              _SearchCard(
                surface: surface,
                controller: _searchController,
                textDirection: _searchDirection,
                onChanged: _setQuery,
              ),
              const SizedBox(height: _ServicesUiTokens.sectionGap),
              _MissingPackageBar(
                surface: surface,
                expanded: _orchestrator.missingPackageExpanded,
                onActivate: _activateMissingPackage,
                onDismiss: _dismissMissingPackage,
              ),
              const SizedBox(height: _ServicesUiTokens.sectionGap),
              _ResultsHeader(count: entries.length),
              const SizedBox(height: _ServicesUiTokens.itemGap),
              if (entries.isEmpty)
                _EmptyResultsCard(surface: surface)
              else
                for (var index = 0; index < entries.length; index++) ...<Widget>[
                  _ServicePhraseCard(
                    entry: entries[index],
                    surface: surface,
                  ),
                  if (index != entries.length - 1)
                    const SizedBox(height: _ServicesUiTokens.itemGap),
                ],
            ],
          ),
        ),
      ),
    );
  }
}

final class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.surface});

  final Color surface;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        key: const ValueKey<String>('services-master-header'),
        backgroundColor: surface,
        borderColor:
            AppColors.primary.withAlpha(_ServicesUiTokens.softBorderAlpha),
        glowColor: AppColors.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'الخدمات اليومية: البريد والإنترنت',
              languageCode: 'ar',
              style: AppTypography.title,
            ),
            const SizedBox(height: _ServicesUiTokens.compactGap),
            AppDirectionalText(
              'Post, Pakete & Internet',
              languageCode: 'de',
              style: AppTypography.display.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: _ServicesUiTokens.compactGap),
            AppDirectionalText(
              'عبارات عملية للطرود، البريد المسجل، الجمارك، Packstation، إعداد الإنترنت، SIM وإنهاء العقود.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

final class _TrackingCard extends StatelessWidget {
  const _TrackingCard({
    required this.surface,
    required this.current,
    required this.guidance,
    required this.onChanged,
  });

  final Color surface;
  final PackageTrackingStatus current;
  final PackageStatusGuidance guidance;
  final ValueChanged<PackageTrackingStatus> onChanged;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        key: const ValueKey<String>('package-tracking-status-card'),
        backgroundColor: surface,
        borderColor:
            AppColors.secondary.withAlpha(_ServicesUiTokens.softBorderAlpha),
        glowColor: AppColors.secondary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'حالة تتبع الشحنة',
              languageCode: 'ar',
              style: AppTypography.title,
            ),
            const SizedBox(height: _ServicesUiTokens.itemGap),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Wrap(
                spacing: _ServicesUiTokens.compactGap,
                runSpacing: _ServicesUiTokens.compactGap,
                children: <Widget>[
                  for (final status in PackageTrackingStatus.values)
                    ChoiceChip(
                      key: ValueKey<String>('tracking-${status.name}'),
                      selected: current == status,
                      selectedColor: AppColors.secondary
                          .withAlpha(_ServicesUiTokens.selectedAlpha),
                      side: BorderSide(
                        color: AppColors.secondary.withAlpha(
                          _ServicesUiTokens.subtleBorderAlpha,
                        ),
                      ),
                      label: AppDirectionalText(
                        status.labelDe,
                        languageCode: 'de',
                        style: AppTypography.label,
                      ),
                      onSelected: (_) => onChanged(status),
                    ),
                ],
              ),
            ),
            const SizedBox(height: _ServicesUiTokens.itemGap),
            AppDirectionalText(
              guidance.titleDe,
              languageCode: 'de',
              style: AppTypography.label.copyWith(color: AppColors.secondary),
            ),
            AppDirectionalText(
              guidance.titleAr,
              languageCode: 'ar',
              style: AppTypography.label,
            ),
            const SizedBox(height: _ServicesUiTokens.compactGap),
            AppDirectionalText(
              guidance.detailDe,
              languageCode: 'de',
              style: AppTypography.body,
            ),
            AppDirectionalText(
              guidance.detailAr,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

final class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.surface,
    required this.selected,
    required this.onToggle,
  });

  final Color surface;
  final Set<ServiceCategory> selected;
  final ValueChanged<ServiceCategory> onToggle;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        key: const ValueKey<String>('services-category-card'),
        backgroundColor: surface,
        borderColor:
            AppColors.tertiary.withAlpha(_ServicesUiTokens.softBorderAlpha),
        glowColor: AppColors.tertiary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'اختر القسم',
              languageCode: 'ar',
              style: AppTypography.title,
            ),
            const SizedBox(height: _ServicesUiTokens.itemGap),
            Wrap(
              spacing: _ServicesUiTokens.compactGap,
              runSpacing: _ServicesUiTokens.compactGap,
              children: <Widget>[
                for (final category in ServiceCategory.values)
                  FilterChip(
                    key: ValueKey<String>('category-${category.name}'),
                    selected: selected.contains(category),
                    selectedColor: AppColors.tertiary
                        .withAlpha(_ServicesUiTokens.selectedAlpha),
                    side: BorderSide(
                      color: AppColors.tertiary.withAlpha(
                        _ServicesUiTokens.subtleBorderAlpha,
                      ),
                    ),
                    label: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        AppDirectionalText(
                          category.labelAr,
                          languageCode: 'ar',
                          style: AppTypography.label,
                        ),
                        AppDirectionalText(
                          category.labelDe,
                          languageCode: 'de',
                          style: AppTypography.label,
                        ),
                      ],
                    ),
                    onSelected: (_) => onToggle(category),
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
    required this.controller,
    required this.textDirection,
    required this.onChanged,
  });

  final Color surface;
  final TextEditingController controller;
  final TextDirection textDirection;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        backgroundColor: surface,
        borderColor:
            AppColors.primary.withAlpha(_ServicesUiTokens.subtleBorderAlpha),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'بحث سريع بالألمانية أو العربية',
              languageCode: 'ar',
              style: AppTypography.label,
            ),
            const SizedBox(height: _ServicesUiTokens.compactGap),
            TextField(
              key: const ValueKey<String>('services-search-field'),
              controller: controller,
              textDirection: textDirection,
              style: AppTypography.body,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: 'Einschreiben · Kündigung · Packstation · SIM',
                hintStyle: AppTypography.body,
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.primary,
                  size: _ServicesUiTokens.iconSize,
                ),
                filled: true,
                fillColor: surface,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(_ServicesUiTokens.fieldRadius),
                  borderSide: BorderSide(
                    color: AppColors.primary.withAlpha(
                      _ServicesUiTokens.subtleBorderAlpha,
                    ),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(_ServicesUiTokens.fieldRadius),
                  borderSide: BorderSide(
                    color: AppColors.primary.withAlpha(
                      _ServicesUiTokens.subtleBorderAlpha,
                    ),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(_ServicesUiTokens.fieldRadius),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      );
}

final class _MissingPackageBar extends StatelessWidget {
  const _MissingPackageBar({
    required this.surface,
    required this.expanded,
    required this.onActivate,
    required this.onDismiss,
  });

  final Color surface;
  final bool expanded;
  final VoidCallback onActivate;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) => Semantics(
        button: !expanded,
        label: 'Missing Package Quick Panic Bar',
        child: AppGlassCard(
          key: const ValueKey<String>('missing-package-panic-bar'),
          backgroundColor: surface,
          borderColor:
              AppColors.tertiary.withAlpha(_ServicesUiTokens.softBorderAlpha),
          glowColor: AppColors.tertiary,
          onTap: expanded ? null : onActivate,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Icon(
                    Icons.inventory_2_outlined,
                    color: AppColors.tertiary,
                    size: _ServicesUiTokens.iconSize,
                  ),
                  const SizedBox(width: _ServicesUiTokens.compactGap),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        AppDirectionalText(
                          'الطرد لم يصل؟',
                          languageCode: 'ar',
                          style: AppTypography.title,
                        ),
                        AppDirectionalText(
                          'Missing Package · Schnellhilfe',
                          languageCode: 'de',
                          style: AppTypography.label,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (!expanded) ...<Widget>[
                const SizedBox(height: _ServicesUiTokens.compactGap),
                AppDirectionalText(
                  'اضغط لعرض خطوات سريعة وعبارة استفسار رسمية.',
                  languageCode: 'ar',
                  style: AppTypography.body,
                ),
              ] else ...<Widget>[
                const SizedBox(height: _ServicesUiTokens.itemGap),
                for (final step
                    in ServicesMasterOrchestrator.missingPackageSteps) ...<
                    Widget>[
                  AppDirectionalText(
                    '• ${step.titleDe}',
                    languageCode: 'de',
                    style: AppTypography.body,
                  ),
                  AppDirectionalText(
                    '• ${step.titleAr}',
                    languageCode: 'ar',
                    style: AppTypography.body,
                  ),
                  const SizedBox(height: _ServicesUiTokens.compactGap),
                ],
                AppDirectionalText(
                  'Meine Sendung ist nicht angekommen. Können Sie bitte anhand der Sendungsnummer eine Nachforschung einleiten?',
                  languageCode: 'de',
                  style:
                      AppTypography.label.copyWith(color: AppColors.tertiary),
                ),
                AppDirectionalText(
                  'شحنتي لم تصل. هل يمكنكم فتح متابعة باستخدام رقم الشحنة من فضلكم؟',
                  languageCode: 'ar',
                  style: AppTypography.body,
                ),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    key: const ValueKey<String>('missing-package-close'),
                    onPressed: onDismiss,
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.tertiary,
                      size: _ServicesUiTokens.iconSize,
                    ),
                    label: AppDirectionalText(
                      'إغلاق',
                      languageCode: 'ar',
                      style: AppTypography.label,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
}

final class _ResultsHeader extends StatelessWidget {
  const _ResultsHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) => Row(
        children: <Widget>[
          Expanded(
            child: AppDirectionalText(
              'العبارات المتاحة',
              languageCode: 'ar',
              style: AppTypography.title,
            ),
          ),
          AppDirectionalText(
            '$count',
            languageCode: 'de',
            style: AppTypography.label.copyWith(color: AppColors.primary),
          ),
        ],
      );
}

final class _EmptyResultsCard extends StatelessWidget {
  const _EmptyResultsCard({required this.surface});

  final Color surface;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        key: const ValueKey<String>('services-empty-results'),
        backgroundColor: surface,
        borderColor:
            AppColors.primary.withAlpha(_ServicesUiTokens.subtleBorderAlpha),
        child: AppDirectionalText(
          'لا توجد نتائج ضمن الأقسام المحددة. غيّر البحث أو فعّل قسماً آخر.',
          languageCode: 'ar',
          style: AppTypography.body,
        ),
      );
}

final class _ServicePhraseCard extends StatelessWidget {
  const _ServicePhraseCard({
    required this.entry,
    required this.surface,
  });

  final ServicePhrase entry;
  final Color surface;

  Color get _accent => switch (entry.category) {
        ServiceCategory.postal => AppColors.primary,
        ServiceCategory.telecom => AppColors.secondary,
      };

  @override
  Widget build(BuildContext context) => AppGlassCard(
        key: ValueKey<String>('service-entry-${entry.id}'),
        backgroundColor: surface,
        borderColor:
            _accent.withAlpha(_ServicesUiTokens.subtleBorderAlpha),
        glowColor: _accent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              entry.topicAr,
              languageCode: 'ar',
              style: AppTypography.label.copyWith(color: _accent),
            ),
            AppDirectionalText(
              entry.topicDe,
              languageCode: 'de',
              style: AppTypography.label,
            ),
            const SizedBox(height: _ServicesUiTokens.compactGap),
            AppDirectionalText(
              entry.german,
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: _ServicesUiTokens.compactGap),
            AppDirectionalText(
              entry.arabic,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}
