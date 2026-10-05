import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../design_system/design_system.dart';
import '../life_diy/diy_models.dart';
import 'hardware_store_master_orchestrator.dart';
import 'hardware_store_models.dart';

abstract final class HardwareStoreUiTokens {
  static const double pageInset = 16;
  static const double bottomInset = 32;
  static const double sectionGap = 18;
  static const double itemGap = 12;
  static const double compactGap = 8;
}

final class HardwareStoreMasterHub extends StatefulWidget {
  const HardwareStoreMasterHub({
    this.orchestrator,
    super.key,
  });

  final HardwareStoreMasterOrchestrator? orchestrator;

  @override
  State<HardwareStoreMasterHub> createState() =>
      _HardwareStoreMasterHubState();
}

final class _HardwareStoreMasterHubState
    extends State<HardwareStoreMasterHub> {
  late final HardwareStoreMasterOrchestrator _orchestrator;
  late final bool _ownsOrchestrator;

  @override
  void initState() {
    super.initState();
    _ownsOrchestrator = widget.orchestrator == null;
    _orchestrator =
        widget.orchestrator ?? HardwareStoreMasterOrchestrator();
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
              HardwareStoreUiTokens.pageInset,
              HardwareStoreUiTokens.pageInset,
              HardwareStoreUiTokens.pageInset,
              HardwareStoreUiTokens.bottomInset,
            ),
            child: AnimatedBuilder(
              animation: _orchestrator,
              builder: (context, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _HeaderCard(dark: dark),
                  const SizedBox(height: HardwareStoreUiTokens.sectionGap),
                  _SearchCard(
                    orchestrator: _orchestrator,
                    dark: dark,
                  ),
                  const SizedBox(height: HardwareStoreUiTokens.itemGap),
                  _SectionSelector(
                    orchestrator: _orchestrator,
                    dark: dark,
                  ),
                  const SizedBox(height: HardwareStoreUiTokens.sectionGap),
                  _CatalogCard(
                    orchestrator: _orchestrator,
                    dark: dark,
                  ),
                  const SizedBox(height: HardwareStoreUiTokens.sectionGap),
                  _PhraseList(
                    phrases: _orchestrator.visiblePhrases,
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
              'Baumarkt · Werkzeuge · Holzzuschnitt · Mietgeräte',
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: HardwareStoreUiTokens.compactGap),
            AppDirectionalText(
              'مركز عملي للسؤال داخل متجر مواد البناء عن الأدوات والمواد وخدمة القص وتأجير المعدات، مع جمل ألمانية جاهزة وسياق عربي واضح.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

final class _SearchCard extends StatelessWidget {
  const _SearchCard({
    required this.orchestrator,
    required this.dark,
  });

  final HardwareStoreMasterOrchestrator orchestrator;
  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.secondary.withAlpha(96),
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: TextField(
          key: const ValueKey<String>('hardware-store-search'),
          onChanged: orchestrator.setQuery,
          textDirection: TextDirection.ltr,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            suffixIcon: orchestrator.query.isEmpty
                ? null
                : IconButton(
                    onPressed: orchestrator.clearSearch,
                    icon: const Icon(Icons.close),
                  ),
            labelText: 'Schnellsuche · بحث سريع',
            hintText: 'Schrauben, Bohrer, Farbe, Holzzuschnitt, Kaution ...',
            border: const OutlineInputBorder(),
          ),
        ),
      );
}

final class _SectionSelector extends StatelessWidget {
  const _SectionSelector({
    required this.orchestrator,
    required this.dark,
  });

  final HardwareStoreMasterOrchestrator orchestrator;
  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        glowColor: AppColors.secondary,
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Wrap(
          spacing: HardwareStoreUiTokens.compactGap,
          runSpacing: HardwareStoreUiTokens.compactGap,
          children: <Widget>[
            for (final section in HardwareStoreSection.values)
              FilterChip(
                key: ValueKey<String>('hardware-store-' + section.name),
                selected: orchestrator.section == section,
                onSelected: (_) => orchestrator.setSection(section),
                label: AppDirectionalText(
                  section.labelDe + ' · ' + section.labelAr,
                  languageCode: 'de',
                  style: AppTypography.label,
                ),
              ),
          ],
        ),
      );
}

final class _CatalogCard extends StatelessWidget {
  const _CatalogCard({
    required this.orchestrator,
    required this.dark,
  });

  final HardwareStoreMasterOrchestrator orchestrator;
  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.achievement.withAlpha(96),
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'Schnellübersicht',
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: HardwareStoreUiTokens.itemGap),
            for (final item in orchestrator.catalogItems) ...<Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(_iconFor(item.kind), color: AppColors.achievement),
                  const SizedBox(width: HardwareStoreUiTokens.compactGap),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        AppDirectionalText(
                          item.nameDe + ' · ' + item.kind.labelDe,
                          languageCode: 'de',
                          style: AppTypography.label,
                        ),
                        AppDirectionalText(
                          item.nameAr + ' — ' + item.noteAr,
                          languageCode: 'ar',
                          style: AppTypography.body,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: HardwareStoreUiTokens.itemGap),
            ],
          ],
        ),
      );

  IconData _iconFor(HardwareStoreItemKind kind) => switch (kind) {
        HardwareStoreItemKind.tool => Icons.build_outlined,
        HardwareStoreItemKind.material => Icons.inventory_2_outlined,
        HardwareStoreItemKind.cuttingService => Icons.content_cut,
        HardwareStoreItemKind.rentalService => Icons.handyman_outlined,
      };
}

final class _PhraseList extends StatelessWidget {
  const _PhraseList({
    required this.phrases,
    required this.dark,
  });

  final List<DiyPhrase> phrases;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    if (phrases.isEmpty) {
      return AppGlassCard(
        borderColor: AppColors.tertiary.withAlpha(96),
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: AppDirectionalText(
          'لا توجد نتيجة في هذا القسم. جرّب كلمة بحث أخرى.',
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
            const SizedBox(height: HardwareStoreUiTokens.itemGap),
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
        glowColor: AppColors.primary,
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              phrase.contextDe,
              languageCode: 'de',
              style: AppTypography.label,
            ),
            const SizedBox(height: HardwareStoreUiTokens.compactGap),
            AppDirectionalText(
              phrase.german,
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: HardwareStoreUiTokens.compactGap),
            AppDirectionalText(
              phrase.arabic,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
            const SizedBox(height: HardwareStoreUiTokens.compactGap),
            AppDirectionalText(
              phrase.contextAr,
              languageCode: 'ar',
              style: AppTypography.label,
            ),
          ],
        ),
      );
}
