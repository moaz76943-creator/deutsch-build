import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../design_system/app_colors.dart';
import '../../design_system/app_glass_card.dart';
import '../../design_system/app_typography.dart' hide AppDirectionalText;
import 'sports_master_orchestrator.dart';
import 'sports_models.dart';

abstract final class _SportsUiTokens {
  static const double pageInset = 16;
  static const double sectionGap = 14;
  static const double contentGap = 10;
  static const double controlGap = 8;
  static const double iconSize = 22;
}

class SportsMasterHub extends StatefulWidget {
  const SportsMasterHub({
    this.orchestrator,
    super.key,
  });

  final SportsMasterOrchestrator? orchestrator;

  @override
  State<SportsMasterHub> createState() => _SportsMasterHubState();
}

class _SportsMasterHubState extends State<SportsMasterHub> {
  late final SportsMasterOrchestrator _orchestrator;
  late final bool _ownsOrchestrator;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _ownsOrchestrator = widget.orchestrator == null;
    _orchestrator = widget.orchestrator ?? SportsMasterOrchestrator();
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
              'Sport & Fitness',
              languageCode: 'de',
              style: AppTypography.title,
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(_SportsUiTokens.pageInset),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _HeaderCard(count: phrases.length),
                  const SizedBox(height: _SportsUiTokens.sectionGap),
                  _FacilityFilter(orchestrator: _orchestrator),
                  const SizedBox(height: _SportsUiTokens.sectionGap),
                  _SearchAndLevelCard(
                    orchestrator: _orchestrator,
                    searchController: _searchController,
                  ),
                  const SizedBox(height: _SportsUiTokens.sectionGap),
                  _MembershipPauseBar(orchestrator: _orchestrator),
                  const SizedBox(height: _SportsUiTokens.sectionGap),
                  if (phrases.isEmpty)
                    const _EmptyState()
                  else
                    for (final phrase in phrases) ...<Widget>[
                      _PhraseCard(phrase: phrase),
                      const SizedBox(height: _SportsUiTokens.contentGap),
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
            'Fitnessstudio & Sportverein',
            languageCode: 'de',
            style: AppTypography.title.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: _SportsUiTokens.controlGap),
          AppDirectionalText(
            'عبارات يومية صحية للتدريب والعضوية والرياضة المجتمعية.',
            languageCode: 'ar',
            style: AppTypography.body,
          ),
          const SizedBox(height: _SportsUiTokens.controlGap),
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

final class _FacilityFilter extends StatelessWidget {
  const _FacilityFilter({required this.orchestrator});

  final SportsMasterOrchestrator orchestrator;

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
            'Ort wählen',
            languageCode: 'de',
            style: AppTypography.title,
          ),
          const SizedBox(height: _SportsUiTokens.controlGap),
          Wrap(
            spacing: _SportsUiTokens.controlGap,
            runSpacing: _SportsUiTokens.controlGap,
            children: <Widget>[
              for (final facility in SportsFacilityType.values)
                ChoiceChip(
                  key: ValueKey<String>(
                    'sports-facility-' + facility.name,
                  ),
                  selected: orchestrator.facility == facility,
                  onSelected: (_) => orchestrator.setFacility(facility),
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      AppDirectionalText(
                        facility.labelDe,
                        languageCode: 'de',
                        style: AppTypography.label,
                      ),
                      AppDirectionalText(
                        facility.labelAr,
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

final class _SearchAndLevelCard extends StatelessWidget {
  const _SearchAndLevelCard({
    required this.orchestrator,
    required this.searchController,
  });

  final SportsMasterOrchestrator orchestrator;
  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AppGlassCard(
      borderColor: AppColors.primary.withAlpha(62),
      backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            key: const ValueKey<String>('sports-search'),
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
            ),
          ),
          const SizedBox(height: _SportsUiTokens.contentGap),
          AppDirectionalText(
            'Sprachniveau',
            languageCode: 'de',
            style: AppTypography.label,
          ),
          const SizedBox(height: _SportsUiTokens.controlGap),
          Wrap(
            spacing: _SportsUiTokens.controlGap,
            runSpacing: _SportsUiTokens.controlGap,
            children: <Widget>[
              ChoiceChip(
                key: const ValueKey<String>('sports-level-all'),
                label: AppDirectionalText(
                  'Alle',
                  languageCode: 'de',
                  style: AppTypography.label,
                ),
                selected: orchestrator.level == null,
                onSelected: (_) => orchestrator.setLevel(null),
              ),
              for (final level in SportsLevel.values)
                ChoiceChip(
                  key: ValueKey<String>('sports-level-' + level.name),
                  label: Text(
                    level.label,
                    textDirection: TextDirection.ltr,
                    style: AppTypography.label,
                  ),
                  selected: orchestrator.level == level,
                  onSelected: (_) => orchestrator.setLevel(level),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

final class _MembershipPauseBar extends StatelessWidget {
  const _MembershipPauseBar({required this.orchestrator});

  final SportsMasterOrchestrator orchestrator;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AppGlassCard(
      key: const ValueKey<String>('sports-pause-bar'),
      onTap: orchestrator.togglePauseDetails,
      glowColor: AppColors.tertiary,
      borderColor: AppColors.tertiary.withAlpha(96),
      backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.pause_circle_outline_rounded,
                color: AppColors.tertiary,
                size: _SportsUiTokens.iconSize,
              ),
              const SizedBox(width: _SportsUiTokens.controlGap),
              Expanded(
                child: AppDirectionalText(
                  'Mitgliedschaft pausieren · Ruhezeit',
                  languageCode: 'de',
                  style: AppTypography.title,
                ),
              ),
              Icon(
                orchestrator.pauseExpanded
                    ? Icons.expand_less_rounded
                    : Icons.expand_more_rounded,
              ),
            ],
          ),
          const SizedBox(height: _SportsUiTokens.controlGap),
          AppDirectionalText(
            orchestrator.membershipPauseGerman,
            languageCode: 'de',
            style: AppTypography.body,
          ),
          const SizedBox(height: _SportsUiTokens.controlGap),
          AppDirectionalText(
            orchestrator.membershipPauseArabic,
            languageCode: 'ar',
            style: AppTypography.body,
          ),
          if (orchestrator.pauseExpanded) ...<Widget>[
            const SizedBox(height: _SportsUiTokens.contentGap),
            AppDirectionalText(
              orchestrator.membershipPauseNoteGerman,
              languageCode: 'de',
              style: AppTypography.label,
            ),
            const SizedBox(height: _SportsUiTokens.controlGap),
            AppDirectionalText(
              orchestrator.membershipPauseNoteArabic,
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

  final SportsPhrase phrase;

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
            spacing: _SportsUiTokens.controlGap,
            runSpacing: _SportsUiTokens.controlGap,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Text(
                phrase.level.label,
                textDirection: TextDirection.ltr,
                style: AppTypography.label.copyWith(color: _accent),
              ),
              AppDirectionalText(
                phrase.topic.labelDe,
                languageCode: 'de',
                style: AppTypography.label,
              ),
              AppDirectionalText(
                phrase.facility.labelDe,
                languageCode: 'de',
                style: AppTypography.label,
              ),
            ],
          ),
          const SizedBox(height: _SportsUiTokens.contentGap),
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
          const SizedBox(height: _SportsUiTokens.contentGap),
          AppDirectionalText(
            phrase.german,
            languageCode: 'de',
            style: AppTypography.body,
          ),
          const SizedBox(height: _SportsUiTokens.controlGap),
          AppDirectionalText(
            phrase.arabic,
            languageCode: 'ar',
            style: AppTypography.body,
          ),
          if (phrase.noteDe != null) ...<Widget>[
            const SizedBox(height: _SportsUiTokens.contentGap),
            AppDirectionalText(
              phrase.noteDe!,
              languageCode: 'de',
              style: AppTypography.label,
            ),
          ],
          if (phrase.noteAr != null) ...<Widget>[
            const SizedBox(height: _SportsUiTokens.controlGap),
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

  Color get _accent => switch (phrase.facility) {
        SportsFacilityType.gym => AppColors.primary,
        SportsFacilityType.communityClub => AppColors.secondary,
        SportsFacilityType.all => AppColors.tertiary,
      };
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
            size: _SportsUiTokens.iconSize,
          ),
          const SizedBox(height: _SportsUiTokens.controlGap),
          AppDirectionalText(
            'لا توجد نتائج مطابقة. غيّر البحث أو مستوى اللغة.',
            languageCode: 'ar',
            style: AppTypography.body,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
