import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../design_system/design_system.dart';
import 'secondhand_master_orchestrator.dart';
import 'secondhand_models.dart';

abstract final class SecondhandUiTokens {
  static const double pageInset = 16;
  static const double bottomInset = 32;
  static const double sectionGap = 18;
  static const double itemGap = 12;
  static const double compactGap = 8;
}

final class SecondhandMasterHub extends StatefulWidget {
  const SecondhandMasterHub({
    this.orchestrator,
    super.key,
  });

  final SecondhandMasterOrchestrator? orchestrator;

  @override
  State<SecondhandMasterHub> createState() => _SecondhandMasterHubState();
}

final class _SecondhandMasterHubState extends State<SecondhandMasterHub> {
  late final SecondhandMasterOrchestrator _orchestrator;
  late final bool _ownsOrchestrator;

  @override
  void initState() {
    super.initState();
    _ownsOrchestrator = widget.orchestrator == null;
    _orchestrator = widget.orchestrator ?? SecondhandMasterOrchestrator();
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
              SecondhandUiTokens.pageInset,
              SecondhandUiTokens.pageInset,
              SecondhandUiTokens.pageInset,
              SecondhandUiTokens.bottomInset,
            ),
            child: AnimatedBuilder(
              animation: _orchestrator,
              builder: (context, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _HeaderCard(dark: dark),
                  const SizedBox(height: SecondhandUiTokens.sectionGap),
                  _FriendlyBargainingTipsBar(
                    orchestrator: _orchestrator,
                    dark: dark,
                  ),
                  const SizedBox(height: SecondhandUiTokens.sectionGap),
                  _SearchField(orchestrator: _orchestrator),
                  const SizedBox(height: SecondhandUiTokens.itemGap),
                  _DomainSelector(
                    orchestrator: _orchestrator,
                    dark: dark,
                  ),
                  const SizedBox(height: SecondhandUiTokens.sectionGap),
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
              'Flohmarkt, Kleinanzeigen & Sozialkaufhaus',
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: SecondhandUiTokens.compactGap),
            AppDirectionalText(
              'مفردات عملية للاقتصاد المستعمل والتبادل المحلي والتبرع المسؤول، مع تفاوض مهذب وواضح.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

final class _FriendlyBargainingTipsBar extends StatelessWidget {
  const _FriendlyBargainingTipsBar({
    required this.orchestrator,
    required this.dark,
  });

  final SecondhandMasterOrchestrator orchestrator;
  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        key: const ValueKey<String>('secondhand-bargaining-bar'),
        glowColor: AppColors.secondary,
        borderColor: AppColors.secondary.withAlpha(112),
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'Höflich handeln · Verhandlungsbasis (VB)',
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: SecondhandUiTokens.compactGap),
            AppDirectionalText(
              'نصائح سريعة للتفاوض الودّي بدون ضغط أو إحراج.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
            const SizedBox(height: SecondhandUiTokens.itemGap),
            for (var index = 0;
                index < orchestrator.bargainingTips.length;
                index++) ...<Widget>[
              _BargainingTipRow(
                tip: orchestrator.bargainingTips[index],
                number: index + 1,
              ),
              if (index != orchestrator.bargainingTips.length - 1)
                const SizedBox(height: SecondhandUiTokens.itemGap),
            ],
          ],
        ),
      );
}

final class _BargainingTipRow extends StatelessWidget {
  const _BargainingTipRow({
    required this.tip,
    required this.number,
  });

  final SecondhandBargainingTip tip;
  final int number;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.primary.withAlpha(32),
            child: Text(
              '$number',
              style: AppTypography.label,
            ),
          ),
          const SizedBox(width: SecondhandUiTokens.compactGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AppDirectionalText(
                  tip.german,
                  languageCode: 'de',
                  style: AppTypography.body,
                ),
                const SizedBox(height: SecondhandUiTokens.compactGap),
                AppDirectionalText(
                  tip.arabic,
                  languageCode: 'ar',
                  style: AppTypography.label,
                ),
              ],
            ),
          ),
        ],
      );
}

final class _SearchField extends StatelessWidget {
  const _SearchField({required this.orchestrator});

  final SecondhandMasterOrchestrator orchestrator;

  @override
  Widget build(BuildContext context) => TextField(
        key: const ValueKey<String>('secondhand-search'),
        onChanged: orchestrator.setQuery,
        textDirection: TextDirection.ltr,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search),
          labelText: 'Suche · بحث',
          hintText: 'Standgebühr, VB, Selbstabholung, Schuhe ...',
          border: OutlineInputBorder(),
        ),
      );
}

final class _DomainSelector extends StatelessWidget {
  const _DomainSelector({
    required this.orchestrator,
    required this.dark,
  });

  final SecondhandMasterOrchestrator orchestrator;
  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.tertiary.withAlpha(96),
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Wrap(
          spacing: SecondhandUiTokens.compactGap,
          runSpacing: SecondhandUiTokens.compactGap,
          children: <Widget>[
            for (final domain in SecondhandDomain.values)
              FilterChip(
                key: ValueKey<String>(
                  'secondhand-domain-${domain.name}',
                ),
                selected: orchestrator.domain == domain,
                onSelected: (_) => orchestrator.setDomain(domain),
                avatar: Icon(
                  domain == SecondhandDomain.fleaMarketsAndAds
                      ? Icons.storefront_outlined
                      : Icons.volunteer_activism_outlined,
                ),
                label: Text(
                  '${domain.labelDe} · ${domain.labelAr}',
                  style: AppTypography.label,
                ),
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

  final SecondhandMasterOrchestrator orchestrator;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final entries = orchestrator.visibleEntries;
    if (entries.isEmpty) {
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
        for (var index = 0; index < entries.length; index++) ...<Widget>[
          _SecondhandEntryCard(entry: entries[index], dark: dark),
          if (index != entries.length - 1)
            const SizedBox(height: SecondhandUiTokens.itemGap),
        ],
      ],
    );
  }
}

final class _SecondhandEntryCard extends StatelessWidget {
  const _SecondhandEntryCard({
    required this.entry,
    required this.dark,
  });

  final SecondhandEntry entry;
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
            const SizedBox(height: SecondhandUiTokens.compactGap),
            AppDirectionalText(
              entry.titleAr,
              languageCode: 'ar',
              style: AppTypography.label,
            ),
            const SizedBox(height: SecondhandUiTokens.itemGap),
            AppDirectionalText(
              entry.german,
              languageCode: 'de',
              style: AppTypography.body,
            ),
            const SizedBox(height: SecondhandUiTokens.compactGap),
            AppDirectionalText(
              entry.arabic,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
            const SizedBox(height: SecondhandUiTokens.itemGap),
            AppDirectionalText(
              entry.contextDe,
              languageCode: 'de',
              style: AppTypography.label,
            ),
            const SizedBox(height: SecondhandUiTokens.compactGap),
            AppDirectionalText(
              entry.contextAr,
              languageCode: 'ar',
              style: AppTypography.label,
            ),
          ],
        ),
      );
}
