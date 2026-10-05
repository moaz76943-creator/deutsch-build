import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../design_system/design_system.dart';
import 'telecom_master_orchestrator.dart';
import 'telecom_models.dart';

abstract final class TelecomUiTokens {
  static const double pageInset = 16;
  static const double bottomInset = 32;
  static const double sectionGap = 18;
  static const double itemGap = 12;
  static const double compactGap = 8;
  static const int softBorderAlpha = 88;
  static const int subtleBorderAlpha = 56;
}

final class TelecomMasterHub extends StatefulWidget {
  const TelecomMasterHub({
    this.orchestrator,
    super.key,
  });

  final TelecomMasterOrchestrator? orchestrator;

  @override
  State<TelecomMasterHub> createState() => _TelecomMasterHubState();
}

final class _TelecomMasterHubState extends State<TelecomMasterHub> {
  late final TelecomMasterOrchestrator _orchestrator;
  late final bool _ownsOrchestrator;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _ownsOrchestrator = widget.orchestrator == null;
    _orchestrator = widget.orchestrator ?? TelecomMasterOrchestrator();
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

  TextDirection get _searchDirection =>
      RegExp(r'[ء-ي]').hasMatch(_searchController.text)
          ? TextDirection.rtl
          : TextDirection.ltr;

  void _setDomain(TelecomDomain domain) {
    _orchestrator.setDomain(domain);
    _searchController.clear();
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
              TelecomUiTokens.pageInset,
              TelecomUiTokens.pageInset,
              TelecomUiTokens.pageInset,
              TelecomUiTokens.bottomInset,
            ),
            child: AnimatedBuilder(
              animation: _orchestrator,
              builder: (context, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _HeaderCard(dark: dark),
                  const SizedBox(height: TelecomUiTokens.sectionGap),
                  _SearchField(
                    controller: _searchController,
                    textDirection: _searchDirection,
                    onChanged: _orchestrator.setQuery,
                  ),
                  const SizedBox(height: TelecomUiTokens.itemGap),
                  _DomainSelector(
                    orchestrator: _orchestrator,
                    dark: dark,
                    onDomainSelected: _setDomain,
                  ),
                  const SizedBox(height: TelecomUiTokens.sectionGap),
                  _NetworkOutageActionBar(
                    orchestrator: _orchestrator,
                    dark: dark,
                  ),
                  const SizedBox(height: TelecomUiTokens.sectionGap),
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
        borderColor:
            AppColors.primary.withAlpha(TelecomUiTokens.softBorderAlpha),
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const _GermanText(
              'Internet & Mobilfunk · DSL, Glasfaser, SIM & Störung',
              title: true,
            ),
            const SizedBox(height: TelecomUiTokens.compactGap),
            const _ArabicText(
              'عبارات عملية لإعداد الإنترنت المنزلي، مواعيد الفني، شرائح الدفع المسبق، نقل الرقم، والتعامل مع أعطال الشبكة.',
            ),
          ],
        ),
      );
}

final class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.textDirection,
    required this.onChanged,
  });

  final TextEditingController controller;
  final TextDirection textDirection;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => TextField(
        key: const ValueKey<String>('telecom-search-field'),
        controller: controller,
        onChanged: onChanged,
        textDirection: textDirection,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search),
          labelText: 'Suche · بحث',
          hintText: 'Router, Technikerfenster, PostIdent, Rufnummer ...',
          border: OutlineInputBorder(),
        ),
      );
}

final class _DomainSelector extends StatelessWidget {
  const _DomainSelector({
    required this.orchestrator,
    required this.dark,
    required this.onDomainSelected,
  });

  final TelecomMasterOrchestrator orchestrator;
  final bool dark;
  final ValueChanged<TelecomDomain> onDomainSelected;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor:
            AppColors.secondary.withAlpha(TelecomUiTokens.softBorderAlpha),
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Wrap(
          spacing: TelecomUiTokens.compactGap,
          runSpacing: TelecomUiTokens.compactGap,
          children: <Widget>[
            for (final domain in TelecomDomain.values)
              FilterChip(
                key: ValueKey<String>('telecom-domain-${domain.name}'),
                selected: orchestrator.domain == domain,
                onSelected: (_) => onDomainSelected(domain),
                label: Text(
                  '${domain.labelDe} · ${domain.labelAr}',
                  style: AppTypography.label,
                ),
              ),
          ],
        ),
      );
}

final class _NetworkOutageActionBar extends StatelessWidget {
  const _NetworkOutageActionBar({
    required this.orchestrator,
    required this.dark,
  });

  final TelecomMasterOrchestrator orchestrator;
  final bool dark;

  @override
  Widget build(BuildContext context) => InkWell(
        key: const ValueKey<String>('telecom-outage-action-bar'),
        onTap: orchestrator.toggleOutageHelp,
        borderRadius: BorderRadius.circular(TelecomUiTokens.compactGap),
        child: AppGlassCard(
          glowColor: AppColors.tertiary,
          borderColor:
              AppColors.tertiary.withAlpha(TelecomUiTokens.softBorderAlpha),
          backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Icon(
                    Icons.wifi_off_outlined,
                    color: AppColors.tertiary,
                  ),
                  const SizedBox(width: TelecomUiTokens.compactGap),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const _GermanText('Störungshilfe', title: true),
                        const _ArabicText('مساعدة سريعة عند انقطاع الشبكة'),
                      ],
                    ),
                  ),
                  Icon(
                    orchestrator.outageHelpExpanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                  ),
                ],
              ),
              if (!orchestrator.outageHelpExpanded) ...<Widget>[
                const SizedBox(height: TelecomUiTokens.compactGap),
                const _ArabicText(
                  'اضغط لعرض خطوات فحص بسيطة وعبارة جاهزة لبلاغ العطل.',
                ),
              ] else ...<Widget>[
                const SizedBox(height: TelecomUiTokens.itemGap),
                for (final step in orchestrator.outageSteps) ...<Widget>[
                  _GermanText(step.german),
                  const SizedBox(height: TelecomUiTokens.compactGap),
                  _ArabicText(step.arabic),
                  const SizedBox(height: TelecomUiTokens.itemGap),
                ],
                const Divider(),
                const SizedBox(height: TelecomUiTokens.compactGap),
                _GermanText(
                  orchestrator.outagePrompt.german,
                  emphasized: true,
                ),
                const SizedBox(height: TelecomUiTokens.compactGap),
                _ArabicText(orchestrator.outagePrompt.arabic),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    key: const ValueKey<String>('telecom-outage-close'),
                    onPressed: orchestrator.dismissOutageHelp,
                    icon: const Icon(Icons.close),
                    label: const Text('Schließen · إغلاق'),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
}

final class _PhraseList extends StatelessWidget {
  const _PhraseList({
    required this.orchestrator,
    required this.dark,
  });

  final TelecomMasterOrchestrator orchestrator;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final phrases = orchestrator.visiblePhrases;

    if (phrases.isEmpty) {
      return AppGlassCard(
        key: const ValueKey<String>('telecom-empty-results'),
        borderColor:
            AppColors.primary.withAlpha(TelecomUiTokens.subtleBorderAlpha),
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: const _ArabicText(
          'لا توجد نتائج في هذا القسم. جرّب كلمة أخرى أو غيّر نوع الخدمة.',
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (var index = 0; index < phrases.length; index++) ...<Widget>[
          _PhraseCard(
            phrase: phrases[index],
            dark: dark,
          ),
          if (index != phrases.length - 1)
            const SizedBox(height: TelecomUiTokens.itemGap),
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

  final TelecomPhrase phrase;
  final bool dark;

  Color get _accent => switch (phrase.domain) {
        TelecomDomain.homeInternet => AppColors.primary,
        TelecomDomain.mobilePrepaid => AppColors.secondary,
      };

  @override
  Widget build(BuildContext context) => AppGlassCard(
        key: ValueKey<String>('telecom-phrase-${phrase.id}'),
        glowColor: _accent,
        borderColor:
            _accent.withAlpha(TelecomUiTokens.subtleBorderAlpha),
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _GermanText(
              phrase.topicDe,
              emphasized: true,
            ),
            const SizedBox(height: TelecomUiTokens.compactGap),
            _ArabicText(
              phrase.topicAr,
              emphasized: true,
            ),
            const SizedBox(height: TelecomUiTokens.itemGap),
            _GermanText(
              phrase.german,
              title: true,
            ),
            const SizedBox(height: TelecomUiTokens.compactGap),
            _ArabicText(phrase.arabic),
          ],
        ),
      );
}

final class _GermanText extends StatelessWidget {
  const _GermanText(
    this.text, {
    this.title = false,
    this.emphasized = false,
  });

  final String text;
  final bool title;
  final bool emphasized;

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.ltr,
        child: AppDirectionalText(
          text,
          languageCode: 'de',
          style: title
              ? AppTypography.title
              : emphasized
                  ? AppTypography.label
                  : AppTypography.body,
        ),
      );
}

final class _ArabicText extends StatelessWidget {
  const _ArabicText(
    this.text, {
    this.emphasized = false,
  });

  final String text;
  final bool emphasized;

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AppDirectionalText(
          text,
          languageCode: 'ar',
          style: emphasized ? AppTypography.label : AppTypography.body,
        ),
      );
}
