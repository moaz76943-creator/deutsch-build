import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../design_system/design_system.dart';
import 'utilities_master_orchestrator.dart';
import 'utilities_models.dart';

abstract final class UtilitiesUiTokens {
  static const double pageInset = 16;
  static const double bottomInset = 32;
  static const double sectionGap = 18;
  static const double itemGap = 12;
  static const double compactGap = 8;
  static const double iconSize = 28;
}

final class UtilitiesMasterHub extends StatefulWidget {
  const UtilitiesMasterHub({
    this.orchestrator,
    super.key,
  });

  final UtilitiesMasterOrchestrator? orchestrator;

  @override
  State<UtilitiesMasterHub> createState() =>
      _UtilitiesMasterHubState();
}

final class _UtilitiesMasterHubState
    extends State<UtilitiesMasterHub> {
  late UtilitiesMasterOrchestrator _orchestrator;
  late bool _ownsOrchestrator;
  final TextEditingController _searchController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _ownsOrchestrator = widget.orchestrator == null;
    _orchestrator =
        widget.orchestrator ?? UtilitiesMasterOrchestrator();
    _searchController.text = _orchestrator.query;
  }

  @override
  void didUpdateWidget(covariant UtilitiesMasterHub oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orchestrator == widget.orchestrator) return;

    if (_ownsOrchestrator) {
      _orchestrator.dispose();
    }

    _ownsOrchestrator = widget.orchestrator == null;
    _orchestrator =
        widget.orchestrator ?? UtilitiesMasterOrchestrator();
    _searchController.text = _orchestrator.query;
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (_ownsOrchestrator) {
      _orchestrator.dispose();
    }
    super.dispose();
  }

  void _setCategory(UtilitiesCategory category) {
    _orchestrator.setCategory(category);
    _searchController.clear();
  }

  void _openQuickGuide() {
    _orchestrator.openQuickMeterReadingGuide();
    _searchController.text = _orchestrator.query;
  }

  @override
  Widget build(BuildContext context) {
    final dark =
        Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: dark
            ? AppColors.darkBackground
            : AppColors.lightBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              UtilitiesUiTokens.pageInset,
              UtilitiesUiTokens.pageInset,
              UtilitiesUiTokens.pageInset,
              UtilitiesUiTokens.bottomInset,
            ),
            child: AnimatedBuilder(
              animation: _orchestrator,
              builder: (context, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _HeaderCard(dark: dark),
                  const SizedBox(
                    height: UtilitiesUiTokens.sectionGap,
                  ),
                  _SearchField(
                    controller: _searchController,
                    orchestrator: _orchestrator,
                  ),
                  const SizedBox(
                    height: UtilitiesUiTokens.itemGap,
                  ),
                  _CategorySelector(
                    orchestrator: _orchestrator,
                    dark: dark,
                    onSelected: _setCategory,
                  ),
                  const SizedBox(
                    height: UtilitiesUiTokens.sectionGap,
                  ),
                  _QuickMeterReadingBar(
                    orchestrator: _orchestrator,
                    dark: dark,
                    onOpen: _openQuickGuide,
                  ),
                  const SizedBox(
                    height: UtilitiesUiTokens.sectionGap,
                  ),
                  _PhraseList(
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
        backgroundColor:
            dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'Strom, Gas & Zählerstand',
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(
              height: UtilitiesUiTokens.compactGap,
            ),
            AppDirectionalText(
              'عبارات عملية لقراءات العدادات والفواتير وعقود الكهرباء والغاز وتغيير المزوّد.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

final class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.orchestrator,
  });

  final TextEditingController controller;
  final UtilitiesMasterOrchestrator orchestrator;

  @override
  Widget build(BuildContext context) {
    final direction = _containsArabic(controller.text)
        ? TextDirection.rtl
        : TextDirection.ltr;

    return Directionality(
      textDirection: direction,
      child: TextField(
        key: const ValueKey<String>('utilities-search'),
        controller: controller,
        onChanged: orchestrator.setQuery,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          labelText: 'Suche · بحث',
          hintText:
              'Zählerstand, Nachzahlung, Tarif, Kündigungsfrist ...',
          suffixIcon: orchestrator.query.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    controller.clear();
                    orchestrator.clearSearch();
                  },
                  icon: const Icon(Icons.close),
                ),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  static bool _containsArabic(String value) =>
      value.runes.any(
        (rune) => rune >= 0x0600 && rune <= 0x06FF,
      );
}

final class _CategorySelector extends StatelessWidget {
  const _CategorySelector({
    required this.orchestrator,
    required this.dark,
    required this.onSelected,
  });

  final UtilitiesMasterOrchestrator orchestrator;
  final bool dark;
  final ValueChanged<UtilitiesCategory> onSelected;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.secondary.withAlpha(96),
        backgroundColor:
            dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Wrap(
          spacing: UtilitiesUiTokens.compactGap,
          runSpacing: UtilitiesUiTokens.compactGap,
          children: <Widget>[
            for (final category in UtilitiesCategory.values)
              FilterChip(
                key: ValueKey<String>(
                  'utilities-category-${category.name}',
                ),
                selected:
                    orchestrator.category == category,
                onSelected: (_) => onSelected(category),
                label: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: <Widget>[
                    AppDirectionalText(
                      category.labelDe,
                      languageCode: 'de',
                      style: AppTypography.label,
                    ),
                    AppDirectionalText(
                      category.labelAr,
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

final class _QuickMeterReadingBar extends StatelessWidget {
  const _QuickMeterReadingBar({
    required this.orchestrator,
    required this.dark,
    required this.onOpen,
  });

  final UtilitiesMasterOrchestrator orchestrator;
  final bool dark;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final guide = orchestrator.quickMeterReadingGuide;

    return AppGlassCard(
      glowColor: AppColors.tertiary,
      borderColor: AppColors.tertiary.withAlpha(96),
      backgroundColor:
          dark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Icon(
                Icons.speed_rounded,
                color: AppColors.tertiary,
                size: UtilitiesUiTokens.iconSize,
              ),
              const SizedBox(
                width: UtilitiesUiTokens.compactGap,
              ),
              Expanded(
                child: AppDirectionalText(
                  'Quick Meter Reading Guide · Zählerstand melden',
                  languageCode: 'de',
                  style: AppTypography.title,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: UtilitiesUiTokens.compactGap,
          ),
          AppDirectionalText(
            'دليل سريع لإرسال قراءة العداد مع التأكد من رقم العداد قبل الإرسال.',
            languageCode: 'ar',
            style: AppTypography.body,
          ),
          const SizedBox(
            height: UtilitiesUiTokens.itemGap,
          ),
          AppDirectionalText(
            guide.german,
            languageCode: 'de',
            style: AppTypography.body,
          ),
          const SizedBox(
            height: UtilitiesUiTokens.compactGap,
          ),
          AppDirectionalText(
            guide.arabic,
            languageCode: 'ar',
            style: AppTypography.body,
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              key: const ValueKey<String>(
                'utilities-quick-meter-guide',
              ),
              onPressed: onOpen,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: AppDirectionalText(
                'Guide öffnen',
                languageCode: 'de',
                style: AppTypography.label,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final class _PhraseList extends StatelessWidget {
  const _PhraseList({
    required this.orchestrator,
    required this.dark,
  });

  final UtilitiesMasterOrchestrator orchestrator;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final phrases = orchestrator.visiblePhrases;

    if (phrases.isEmpty) {
      return AppGlassCard(
        borderColor: AppColors.tertiary.withAlpha(96),
        backgroundColor:
            dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: AppDirectionalText(
          'لا توجد نتائج في هذا القسم. جرّب كلمة بحث ألمانية أو عربية أخرى.',
          languageCode: 'ar',
          style: AppTypography.body,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (var index = 0;
            index < phrases.length;
            index++) ...<Widget>[
          _PhraseCard(
            phrase: phrases[index],
            dark: dark,
          ),
          if (index != phrases.length - 1)
            const SizedBox(
              height: UtilitiesUiTokens.itemGap,
            ),
        ],
      ],
    );
  }
}

final class _PhraseCard extends StatelessWidget {
  const _PhraseCard({
    required this.phrase,
    required this.dark,
  });

  final UtilitiesPhrase phrase;
  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.primary.withAlpha(80),
        backgroundColor:
            dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              phrase.contextDe,
              languageCode: 'de',
              style: AppTypography.label,
            ),
            const SizedBox(
              height: UtilitiesUiTokens.compactGap,
            ),
            AppDirectionalText(
              phrase.german,
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(
              height: UtilitiesUiTokens.compactGap,
            ),
            AppDirectionalText(
              phrase.arabic,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
            const SizedBox(
              height: UtilitiesUiTokens.compactGap,
            ),
            AppDirectionalText(
              phrase.contextAr,
              languageCode: 'ar',
              style: AppTypography.label,
            ),
          ],
        ),
      );
}
