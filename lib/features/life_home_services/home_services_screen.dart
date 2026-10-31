import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../design_system/design_system.dart';
import 'home_services_master_orchestrator.dart';
import 'home_services_models.dart';

abstract final class HomeServicesUiTokens {
  static const double pageInset = 16;
  static const double bottomInset = 32;
  static const double sectionGap = 18;
  static const double itemGap = 12;
  static const double compactGap = 8;
  static const double warningBorderAlpha = 120;
  static const double surfaceBorderAlpha = 80;
}

final class HomeServicesMasterHub extends StatefulWidget {
  const HomeServicesMasterHub({
    this.orchestrator,
    super.key,
  });

  final HomeServicesMasterOrchestrator? orchestrator;

  @override
  State<HomeServicesMasterHub> createState() =>
      _HomeServicesMasterHubState();
}

final class _HomeServicesMasterHubState
    extends State<HomeServicesMasterHub> {
  late final HomeServicesMasterOrchestrator _orchestrator;
  late final bool _ownsOrchestrator;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _ownsOrchestrator = widget.orchestrator == null;
    _orchestrator =
        widget.orchestrator ?? HomeServicesMasterOrchestrator();
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
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor:
            dark ? AppColors.darkBackground : AppColors.lightBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              HomeServicesUiTokens.pageInset,
              HomeServicesUiTokens.pageInset,
              HomeServicesUiTokens.pageInset,
              HomeServicesUiTokens.bottomInset,
            ),
            child: AnimatedBuilder(
              animation: _orchestrator,
              builder: (context, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _HeaderCard(dark: dark),
                  const SizedBox(
                    height: HomeServicesUiTokens.sectionGap,
                  ),
                  _ConsumerProtectionBar(
                    warnings: _orchestrator.consumerWarnings,
                    dark: dark,
                  ),
                  const SizedBox(
                    height: HomeServicesUiTokens.sectionGap,
                  ),
                  _DomainSelector(
                    orchestrator: _orchestrator,
                    dark: dark,
                    onDomainSelected: _selectDomain,
                  ),
                  const SizedBox(
                    height: HomeServicesUiTokens.itemGap,
                  ),
                  _SearchField(
                    controller: _searchController,
                    orchestrator: _orchestrator,
                  ),
                  const SizedBox(
                    height: HomeServicesUiTokens.sectionGap,
                  ),
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

  void _selectDomain(HomeServicesDomain domain) {
    if (_orchestrator.domain == domain) return;
    _orchestrator.setDomain(domain);
    _searchController.clear();
  }
}

final class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        glowColor: AppColors.primary,
        borderColor: AppColors.primary.withAlpha(
          HomeServicesUiTokens.surfaceBorderAlpha.toInt(),
        ),
        backgroundColor:
            dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(
                  Icons.home_repair_service,
                  color: AppColors.primary,
                ),
                const SizedBox(
                  width: HomeServicesUiTokens.compactGap,
                ),
                Expanded(
                  child: AppDirectionalText(
                    'Schlüsseldienst & Notfallhandwerker',
                    languageCode: 'de',
                    style: AppTypography.title,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: HomeServicesUiTokens.compactGap,
            ),
            AppDirectionalText(
              'مركز لغوي للطوارئ المنزلية يساعدك على وصف المشكلة، '
              'طلب السعر بوضوح والتحقق من مقدم الخدمة قبل بدء العمل.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

final class _ConsumerProtectionBar extends StatelessWidget {
  const _ConsumerProtectionBar({
    required this.warnings,
    required this.dark,
  });

  final List<ConsumerProtectionWarning> warnings;
  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        glowColor: AppColors.tertiary,
        borderColor: AppColors.tertiary.withAlpha(
          HomeServicesUiTokens.warningBorderAlpha.toInt(),
        ),
        backgroundColor:
            dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(
                  Icons.shield_outlined,
                  color: AppColors.tertiary,
                ),
                const SizedBox(
                  width: HomeServicesUiTokens.compactGap,
                ),
                Expanded(
                  child: Text(
                    'Abzocke vermeiden · Festpreis vereinbaren',
                    style: AppTypography.title,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: HomeServicesUiTokens.compactGap,
            ),
            AppDirectionalText(
              'قبل الموافقة على الخدمة، اجعل السعر والهوية والأعمال الإضافية والفاتورة واضحة.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
            const SizedBox(
              height: HomeServicesUiTokens.itemGap,
            ),
            for (var index = 0; index < warnings.length; index++) ...<Widget>[
              _WarningRow(warning: warnings[index]),
              if (index != warnings.length - 1)
                const SizedBox(
                  height: HomeServicesUiTokens.itemGap,
                ),
            ],
          ],
        ),
      );
}

final class _WarningRow extends StatelessWidget {
  const _WarningRow({required this.warning});

  final ConsumerProtectionWarning warning;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              Icons.check_circle_outline,
              size: 18,
              color: AppColors.tertiary,
            ),
          ),
          const SizedBox(
            width: HomeServicesUiTokens.compactGap,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AppDirectionalText(
                  warning.german,
                  languageCode: 'de',
                  style: AppTypography.label,
                ),
                const SizedBox(
                  height: HomeServicesUiTokens.compactGap,
                ),
                AppDirectionalText(
                  warning.arabic,
                  languageCode: 'ar',
                  style: AppTypography.body,
                ),
              ],
            ),
          ),
        ],
      );
}

final class _DomainSelector extends StatelessWidget {
  const _DomainSelector({
    required this.orchestrator,
    required this.dark,
    required this.onDomainSelected,
  });

  final HomeServicesMasterOrchestrator orchestrator;
  final bool dark;
  final ValueChanged<HomeServicesDomain> onDomainSelected;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.secondary.withAlpha(
          HomeServicesUiTokens.surfaceBorderAlpha.toInt(),
        ),
        backgroundColor:
            dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'Bereich wählen',
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(
              height: HomeServicesUiTokens.compactGap,
            ),
            AppDirectionalText(
              'اختر نوع الطوارئ حتى يبقى البحث داخل القسم الصحيح.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
            const SizedBox(
              height: HomeServicesUiTokens.itemGap,
            ),
            Wrap(
              spacing: HomeServicesUiTokens.compactGap,
              runSpacing: HomeServicesUiTokens.compactGap,
              children: <Widget>[
                for (final domain in HomeServicesDomain.values)
                  FilterChip(
                    key: ValueKey<String>(
                      'home-services-domain-${domain.name}',
                    ),
                    selected: orchestrator.domain == domain,
                    onSelected: (_) => onDomainSelected(domain),
                    label: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        AppDirectionalText(
                          domain.labelDe,
                          languageCode: 'de',
                          style: AppTypography.label,
                        ),
                        AppDirectionalText(
                          domain.labelAr,
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

final class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.orchestrator,
  });

  final TextEditingController controller;
  final HomeServicesMasterOrchestrator orchestrator;

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.ltr,
        child: TextField(
          key: const ValueKey<String>('home-services-search'),
          controller: controller,
          onChanged: orchestrator.setQuery,
          textDirection: TextDirection.ltr,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            labelText: 'Suche · بحث',
            hintText: 'Festpreis, zugefallen, Heizung, Abfluss ...',
            border: OutlineInputBorder(),
          ),
        ),
      );
}

final class _PhraseList extends StatelessWidget {
  const _PhraseList({
    required this.orchestrator,
    required this.dark,
  });

  final HomeServicesMasterOrchestrator orchestrator;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final phrases = orchestrator.visiblePhrases;

    if (phrases.isEmpty) {
      return AppGlassCard(
        borderColor: AppColors.tertiary.withAlpha(
          HomeServicesUiTokens.surfaceBorderAlpha.toInt(),
        ),
        backgroundColor:
            dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: AppDirectionalText(
          'لا توجد نتائج في هذا القسم. جرّب وصفاً أقصر للمشكلة.',
          languageCode: 'ar',
          style: AppTypography.body,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: AppDirectionalText(
                orchestrator.domain.labelDe,
                languageCode: 'de',
                style: AppTypography.title,
              ),
            ),
            const SizedBox(
              width: HomeServicesUiTokens.compactGap,
            ),
            const Icon(
              Icons.emergency_outlined,
              color: AppColors.primary,
            ),
          ],
        ),
        const SizedBox(
          height: HomeServicesUiTokens.itemGap,
        ),
        for (var index = 0; index < phrases.length; index++) ...<Widget>[
          _PhraseCard(
            phrase: phrases[index],
            dark: dark,
          ),
          if (index != phrases.length - 1)
            const SizedBox(
              height: HomeServicesUiTokens.itemGap,
            ),
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

  final HomeServicePhrase phrase;
  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.primary.withAlpha(
          HomeServicesUiTokens.surfaceBorderAlpha.toInt(),
        ),
        backgroundColor:
            dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              phrase.contextDe,
              languageCode: 'de',
              style: AppTypography.label.copyWith(
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(
              height: HomeServicesUiTokens.compactGap,
            ),
            AppDirectionalText(
              phrase.german,
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(
              height: HomeServicesUiTokens.compactGap,
            ),
            AppDirectionalText(
              phrase.arabic,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
            const SizedBox(
              height: HomeServicesUiTokens.compactGap,
            ),
            AppDirectionalText(
              phrase.contextAr,
              languageCode: 'ar',
              style: AppTypography.label,
            ),
          ],
        ),
      );
}
