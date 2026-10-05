import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../../design_system/design_system.dart';
import '../application/culture_master_orchestrator.dart';
import '../domain/culture_models.dart';

abstract final class _CultureUiTokens {
  static const double pageInset = 16;
  static const double topInset = 18;
  static const double bottomInset = 32;
  static const double sectionGap = 14;
  static const double contentGap = 10;
  static const double smallGap = 7;
  static const double chipHorizontal = 12;
  static const double chipVertical = 10;
  static const double icon = 28;
}

final class LifeCultureScreen extends StatefulWidget {
  const LifeCultureScreen({
    required this.orchestrator,
    super.key,
  });

  final CultureMasterOrchestrator orchestrator;

  @override
  State<LifeCultureScreen> createState() => _LifeCultureScreenState();
}

final class _LifeCultureScreenState extends State<LifeCultureScreen> {
  final TextEditingController _searchController = TextEditingController();

  CultureMasterOrchestrator get orchestrator => widget.orchestrator;

  @override
  void initState() {
    super.initState();
    orchestrator.addListener(_refresh);
  }

  @override
  void didUpdateWidget(covariant LifeCultureScreen oldWidget) {
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

  void _selectDomain(CultureDomain domain) {
    _searchController.clear();
    orchestrator.setDomain(domain);
  }

  void _openQuickRenewal() {
    _searchController.clear();
    orchestrator.openQuickCardRenewal();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border =
        isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              _CultureUiTokens.pageInset,
              _CultureUiTokens.topInset,
              _CultureUiTokens.pageInset,
              _CultureUiTokens.bottomInset,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _HeaderCard(surface: surface, border: border),
                const SizedBox(height: _CultureUiTokens.sectionGap),
                _DomainSelector(
                  activeDomain: orchestrator.activeDomain,
                  surface: surface,
                  border: border,
                  onSelected: _selectDomain,
                ),
                const SizedBox(height: _CultureUiTokens.sectionGap),
                _QuickRenewalBar(
                  guide: orchestrator.quickCardRenewalGuide,
                  surface: surface,
                  onOpen: _openQuickRenewal,
                ),
                const SizedBox(height: _CultureUiTokens.sectionGap),
                _SearchCard(
                  controller: _searchController,
                  query: orchestrator.query,
                  surface: surface,
                  border: border,
                  onChanged: orchestrator.search,
                  onClear: () {
                    _searchController.clear();
                    orchestrator.clearSearch();
                  },
                ),
                const SizedBox(height: _CultureUiTokens.sectionGap),
                _GuidesSection(
                  guides: orchestrator.visibleGuides,
                  activeGuide: orchestrator.activeGuide,
                  surface: surface,
                  border: border,
                  onSelected: orchestrator.selectGuide,
                ),
                if (orchestrator.activeGuide != null) ...<Widget>[
                  const SizedBox(height: _CultureUiTokens.sectionGap),
                  _GuideDetailsCard(
                    guide: orchestrator.activeGuide!,
                    surface: surface,
                    border: border,
                  ),
                ],
                const SizedBox(height: _CultureUiTokens.sectionGap),
                _LocalVariationNote(surface: surface, border: border),
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
              'Stadtbibliothek & Volkshochschule',
              languageCode: 'de',
              style: AppTypography.title.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: _CultureUiTokens.smallGap),
            AppDirectionalText(
              'المكتبة العامة والتعليم المستمر للكبار',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

final class _DomainSelector extends StatelessWidget {
  const _DomainSelector({
    required this.activeDomain,
    required this.surface,
    required this.border,
    required this.onSelected,
  });

  final CultureDomain activeDomain;
  final Color surface;
  final Color border;
  final ValueChanged<CultureDomain> onSelected;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: _CultureUiTokens.contentGap,
        runSpacing: _CultureUiTokens.contentGap,
        children: <Widget>[
          for (final domain in CultureDomain.values)
            AppGlassCard(
              onTap: () => onSelected(domain),
              backgroundColor: surface,
              borderColor:
                  domain == activeDomain ? AppColors.secondary : border,
              glowColor: domain == activeDomain ? AppColors.secondary : null,
              padding: const EdgeInsets.symmetric(
                horizontal: _CultureUiTokens.chipHorizontal,
                vertical: _CultureUiTokens.chipVertical,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  AppDirectionalText(
                    domain.germanLabel,
                    languageCode: 'de',
                    style: AppTypography.label.copyWith(
                      color:
                          domain == activeDomain ? AppColors.secondary : null,
                    ),
                  ),
                  const SizedBox(height: _CultureUiTokens.smallGap),
                  AppDirectionalText(
                    domain.arabicLabel,
                    languageCode: 'ar',
                    style: AppTypography.label,
                  ),
                ],
              ),
            ),
        ],
      );
}

final class _QuickRenewalBar extends StatelessWidget {
  const _QuickRenewalBar({
    required this.guide,
    required this.surface,
    required this.onOpen,
  });

  final CultureGuide guide;
  final Color surface;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        backgroundColor: surface,
        borderColor: AppColors.tertiary,
        glowColor: AppColors.tertiary,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Icon(
              Icons.badge_outlined,
              color: AppColors.tertiary,
              size: _CultureUiTokens.icon,
            ),
            const SizedBox(width: _CultureUiTokens.contentGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  AppDirectionalText(
                    'Bibliotheksausweis schnell verlängern',
                    languageCode: 'de',
                    style: AppTypography.label.copyWith(
                      color: AppColors.tertiary,
                    ),
                  ),
                  const SizedBox(height: _CultureUiTokens.smallGap),
                  AppDirectionalText(
                    'تجديد سريع لبطاقة المكتبة',
                    languageCode: 'ar',
                    style: AppTypography.body,
                  ),
                  const SizedBox(height: _CultureUiTokens.smallGap),
                  AppDirectionalText(
                    guide.phraseDe,
                    languageCode: 'de',
                    style: AppTypography.label,
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton.icon(
                      key: const ValueKey<String>('culture-quick-renewal'),
                      onPressed: onOpen,
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: AppDirectionalText(
                        'Öffnen',
                        languageCode: 'de',
                        style: AppTypography.label,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
  Widget build(BuildContext context) {
    final direction =
        _containsArabic(query) ? TextDirection.rtl : TextDirection.ltr;

    return AppGlassCard(
      backgroundColor: surface,
      borderColor: border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppDirectionalText(
            'ابحث بالألمانية أو العربية',
            languageCode: 'ar',
            style: AppTypography.label,
          ),
          const SizedBox(height: _CultureUiTokens.smallGap),
          Directionality(
            textDirection: direction,
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: AppTypography.body,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Onleihe / VHS / شهادة الحضور',
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

  static bool _containsArabic(String value) =>
      value.runes.any((rune) => rune >= 0x0600 && rune <= 0x06FF);
}

final class _GuidesSection extends StatelessWidget {
  const _GuidesSection({
    required this.guides,
    required this.activeGuide,
    required this.surface,
    required this.border,
    required this.onSelected,
  });

  final List<CultureGuide> guides;
  final CultureGuide? activeGuide;
  final Color surface;
  final Color border;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    if (guides.isEmpty) {
      return AppGlassCard(
        backgroundColor: surface,
        borderColor: AppColors.tertiary,
        child: AppDirectionalText(
          'لا توجد نتيجة مطابقة في هذا القسم. جرّب كلمة ألمانية أو عربية أخرى.',
          languageCode: 'ar',
          style: AppTypography.body,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AppDirectionalText(
          'المواقف والعبارات',
          languageCode: 'ar',
          style: AppTypography.title,
        ),
        const SizedBox(height: _CultureUiTokens.contentGap),
        for (var index = 0; index < guides.length; index++) ...<Widget>[
          AppGlassCard(
            onTap: () => onSelected(guides[index].id),
            backgroundColor: surface,
            borderColor: activeGuide?.id == guides[index].id
                ? AppColors.primary
                : border,
            glowColor: activeGuide?.id == guides[index].id
                ? AppColors.primary
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AppDirectionalText(
                  guides[index].titleDe,
                  languageCode: 'de',
                  style: AppTypography.title,
                ),
                const SizedBox(height: _CultureUiTokens.smallGap),
                AppDirectionalText(
                  guides[index].titleAr,
                  languageCode: 'ar',
                  style: AppTypography.body,
                ),
              ],
            ),
          ),
          if (index != guides.length - 1)
            const SizedBox(height: _CultureUiTokens.contentGap),
        ],
      ],
    );
  }
}

final class _GuideDetailsCard extends StatelessWidget {
  const _GuideDetailsCard({
    required this.guide,
    required this.surface,
    required this.border,
  });

  final CultureGuide guide;
  final Color surface;
  final Color border;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        backgroundColor: surface,
        borderColor: border,
        glowColor: AppColors.secondary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              guide.titleDe,
              languageCode: 'de',
              style: AppTypography.title.copyWith(color: AppColors.secondary),
            ),
            const SizedBox(height: _CultureUiTokens.contentGap),
            AppDirectionalText(
              guide.phraseDe,
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: _CultureUiTokens.contentGap),
            AppDirectionalText(
              guide.phraseAr,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
            const SizedBox(height: _CultureUiTokens.smallGap),
            AppDirectionalText(
              guide.noteAr,
              languageCode: 'ar',
              style: AppTypography.label,
            ),
          ],
        ),
      );
}

final class _LocalVariationNote extends StatelessWidget {
  const _LocalVariationNote({
    required this.surface,
    required this.border,
  });

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
              'Hinweis',
              languageCode: 'de',
              style: AppTypography.label.copyWith(color: AppColors.tertiary),
            ),
            const SizedBox(height: _CultureUiTokens.smallGap),
            AppDirectionalText(
              'قد تختلف الرسوم ومدد الإعارة وشروط Onleihe ومواعيد دورات VHS وإصدار الشهادات حسب المدينة والجهة. استخدم هذه البطاقات للتواصل اللغوي ثم تحقق من القواعد المحلية.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}
