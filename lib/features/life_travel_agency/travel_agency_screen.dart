import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../design_system/design_system.dart';
import 'flight_hotel_booking_agent.dart';
import 'holiday_package_agent.dart';
import 'travel_agency_master_hub.dart';

abstract final class _TravelUi {
  static const double inset = 16;
  static const double gap = 14;
  static const double smallGap = 8;
  static const double radius = 18;
  static const int borderAlpha = 72;
  static const int selectedAlpha = 32;
}

final class TravelAgencyMasterScreen extends StatefulWidget {
  const TravelAgencyMasterScreen({super.key});

  @override
  State<TravelAgencyMasterScreen> createState() =>
      _TravelAgencyMasterScreenState();
}

final class _TravelAgencyMasterScreenState extends State<TravelAgencyMasterScreen> {
  late final TravelAgencyMasterHub _hub;
  final TextEditingController _search = TextEditingController();
  final TextEditingController _destination = TextEditingController();

  @override
  void initState() {
    super.initState();
    _hub = TravelAgencyMasterHub(
      entries: <TravelAgencyPhrase>[
        ...FlightHotelBookingAgent.entries,
        ...HolidayPackageAgent.entries,
      ],
    );
  }

  @override
  void dispose() {
    _search.dispose();
    _destination.dispose();
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
          padding: const EdgeInsets.all(_TravelUi.inset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              AppGlassCard(
                key: const ValueKey<String>('travel-agency-header'),
                backgroundColor: surface,
                glowColor: AppColors.primary,
                borderColor: AppColors.primary.withAlpha(_TravelUi.borderAlpha),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    AppDirectionalText(
                      'وكالة السياحة والسفر',
                      languageCode: 'ar',
                      style: AppTypography.title,
                    ),
                    const SizedBox(height: _TravelUi.smallGap),
                    AppDirectionalText(
                      'Reisebüro · Flüge · Hotels · Urlaub',
                      languageCode: 'de',
                      style: AppTypography.display.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: _TravelUi.smallGap),
                    AppDirectionalText(
                      'تدريب عملي كامل لحجز الرحلات والفنادق والعطلات والاستفسار عن الشروط والأسعار.',
                      languageCode: 'ar',
                      style: AppTypography.body,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: _TravelUi.gap),
              _TripPlannerCard(
                surface: surface,
                hub: _hub,
                destinationController: _destination,
                onChanged: () => setState(() {}),
              ),
              const SizedBox(height: _TravelUi.gap),
              _CategoryCard(
                surface: surface,
                hub: _hub,
                onChanged: () => setState(() {}),
              ),
              const SizedBox(height: _TravelUi.gap),
              AppGlassCard(
                backgroundColor: surface,
                borderColor:
                    AppColors.secondary.withAlpha(_TravelUi.borderAlpha),
                child: TextField(
                  key: const ValueKey<String>('travel-agency-search'),
                  controller: _search,
                  textDirection: RegExp(r'[ء-ي]').hasMatch(_search.text)
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  style: AppTypography.body,
                  onChanged: (value) {
                    setState(() {
                      _hub.setQuery(value);
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Flug · Hotel · Pauschalreise · إلغاء',
                    hintStyle: AppTypography.body,
                    prefixIcon:
                        const Icon(Icons.search, color: AppColors.secondary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(_TravelUi.radius),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: _TravelUi.gap),
              AppDirectionalText(
                'عبارات الوكالة',
                languageCode: 'ar',
                style: AppTypography.title,
              ),
              const SizedBox(height: _TravelUi.smallGap),
              if (entries.isEmpty)
                AppGlassCard(
                  key: const ValueKey<String>('travel-agency-empty'),
                  backgroundColor: surface,
                  child: AppDirectionalText(
                    'لا توجد نتائج. غيّر البحث أو أعد تفعيل القسم المطلوب.',
                    languageCode: 'ar',
                    style: AppTypography.body,
                  ),
                )
              else
                for (var i = 0; i < entries.length; i++) ...<Widget>[
                  _PhraseCard(entry: entries[i], surface: surface),
                  if (i != entries.length - 1)
                    const SizedBox(height: _TravelUi.smallGap),
                ],
            ],
          ),
        ),
      ),
    );
  }
}

final class _TripPlannerCard extends StatelessWidget {
  const _TripPlannerCard({
    required this.surface,
    required this.hub,
    required this.destinationController,
    required this.onChanged,
  });

  final Color surface;
  final TravelAgencyMasterHub hub;
  final TextEditingController destinationController;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final summary = hub.tripSummary;
    return AppGlassCard(
      key: const ValueKey<String>('travel-trip-planner'),
      backgroundColor: surface,
      glowColor: AppColors.tertiary,
      borderColor: AppColors.tertiary.withAlpha(_TravelUi.borderAlpha),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppDirectionalText(
            'ملخص طلب الرحلة',
            languageCode: 'ar',
            style: AppTypography.title,
          ),
          const SizedBox(height: _TravelUi.smallGap),
          TextField(
            key: const ValueKey<String>('travel-destination'),
            controller: destinationController,
            textDirection: TextDirection.ltr,
            onChanged: (value) {
              hub.setDestination(value);
              onChanged();
            },
            decoration: InputDecoration(
              labelText: 'Reiseziel',
              labelStyle: AppTypography.label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_TravelUi.radius),
              ),
            ),
          ),
          const SizedBox(height: _TravelUi.smallGap),
          Wrap(
            spacing: _TravelUi.smallGap,
            runSpacing: _TravelUi.smallGap,
            children: <Widget>[
              for (final count in <int>[1, 2, 3, 4])
                ChoiceChip(
                  key: ValueKey<String>('travel-count-$count'),
                  selected: summary.travellers == count,
                  selectedColor:
                      AppColors.tertiary.withAlpha(_TravelUi.selectedAlpha),
                  label: AppDirectionalText(
                    '$count Reisende',
                    languageCode: 'de',
                    style: AppTypography.label,
                  ),
                  onSelected: (_) {
                    hub.setTravellers(count);
                    onChanged();
                  },
                ),
              FilterChip(
                key: const ValueKey<String>('travel-flexible-dates'),
                selected: summary.flexibleDates,
                selectedColor:
                    AppColors.tertiary.withAlpha(_TravelUi.selectedAlpha),
                label: AppDirectionalText(
                  'Flexible Reisedaten',
                  languageCode: 'de',
                  style: AppTypography.label,
                ),
                onSelected: (_) {
                  hub.toggleFlexibleDates();
                  onChanged();
                },
              ),
            ],
          ),
          const SizedBox(height: _TravelUi.smallGap),
          AppDirectionalText(
            summary.german,
            languageCode: 'de',
            style: AppTypography.label,
          ),
          AppDirectionalText(
            summary.arabic,
            languageCode: 'ar',
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }
}

final class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.surface,
    required this.hub,
    required this.onChanged,
  });

  final Color surface;
  final TravelAgencyMasterHub hub;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        backgroundColor: surface,
        borderColor: AppColors.primary.withAlpha(_TravelUi.borderAlpha),
        child: Wrap(
          spacing: _TravelUi.smallGap,
          runSpacing: _TravelUi.smallGap,
          children: <Widget>[
            for (final category in TravelAgencyCategory.values)
              FilterChip(
                key: ValueKey<String>('travel-category-${category.name}'),
                selected: hub.selected.contains(category),
                selectedColor:
                    AppColors.primary.withAlpha(_TravelUi.selectedAlpha),
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

  final TravelAgencyPhrase entry;
  final Color surface;

  Color get _accent => switch (entry.category) {
        TravelAgencyCategory.flights => AppColors.primary,
        TravelAgencyCategory.hotels => AppColors.secondary,
        TravelAgencyCategory.holidays => AppColors.tertiary,
      };

  @override
  Widget build(BuildContext context) => AppGlassCard(
        key: ValueKey<String>('travel-entry-${entry.id}'),
        backgroundColor: surface,
        borderColor: _accent.withAlpha(_TravelUi.borderAlpha),
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
            const SizedBox(height: _TravelUi.smallGap),
            AppDirectionalText(
              entry.german,
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: _TravelUi.smallGap),
            AppDirectionalText(
              entry.arabic,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}
