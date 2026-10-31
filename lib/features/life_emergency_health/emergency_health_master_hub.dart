import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../design_system/design_system.dart';
import 'emergency_health_master_orchestrator.dart';
import 'emergency_health_models.dart';

abstract final class EmergencyHealthUiTokens {
  static const double pageInset = 16;
  static const double topInset = 18;
  static const double bottomInset = 32;
  static const double sectionGap = 16;
  static const double itemGap = 12;
  static const double compactGap = 8;
}

final class EmergencyHealthMasterHub extends StatefulWidget {
  const EmergencyHealthMasterHub({
    this.orchestrator,
    super.key,
  });

  final EmergencyHealthMasterOrchestrator? orchestrator;

  @override
  State<EmergencyHealthMasterHub> createState() =>
      _EmergencyHealthMasterHubState();
}

final class _EmergencyHealthMasterHubState
    extends State<EmergencyHealthMasterHub> {
  late final EmergencyHealthMasterOrchestrator _orchestrator;
  late final bool _ownsOrchestrator;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ownsOrchestrator = widget.orchestrator == null;
    _orchestrator =
        widget.orchestrator ?? EmergencyHealthMasterOrchestrator();
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (_ownsOrchestrator) {
      _orchestrator.dispose();
    }
    super.dispose();
  }

  void _switchDomain(EmergencyHealthDomain domain) {
    _searchController.clear();
    _orchestrator.switchDomain(domain);
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final background =
        dark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = dark ? AppColors.darkSurface : AppColors.lightSurface;
    final border =
        dark ? AppColors.glassBorderDark : AppColors.glassBorderLight;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: background,
        body: SafeArea(
          child: AnimatedBuilder(
            animation: _orchestrator,
            builder: (context, _) => SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                EmergencyHealthUiTokens.pageInset,
                EmergencyHealthUiTokens.topInset,
                EmergencyHealthUiTokens.pageInset,
                EmergencyHealthUiTokens.bottomInset,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _Header(surface: surface, border: border),
                  const SizedBox(height: EmergencyHealthUiTokens.sectionGap),
                  _ServiceDecision(surface: surface, border: border),
                  const SizedBox(height: EmergencyHealthUiTokens.sectionGap),
                  _DomainSelector(
                    domain: _orchestrator.domain,
                    surface: surface,
                    border: border,
                    onSelected: _switchDomain,
                  ),
                  const SizedBox(height: EmergencyHealthUiTokens.sectionGap),
                  _ImmediateChecklist(
                    orchestrator: _orchestrator,
                    surface: surface,
                    border: border,
                  ),
                  const SizedBox(height: EmergencyHealthUiTokens.sectionGap),
                  _SearchCard(
                    controller: _searchController,
                    query: _orchestrator.query,
                    surface: surface,
                    border: border,
                    onChanged: _orchestrator.setQuery,
                    onClear: () {
                      _searchController.clear();
                      _orchestrator.clearSearch();
                    },
                  ),
                  const SizedBox(height: EmergencyHealthUiTokens.sectionGap),
                  _PhraseResults(
                    items: _orchestrator.visibleItems,
                    surface: surface,
                    border: border,
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

final class _Header extends StatelessWidget {
  const _Header({required this.surface, required this.border});

  final Color surface;
  final Color border;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        backgroundColor: surface,
        borderColor: border,
        glowColor: AppColors.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Icon(
              Icons.health_and_safety_rounded,
              color: AppColors.primary,
              size: 34,
            ),
            const SizedBox(height: EmergencyHealthUiTokens.itemGap),
            AppDirectionalText(
              'Notruf, Notdienst & medizinische Hilfe',
              languageCode: 'de',
              style: AppTypography.title.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: EmergencyHealthUiTokens.compactGap),
            AppDirectionalText(
              'طوارئ الصحة والخدمات الطبية',
              languageCode: 'ar',
              style: AppTypography.title,
            ),
            const SizedBox(height: EmergencyHealthUiTokens.compactGap),
            AppDirectionalText(
              'Schnelle Sprachhilfe für 112, 116 117 und Apotheken-Notdienst.',
              languageCode: 'de',
              style: AppTypography.body,
            ),
            AppDirectionalText(
              'مساعدة لغوية سريعة للطوارئ الطبية والطبيب والصيدلية المناوبة.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

final class _ServiceDecision extends StatelessWidget {
  const _ServiceDecision({required this.surface, required this.border});

  final Color surface;
  final Color border;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        backgroundColor: surface,
        borderColor: AppColors.tertiary,
        glowColor: AppColors.tertiary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'Lebensgefahr: 112',
              languageCode: 'de',
              style: AppTypography.title.copyWith(color: AppColors.tertiary),
            ),
            AppDirectionalText(
              'خطر يهدد الحياة: اتصل بـ112',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
            const SizedBox(height: EmergencyHealthUiTokens.itemGap),
            AppDirectionalText(
              'Dringend, aber nicht lebensbedrohlich außerhalb der Sprechzeiten: 116 117',
              languageCode: 'de',
              style: AppTypography.label,
            ),
            AppDirectionalText(
              'حاجة طبية عاجلة غير مهددة للحياة خارج أوقات العيادات: 116117',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

final class _DomainSelector extends StatelessWidget {
  const _DomainSelector({
    required this.domain,
    required this.surface,
    required this.border,
    required this.onSelected,
  });

  final EmergencyHealthDomain domain;
  final Color surface;
  final Color border;
  final ValueChanged<EmergencyHealthDomain> onSelected;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: EmergencyHealthUiTokens.itemGap,
        runSpacing: EmergencyHealthUiTokens.itemGap,
        children: <Widget>[
          for (final value in EmergencyHealthDomain.values)
            AppGlassCard(
              onTap: () => onSelected(value),
              backgroundColor: surface,
              borderColor: value == domain ? AppColors.secondary : border,
              glowColor: value == domain ? AppColors.secondary : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  AppDirectionalText(
                    value.labelDe,
                    languageCode: 'de',
                    style: AppTypography.label.copyWith(
                      color: value == domain ? AppColors.secondary : null,
                    ),
                  ),
                  const SizedBox(height: EmergencyHealthUiTokens.compactGap),
                  AppDirectionalText(
                    value.labelAr,
                    languageCode: 'ar',
                    style: AppTypography.label,
                  ),
                ],
              ),
            ),
        ],
      );
}

final class _ImmediateChecklist extends StatelessWidget {
  const _ImmediateChecklist({
    required this.orchestrator,
    required this.surface,
    required this.border,
  });

  final EmergencyHealthMasterOrchestrator orchestrator;
  final Color surface;
  final Color border;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        backgroundColor: surface,
        borderColor: border,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'Sofort-Check',
              languageCode: 'de',
              style: AppTypography.title,
            ),
            AppDirectionalText(
              'قائمة التصرف الفوري',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
            const SizedBox(height: EmergencyHealthUiTokens.itemGap),
            AppDirectionalText(
              '${orchestrator.completedActionCount}/${orchestrator.immediateActions.length} erledigt',
              languageCode: 'de',
              style: AppTypography.label,
            ),
            const SizedBox(height: EmergencyHealthUiTokens.itemGap),
            for (var index = 0;
                index < orchestrator.immediateActions.length;
                index++) ...<Widget>[
              _ChecklistRow(
                action: orchestrator.immediateActions[index],
                checked: orchestrator.isActionComplete(
                  orchestrator.immediateActions[index].id,
                ),
                onTap: () {
                  final action = orchestrator.immediateActions[index];
                  orchestrator.setActionComplete(
                    action.id,
                    !orchestrator.isActionComplete(action.id),
                  );
                },
              ),
              if (index != orchestrator.immediateActions.length - 1)
                const SizedBox(height: EmergencyHealthUiTokens.compactGap),
            ],
          ],
        ),
      );
}

final class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({
    required this.action,
    required this.checked,
    required this.onTap,
  });

  final EmergencyChecklistAction action;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                checked
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: checked ? AppColors.mastery : AppColors.tertiary,
              ),
              const SizedBox(width: EmergencyHealthUiTokens.itemGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    AppDirectionalText(
                      action.titleDe,
                      languageCode: 'de',
                      style: AppTypography.label,
                    ),
                    AppDirectionalText(
                      action.titleAr,
                      languageCode: 'ar',
                      style: AppTypography.body,
                    ),
                    AppDirectionalText(
                      action.detailAr,
                      languageCode: 'ar',
                      style: AppTypography.label,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

final class _SearchCard extends StatelessWidget {
  const _SearchCard({
    required this.controller,
    required this.query,
    required this.surface,
    required this.border,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final String query;
  final Color surface;
  final Color border;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        backgroundColor: surface,
        borderColor: border,
        child: Directionality(
          textDirection: _hasArabic(query)
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: AppTypography.body,
            decoration: InputDecoration(
              hintText: 'Atemnot / Schmerzen / الموقع',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: query.isEmpty
                  ? null
                  : IconButton(
                      onPressed: onClear,
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ),
        ),
      );

  static bool _hasArabic(String value) =>
      value.runes.any((rune) => rune >= 0x0600 && rune <= 0x06FF);
}

final class _PhraseResults extends StatelessWidget {
  const _PhraseResults({
    required this.items,
    required this.surface,
    required this.border,
  });

  final List<EmergencyPhrase> items;
  final Color surface;
  final Color border;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return AppGlassCard(
        backgroundColor: surface,
        borderColor: border,
        child: AppDirectionalText(
          'سيظهر هنا محتوى الوكيل المرتبط بهذه الفئة بعد حقنه في الـMaster Hub.',
          languageCode: 'ar',
          style: AppTypography.body,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (var index = 0; index < items.length; index++) ...<Widget>[
          AppGlassCard(
            backgroundColor: surface,
            borderColor: items[index].urgency == EmergencyUrgency.lifeThreatening
                ? AppColors.tertiary
                : AppColors.secondary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AppDirectionalText(
                  items[index].titleDe,
                  languageCode: 'de',
                  style: AppTypography.title,
                ),
                AppDirectionalText(
                  items[index].titleAr,
                  languageCode: 'ar',
                  style: AppTypography.label,
                ),
                const SizedBox(height: EmergencyHealthUiTokens.compactGap),
                AppDirectionalText(
                  items[index].german,
                  languageCode: 'de',
                  style: AppTypography.body,
                ),
                AppDirectionalText(
                  items[index].arabic,
                  languageCode: 'ar',
                  style: AppTypography.body,
                ),
                const SizedBox(height: EmergencyHealthUiTokens.compactGap),
                AppDirectionalText(
                  items[index].explanationAr,
                  languageCode: 'ar',
                  style: AppTypography.label,
                ),
              ],
            ),
          ),
          if (index != items.length - 1)
            const SizedBox(height: EmergencyHealthUiTokens.itemGap),
        ],
      ],
    );
  }
}
