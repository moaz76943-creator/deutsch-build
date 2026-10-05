import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../design_system/design_system.dart';
import 'delay_bahncard_agent.dart';
import 'ice_booking_agent.dart';
import 'intercity_train_master_hub.dart';

abstract final class _TrainUi {
  static const double inset = 16;
  static const double gap = 14;
  static const double smallGap = 8;
  static const double radius = 18;
  static const int borderAlpha = 72;
  static const int selectedAlpha = 32;
}

final class IntercityTrainTravelMasterScreen extends StatefulWidget {
  const IntercityTrainTravelMasterScreen({super.key});

  @override
  State<IntercityTrainTravelMasterScreen> createState() =>
      _IntercityTrainTravelMasterScreenState();
}

final class _IntercityTrainTravelMasterScreenState
    extends State<IntercityTrainTravelMasterScreen> {
  late final IntercityTrainTravelMasterHub _hub;
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _hub = IntercityTrainTravelMasterHub(
      entries: <IntercityPhrase>[
        ...IceBookingAgent.entries,
        ...DelayBahnCardAgent.entries,
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
          padding: const EdgeInsets.all(_TrainUi.inset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              AppGlassCard(
                key: const ValueKey<String>('intercity-train-header'),
                backgroundColor: surface,
                glowColor: AppColors.primary,
                borderColor: AppColors.primary.withAlpha(_TrainUi.borderAlpha),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    AppDirectionalText(
                      'السفر بالقطارات بين المدن',
                      languageCode: 'ar',
                      style: AppTypography.title,
                    ),
                    const SizedBox(height: _TrainUi.smallGap),
                    AppDirectionalText(
                      'DB Fernverkehr · ICE · BahnCard',
                      languageCode: 'de',
                      style: AppTypography.display.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: _TrainUi.smallGap),
                    AppDirectionalText(
                      'عبارات عملية لحجز ICE، المقاعد والتبديلات، التعامل مع التأخير، والاستفسار عن BahnCard.',
                      languageCode: 'ar',
                      style: AppTypography.body,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: _TrainUi.gap),
              _SituationCard(
                surface: surface,
                hub: _hub,
                onChanged: () => setState(() {}),
              ),
              const SizedBox(height: _TrainUi.gap),
              _CategoryCard(
                surface: surface,
                hub: _hub,
                onChanged: () => setState(() {}),
              ),
              const SizedBox(height: _TrainUi.gap),
              AppGlassCard(
                backgroundColor: surface,
                borderColor:
                    AppColors.secondary.withAlpha(_TrainUi.borderAlpha),
                child: TextField(
                  key: const ValueKey<String>('intercity-train-search'),
                  controller: _search,
                  textDirection: RegExp(r'[ء-ي]').hasMatch(_search.text)
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  style: AppTypography.body,
                  onChanged: (value) {
                    setState(() => _hub.setQuery(value));
                  },
                  decoration: InputDecoration(
                    hintText: 'ICE · Verspätung · BahnCard · مقعد',
                    hintStyle: AppTypography.body,
                    prefixIcon:
                        const Icon(Icons.search, color: AppColors.secondary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(_TrainUi.radius),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: _TrainUi.gap),
              AppDirectionalText(
                'عبارات السفر',
                languageCode: 'ar',
                style: AppTypography.title,
              ),
              const SizedBox(height: _TrainUi.smallGap),
              if (entries.isEmpty)
                AppGlassCard(
                  key: const ValueKey<String>('intercity-train-empty'),
                  backgroundColor: surface,
                  child: AppDirectionalText(
                    'لا توجد نتائج. عدّل البحث أو أعد تفعيل القسم المطلوب.',
                    languageCode: 'ar',
                    style: AppTypography.body,
                  ),
                )
              else
                for (var i = 0; i < entries.length; i++) ...<Widget>[
                  _PhraseCard(entry: entries[i], surface: surface),
                  if (i != entries.length - 1)
                    const SizedBox(height: _TrainUi.smallGap),
                ],
            ],
          ),
        ),
      ),
    );
  }
}

final class _SituationCard extends StatelessWidget {
  const _SituationCard({
    required this.surface,
    required this.hub,
    required this.onChanged,
  });

  final Color surface;
  final IntercityTrainTravelMasterHub hub;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        key: const ValueKey<String>('intercity-situation-card'),
        backgroundColor: surface,
        glowColor: AppColors.tertiary,
        borderColor: AppColors.tertiary.withAlpha(_TrainUi.borderAlpha),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'وضع الرحلة',
              languageCode: 'ar',
              style: AppTypography.title,
            ),
            const SizedBox(height: _TrainUi.smallGap),
            Wrap(
              spacing: _TrainUi.smallGap,
              runSpacing: _TrainUi.smallGap,
              children: <Widget>[
                for (final situation in JourneySituation.values)
                  ChoiceChip(
                    key: ValueKey<String>(
                      'intercity-situation-${situation.name}',
                    ),
                    selected: hub.situation == situation,
                    selectedColor:
                        AppColors.tertiary.withAlpha(_TrainUi.selectedAlpha),
                    label: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        AppDirectionalText(
                          situation.labelAr,
                          languageCode: 'ar',
                          style: AppTypography.label,
                        ),
                        AppDirectionalText(
                          situation.labelDe,
                          languageCode: 'de',
                          style: AppTypography.label,
                        ),
                      ],
                    ),
                    onSelected: (_) {
                      hub.setSituation(situation);
                      onChanged();
                    },
                  ),
              ],
            ),
            const SizedBox(height: _TrainUi.smallGap),
            AppDirectionalText(
              hub.situationPromptDe,
              languageCode: 'de',
              style: AppTypography.label.copyWith(color: AppColors.tertiary),
            ),
            AppDirectionalText(
              hub.situationPromptAr,
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
  final IntercityTrainTravelMasterHub hub;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        backgroundColor: surface,
        borderColor: AppColors.primary.withAlpha(_TrainUi.borderAlpha),
        child: Wrap(
          spacing: _TrainUi.smallGap,
          runSpacing: _TrainUi.smallGap,
          children: <Widget>[
            for (final category in IntercityTravelCategory.values)
              FilterChip(
                key: ValueKey<String>('intercity-category-${category.name}'),
                selected: hub.selected.contains(category),
                selectedColor:
                    AppColors.primary.withAlpha(_TrainUi.selectedAlpha),
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

  final IntercityPhrase entry;
  final Color surface;

  Color get _accent => switch (entry.category) {
        IntercityTravelCategory.iceBooking => AppColors.primary,
        IntercityTravelCategory.delaySupport => AppColors.tertiary,
        IntercityTravelCategory.bahnCard => AppColors.secondary,
      };

  @override
  Widget build(BuildContext context) => AppGlassCard(
        key: ValueKey<String>('intercity-entry-${entry.id}'),
        backgroundColor: surface,
        borderColor: _accent.withAlpha(_TrainUi.borderAlpha),
        glowColor: _accent,
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
            const SizedBox(height: _TrainUi.smallGap),
            AppDirectionalText(
              entry.german,
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: _TrainUi.smallGap),
            AppDirectionalText(
              entry.arabic,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}
