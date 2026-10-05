import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../design_system/design_system.dart';
import 'lost_found_master_orchestrator.dart';
import 'lost_found_models.dart';

abstract final class LostFoundUiTokens {
  static const double pageInset = 16;
  static const double topInset = 18;
  static const double bottomInset = 32;
  static const double sectionGap = 18;
  static const double itemGap = 12;
  static const double compactGap = 8;
  static const double chipHorizontal = 12;
  static const double chipVertical = 9;
  static const double icon = 28;
  static const double statusIcon = 22;
}

final class LostFoundMasterHub extends StatefulWidget {
  const LostFoundMasterHub({
    this.orchestrator,
    super.key,
  });

  final LostFoundMasterOrchestrator? orchestrator;

  @override
  State<LostFoundMasterHub> createState() => _LostFoundMasterHubState();
}

final class _LostFoundMasterHubState extends State<LostFoundMasterHub> {
  late final LostFoundMasterOrchestrator _orchestrator;
  late final bool _ownsOrchestrator;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ownsOrchestrator = widget.orchestrator == null;
    _orchestrator = widget.orchestrator ?? LostFoundMasterOrchestrator();
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (_ownsOrchestrator) {
      _orchestrator.dispose();
    }
    super.dispose();
  }

  void _switchDomain(LostFoundDomain domain) {
    _searchController.clear();
    _orchestrator.switchDomain(domain);
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final background =
        dark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = dark ? AppColors.darkSurface : AppColors.lightSurface;
    final border =
        dark ? AppColors.glassBorderDark : AppColors.glassBorderLight;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: background,
        body: SafeArea(
          child: AnimatedBuilder(
            animation: _orchestrator,
            builder: (context, _) => SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                LostFoundUiTokens.pageInset,
                LostFoundUiTokens.topInset,
                LostFoundUiTokens.pageInset,
                LostFoundUiTokens.bottomInset,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _HeaderCard(surface: surface, border: border),
                  const SizedBox(height: LostFoundUiTokens.sectionGap),
                  _DomainSelector(
                    domain: _orchestrator.domain,
                    surface: surface,
                    border: border,
                    onSelected: _switchDomain,
                  ),
                  const SizedBox(height: LostFoundUiTokens.sectionGap),
                  _ImmediateActionBar(
                    orchestrator: _orchestrator,
                    surface: surface,
                    border: border,
                  ),
                  const SizedBox(height: LostFoundUiTokens.sectionGap),
                  _SearchCard(
                    controller: _searchController,
                    query: _orchestrator.query,
                    surface: surface,
                    border: border,
                    onChanged: _orchestrator.setQuery,
                    onClear: () {
                      _searchController.clear();
                      _orchestrator.clearSearch();
                    },
                  ),
                  const SizedBox(height: LostFoundUiTokens.sectionGap),
                  _ResultsSection(
                    items: _orchestrator.visibleItems,
                    surface: surface,
                    border: border,
                  ),
                  const SizedBox(height: LostFoundUiTokens.sectionGap),
                  _ScopeNote(surface: surface, border: border),
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
  const _HeaderCard({required this.surface, required this.border});

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
            Row(
              children: <Widget>[
                const Icon(
                  Icons.find_in_page_rounded,
                  color: AppColors.primary,
                  size: LostFoundUiTokens.icon,
                ),
                const SizedBox(width: LostFoundUiTokens.itemGap),
                Expanded(
                  child: AppDirectionalText(
                    'Fundbüro & DB Fundservice',
                    languageCode: 'de',
                    style: AppTypography.title.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: LostFoundUiTokens.compactGap),
            AppDirectionalText(
              'المفقودات واستعادة الأغراض',
              languageCode: 'ar',
              style: AppTypography.title,
            ),
            const SizedBox(height: LostFoundUiTokens.compactGap),
            AppDirectionalText(
              'Praktische Sätze für Verlustmeldung, Fundstelle, Eigentumsnachweis und Abholung.',
              languageCode: 'de',
              style: AppTypography.body,
            ),
            AppDirectionalText(
              'عبارات عملية للبلاغ والبحث وإثبات الملكية واستلام الغرض.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

final class _DomainSelector extends StatelessWidget {
  const _DomainSelector({
    required this.domain,
    required this.surface,
    required this.border,
    required this.onSelected,
  });

  final LostFoundDomain domain;
  final Color surface;
  final Color border;
  final ValueChanged<LostFoundDomain> onSelected;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: LostFoundUiTokens.itemGap,
        runSpacing: LostFoundUiTokens.itemGap,
        children: <Widget>[
          for (final value in LostFoundDomain.values)
            AppGlassCard(
              onTap: () => onSelected(value),
              backgroundColor: surface,
              borderColor: value == domain ? AppColors.secondary : border,
              glowColor: value == domain ? AppColors.secondary : null,
              padding: const EdgeInsets.symmetric(
                horizontal: LostFoundUiTokens.chipHorizontal,
                vertical: LostFoundUiTokens.chipVertical,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  AppDirectionalText(
                    value.labelDe,
                    languageCode: 'de',
                    style: AppTypography.label.copyWith(
                      color: value == domain ? AppColors.secondary : null,
                    ),
                  ),
                  const SizedBox(height: LostFoundUiTokens.compactGap),
                  AppDirectionalText(
                    value.labelAr,
                    languageCode: 'ar',
                    style: AppTypography.label,
                  ),
                ],
              ),
            ),
        ],
      );
}

final class _ImmediateActionBar extends StatelessWidget {
  const _ImmediateActionBar({
    required this.orchestrator,
    required this.surface,
    required this.border,
  });

  final LostFoundMasterOrchestrator orchestrator;
  final Color surface;
  final Color border;

  @override
  Widget build(BuildContext context) {
    final complete = orchestrator.isImmediateChecklistComplete;
    final accent = complete ? AppColors.mastery : AppColors.tertiary;

    return AppGlassCard(
      backgroundColor: surface,
      borderColor: accent,
      glowColor: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                complete
                    ? Icons.task_alt_rounded
                    : Icons.notification_important_rounded,
                color: accent,
                size: LostFoundUiTokens.icon,
              ),
              const SizedBox(width: LostFoundUiTokens.itemGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    AppDirectionalText(
                      'Sofort-Check: Verlustmeldung aufgeben',
                      languageCode: 'de',
                      style: AppTypography.title.copyWith(color: accent),
                    ),
                    AppDirectionalText(
                      complete
                          ? 'تم تجهيز خطوات البلاغ الأساسية.'
                          : 'نفّذ هذه الخطوات سريعًا بعد اكتشاف الفقد.',
                      languageCode: 'ar',
                      style: AppTypography.body,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: LostFoundUiTokens.itemGap),
          AppDirectionalText(
            '${orchestrator.completedActionCount}/${orchestrator.immediateActions.length} erledigt',
            languageCode: 'de',
            style: AppTypography.label,
          ),
          const SizedBox(height: LostFoundUiTokens.itemGap),
          for (var index = 0;
              index < orchestrator.immediateActions.length;
              index++) ...<Widget>[
            _ActionRow(
              action: orchestrator.immediateActions[index],
              complete: orchestrator.isActionComplete(
                orchestrator.immediateActions[index].id,
              ),
              surface: surface,
              border: border,
              onTap: () {
                final action = orchestrator.immediateActions[index];
                orchestrator.setActionComplete(
                  action.id,
                  !orchestrator.isActionComplete(action.id),
                );
              },
            ),
            if (index != orchestrator.immediateActions.length - 1)
              const SizedBox(height: LostFoundUiTokens.compactGap),
          ],
        ],
      ),
    );
  }
}

final class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.action,
    required this.complete,
    required this.surface,
    required this.border,
    required this.onTap,
  });

  final ImmediateLostAction action;
  final bool complete;
  final Color surface;
  final Color border;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        onTap: onTap,
        backgroundColor: surface,
        borderColor: complete ? AppColors.mastery : border,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              complete
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: complete ? AppColors.mastery : AppColors.tertiary,
              size: LostFoundUiTokens.statusIcon,
            ),
            const SizedBox(width: LostFoundUiTokens.itemGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  AppDirectionalText(
                    action.titleDe,
                    languageCode: 'de',
                    style: AppTypography.label,
                  ),
                  const SizedBox(height: LostFoundUiTokens.compactGap),
                  AppDirectionalText(
                    action.titleAr,
                    languageCode: 'ar',
                    style: AppTypography.body,
                  ),
                  AppDirectionalText(
                    action.detailAr,
                    languageCode: 'ar',
                    style: AppTypography.label,
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
            'Suche / بحث',
            languageCode: 'de',
            style: AppTypography.label,
          ),
          const SizedBox(height: LostFoundUiTokens.compactGap),
          Directionality(
            textDirection: direction,
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: AppTypography.body,
              decoration: InputDecoration(
                hintText: 'Seriennummer / Fundstelle / القطار',
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

final class _ResultsSection extends StatelessWidget {
  const _ResultsSection({
    required this.items,
    required this.surface,
    required this.border,
  });

  final List<LostFoundItem> items;
  final Color surface;
  final Color border;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return AppGlassCard(
        backgroundColor: surface,
        borderColor: AppColors.tertiary,
        child: AppDirectionalText(
          'لا توجد نتيجة مطابقة في هذه الفئة. جرّب كلمة أخرى أو بدّل نوع الجهة.',
          languageCode: 'ar',
          style: AppTypography.body,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AppDirectionalText(
          'Wiederfinden & Abholen',
          languageCode: 'de',
          style: AppTypography.title,
        ),
        const SizedBox(height: LostFoundUiTokens.itemGap),
        for (var index = 0; index < items.length; index++) ...<Widget>[
          _RecoveryCard(
            item: items[index],
            surface: surface,
            border: border,
          ),
          if (index != items.length - 1)
            const SizedBox(height: LostFoundUiTokens.itemGap),
        ],
      ],
    );
  }
}

final class _RecoveryCard extends StatelessWidget {
  const _RecoveryCard({
    required this.item,
    required this.surface,
    required this.border,
  });

  final LostFoundItem item;
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
              item.titleDe,
              languageCode: 'de',
              style: AppTypography.title.copyWith(
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: LostFoundUiTokens.compactGap),
            AppDirectionalText(
              item.titleAr,
              languageCode: 'ar',
              style: AppTypography.label,
            ),
            const SizedBox(height: LostFoundUiTokens.itemGap),
            AppDirectionalText(
              item.german,
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: LostFoundUiTokens.compactGap),
            AppDirectionalText(
              item.arabic,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
            const SizedBox(height: LostFoundUiTokens.itemGap),
            AppDirectionalText(
              item.contextDe,
              languageCode: 'de',
              style: AppTypography.label,
            ),
            const SizedBox(height: LostFoundUiTokens.compactGap),
            AppDirectionalText(
              item.contextAr,
              languageCode: 'ar',
              style: AppTypography.label,
            ),
          ],
        ),
      );
}

final class _ScopeNote extends StatelessWidget {
  const _ScopeNote({required this.surface, required this.border});

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
              'Aktuelle Stelle prüfen',
              languageCode: 'de',
              style: AppTypography.label.copyWith(
                color: AppColors.tertiary,
              ),
            ),
            const SizedBox(height: LostFoundUiTokens.compactGap),
            AppDirectionalText(
              'الجهة المختصة وطريقة البلاغ والرسوم ومدد الحفظ قد تختلف حسب البلدية أو شركة النقل. استخدم البطاقة للتجهيز اللغوي ثم راجع الجهة الرسمية المسؤولة عن مكان الفقد.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}
