import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../design_system/design_system.dart';
import 'key_service_agent.dart';
import 'quick_service_master_hub.dart';
import 'shoe_repair_agent.dart';

abstract final class _QuickUi {
  static const double inset = 16;
  static const double gap = 14;
  static const double smallGap = 8;
  static const double radius = 18;
  static const int borderAlpha = 72;
  static const int selectedAlpha = 32;
}

final class ShoeRepairKeysMasterScreen extends StatefulWidget {
  const ShoeRepairKeysMasterScreen({super.key});

  @override
  State<ShoeRepairKeysMasterScreen> createState() =>
      _ShoeRepairKeysMasterScreenState();
}

final class _ShoeRepairKeysMasterScreenState
    extends State<ShoeRepairKeysMasterScreen> {
  late final QuickServiceMasterHub _hub;
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _hub = QuickServiceMasterHub(
      entries: <QuickServicePhrase>[
        ...ShoeRepairAgent.entries,
        ...KeyServiceAgent.entries,
      ],
    );
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Color _surface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkSurface
          : AppColors.lightSurface;

  @override
  Widget build(BuildContext context) {
    final surface = _surface(context);
    final entries = _hub.visibleEntries;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(_QuickUi.inset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              AppGlassCard(
                key: const ValueKey<String>('quick-services-header'),
                backgroundColor: surface,
                glowColor: AppColors.primary,
                borderColor: AppColors.primary.withAlpha(_QuickUi.borderAlpha),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    AppDirectionalText(
                      'الخدمات السريعة',
                      languageCode: 'ar',
                      style: AppTypography.title,
                    ),
                    const SizedBox(height: _QuickUi.smallGap),
                    AppDirectionalText(
                      'Schuhreparatur & Schlüsselservice',
                      languageCode: 'de',
                      style: AppTypography.display.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: _QuickUi.smallGap),
                    AppDirectionalText(
                      'عبارات عملية لتصليح الأحذية، نسخ المفاتيح والاستفسار الآمن عن خدمة فتح الباب.',
                      languageCode: 'ar',
                      style: AppTypography.body,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: _QuickUi.gap),
              _UrgencyCard(
                surface: surface,
                hub: _hub,
                onChanged: () => setState(() {}),
              ),
              const SizedBox(height: _QuickUi.gap),
              _CategoryCard(
                surface: surface,
                hub: _hub,
                onChanged: () => setState(() {}),
              ),
              const SizedBox(height: _QuickUi.gap),
              AppGlassCard(
                backgroundColor: surface,
                borderColor:
                    AppColors.secondary.withAlpha(_QuickUi.borderAlpha),
                child: TextField(
                  key: const ValueKey<String>('quick-services-search'),
                  controller: _search,
                  textDirection: RegExp(r'[ء-ي]').hasMatch(_search.text)
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  style: AppTypography.body,
                  onChanged: (value) {
                    setState(() => _hub.setQuery(value));
                  },
                  decoration: InputDecoration(
                    hintText: 'Sohle · Schlüssel · Türöffnung · نعل',
                    hintStyle: AppTypography.body,
                    prefixIcon:
                        const Icon(Icons.search, color: AppColors.secondary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(_QuickUi.radius),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: _QuickUi.gap),
              AppDirectionalText(
                'العبارات الجاهزة',
                languageCode: 'ar',
                style: AppTypography.title,
              ),
              const SizedBox(height: _QuickUi.smallGap),
              if (entries.isEmpty)
                AppGlassCard(
                  key: const ValueKey<String>('quick-services-empty'),
                  backgroundColor: surface,
                  child: AppDirectionalText(
                    'لا توجد نتائج ضمن الاختيارات الحالية.',
                    languageCode: 'ar',
                    style: AppTypography.body,
                  ),
                )
              else
                for (var i = 0; i < entries.length; i++) ...<Widget>[
                  _PhraseCard(entry: entries[i], surface: surface),
                  if (i != entries.length - 1)
                    const SizedBox(height: _QuickUi.smallGap),
                ],
            ],
          ),
        ),
      ),
    );
  }
}

final class _UrgencyCard extends StatelessWidget {
  const _UrgencyCard({
    required this.surface,
    required this.hub,
    required this.onChanged,
  });

  final Color surface;
  final QuickServiceMasterHub hub;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        key: const ValueKey<String>('quick-services-urgency'),
        backgroundColor: surface,
        glowColor: AppColors.tertiary,
        borderColor: AppColors.tertiary.withAlpha(_QuickUi.borderAlpha),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'سرعة الخدمة',
              languageCode: 'ar',
              style: AppTypography.title,
            ),
            const SizedBox(height: _QuickUi.smallGap),
            Wrap(
              spacing: _QuickUi.smallGap,
              runSpacing: _QuickUi.smallGap,
              children: <Widget>[
                for (final urgency in QuickServiceUrgency.values)
                  ChoiceChip(
                    key: ValueKey<String>('quick-urgency-${urgency.name}'),
                    selected: hub.urgency == urgency,
                    selectedColor:
                        AppColors.tertiary.withAlpha(_QuickUi.selectedAlpha),
                    label: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        AppDirectionalText(
                          urgency.labelAr,
                          languageCode: 'ar',
                          style: AppTypography.label,
                        ),
                        AppDirectionalText(
                          urgency.labelDe,
                          languageCode: 'de',
                          style: AppTypography.label,
                        ),
                      ],
                    ),
                    onSelected: (_) {
                      hub.setUrgency(urgency);
                      onChanged();
                    },
                  ),
              ],
            ),
            const SizedBox(height: _QuickUi.smallGap),
            AppDirectionalText(
              hub.urgencyPromptDe,
              languageCode: 'de',
              style: AppTypography.label.copyWith(color: AppColors.tertiary),
            ),
            AppDirectionalText(
              hub.urgencyPromptAr,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

final class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.surface,
    required this.hub,
    required this.onChanged,
  });

  final Color surface;
  final QuickServiceMasterHub hub;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        backgroundColor: surface,
        borderColor: AppColors.primary.withAlpha(_QuickUi.borderAlpha),
        child: Wrap(
          spacing: _QuickUi.smallGap,
          runSpacing: _QuickUi.smallGap,
          children: <Widget>[
            for (final category in QuickServiceCategory.values)
              FilterChip(
                key: ValueKey<String>('quick-category-${category.name}'),
                selected: hub.selected.contains(category),
                selectedColor:
                    AppColors.primary.withAlpha(_QuickUi.selectedAlpha),
                label: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    AppDirectionalText(
                      category.labelAr,
                      languageCode: 'ar',
                      style: AppTypography.label,
                    ),
                    AppDirectionalText(
                      category.labelDe,
                      languageCode: 'de',
                      style: AppTypography.label,
                    ),
                  ],
                ),
                onSelected: (_) {
                  hub.toggleCategory(category);
                  onChanged();
                },
              ),
          ],
        ),
      );
}

final class _PhraseCard extends StatelessWidget {
  const _PhraseCard({required this.entry, required this.surface});

  final QuickServicePhrase entry;
  final Color surface;

  Color get _accent => switch (entry.category) {
        QuickServiceCategory.shoeRepair => AppColors.primary,
        QuickServiceCategory.keyService => AppColors.secondary,
      };

  @override
  Widget build(BuildContext context) => AppGlassCard(
        key: ValueKey<String>('quick-entry-${entry.id}'),
        backgroundColor: surface,
        glowColor: _accent,
        borderColor: _accent.withAlpha(_QuickUi.borderAlpha),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              entry.topicAr,
              languageCode: 'ar',
              style: AppTypography.label.copyWith(color: _accent),
            ),
            AppDirectionalText(
              entry.topicDe,
              languageCode: 'de',
              style: AppTypography.label,
            ),
            const SizedBox(height: _QuickUi.smallGap),
            AppDirectionalText(
              entry.german,
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: _QuickUi.smallGap),
            AppDirectionalText(
              entry.arabic,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}
