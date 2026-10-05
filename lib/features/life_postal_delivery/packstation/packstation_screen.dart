import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../../design_system/design_system.dart';
import 'packstation_models.dart';
import 'packstation_orchestrator.dart';

abstract final class PackstationUiTokens {
  static const double pageInset = 16;
  static const double bottomInset = 32;
  static const double sectionGap = 18;
  static const double itemGap = 12;
  static const double compactGap = 8;
}

final class PackstationIssuesScreen extends StatefulWidget {
  const PackstationIssuesScreen({
    this.orchestrator,
    super.key,
  });

  final PackstationOrchestrator? orchestrator;

  @override
  State<PackstationIssuesScreen> createState() =>
      _PackstationIssuesScreenState();
}

final class _PackstationIssuesScreenState
    extends State<PackstationIssuesScreen> {
  late final PackstationOrchestrator _orchestrator;
  late final bool _ownsOrchestrator;

  @override
  void initState() {
    super.initState();
    _ownsOrchestrator = widget.orchestrator == null;
    _orchestrator = widget.orchestrator ?? PackstationOrchestrator();
  }

  @override
  void dispose() {
    if (_ownsOrchestrator) _orchestrator.dispose();
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
              PackstationUiTokens.pageInset,
              PackstationUiTokens.pageInset,
              PackstationUiTokens.pageInset,
              PackstationUiTokens.bottomInset,
            ),
            child: AnimatedBuilder(
              animation: _orchestrator,
              builder: (context, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _HeaderCard(dark: dark),
                  const SizedBox(height: PackstationUiTokens.sectionGap),
                  _SearchField(orchestrator: _orchestrator),
                  const SizedBox(height: PackstationUiTokens.itemGap),
                  _ScenarioSelector(
                    orchestrator: _orchestrator,
                    dark: dark,
                  ),
                  const SizedBox(height: PackstationUiTokens.sectionGap),
                  _PackstationStepsBar(dark: dark),
                  const SizedBox(height: PackstationUiTokens.sectionGap),
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
              'Packstation & Zustellprobleme',
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: PackstationUiTokens.compactGap),
            AppDirectionalText(
              'ماكينات الطرود ومشاكل التسليم والإرجاع',
              languageCode: 'ar',
              style: AppTypography.title,
            ),
          ],
        ),
      );
}

final class _SearchField extends StatelessWidget {
  const _SearchField({required this.orchestrator});

  final PackstationOrchestrator orchestrator;

  @override
  Widget build(BuildContext context) => TextField(
        key: const ValueKey<String>('packstation-search'),
        onChanged: orchestrator.setQuery,
        textDirection: TextDirection.ltr,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search),
          labelText: 'Suche · بحث',
          hintText: 'Barcode, Abholcode, Nachbarn, Sendungsverlust ...',
          border: OutlineInputBorder(),
        ),
      );
}

final class _ScenarioSelector extends StatelessWidget {
  const _ScenarioSelector({
    required this.orchestrator,
    required this.dark,
  });

  final PackstationOrchestrator orchestrator;
  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.secondary.withAlpha(96),
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Wrap(
          spacing: PackstationUiTokens.compactGap,
          runSpacing: PackstationUiTokens.compactGap,
          children: <Widget>[
            for (final scenario in PackstationScenario.values)
              FilterChip(
                key: ValueKey<String>(
                  'packstation-scenario-${scenario.name}',
                ),
                selected: orchestrator.scenario == scenario,
                onSelected: (_) => orchestrator.setScenario(scenario),
                label: Text(
                  '${scenario.labelDe} · ${scenario.labelAr}',
                  style: AppTypography.label,
                ),
              ),
          ],
        ),
      );
}

final class _PackstationStepsBar extends StatelessWidget {
  const _PackstationStepsBar({required this.dark});

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
              'Packstation · Kurzablauf',
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: PackstationUiTokens.compactGap),
            AppDirectionalText(
              '1. Barcode scannen  →  2. Abholcode eingeben  →  3. Fach öffnen und wieder schließen',
              languageCode: 'de',
              style: AppTypography.body,
            ),
            const SizedBox(height: PackstationUiTokens.compactGap),
            AppDirectionalText(
              '1. امسح الباركود ← 2. أدخل رمز الاستلام ← 3. افتح الخزانة ثم أغلقها بعد أخذ الشحنة.',
              languageCode: 'ar',
              style: AppTypography.body,
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

  final PackstationOrchestrator orchestrator;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final phrases = orchestrator.visiblePhrases;

    if (phrases.isEmpty) {
      return AppGlassCard(
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: AppDirectionalText(
          'لا توجد عبارات مطابقة. جرّب كلمة بحث أخرى.',
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
            const SizedBox(height: PackstationUiTokens.itemGap),
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

  final PackstationPhrase phrase;
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
            const SizedBox(height: PackstationUiTokens.compactGap),
            AppDirectionalText(
              phrase.german,
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: PackstationUiTokens.compactGap),
            AppDirectionalText(
              phrase.arabic,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
            const SizedBox(height: PackstationUiTokens.compactGap),
            AppDirectionalText(
              phrase.contextAr,
              languageCode: 'ar',
              style: AppTypography.label,
            ),
            const SizedBox(height: PackstationUiTokens.compactGap),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Wrap(
                spacing: PackstationUiTokens.compactGap,
                runSpacing: PackstationUiTokens.compactGap,
                children: <Widget>[
                  for (final carrier in phrase.carriers)
                    Chip(
                      label: Text(
                        carrier.labelDe,
                        style: AppTypography.label,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
}
