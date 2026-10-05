import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../../design_system/design_system.dart';
import '../application/haircut_master_orchestrator.dart';
import '../domain/haircut_models.dart';
import '../styles/haircut_phrase.dart';

abstract final class HaircutUiTokens {
  static const double page = 16;
  static const double gapXs = 6;
  static const double gapSm = 10;
  static const double gapMd = 14;
  static const double gapLg = 18;
  static const double chipHorizontal = 12;
  static const double chipVertical = 8;
  static const double icon = 24;
}

final class HaircutMasterScreen extends StatefulWidget {
  const HaircutMasterScreen({
    this.module = const HaircutBarbershopModule(),
    super.key,
  });

  final HaircutBarbershopModule module;

  @override
  State<HaircutMasterScreen> createState() => _HaircutMasterScreenState();
}

final class _HaircutMasterScreenState extends State<HaircutMasterScreen> {
  late final HaircutMasterOrchestrator _orchestrator;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _orchestrator = widget.module.createOrchestrator();
    _searchController = TextEditingController();
    _orchestrator.addListener(_refresh);
  }

  @override
  void dispose() {
    _orchestrator.removeListener(_refresh);
    _orchestrator.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (!mounted) return;
    if (_searchController.text != _orchestrator.query) {
      _searchController.text = _orchestrator.query;
      _searchController.selection = TextSelection.collapsed(
        offset: _searchController.text.length,
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface = dark ? AppColors.darkSurface : AppColors.lightSurface;
    final border =
        dark ? AppColors.glassBorderDark : AppColors.glassBorderLight;
    final results = _orchestrator.results;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            dark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: AppBar(
          title: const Text('الحلاقة والعناية · Friseursalon'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              HaircutUiTokens.page,
              HaircutUiTokens.page,
              HaircutUiTokens.page,
              32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _HeaderCard(surface: surface, border: border),
                const SizedBox(height: HaircutUiTokens.gapMd),
                _SearchCard(
                  controller: _searchController,
                  query: _orchestrator.query,
                  surface: surface,
                  border: border,
                  onChanged: _orchestrator.setQuery,
                  onClear: () {
                    _searchController.clear();
                    _orchestrator.setQuery('');
                  },
                ),
                const SizedBox(height: HaircutUiTokens.gapMd),
                _LevelFilters(
                  active: _orchestrator.level,
                  surface: surface,
                  border: border,
                  onSelected: _orchestrator.setLevel,
                ),
                const SizedBox(height: HaircutUiTokens.gapMd),
                _ServiceOverview(
                  services: _orchestrator.services,
                  selected: _orchestrator.selectedService,
                  surface: surface,
                  border: border,
                  onSelected: _orchestrator.selectService,
                ),
                const SizedBox(height: HaircutUiTokens.gapMd),
                _OpeningHoursCard(
                  hours: _orchestrator.openingHours,
                  surface: surface,
                  border: border,
                ),
                const SizedBox(height: HaircutUiTokens.gapMd),
                _QuickPhrasesCard(
                  phrases: _orchestrator.quickPhrases,
                  surface: surface,
                  border: border,
                ),
                const SizedBox(height: HaircutUiTokens.gapMd),
                _ResultSummary(
                  count: results.length,
                  canReset: _orchestrator.query.isNotEmpty ||
                      _orchestrator.level != null ||
                      _orchestrator.topic != null ||
                      _orchestrator.selectedService != null,
                  surface: surface,
                  border: border,
                  onReset: () {
                    _searchController.clear();
                    _orchestrator.resetFilters();
                  },
                ),
                const SizedBox(height: HaircutUiTokens.gapSm),
                if (results.isEmpty)
                  _EmptyCard(surface: surface, border: border)
                else
                  for (var index = 0; index < results.length; index += 1) ...[
                    _PhraseCard(
                      phrase: results[index],
                      surface: surface,
                      border: border,
                    ),
                    if (index != results.length - 1)
                      const SizedBox(height: HaircutUiTokens.gapSm),
                  ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.surface,
    required this.border,
  });

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
            AppDirectionalText(
              'Friseursalon & Barbershop',
              languageCode: 'de',
              style: AppTypography.title.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: HaircutUiTokens.gapXs),
            AppDirectionalText(
              'محادثات عملية للمواعيد، القصة الكلاسيكية المرتبة، اللحية والشارب، غسل الشعر والعناية الأساسية والدفع.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
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
  Widget build(BuildContext context) {
    final direction = RegExp(r'[\u0600-\u06FF]').hasMatch(query)
        ? TextDirection.rtl
        : TextDirection.ltr;

    return AppGlassCard(
      backgroundColor: surface,
      borderColor: border,
      child: Directionality(
        textDirection: direction,
        child: TextField(
          key: const ValueKey<String>('haircut-search'),
          controller: controller,
          textDirection: direction,
          onChanged: onChanged,
          style: AppTypography.body,
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.primary,
            ),
            hintText: 'Termin · Schere · Bart · Waschen · Rechnung',
            suffixIcon: query.isEmpty
                ? null
                : IconButton(
                    onPressed: onClear,
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.secondary,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

final class _LevelFilters extends StatelessWidget {
  const _LevelFilters({
    required this.active,
    required this.surface,
    required this.border,
    required this.onSelected,
  });

  final HaircutLevel? active;
  final Color surface;
  final Color border;
  final ValueChanged<HaircutLevel?> onSelected;

  @override
  Widget build(BuildContext context) {
    final values = <HaircutLevel?>[null, ...HaircutLevel.values];

    return AppGlassCard(
      backgroundColor: surface,
      borderColor: border,
      child: Wrap(
        spacing: HaircutUiTokens.gapSm,
        runSpacing: HaircutUiTokens.gapSm,
        children: <Widget>[
          for (final level in values)
            AppGlassCard(
              onTap: () => onSelected(level),
              padding: const EdgeInsets.symmetric(
                horizontal: HaircutUiTokens.chipHorizontal,
                vertical: HaircutUiTokens.chipVertical,
              ),
              borderColor: active == level ? AppColors.primary : border,
              glowColor: active == level ? AppColors.primary : null,
              backgroundColor: surface,
              child: AppDirectionalText(
                level?.label ?? 'Alle',
                languageCode: 'de',
                style: AppTypography.label.copyWith(
                  color: active == level ? AppColors.primary : null,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

final class _ServiceOverview extends StatelessWidget {
  const _ServiceOverview({
    required this.services,
    required this.selected,
    required this.surface,
    required this.border,
    required this.onSelected,
  });

  final List<HaircutServiceOption> services;
  final HaircutServiceKind? selected;
  final Color surface;
  final Color border;
  final ValueChanged<HaircutServiceKind?> onSelected;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        backgroundColor: surface,
        borderColor: border,
        glowColor: AppColors.secondary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'Leistungen · الخدمات الأساسية',
              languageCode: 'de',
              style: AppTypography.title.copyWith(color: AppColors.secondary),
            ),
            const SizedBox(height: HaircutUiTokens.gapSm),
            for (final service in services) ...<Widget>[
              AppGlassCard(
                onTap: () => onSelected(
                  selected == service.kind ? null : service.kind,
                ),
                borderColor:
                    selected == service.kind ? AppColors.secondary : border,
                backgroundColor: surface,
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.content_cut_rounded,
                      color: AppColors.secondary,
                      size: HaircutUiTokens.icon,
                    ),
                    const SizedBox(width: HaircutUiTokens.gapSm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          AppDirectionalText(
                            service.germanName,
                            languageCode: 'de',
                            style: AppTypography.label,
                          ),
                          AppDirectionalText(
                            '${service.arabicName} · ${service.estimatedMinutes} دقيقة تقريباً',
                            languageCode: 'ar',
                            style: AppTypography.body,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (service != services.last)
                const SizedBox(height: HaircutUiTokens.gapXs),
            ],
          ],
        ),
      );
}

final class _OpeningHoursCard extends StatelessWidget {
  const _OpeningHoursCard({
    required this.hours,
    required this.surface,
    required this.border,
  });

  final List<SalonOpeningHours> hours;
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
              'Öffnungszeiten · مثال تدريبي لأوقات العمل',
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: HaircutUiTokens.gapSm),
            for (final item in hours)
              Padding(
                padding: const EdgeInsets.only(bottom: HaircutUiTokens.gapXs),
                child: AppDirectionalText(
                  item.labelDe,
                  languageCode: 'de',
                  style: AppTypography.label,
                ),
              ),
          ],
        ),
      );
}

final class _QuickPhrasesCard extends StatelessWidget {
  const _QuickPhrasesCard({
    required this.phrases,
    required this.surface,
    required this.border,
  });

  final List<HaircutPhrase> phrases;
  final Color surface;
  final Color border;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        backgroundColor: surface,
        borderColor: border,
        glowColor: AppColors.tertiary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'Schnelle Sätze · عبارات سريعة',
              languageCode: 'de',
              style: AppTypography.title.copyWith(color: AppColors.tertiary),
            ),
            const SizedBox(height: HaircutUiTokens.gapSm),
            for (var index = 0; index < phrases.length; index += 1) ...[
              AppDirectionalText(
                phrases[index].german,
                languageCode: 'de',
                style: AppTypography.label,
              ),
              AppDirectionalText(
                phrases[index].arabic,
                languageCode: 'ar',
                style: AppTypography.body,
              ),
              if (index != phrases.length - 1)
                const SizedBox(height: HaircutUiTokens.gapSm),
            ],
          ],
        ),
      );
}

final class _ResultSummary extends StatelessWidget {
  const _ResultSummary({
    required this.count,
    required this.canReset,
    required this.surface,
    required this.border,
    required this.onReset,
  });

  final int count;
  final bool canReset;
  final Color surface;
  final Color border;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        backgroundColor: surface,
        borderColor: border,
        child: Row(
          children: <Widget>[
            Expanded(
              child: AppDirectionalText(
                '$count عبارات مناسبة',
                languageCode: 'ar',
                style: AppTypography.label,
              ),
            ),
            if (canReset)
              AppGlassCard(
                onTap: onReset,
                padding: const EdgeInsets.symmetric(
                  horizontal: HaircutUiTokens.chipHorizontal,
                  vertical: HaircutUiTokens.chipVertical,
                ),
                borderColor: AppColors.primary,
                child: AppDirectionalText(
                  'إلغاء الفلاتر',
                  languageCode: 'ar',
                  style: AppTypography.label.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
      );
}

final class _PhraseCard extends StatelessWidget {
  const _PhraseCard({
    required this.phrase,
    required this.surface,
    required this.border,
  });

  final HaircutPhrase phrase;
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
              phrase.german,
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: HaircutUiTokens.gapXs),
            AppDirectionalText(
              phrase.arabic,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
            const SizedBox(height: HaircutUiTokens.gapXs),
            AppDirectionalText(
              '${phrase.level.label} · ${phrase.noteArabic}',
              languageCode: 'ar',
              style: AppTypography.label,
            ),
          ],
        ),
      );
}

final class _EmptyCard extends StatelessWidget {
  const _EmptyCard({
    required this.surface,
    required this.border,
  });

  final Color surface;
  final Color border;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        backgroundColor: surface,
        borderColor: border,
        child: AppDirectionalText(
          'لا توجد عبارة مطابقة. جرّب كلمة أبسط أو ألغِ الفلتر.',
          languageCode: 'ar',
          textAlign: TextAlign.center,
          style: AppTypography.body,
        ),
      );
}
