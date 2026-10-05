import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';
import '../../../design_system/design_system.dart';
import '../application/bureaucracy_master_orchestrator.dart';
import '../domain/bureaucracy_models.dart';
abstract final class _BureaucracyUiTokens {
  static const double pageInset = 16;
  static const double topInset = 18;
  static const double bottomInset = 32;
  static const double sectionGap = 14;
  static const double contentGap = 10;
  static const double smallGap = 7;
  static const double chipHorizontal = 12;
  static const double chipVertical = 9;
  static const double icon = 28;
  static const double statusIcon = 22;
}
final class LifeBureaucracyScreen extends StatefulWidget {
  const LifeBureaucracyScreen({
    required this.orchestrator,
    super.key,
  });
  final BureaucracyMasterOrchestrator orchestrator;
  @override
  State<LifeBureaucracyScreen> createState() =>
      _LifeBureaucracyScreenState();
}
final class _LifeBureaucracyScreenState
    extends State<LifeBureaucracyScreen> {
  final TextEditingController _searchController = TextEditingController();
  BureaucracyMasterOrchestrator get orchestrator => widget.orchestrator;
  @override
  void initState() {
    super.initState();
    orchestrator.addListener(_refresh);
  }
  @override
  void didUpdateWidget(covariant LifeBureaucracyScreen oldWidget) {
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
  void _selectCategory(BureaucracyCategory category) {
    _searchController.clear();
    orchestrator.setCategory(category);
  }
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border =
        isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight;
    final activeGuide = orchestrator.activeGuide;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              _BureaucracyUiTokens.pageInset,
              _BureaucracyUiTokens.topInset,
              _BureaucracyUiTokens.pageInset,
              _BureaucracyUiTokens.bottomInset,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _HeaderCard(surface: surface, border: border),
                const SizedBox(height: _BureaucracyUiTokens.sectionGap),
                _CategorySelector(
                  activeCategory: orchestrator.activeCategory,
                  surface: surface,
                  border: border,
                  onSelected: _selectCategory,
                ),
                const SizedBox(height: _BureaucracyUiTokens.sectionGap),
                _RegisterCard(
                  register: orchestrator.activeRegister,
                  surface: surface,
                  border: border,
                ),
                const SizedBox(height: _BureaucracyUiTokens.sectionGap),
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
                const SizedBox(height: _BureaucracyUiTokens.sectionGap),
                _GuidesSection(
                  guides: orchestrator.visibleGuides,
                  activeGuide: activeGuide,
                  surface: surface,
                  border: border,
                  onSelected: orchestrator.selectGuide,
                ),
                if (activeGuide != null) ...<Widget>[
                  const SizedBox(height: _BureaucracyUiTokens.sectionGap),
                  _GuideDetailsCard(
                    guide: activeGuide,
                    surface: surface,
                    border: border,
                  ),
                  const SizedBox(height: _BureaucracyUiTokens.sectionGap),
                  _PanicChecklistCard(
                    guide: activeGuide,
                    checklist: orchestrator.panicChecklist,
                    surface: surface,
                    border: border,
                    isReady: orchestrator.isDocumentReady,
                    onChanged: orchestrator.setDocumentReady,
                  ),
                ],
                const SizedBox(height: _BureaucracyUiTokens.sectionGap),
                _LocalRequirementsNote(
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
                  Icons.account_balance_rounded,
                  color: AppColors.primary,
                  size: _BureaucracyUiTokens.icon,
                ),
                const SizedBox(width: _BureaucracyUiTokens.contentGap),
                Expanded(
                  child: AppDirectionalText(
                    'المعاملات الرسمية والدوائر الحكومية',
                    languageCode: 'ar',
                    style: AppTypography.title,
                  ),
                ),
              ],
            ),
            const SizedBox(height: _BureaucracyUiTokens.smallGap),
            AppDirectionalText(
              'Bürgeramt & Ausländerbehörde',
              languageCode: 'de',
              style: AppTypography.title.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: _BureaucracyUiTokens.smallGap),
            AppDirectionalText(
              'عبارات رسمية وقوائم تجهيز تساعدك على ترتيب المعاملة قبل مراجعة الدائرة.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}
final class _CategorySelector extends StatelessWidget {
  const _CategorySelector({
    required this.activeCategory,
    required this.surface,
    required this.border,
    required this.onSelected,
  });
  final BureaucracyCategory activeCategory;
  final Color surface;
  final Color border;
  final ValueChanged<BureaucracyCategory> onSelected;
  @override
  Widget build(BuildContext context) => Wrap(
        spacing: _BureaucracyUiTokens.contentGap,
        runSpacing: _BureaucracyUiTokens.contentGap,
        children: <Widget>[
          for (final category in BureaucracyCategory.values)
            AppGlassCard(
              onTap: () => onSelected(category),
              backgroundColor: surface,
              borderColor:
                  category == activeCategory ? AppColors.secondary : border,
              glowColor:
                  category == activeCategory ? AppColors.secondary : null,
              padding: const EdgeInsets.symmetric(
                horizontal: _BureaucracyUiTokens.chipHorizontal,
                vertical: _BureaucracyUiTokens.chipVertical,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  AppDirectionalText(
                    category.germanLabel,
                    languageCode: 'de',
                    style: AppTypography.label.copyWith(
                      color: category == activeCategory
                          ? AppColors.secondary
                          : null,
                    ),
                  ),
                  const SizedBox(height: _BureaucracyUiTokens.smallGap),
                  AppDirectionalText(
                    category.arabicLabel,
                    languageCode: 'ar',
                    style: AppTypography.label,
                  ),
                ],
              ),
            ),
        ],
      );
}
final class _RegisterCard extends StatelessWidget {
  const _RegisterCard({
    required this.register,
    required this.surface,
    required this.border,
  });
  final BureaucracyRegister register;
  final Color surface;
  final Color border;
  @override
  Widget build(BuildContext context) => AppGlassCard(
        backgroundColor: surface,
        borderColor: border,
        glowColor: AppColors.achievement,
        child: Row(
          children: <Widget>[
            const Icon(
              Icons.record_voice_over_rounded,
              color: AppColors.achievement,
              size: _BureaucracyUiTokens.icon,
            ),
            const SizedBox(width: _BureaucracyUiTokens.contentGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  AppDirectionalText(
                    register.germanLabel,
                    languageCode: 'de',
                    style: AppTypography.title.copyWith(
                      color: AppColors.achievement,
                    ),
                  ),
                  AppDirectionalText(
                    register.arabicLabel,
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
            'بحث في العبارات والمستندات',
            languageCode: 'ar',
            style: AppTypography.label,
          ),
          const SizedBox(height: _BureaucracyUiTokens.smallGap),
          Directionality(
            textDirection: direction,
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: AppTypography.body,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Anmeldung / Aufenthaltstitel / الإقامة',
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
  final List<BureaucracyGuide> guides;
  final BureaucracyGuide? activeGuide;
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
          'لا توجد نتيجة مطابقة في هذه الفئة. جرّب كلمة ألمانية أو عربية أخرى.',
          languageCode: 'ar',
          style: AppTypography.body,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AppDirectionalText(
          'المعاملات المتاحة',
          languageCode: 'ar',
          style: AppTypography.title,
        ),
        const SizedBox(height: _BureaucracyUiTokens.contentGap),
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
                const SizedBox(height: _BureaucracyUiTokens.smallGap),
                AppDirectionalText(
                  guides[index].titleAr,
                  languageCode: 'ar',
                  style: AppTypography.body,
                ),
              ],
            ),
          ),
          if (index != guides.length - 1)
            const SizedBox(height: _BureaucracyUiTokens.contentGap),
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
  final BureaucracyGuide guide;
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
            const SizedBox(height: _BureaucracyUiTokens.contentGap),
            AppDirectionalText(
              guide.phraseDe,
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: _BureaucracyUiTokens.contentGap),
            AppDirectionalText(
              guide.phraseAr,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
            const SizedBox(height: _BureaucracyUiTokens.smallGap),
            AppDirectionalText(
              guide.explanationAr,
              languageCode: 'ar',
              style: AppTypography.label,
            ),
          ],
        ),
      );
}
final class _PanicChecklistCard extends StatelessWidget {
  const _PanicChecklistCard({
    required this.guide,
    required this.checklist,
    required this.surface,
    required this.border,
    required this.isReady,
    required this.onChanged,
  });
  final BureaucracyGuide guide;
  final ChecklistSnapshot checklist;
  final Color surface;
  final Color border;
  final bool Function(String documentId) isReady;
  final void Function(String documentId, bool ready) onChanged;
  @override
  Widget build(BuildContext context) {
    final accent =
        checklist.isReady ? AppColors.mastery : AppColors.tertiary;
    return AppGlassCard(
      backgroundColor: surface,
      borderColor: accent,
      glowColor: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppDirectionalText(
            checklist.isReady
                ? 'قائمة المستندات: جاهزة'
                : 'قائمة المستندات السريعة قبل الموعد',
            languageCode: 'ar',
            style: AppTypography.title.copyWith(color: accent),
          ),
          const SizedBox(height: _BureaucracyUiTokens.smallGap),
          AppDirectionalText(
            'Dokumenten-Check: ' +
                checklist.readyCount.toString() +
                '/' +
                checklist.documents.length.toString(),
            languageCode: 'de',
            style: AppTypography.label,
          ),
          const SizedBox(height: _BureaucracyUiTokens.contentGap),
          for (var index = 0;
              index < guide.documents.length;
              index++) ...<Widget>[
            _DocumentChecklistRow(
              document: guide.documents[index],
              ready: isReady(guide.documents[index].id),
              surface: surface,
              border: border,
              onTap: () {
                final current = isReady(guide.documents[index].id);
                onChanged(guide.documents[index].id, !current);
              },
            ),
            if (index != guide.documents.length - 1)
              const SizedBox(height: _BureaucracyUiTokens.smallGap),
          ],
        ],
      ),
    );
  }
}
final class _DocumentChecklistRow extends StatelessWidget {
  const _DocumentChecklistRow({
    required this.document,
    required this.ready,
    required this.surface,
    required this.border,
    required this.onTap,
  });
  final OfficialDocument document;
  final bool ready;
  final Color surface;
  final Color border;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => AppGlassCard(
        onTap: onTap,
        backgroundColor: surface,
        borderColor: ready ? AppColors.mastery : border,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              ready
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: ready ? AppColors.mastery : AppColors.tertiary,
              size: _BureaucracyUiTokens.statusIcon,
            ),
            const SizedBox(width: _BureaucracyUiTokens.contentGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  AppDirectionalText(
                    document.nameDe,
                    languageCode: 'de',
                    style: AppTypography.label,
                  ),
                  const SizedBox(height: _BureaucracyUiTokens.smallGap),
                  AppDirectionalText(
                    document.nameAr,
                    languageCode: 'ar',
                    style: AppTypography.body,
                  ),
                  AppDirectionalText(
                    document.noteAr,
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
final class _LocalRequirementsNote extends StatelessWidget {
  const _LocalRequirementsNote({
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
            const SizedBox(height: _BureaucracyUiTokens.smallGap),
            AppDirectionalText(
              'قد تختلف النماذج والرسوم والمستندات وطريقة تقديم الصور حسب المدينة ونوع الإقامة. استخدم هذه البطاقات للتجهيز اللغوي والتنظيمي، ثم راجع القائمة الرسمية للجهة المختصة بمعاملتك.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}
