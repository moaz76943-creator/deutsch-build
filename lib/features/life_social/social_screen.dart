import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../design_system/design_system.dart';
import 'social_master_orchestrator.dart';
import 'social_models.dart';

abstract final class SocialUiTokens {
  static const double pageInset = 16;
  static const double bottomInset = 32;
  static const double sectionGap = 18;
  static const double itemGap = 12;
  static const double compactGap = 8;
}

final class SocialMasterHub extends StatefulWidget {
  const SocialMasterHub({
    this.orchestrator,
    super.key,
  });

  final SocialMasterOrchestrator? orchestrator;

  @override
  State<SocialMasterHub> createState() => _SocialMasterHubState();
}

final class _SocialMasterHubState extends State<SocialMasterHub> {
  late final SocialMasterOrchestrator _orchestrator;
  late final bool _ownsOrchestrator;

  @override
  void initState() {
    super.initState();
    _ownsOrchestrator = widget.orchestrator == null;
    _orchestrator = widget.orchestrator ?? SocialMasterOrchestrator();
  }

  @override
  void dispose() {
    if (_ownsOrchestrator) {
      _orchestrator.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor:
            dark ? AppColors.darkBackground : AppColors.lightBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              SocialUiTokens.pageInset,
              SocialUiTokens.pageInset,
              SocialUiTokens.pageInset,
              SocialUiTokens.bottomInset,
            ),
            child: AnimatedBuilder(
              animation: _orchestrator,
              builder: (context, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _HeaderCard(dark: dark),
                  const SizedBox(height: SocialUiTokens.sectionGap),
                  _ToneSelector(orchestrator: _orchestrator, dark: dark),
                  const SizedBox(height: SocialUiTokens.itemGap),
                  _SearchField(orchestrator: _orchestrator),
                  const SizedBox(height: SocialUiTokens.itemGap),
                  _CategorySelector(
                    orchestrator: _orchestrator,
                    dark: dark,
                  ),
                  const SizedBox(height: SocialUiTokens.sectionGap),
                  _QuickResponsesBar(
                    orchestrator: _orchestrator,
                    dark: dark,
                  ),
                  const SizedBox(height: SocialUiTokens.sectionGap),
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
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'Knigge, Nachbarschaft & Höflichkeit',
              languageCode: 'de',
              style: AppTypography.title,
            ),
            SizedBox(height: SocialUiTokens.compactGap),
            AppDirectionalText(
              'عبارات يومية مهذبة للجيرة والمناسبات، مع اختيار واضح بين Du وSie.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

final class _ToneSelector extends StatelessWidget {
  const _ToneSelector({
    required this.orchestrator,
    required this.dark,
  });

  final SocialMasterOrchestrator orchestrator;
  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.secondary.withAlpha(96),
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'Anrede · أسلوب المخاطبة',
              languageCode: 'de',
              style: AppTypography.label,
            ),
            const SizedBox(height: SocialUiTokens.compactGap),
            Wrap(
              spacing: SocialUiTokens.compactGap,
              runSpacing: SocialUiTokens.compactGap,
              children: <Widget>[
                for (final tone in SocialTone.values)
                  FilterChip(
                    key: ValueKey<String>('social-tone-${tone.name}'),
                    selected: orchestrator.tone == tone,
                    onSelected: (_) => orchestrator.setTone(tone),
                    avatar: Icon(
                      tone == SocialTone.sie
                          ? Icons.business_outlined
                          : Icons.chat_bubble_outline,
                    ),
                    label: Text(
                      '${tone.labelDe} · ${tone.labelAr}',
                      style: AppTypography.label,
                    ),
                  ),
              ],
            ),
          ],
        ),
      );
}

final class _SearchField extends StatelessWidget {
  const _SearchField({required this.orchestrator});

  final SocialMasterOrchestrator orchestrator;

  @override
  Widget build(BuildContext context) => TextField(
        key: const ValueKey<String>('social-search'),
        onChanged: orchestrator.setQuery,
        textDirection: TextDirection.ltr,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search),
          labelText: 'Suche · بحث',
          hintText: 'Hausordnung, Beileid, Paket ...',
          border: OutlineInputBorder(),
        ),
      );
}

final class _CategorySelector extends StatelessWidget {
  const _CategorySelector({
    required this.orchestrator,
    required this.dark,
  });

  final SocialMasterOrchestrator orchestrator;
  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.tertiary.withAlpha(96),
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Wrap(
          spacing: SocialUiTokens.compactGap,
          runSpacing: SocialUiTokens.compactGap,
          children: <Widget>[
            for (final category in SocialCategory.values)
              FilterChip(
                key: ValueKey<String>('social-category-${category.name}'),
                selected: orchestrator.category == category,
                onSelected: (_) => orchestrator.setCategory(category),
                label: Text(
                  '${category.labelDe} · ${category.labelAr}',
                  style: AppTypography.label,
                ),
              ),
          ],
        ),
      );
}

final class _QuickResponsesBar extends StatelessWidget {
  const _QuickResponsesBar({
    required this.orchestrator,
    required this.dark,
  });

  final SocialMasterOrchestrator orchestrator;
  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        glowColor: AppColors.secondary,
        borderColor: AppColors.secondary.withAlpha(96),
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'Quick Polite Responses',
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: SocialUiTokens.compactGap),
            Wrap(
              spacing: SocialUiTokens.compactGap,
              runSpacing: SocialUiTokens.compactGap,
              children: <Widget>[
                for (final response in orchestrator.quickResponses)
                  ActionChip(
                    label: AppDirectionalText(
                      response,
                      languageCode: 'de',
                      style: AppTypography.label,
                    ),
                    onPressed: () {},
                  ),
              ],
            ),
          ],
        ),
      );
}

final class _PhraseList extends StatelessWidget {
  const _PhraseList({
    required this.orchestrator,
    required this.dark,
  });

  final SocialMasterOrchestrator orchestrator;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final phrases = orchestrator.visiblePhrases;
    if (phrases.isEmpty) {
      return AppGlassCard(
        borderColor: AppColors.tertiary.withAlpha(96),
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: AppDirectionalText(
          'لا توجد نتائج في هذا القسم. جرّب كلمة بحث أخرى.',
          languageCode: 'ar',
          style: AppTypography.body,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (var index = 0; index < phrases.length; index++) ...<Widget>[
          _PhraseCard(
            phrase: phrases[index],
            tone: orchestrator.tone,
            dark: dark,
          ),
          if (index != phrases.length - 1)
            const SizedBox(height: SocialUiTokens.itemGap),
        ],
      ],
    );
  }
}

final class _PhraseCard extends StatelessWidget {
  const _PhraseCard({
    required this.phrase,
    required this.tone,
    required this.dark,
  });

  final SocialPhrase phrase;
  final SocialTone tone;
  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.primary.withAlpha(80),
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              phrase.contextDe,
              languageCode: 'de',
              style: AppTypography.label,
            ),
            const SizedBox(height: SocialUiTokens.compactGap),
            AppDirectionalText(
              phrase.germanFor(tone),
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: SocialUiTokens.compactGap),
            AppDirectionalText(
              phrase.arabic,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
            const SizedBox(height: SocialUiTokens.compactGap),
            AppDirectionalText(
              phrase.contextAr,
              languageCode: 'ar',
              style: AppTypography.label,
            ),
          ],
        ),
      );
}
