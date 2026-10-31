import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../design_system/design_system.dart';
import 'career_models.dart';
import 'career_orchestrator.dart';

abstract final class _CareerUiTokens {
  static const double pageInset = 16;
  static const double sectionGap = 16;
  static const double contentGap = 10;
  static const double compactGap = 8;
  static const double chipRadius = 18;
}

class CareerHubScreen extends StatefulWidget {
  const CareerHubScreen({super.key});

  @override
  State<CareerHubScreen> createState() => _CareerHubScreenState();
}

class _CareerHubScreenState extends State<CareerHubScreen> {
  late final CareerMasterOrchestrator _orchestrator;

  @override
  void initState() {
    super.initState();
    _orchestrator = CareerMasterOrchestrator()..addListener(_refresh);
  }

  @override
  void dispose() {
    _orchestrator
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface = dark ? AppColors.darkSurface : AppColors.lightSurface;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(_CareerUiTokens.pageInset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppGlassCard(
              glowColor: AppColors.primary,
              borderColor: AppColors.primary,
              backgroundColor: surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  AppDirectionalText(
                    'Bewerbung & Karriere',
                    languageCode: 'de',
                    style: AppTypography.title,
                  ),
                  const SizedBox(height: _CareerUiTokens.compactGap),
                  AppDirectionalText(
                    'التقديم والمسار المهني',
                    languageCode: 'ar',
                    style: AppTypography.body,
                  ),
                ],
              ),
            ),
            const SizedBox(height: _CareerUiTokens.sectionGap),
            _StageSelector(
              selected: _orchestrator.stage,
              onSelected: _orchestrator.setStage,
            ),
            const SizedBox(height: _CareerUiTokens.sectionGap),
            _SearchCard(
              onChanged: _orchestrator.setQuery,
              onClear: _orchestrator.clearQuery,
              showClear: _orchestrator.query.isNotEmpty,
              surface: surface,
            ),
            const SizedBox(height: _CareerUiTokens.sectionGap),
            _UrgentPrepBar(
              key: const ValueKey('career-urgent-prep'),
              phrases: _orchestrator.urgentPrep,
              surface: surface,
            ),
            const SizedBox(height: _CareerUiTokens.sectionGap),
            if (_orchestrator.visibleItems.isEmpty)
              AppGlassCard(
                backgroundColor: surface,
                child: AppDirectionalText(
                  'لا توجد عبارات مطابقة. جرّب كلمة بحث أخرى.',
                  languageCode: 'ar',
                  style: AppTypography.body,
                ),
              )
            else
              for (final phrase in _orchestrator.visibleItems) ...<Widget>[
                _CareerPhraseCard(phrase: phrase, surface: surface),
                const SizedBox(height: _CareerUiTokens.contentGap),
              ],
          ],
        ),
      ),
    );
  }
}

final class _StageSelector extends StatelessWidget {
  const _StageSelector({required this.selected, required this.onSelected});

  final CareerStage selected;
  final ValueChanged<CareerStage> onSelected;

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.ltr,
        child: Wrap(
          spacing: _CareerUiTokens.compactGap,
          runSpacing: _CareerUiTokens.compactGap,
          children: <Widget>[
            for (final stage in CareerStage.values)
              ChoiceChip(
                key: ValueKey<String>('career-stage-${stage.name}'),
                selected: selected == stage,
                onSelected: (_) => onSelected(stage),
                label: Text(
                  '${stage.labelDe} · ${stage.labelAr}',
                  style: AppTypography.label,
                ),
              ),
          ],
        ),
      );
}

final class _SearchCard extends StatelessWidget {
  const _SearchCard({
    required this.onChanged,
    required this.onClear,
    required this.showClear,
    required this.surface,
  });

  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool showClear;
  final Color surface;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.secondary,
        backgroundColor: surface,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: TextField(
            key: const ValueKey('career-search-field'),
            onChanged: onChanged,
            style: AppTypography.body,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              hintText: 'Suchen / ابحث',
              hintStyle: AppTypography.body,
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: showClear
                  ? IconButton(
                      tooltip: 'Clear search',
                      onPressed: onClear,
                      icon: const Icon(Icons.close),
                    )
                  : null,
            ),
          ),
        ),
      );
}

final class _UrgentPrepBar extends StatelessWidget {
  const _UrgentPrepBar({
    required this.phrases,
    required this.surface,
    super.key,
  });

  final List<CareerPhrase> phrases;
  final Color surface;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        glowColor: AppColors.tertiary,
        borderColor: AppColors.tertiary,
        backgroundColor: surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'Interview Urgent Prep · تجهيز سريع للمقابلة',
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: _CareerUiTokens.compactGap),
            for (final phrase in phrases.take(4)) ...<Widget>[
              AppDirectionalText(
                phrase.german,
                languageCode: 'de',
                style: AppTypography.label,
              ),
              AppDirectionalText(
                phrase.arabic,
                languageCode: 'ar',
                style: AppTypography.body,
              ),
              const SizedBox(height: _CareerUiTokens.compactGap),
            ],
          ],
        ),
      );
}

final class _CareerPhraseCard extends StatelessWidget {
  const _CareerPhraseCard({required this.phrase, required this.surface});

  final CareerPhrase phrase;
  final Color surface;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: _topicColor(phrase.topic),
        glowColor: phrase.urgent ? AppColors.tertiary : null,
        backgroundColor: surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Directionality(
              textDirection: TextDirection.ltr,
              child: Wrap(
                spacing: _CareerUiTokens.compactGap,
                runSpacing: _CareerUiTokens.compactGap,
                children: <Widget>[
                  _Tag(text: phrase.stage.labelDe),
                  _Tag(text: _topicLabel(phrase.topic)),
                ],
              ),
            ),
            const SizedBox(height: _CareerUiTokens.contentGap),
            AppDirectionalText(
              phrase.german,
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: _CareerUiTokens.compactGap),
            AppDirectionalText(
              phrase.arabic,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
            if (phrase.noteAr != null) ...<Widget>[
              const SizedBox(height: _CareerUiTokens.compactGap),
              AppDirectionalText(
                phrase.noteAr!,
                languageCode: 'ar',
                style: AppTypography.label,
              ),
            ],
          ],
        ),
      );

  static Color _topicColor(CareerTopic topic) => switch (topic) {
        CareerTopic.cv => AppColors.primary,
        CareerTopic.experience => AppColors.primary,
        CareerTopic.coverLetter => AppColors.secondary,
        CareerTopic.openPosition => AppColors.secondary,
        CareerTopic.selfIntroduction => AppColors.achievement,
        CareerTopic.qualifications => AppColors.achievement,
        CareerTopic.workingHours => AppColors.tertiary,
        CareerTopic.teamStructure => AppColors.tertiary,
        CareerTopic.followUp => AppColors.mastery,
      };

  static String _topicLabel(CareerTopic topic) => switch (topic) {
        CareerTopic.cv => 'Lebenslauf',
        CareerTopic.coverLetter => 'Anschreiben',
        CareerTopic.openPosition => 'Offene Stelle',
        CareerTopic.selfIntroduction => 'Selbstvorstellung',
        CareerTopic.experience => 'Berufserfahrung',
        CareerTopic.qualifications => 'Qualifikationen',
        CareerTopic.workingHours => 'Arbeitszeiten',
        CareerTopic.teamStructure => 'Teamstruktur',
        CareerTopic.followUp => 'Nachfassen',
      };
}

final class _Tag extends StatelessWidget {
  const _Tag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: _CareerUiTokens.contentGap,
          vertical: _CareerUiTokens.compactGap,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_CareerUiTokens.chipRadius),
          border: Border.all(color: AppColors.primary),
        ),
        child: Text(text, style: AppTypography.label),
      );
}
