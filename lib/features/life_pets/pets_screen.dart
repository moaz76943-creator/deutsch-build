import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../design_system/design_system.dart';
import 'pets_master_orchestrator.dart';
import 'pets_models.dart';

abstract final class PetsUiTokens {
  static const double pageInset = 16;
  static const double bottomInset = 32;
  static const double sectionGap = 18;
  static const double itemGap = 12;
  static const double compactGap = 8;
}

final class PetsMasterHub extends StatefulWidget {
  const PetsMasterHub({
    this.orchestrator,
    super.key,
  });

  final PetsMasterOrchestrator? orchestrator;

  @override
  State<PetsMasterHub> createState() => _PetsMasterHubState();
}

final class _PetsMasterHubState extends State<PetsMasterHub> {
  late final PetsMasterOrchestrator _orchestrator;
  late final bool _ownsOrchestrator;

  @override
  void initState() {
    super.initState();
    _ownsOrchestrator = widget.orchestrator == null;
    _orchestrator = widget.orchestrator ?? PetsMasterOrchestrator();
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
              PetsUiTokens.pageInset,
              PetsUiTokens.pageInset,
              PetsUiTokens.pageInset,
              PetsUiTokens.bottomInset,
            ),
            child: AnimatedBuilder(
              animation: _orchestrator,
              builder: (context, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _HeaderCard(dark: dark),
                  const SizedBox(height: PetsUiTokens.sectionGap),
                  _EmergencyBar(orchestrator: _orchestrator, dark: dark),
                  const SizedBox(height: PetsUiTokens.sectionGap),
                  _SearchField(orchestrator: _orchestrator),
                  const SizedBox(height: PetsUiTokens.itemGap),
                  _CategorySelector(
                    orchestrator: _orchestrator,
                    dark: dark,
                  ),
                  const SizedBox(height: PetsUiTokens.sectionGap),
                  _PhraseList(orchestrator: _orchestrator, dark: dark),
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
        glowColor: AppColors.secondary,
        borderColor: AppColors.secondary.withAlpha(96),
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'Tierarzt, Tierheim & Hundesteuer',
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: PetsUiTokens.compactGap),
            AppDirectionalText(
              'عبارات عملية لرعاية الحيوانات الأليفة، القواعد المحلية، وزيارات مأوى الحيوانات.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

final class _EmergencyBar extends StatelessWidget {
  const _EmergencyBar({
    required this.orchestrator,
    required this.dark,
  });

  final PetsMasterOrchestrator orchestrator;
  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        key: const ValueKey<String>('pets-emergency-bar'),
        glowColor: AppColors.tertiary,
        borderColor: AppColors.tertiary.withAlpha(112),
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(Icons.warning_amber_rounded),
                const SizedBox(width: PetsUiTokens.compactGap),
                Expanded(
                  child: AppDirectionalText(
                    'Tierärztlicher Notdienst · طوارئ بيطرية',
                    languageCode: 'de',
                    style: AppTypography.title,
                  ),
                ),
              ],
            ),
            const SizedBox(height: PetsUiTokens.compactGap),
            AppDirectionalText(
              'Bei einem akuten Notfall sofort den tierärztlichen Notdienst kontaktieren.',
              languageCode: 'de',
              style: AppTypography.body,
            ),
            const SizedBox(height: PetsUiTokens.itemGap),
            Wrap(
              spacing: PetsUiTokens.compactGap,
              runSpacing: PetsUiTokens.compactGap,
              children: <Widget>[
                for (final script in orchestrator.emergencyScripts)
                  ActionChip(
                    label: AppDirectionalText(
                      script,
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

final class _SearchField extends StatelessWidget {
  const _SearchField({required this.orchestrator});

  final PetsMasterOrchestrator orchestrator;

  @override
  Widget build(BuildContext context) => TextField(
        key: const ValueKey<String>('pets-search'),
        onChanged: orchestrator.setQuery,
        textDirection: TextDirection.ltr,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search),
          labelText: 'Suche · بحث',
          hintText: 'Impfung, Hundesteuer, Tierheim ...',
          border: OutlineInputBorder(),
        ),
      );
}

final class _CategorySelector extends StatelessWidget {
  const _CategorySelector({
    required this.orchestrator,
    required this.dark,
  });

  final PetsMasterOrchestrator orchestrator;
  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.primary.withAlpha(96),
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Wrap(
          spacing: PetsUiTokens.compactGap,
          runSpacing: PetsUiTokens.compactGap,
          children: <Widget>[
            for (final category in PetsCategory.values)
              FilterChip(
                key: ValueKey<String>('pets-category-${category.name}'),
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

final class _PhraseList extends StatelessWidget {
  const _PhraseList({
    required this.orchestrator,
    required this.dark,
  });

  final PetsMasterOrchestrator orchestrator;
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
          _PhraseCard(phrase: phrases[index], dark: dark),
          if (index != phrases.length - 1)
            const SizedBox(height: PetsUiTokens.itemGap),
        ],
      ],
    );
  }
}

final class _PhraseCard extends StatelessWidget {
  const _PhraseCard({required this.phrase, required this.dark});

  final PetPhrase phrase;
  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.secondary.withAlpha(80),
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              phrase.contextDe,
              languageCode: 'de',
              style: AppTypography.label,
            ),
            const SizedBox(height: PetsUiTokens.compactGap),
            AppDirectionalText(
              phrase.german,
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: PetsUiTokens.compactGap),
            AppDirectionalText(
              phrase.arabic,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
            const SizedBox(height: PetsUiTokens.compactGap),
            AppDirectionalText(
              phrase.contextAr,
              languageCode: 'ar',
              style: AppTypography.label,
            ),
          ],
        ),
      );
}
