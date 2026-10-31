import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../design_system/app_colors.dart';
import '../../design_system/app_glass_card.dart';
import '../../design_system/app_typography.dart' hide AppDirectionalText;
import 'car_service_master_orchestrator.dart';
import 'car_service_models.dart';

abstract final class _CarServiceUiTokens {
  static const double pageInset = 16;
  static const double sectionGap = 14;
  static const double contentGap = 10;
  static const double controlGap = 8;
  static const double iconSize = 22;
}

class CarServiceMasterHub extends StatefulWidget {
  const CarServiceMasterHub({
    this.orchestrator,
    super.key,
  });

  final CarServiceMasterOrchestrator? orchestrator;

  @override
  State<CarServiceMasterHub> createState() => _CarServiceMasterHubState();
}

class _CarServiceMasterHubState extends State<CarServiceMasterHub> {
  late final CarServiceMasterOrchestrator _orchestrator;
  late final bool _ownsOrchestrator;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _ownsOrchestrator = widget.orchestrator == null;
    _orchestrator = widget.orchestrator ?? CarServiceMasterOrchestrator();
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
        final phrases = _orchestrator.visiblePhrases;

        return Scaffold(
          appBar: AppBar(
            title: AppDirectionalText(
              'Werkstatt & HU',
              languageCode: 'de',
              style: AppTypography.title,
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(_CarServiceUiTokens.pageInset),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _HeaderCard(count: phrases.length),
                  const SizedBox(height: _CarServiceUiTokens.sectionGap),
                  _ModeFilter(orchestrator: _orchestrator),
                  const SizedBox(height: _CarServiceUiTokens.sectionGap),
                  _SearchCard(
                    orchestrator: _orchestrator,
                    searchController: _searchController,
                  ),
                  const SizedBox(height: _CarServiceUiTokens.sectionGap),
                  _SeasonalTireBar(orchestrator: _orchestrator),
                  const SizedBox(height: _CarServiceUiTokens.sectionGap),
                  if (phrases.isEmpty)
                    const _EmptyState()
                  else
                    for (final phrase in phrases) ...<Widget>[
                      _PhraseCard(phrase: phrase),
                      const SizedBox(height: _CarServiceUiTokens.contentGap),
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

final class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return AppGlassCard(
      glowColor: AppColors.primary,
      borderColor: AppColors.primary.withAlpha(78),
      backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppDirectionalText(
            'Autowerkstatt · Hauptuntersuchung',
            languageCode: 'de',
            style: AppTypography.title.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: _CarServiceUiTokens.controlGap),
          AppDirectionalText(
            'عبارات عملية لصيانة السيارة، الورشة، الفحص الدوري وسلامة الطريق.',
            languageCode: 'ar',
            style: AppTypography.body,
          ),
          const SizedBox(height: _CarServiceUiTokens.controlGap),
          AppDirectionalText(
            'Treffer: ' + count.toString(),
            languageCode: 'de',
            style: AppTypography.label,
          ),
        ],
      ),
    );
  }
}

final class _ModeFilter extends StatelessWidget {
  const _ModeFilter({required this.orchestrator});

  final CarServiceMasterOrchestrator orchestrator;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return AppGlassCard(
      borderColor: AppColors.secondary.withAlpha(78),
      backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppDirectionalText(
            'Bereich wählen',
            languageCode: 'de',
            style: AppTypography.title,
          ),
          const SizedBox(height: _CarServiceUiTokens.controlGap),
          Wrap(
            spacing: _CarServiceUiTokens.controlGap,
            runSpacing: _CarServiceUiTokens.controlGap,
            children: <Widget>[
              for (final mode in CarServiceMode.values)
                ChoiceChip(
                  key: ValueKey<String>('car-service-mode-' + mode.name),
                  selected: orchestrator.mode == mode,
                  onSelected: (_) => orchestrator.setMode(mode),
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      AppDirectionalText(
                        mode.labelDe,
                        languageCode: 'de',
                        style: AppTypography.label,
                      ),
                      AppDirectionalText(
                        mode.labelAr,
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
    required this.searchController,
  });

  final CarServiceMasterOrchestrator orchestrator;
  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return AppGlassCard(
      borderColor: AppColors.primary.withAlpha(62),
      backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
      child: TextField(
        key: const ValueKey<String>('car-service-search'),
        controller: searchController,
        textDirection: TextDirection.rtl,
        style: AppTypography.body,
        onChanged: orchestrator.setQuery,
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
                    searchController.clear();
                    orchestrator.setQuery('');
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
        ),
      ),
    );
  }
}

final class _SeasonalTireBar extends StatelessWidget {
  const _SeasonalTireBar({required this.orchestrator});

  final CarServiceMasterOrchestrator orchestrator;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return AppGlassCard(
      key: const ValueKey<String>('car-service-seasonal-tire-bar'),
      onTap: orchestrator.toggleSeasonalTireDetails,
      glowColor: AppColors.tertiary,
      borderColor: AppColors.tertiary.withAlpha(96),
      backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.tire_repair_rounded,
                color: AppColors.tertiary,
                size: _CarServiceUiTokens.iconSize,
              ),
              const SizedBox(width: _CarServiceUiTokens.controlGap),
              Expanded(
                child: AppDirectionalText(
                  'Reifenregel · O bis O',
                  languageCode: 'de',
                  style: AppTypography.title,
                ),
              ),
              Icon(
                orchestrator.seasonalTireExpanded
                    ? Icons.expand_less_rounded
                    : Icons.expand_more_rounded,
              ),
            ],
          ),
          const SizedBox(height: _CarServiceUiTokens.controlGap),
          AppDirectionalText(
            orchestrator.seasonalTireGerman,
            languageCode: 'de',
            style: AppTypography.body,
          ),
          const SizedBox(height: _CarServiceUiTokens.controlGap),
          AppDirectionalText(
            orchestrator.seasonalTireArabic,
            languageCode: 'ar',
            style: AppTypography.body,
          ),
          if (orchestrator.seasonalTireExpanded) ...<Widget>[
            const SizedBox(height: _CarServiceUiTokens.contentGap),
            AppDirectionalText(
              orchestrator.seasonalTireSafetyGerman,
              languageCode: 'de',
              style: AppTypography.label,
            ),
            const SizedBox(height: _CarServiceUiTokens.controlGap),
            AppDirectionalText(
              orchestrator.seasonalTireSafetyArabic,
              languageCode: 'ar',
              style: AppTypography.label,
            ),
          ],
        ],
      ),
    );
  }
}

final class _PhraseCard extends StatelessWidget {
  const _PhraseCard({required this.phrase});

  final CarServicePhrase phrase;

  Color get _accent => switch (phrase.mode) {
        CarServiceMode.workshop => AppColors.primary,
        CarServiceMode.inspection => AppColors.secondary,
        CarServiceMode.all => AppColors.tertiary,
      };

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return AppGlassCard(
      borderColor: _accent.withAlpha(72),
      glowColor: _accent,
      backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Wrap(
            spacing: _CarServiceUiTokens.controlGap,
            runSpacing: _CarServiceUiTokens.controlGap,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              AppDirectionalText(
                phrase.mode.labelDe,
                languageCode: 'de',
                style: AppTypography.label.copyWith(color: _accent),
              ),
              AppDirectionalText(
                phrase.topic.labelDe,
                languageCode: 'de',
                style: AppTypography.label,
              ),
            ],
          ),
          const SizedBox(height: _CarServiceUiTokens.contentGap),
          AppDirectionalText(
            phrase.titleDe,
            languageCode: 'de',
            style: AppTypography.title,
          ),
          AppDirectionalText(
            phrase.titleAr,
            languageCode: 'ar',
            style: AppTypography.label,
          ),
          const SizedBox(height: _CarServiceUiTokens.contentGap),
          AppDirectionalText(
            phrase.german,
            languageCode: 'de',
            style: AppTypography.body,
          ),
          const SizedBox(height: _CarServiceUiTokens.controlGap),
          AppDirectionalText(
            phrase.arabic,
            languageCode: 'ar',
            style: AppTypography.body,
          ),
          if (phrase.noteDe != null) ...<Widget>[
            const SizedBox(height: _CarServiceUiTokens.contentGap),
            AppDirectionalText(
              phrase.noteDe!,
              languageCode: 'de',
              style: AppTypography.label,
            ),
          ],
          if (phrase.noteAr != null) ...<Widget>[
            const SizedBox(height: _CarServiceUiTokens.controlGap),
            AppDirectionalText(
              phrase.noteAr!,
              languageCode: 'ar',
              style: AppTypography.label,
            ),
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
      child: Column(
        children: <Widget>[
          const Icon(
            Icons.search_off_rounded,
            color: AppColors.secondary,
            size: _CarServiceUiTokens.iconSize,
          ),
          const SizedBox(height: _CarServiceUiTokens.controlGap),
          AppDirectionalText(
            'لا توجد نتائج مطابقة. غيّر البحث أو اختر قسمًا آخر.',
            languageCode: 'ar',
            style: AppTypography.body,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
