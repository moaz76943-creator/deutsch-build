import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../design_system/design_system.dart';
import 'rent_housing_master_orchestrator.dart';
import 'rent_housing_models.dart';

abstract final class RentHousingUiTokens {
  static const double pageInset = 16;
  static const double bottomInset = 32;
  static const double sectionGap = 18;
  static const double itemGap = 12;
  static const double compactGap = 8;
}

final class RentHousingMasterHub extends StatefulWidget {
  const RentHousingMasterHub({
    this.orchestrator,
    super.key,
  });

  final RentHousingMasterOrchestrator? orchestrator;

  @override
  State<RentHousingMasterHub> createState() => _RentHousingMasterHubState();
}

final class _RentHousingMasterHubState extends State<RentHousingMasterHub> {
  late final RentHousingMasterOrchestrator _orchestrator;
  late final bool _ownsOrchestrator;

  @override
  void initState() {
    super.initState();
    _ownsOrchestrator = widget.orchestrator == null;
    _orchestrator = widget.orchestrator ?? RentHousingMasterOrchestrator();
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
              RentHousingUiTokens.pageInset,
              RentHousingUiTokens.pageInset,
              RentHousingUiTokens.pageInset,
              RentHousingUiTokens.bottomInset,
            ),
            child: AnimatedBuilder(
              animation: _orchestrator,
              builder: (context, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _HeaderCard(dark: dark),
                  const SizedBox(height: RentHousingUiTokens.sectionGap),
                  _SearchField(orchestrator: _orchestrator),
                  const SizedBox(height: RentHousingUiTokens.itemGap),
                  _SectionSelector(
                    orchestrator: _orchestrator,
                    dark: dark,
                  ),
                  const SizedBox(height: RentHousingUiTokens.sectionGap),
                  _CoreDataCard(dark: dark),
                  const SizedBox(height: RentHousingUiTokens.sectionGap),
                  _EntryList(
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
              'Wohnen, Mietvertrag & Wohnungsübergabe',
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: RentHousingUiTokens.compactGap),
            AppDirectionalText(
              'مركز عملي لمفردات عقد الإيجار والتكاليف ومحضر تسليم الشقة، مع توثيق واضح دون افتراض شروط غير مكتوبة.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

final class _SearchField extends StatelessWidget {
  const _SearchField({required this.orchestrator});

  final RentHousingMasterOrchestrator orchestrator;

  @override
  Widget build(BuildContext context) => TextField(
        key: const ValueKey<String>('rent-housing-search'),
        onChanged: orchestrator.setQuery,
        textDirection: TextDirection.ltr,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search),
          labelText: 'Suche · بحث',
          hintText: 'Mietvertrag, Nebenkosten, Übergabeprotokoll ...',
          border: OutlineInputBorder(),
        ),
      );
}

final class _SectionSelector extends StatelessWidget {
  const _SectionSelector({
    required this.orchestrator,
    required this.dark,
  });

  final RentHousingMasterOrchestrator orchestrator;
  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.secondary.withAlpha(96),
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Wrap(
          spacing: RentHousingUiTokens.compactGap,
          runSpacing: RentHousingUiTokens.compactGap,
          children: <Widget>[
            for (final section in RentHousingSection.values)
              FilterChip(
                key: ValueKey<String>(
                  'rent-housing-section-${section.name}',
                ),
                selected: orchestrator.section == section,
                onSelected: (_) => orchestrator.setSection(section),
                label: Text(
                  '${section.labelDe} · ${section.labelAr}',
                  style: AppTypography.label,
                ),
              ),
          ],
        ),
      );
}

final class _CoreDataCard extends StatelessWidget {
  const _CoreDataCard({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        glowColor: AppColors.tertiary,
        borderColor: AppColors.tertiary.withAlpha(96),
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'Daten, die du getrennt notieren solltest',
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: RentHousingUiTokens.compactGap),
            AppDirectionalText(
              'Kaltmiete · Nebenkosten-Vorauszahlung · Heizkosten · Kaution · Zählerstände · Schlüssel · sichtbare Mängel',
              languageCode: 'de',
              style: AppTypography.body,
            ),
            const SizedBox(height: RentHousingUiTokens.compactGap),
            AppDirectionalText(
              'دوّن الإيجار الأساسي والدفعات الإضافية والتدفئة والتأمين وقراءات العدادات والمفاتيح والعيوب الظاهرة كل بند على حدة.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

final class _EntryList extends StatelessWidget {
  const _EntryList({
    required this.orchestrator,
    required this.dark,
  });

  final RentHousingMasterOrchestrator orchestrator;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final entries = orchestrator.visibleEntries;

    if (entries.isEmpty) {
      return AppGlassCard(
        borderColor: AppColors.tertiary.withAlpha(96),
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: AppDirectionalText(
          'لا توجد نتيجة في هذا القسم. جرّب كلمة أخرى.',
          languageCode: 'ar',
          style: AppTypography.body,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (var index = 0; index < entries.length; index++) ...<Widget>[
          _EntryCard(entry: entries[index], dark: dark),
          if (index != entries.length - 1)
            const SizedBox(height: RentHousingUiTokens.itemGap),
        ],
      ],
    );
  }
}

final class _EntryCard extends StatelessWidget {
  const _EntryCard({
    required this.entry,
    required this.dark,
  });

  final RentHousingEntry entry;
  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.primary.withAlpha(80),
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              entry.titleDe,
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: RentHousingUiTokens.compactGap),
            AppDirectionalText(
              entry.titleAr,
              languageCode: 'ar',
              style: AppTypography.label,
            ),
            const SizedBox(height: RentHousingUiTokens.itemGap),
            AppDirectionalText(
              entry.german,
              languageCode: 'de',
              style: AppTypography.body,
            ),
            const SizedBox(height: RentHousingUiTokens.compactGap),
            AppDirectionalText(
              entry.arabic,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
            const SizedBox(height: RentHousingUiTokens.itemGap),
            AppDirectionalText(
              entry.contextDe,
              languageCode: 'de',
              style: AppTypography.label,
            ),
            const SizedBox(height: RentHousingUiTokens.compactGap),
            AppDirectionalText(
              entry.contextAr,
              languageCode: 'ar',
              style: AppTypography.label,
            ),
          ],
        ),
      );
}
