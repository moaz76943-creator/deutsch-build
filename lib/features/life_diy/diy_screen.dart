import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../design_system/design_system.dart';
import 'diy_master_orchestrator.dart';
import 'diy_models.dart';

abstract final class DiyUiTokens {
  static const double pageInset = 16;
  static const double bottomInset = 32;
  static const double sectionGap = 18;
  static const double itemGap = 12;
  static const double compactGap = 8;
}

final class DiyMasterHub extends StatefulWidget {
  const DiyMasterHub({
    this.orchestrator,
    super.key,
  });

  final DiyMasterOrchestrator? orchestrator;

  @override
  State<DiyMasterHub> createState() => _DiyMasterHubState();
}

final class _DiyMasterHubState extends State<DiyMasterHub> {
  late final DiyMasterOrchestrator _orchestrator;
  late final bool _ownsOrchestrator;

  @override
  void initState() {
    super.initState();
    _ownsOrchestrator = widget.orchestrator == null;
    _orchestrator = widget.orchestrator ?? DiyMasterOrchestrator();
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
              DiyUiTokens.pageInset,
              DiyUiTokens.pageInset,
              DiyUiTokens.pageInset,
              DiyUiTokens.bottomInset,
            ),
            child: AnimatedBuilder(
              animation: _orchestrator,
              builder: (context, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _HeaderCard(dark: dark),
                  const SizedBox(height: DiyUiTokens.sectionGap),
                  _SearchField(orchestrator: _orchestrator),
                  const SizedBox(height: DiyUiTokens.itemGap),
                  _DomainSelector(
                    orchestrator: _orchestrator,
                    dark: dark,
                  ),
                  const SizedBox(height: DiyUiTokens.sectionGap),
                  _QuickSizingBar(
                    orchestrator: _orchestrator,
                    dark: dark,
                  ),
                  const SizedBox(height: DiyUiTokens.sectionGap),
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
              'Baumarkt, Werkzeuge & Zuschnitt',
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: DiyUiTokens.compactGap),
            AppDirectionalText(
              'عبارات عملية للشراء والقص حسب المقاس وتأجير المعدات، مع محوّل وحدات سريع.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

final class _SearchField extends StatelessWidget {
  const _SearchField({required this.orchestrator});

  final DiyMasterOrchestrator orchestrator;

  @override
  Widget build(BuildContext context) => TextField(
        key: const ValueKey<String>('diy-search'),
        onChanged: orchestrator.setQuery,
        textDirection: TextDirection.ltr,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search),
          labelText: 'Suche · بحث',
          hintText: 'Dübel, Farbe, Zuschnitt, Kaution ...',
          border: OutlineInputBorder(),
        ),
      );
}

final class _DomainSelector extends StatelessWidget {
  const _DomainSelector({
    required this.orchestrator,
    required this.dark,
  });

  final DiyMasterOrchestrator orchestrator;
  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.secondary.withAlpha(96),
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Wrap(
          spacing: DiyUiTokens.compactGap,
          runSpacing: DiyUiTokens.compactGap,
          children: <Widget>[
            for (final domain in DiyDomain.values)
              FilterChip(
                key: ValueKey<String>('diy-domain-${domain.name}'),
                selected: orchestrator.domain == domain,
                onSelected: (_) => orchestrator.setDomain(domain),
                label: Text(
                  '${domain.labelDe} · ${domain.labelAr}',
                  style: AppTypography.label,
                ),
              ),
          ],
        ),
      );
}

final class _QuickSizingBar extends StatelessWidget {
  const _QuickSizingBar({
    required this.orchestrator,
    required this.dark,
  });

  final DiyMasterOrchestrator orchestrator;
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
              'Quick Unit Converter / Sizing',
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: DiyUiTokens.compactGap),
            AppDirectionalText(
              'حوّل المقاسات بسرعة ثم استخدم صيغة آمنة للسؤال عن قطعة التثبيت المناسبة حسب تعليمات الشركة المصنّعة.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
            const SizedBox(height: DiyUiTokens.itemGap),
            TextFormField(
              key: const ValueKey<String>('diy-converter-input'),
              initialValue: orchestrator.conversionValue.toStringAsFixed(0),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textDirection: TextDirection.ltr,
              onChanged: (value) {
                final parsed = double.tryParse(value.replaceAll(',', '.'));
                if (parsed != null) {
                  orchestrator.setConversionValue(parsed);
                }
              },
              decoration: const InputDecoration(
                labelText: 'Wert · القيمة',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: DiyUiTokens.compactGap),
            Row(
              children: <Widget>[
                Expanded(
                  child: _UnitDropdown(
                    key: const ValueKey<String>('diy-from-unit'),
                    label: 'Von · من',
                    value: orchestrator.fromUnit,
                    onChanged: orchestrator.setFromUnit,
                  ),
                ),
                const SizedBox(width: DiyUiTokens.compactGap),
                const Icon(Icons.arrow_forward),
                const SizedBox(width: DiyUiTokens.compactGap),
                Expanded(
                  child: _UnitDropdown(
                    key: const ValueKey<String>('diy-to-unit'),
                    label: 'Nach · إلى',
                    value: orchestrator.toUnit,
                    onChanged: orchestrator.setToUnit,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DiyUiTokens.itemGap),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                '${orchestrator.formattedInputValue} ${orchestrator.fromUnit.symbol} = ${orchestrator.formattedConversion}',
                key: const ValueKey<String>('diy-conversion-result'),
                style: AppTypography.title,
              ),
            ),
            const SizedBox(height: DiyUiTokens.itemGap),
            AppDirectionalText(
              'Schraubendurchmesser · قطر البرغي',
              languageCode: 'de',
              style: AppTypography.label,
            ),
            const SizedBox(height: DiyUiTokens.compactGap),
            Wrap(
              spacing: DiyUiTokens.compactGap,
              runSpacing: DiyUiTokens.compactGap,
              children: <Widget>[
                for (final size in const <int>[4, 5, 6, 8])
                  ChoiceChip(
                    key: ValueKey<String>('diy-size-$size'),
                    selected: orchestrator.screwDiameterMm == size,
                    onSelected: (_) => orchestrator.setScrewDiameterMm(size),
                    label: Text('$size mm'),
                  ),
              ],
            ),
            const SizedBox(height: DiyUiTokens.compactGap),
            AppDirectionalText(
              orchestrator.sizingPrompt.german,
              languageCode: 'de',
              style: AppTypography.body,
            ),
            const SizedBox(height: DiyUiTokens.compactGap),
            AppDirectionalText(
              orchestrator.sizingPrompt.arabic,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

final class _UnitDropdown extends StatelessWidget {
  const _UnitDropdown({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String label;
  final DiyLengthUnit value;
  final ValueChanged<DiyLengthUnit> onChanged;

  @override
  Widget build(BuildContext context) => InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<DiyLengthUnit>(
            value: value,
            isExpanded: true,
            items: <DropdownMenuItem<DiyLengthUnit>>[
              for (final unit in DiyLengthUnit.values)
                DropdownMenuItem<DiyLengthUnit>(
                  value: unit,
                  child: Text(unit.symbol),
                ),
            ],
            onChanged: (next) {
              if (next != null) onChanged(next);
            },
          ),
        ),
      );
}

final class _PhraseList extends StatelessWidget {
  const _PhraseList({
    required this.orchestrator,
    required this.dark,
  });

  final DiyMasterOrchestrator orchestrator;
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
            const SizedBox(height: DiyUiTokens.itemGap),
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

  final DiyPhrase phrase;
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
            const SizedBox(height: DiyUiTokens.compactGap),
            AppDirectionalText(
              phrase.german,
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: DiyUiTokens.compactGap),
            AppDirectionalText(
              phrase.arabic,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
            const SizedBox(height: DiyUiTokens.compactGap),
            AppDirectionalText(
              phrase.contextAr,
              languageCode: 'ar',
              style: AppTypography.label,
            ),
          ],
        ),
      );
}
