import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../../design_system/design_system.dart';
import '../application/shopping_master_orchestrator.dart';
import '../domain/shopping_models.dart';

abstract final class ShoppingUiTokens {
  static const double pageHorizontal = 16;
  static const double pageTop = 18;
  static const double pageBottom = 28;
  static const double gapXs = 6;
  static const double gapSm = 10;
  static const double gapMd = 14;
  static const double gapLg = 18;
  static const double chipHorizontal = 12;
  static const double chipVertical = 9;
  static const double iconSm = 20;
  static const double iconMd = 28;
  static const double iconLg = 36;
  static const double panicIcon = 24;
}

final class ShoppingMasterScreen extends StatefulWidget {
  const ShoppingMasterScreen({
    required this.orchestrator,
    super.key,
  });

  final ShoppingMasterOrchestrator orchestrator;

  @override
  State<ShoppingMasterScreen> createState() => _ShoppingMasterScreenState();
}

final class _ShoppingMasterScreenState extends State<ShoppingMasterScreen> {
  late final TextEditingController _searchController;

  ShoppingMasterOrchestrator get orchestrator => widget.orchestrator;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: orchestrator.query);
    orchestrator.addListener(_refresh);
  }

  @override
  void didUpdateWidget(covariant ShoppingMasterScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orchestrator == orchestrator) return;
    oldWidget.orchestrator.removeListener(_refresh);
    orchestrator.addListener(_refresh);
    _searchController.text = orchestrator.query;
  }

  @override
  void dispose() {
    orchestrator.removeListener(_refresh);
    _searchController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (!mounted) return;
    if (_searchController.text != orchestrator.query) {
      _searchController.text = orchestrator.query;
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
    final results = orchestrator.results;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            dark ? AppColors.darkBackground : AppColors.lightBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              ShoppingUiTokens.pageHorizontal,
              ShoppingUiTokens.pageTop,
              ShoppingUiTokens.pageHorizontal,
              ShoppingUiTokens.pageBottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _HeaderCard(surface: surface, border: border),
                const SizedBox(height: ShoppingUiTokens.gapMd),
                _SearchCard(
                  controller: _searchController,
                  query: orchestrator.query,
                  surface: surface,
                  border: border,
                  onChanged: orchestrator.setQuery,
                  onClear: () {
                    _searchController.clear();
                    orchestrator.clearSearch();
                  },
                ),
                const SizedBox(height: ShoppingUiTokens.gapMd),
                _LevelFilters(
                  activeLevel: orchestrator.activeLevel,
                  surface: surface,
                  border: border,
                  onSelected: orchestrator.setLevel,
                ),
                const SizedBox(height: ShoppingUiTokens.gapMd),
                _PanicBar(
                  isOpen: orchestrator.isPanicBarOpen,
                  phrases: orchestrator.panicPhrases,
                  surface: surface,
                  border: border,
                  onToggle: orchestrator.togglePanicBar,
                ),
                const SizedBox(height: ShoppingUiTokens.gapMd),
                _ResultSummary(
                  total: results.length,
                  groceryCount: orchestrator.groceryResultCount,
                  returnCount: orchestrator.returnWarrantyResultCount,
                  surface: surface,
                  border: border,
                  canReset: orchestrator.query.isNotEmpty ||
                      orchestrator.activeLevel != null,
                  onReset: () {
                    _searchController.clear();
                    orchestrator.resetFilters();
                  },
                ),
                const SizedBox(height: ShoppingUiTokens.gapMd),
                if (results.isEmpty)
                  _EmptyResults(surface: surface, border: border)
                else
                  for (var index = 0; index < results.length; index += 1) ...[
                    _PhraseCard(
                      phrase: results[index],
                      surface: surface,
                      border: border,
                    ),
                    if (index != results.length - 1)
                      const SizedBox(height: ShoppingUiTokens.gapSm),
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
        child: Row(
          children: <Widget>[
            const Icon(
              Icons.shopping_cart_rounded,
              color: AppColors.primary,
              size: ShoppingUiTokens.iconLg,
            ),
            const SizedBox(width: ShoppingUiTokens.gapSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  AppDirectionalText(
                    'مركز التسوق وحياة المستهلك',
                    languageCode: 'ar',
                    style: AppTypography.title,
                  ),
                  const SizedBox(height: ShoppingUiTokens.gapXs),
                  AppDirectionalText(
                    'Supermarkt & Reklamation',
                    languageCode: 'de',
                    style: AppTypography.label.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
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
    final direction = _directionForQuery(query);

    return AppGlassCard(
      backgroundColor: surface,
      borderColor: border,
      glowColor: AppColors.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppDirectionalText(
            'ابحث بالألمانية أو العربية',
            languageCode: 'ar',
            style: AppTypography.title,
          ),
          const SizedBox(height: ShoppingUiTokens.gapSm),
          Directionality(
            textDirection: direction,
            child: TextField(
              controller: controller,
              textDirection: direction,
              style: AppTypography.body,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Zutaten · Kasse · Rechnung · مكونات · ضمان',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.primary,
                  size: ShoppingUiTokens.iconSm,
                ),
                suffixIcon: query.isEmpty
                    ? null
                    : IconButton(
                        onPressed: onClear,
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppColors.secondary,
                          size: ShoppingUiTokens.iconSm,
                        ),
                      ),
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

final class _LevelFilters extends StatelessWidget {
  const _LevelFilters({
    required this.activeLevel,
    required this.surface,
    required this.border,
    required this.onSelected,
  });

  final ShoppingLevel? activeLevel;
  final Color surface;
  final Color border;
  final ValueChanged<ShoppingLevel?> onSelected;

  @override
  Widget build(BuildContext context) {
    final levels = <ShoppingLevel?>[null, ...ShoppingLevel.values];

    return AppGlassCard(
      backgroundColor: surface,
      borderColor: border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppDirectionalText(
            'فلترة المستوى',
            languageCode: 'ar',
            style: AppTypography.title,
          ),
          const SizedBox(height: ShoppingUiTokens.gapSm),
          Wrap(
            spacing: ShoppingUiTokens.gapSm,
            runSpacing: ShoppingUiTokens.gapSm,
            children: <Widget>[
              for (final level in levels)
                AppGlassCard(
                  onTap: () => onSelected(level),
                  backgroundColor: surface,
                  padding: const EdgeInsets.symmetric(
                    horizontal: ShoppingUiTokens.chipHorizontal,
                    vertical: ShoppingUiTokens.chipVertical,
                  ),
                  borderColor:
                      activeLevel == level ? AppColors.primary : border,
                  glowColor:
                      activeLevel == level ? AppColors.primary : null,
                  child: AppDirectionalText(
                    level?.germanLabel ?? 'Alle',
                    languageCode: 'de',
                    style: AppTypography.label.copyWith(
                      color:
                          activeLevel == level ? AppColors.primary : null,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

final class _PanicBar extends StatelessWidget {
  const _PanicBar({
    required this.isOpen,
    required this.phrases,
    required this.surface,
    required this.border,
    required this.onToggle,
  });

  final bool isOpen;
  final List<ShoppingPhrase> phrases;
  final Color surface;
  final Color border;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        onTap: onToggle,
        backgroundColor: surface,
        borderColor: isOpen ? AppColors.tertiary : border,
        glowColor: isOpen ? AppColors.tertiary : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(
                  Icons.bolt_rounded,
                  color: AppColors.tertiary,
                  size: ShoppingUiTokens.panicIcon,
                ),
                const SizedBox(width: ShoppingUiTokens.gapSm),
                Expanded(
                  child: AppDirectionalText(
                    'Panic Bar · عبارات سريعة عند الحاجة',
                    languageCode: 'ar',
                    style: AppTypography.title.copyWith(
                      color: AppColors.tertiary,
                    ),
                  ),
                ),
                Icon(
                  isOpen
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  color: AppColors.tertiary,
                  size: ShoppingUiTokens.iconMd,
                ),
              ],
            ),
            if (isOpen) ...<Widget>[
              const SizedBox(height: ShoppingUiTokens.gapMd),
              for (var index = 0; index < phrases.length; index += 1) ...[
                _PanicPhrase(phrase: phrases[index]),
                if (index != phrases.length - 1)
                  const SizedBox(height: ShoppingUiTokens.gapSm),
              ],
            ],
          ],
        ),
      );
}

final class _PanicPhrase extends StatelessWidget {
  const _PanicPhrase({required this.phrase});

  final ShoppingPhrase phrase;

  @override
  Widget build(BuildContext context) {
    final accent = _agentAccent(phrase.agent);

    return AppGlassCard(
      borderColor: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppDirectionalText(
            phrase.german,
            languageCode: 'de',
            style: AppTypography.title.copyWith(color: accent),
          ),
          const SizedBox(height: ShoppingUiTokens.gapXs),
          AppDirectionalText(
            phrase.arabic,
            languageCode: 'ar',
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }
}

final class _ResultSummary extends StatelessWidget {
  const _ResultSummary({
    required this.total,
    required this.groceryCount,
    required this.returnCount,
    required this.surface,
    required this.border,
    required this.canReset,
    required this.onReset,
  });

  final int total;
  final int groceryCount;
  final int returnCount;
  final Color surface;
  final Color border;
  final bool canReset;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        backgroundColor: surface,
        borderColor: border,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              '$total نتيجة · $groceryCount سوبرماركت · $returnCount إرجاع وضمان',
              languageCode: 'ar',
              style: AppTypography.label,
            ),
            if (canReset) ...<Widget>[
              const SizedBox(height: ShoppingUiTokens.gapSm),
              AppGlassCard(
                onTap: onReset,
                borderColor: AppColors.secondary,
                child: AppDirectionalText(
                  'إلغاء البحث والفلترة',
                  languageCode: 'ar',
                  textAlign: TextAlign.center,
                  style: AppTypography.label.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
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

  final ShoppingPhrase phrase;
  final Color surface;
  final Color border;

  @override
  Widget build(BuildContext context) {
    final accent = _agentAccent(phrase.agent);

    return AppGlassCard(
      backgroundColor: surface,
      borderColor: border,
      glowColor: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                phrase.agent == ShoppingAgentType.grocery
                    ? Icons.local_grocery_store_rounded
                    : Icons.assignment_return_rounded,
                color: accent,
                size: ShoppingUiTokens.iconMd,
              ),
              const SizedBox(width: ShoppingUiTokens.gapSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    AppDirectionalText(
                      phrase.agent.germanLabel,
                      languageCode: 'de',
                      style: AppTypography.label.copyWith(color: accent),
                    ),
                    const SizedBox(height: ShoppingUiTokens.gapXs),
                    AppDirectionalText(
                      phrase.level.germanLabel,
                      languageCode: 'de',
                      style: AppTypography.label.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: ShoppingUiTokens.gapSm),
          AppDirectionalText(
            phrase.german,
            languageCode: 'de',
            style: AppTypography.title,
          ),
          const SizedBox(height: ShoppingUiTokens.gapSm),
          AppDirectionalText(
            phrase.arabic,
            languageCode: 'ar',
            style: AppTypography.body,
          ),
          const SizedBox(height: ShoppingUiTokens.gapXs),
          AppDirectionalText(
            phrase.usageArabic,
            languageCode: 'ar',
            style: AppTypography.label,
          ),
        ],
      ),
    );
  }
}

final class _EmptyResults extends StatelessWidget {
  const _EmptyResults({
    required this.surface,
    required this.border,
  });

  final Color surface;
  final Color border;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        backgroundColor: surface,
        borderColor: border,
        child: Column(
          children: <Widget>[
            const Icon(
              Icons.search_off_rounded,
              color: AppColors.primary,
              size: ShoppingUiTokens.iconLg,
            ),
            const SizedBox(height: ShoppingUiTokens.gapSm),
            AppDirectionalText(
              'لا توجد عبارات مطابقة. جرّب كلمة أوسع أو ألغِ فلتر المستوى.',
              languageCode: 'ar',
              textAlign: TextAlign.center,
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

Color _agentAccent(ShoppingAgentType agent) => switch (agent) {
      ShoppingAgentType.grocery => AppColors.secondary,
      ShoppingAgentType.returnWarranty => AppColors.tertiary,
    };

TextDirection _directionForQuery(String query) {
  final hasArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(query);
  return hasArabic ? TextDirection.rtl : TextDirection.ltr;
}
