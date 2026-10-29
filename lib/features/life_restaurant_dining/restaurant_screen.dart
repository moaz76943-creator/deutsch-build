import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../design_system/design_system.dart';
import 'restaurant_master_orchestrator.dart';
import 'restaurant_models.dart';

abstract final class RestaurantDiningUiTokens {
  static const double pageInset = 16;
  static const double bottomInset = 32;
  static const double sectionGap = 18;
  static const double itemGap = 12;
  static const double compactGap = 8;
}

final class RestaurantDiningMasterHub extends StatefulWidget {
  const RestaurantDiningMasterHub({
    this.orchestrator,
    this.orchestratorFactory,
    super.key,
  });

  static const String routeName = '/life/restaurant-dining';

  final RestaurantDiningMasterOrchestrator? orchestrator;
  final RestaurantDiningMasterOrchestrator Function()? orchestratorFactory;

  @override
  State<RestaurantDiningMasterHub> createState() =>
      _RestaurantDiningMasterHubState();
}

final class _RestaurantDiningMasterHubState
    extends State<RestaurantDiningMasterHub> {
  late final RestaurantDiningMasterOrchestrator _orchestrator;
  late final bool _ownsOrchestrator;

  @override
  void initState() {
    super.initState();
    if (widget.orchestrator != null) {
      _orchestrator = widget.orchestrator!;
      _ownsOrchestrator = false;
    } else {
      _orchestrator =
          widget.orchestratorFactory?.call() ?? RestaurantDiningMasterOrchestrator();
      _ownsOrchestrator = true;
    }
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
              RestaurantDiningUiTokens.pageInset,
              RestaurantDiningUiTokens.pageInset,
              RestaurantDiningUiTokens.pageInset,
              RestaurantDiningUiTokens.bottomInset,
            ),
            child: AnimatedBuilder(
              animation: _orchestrator,
              builder: (context, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _HeaderCard(dark: dark),
                  const SizedBox(height: RestaurantDiningUiTokens.sectionGap),
                  _VenueSelector(orchestrator: _orchestrator, dark: dark),
                  const SizedBox(height: RestaurantDiningUiTokens.itemGap),
                  _SearchField(orchestrator: _orchestrator),
                  const SizedBox(height: RestaurantDiningUiTokens.itemGap),
                  _MealOptions(orchestrator: _orchestrator, dark: dark),
                  const SizedBox(height: RestaurantDiningUiTokens.sectionGap),
                  _MenuCard(orchestrator: _orchestrator, dark: dark),
                  const SizedBox(height: RestaurantDiningUiTokens.sectionGap),
                  _BillTipCard(orchestrator: _orchestrator, dark: dark),
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
        glowColor: AppColors.tertiary,
        borderColor: AppColors.tertiary.withAlpha(96),
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'Restaurant, Café & Schnellrestaurant',
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: RestaurantDiningUiTokens.compactGap),
            AppDirectionalText(
              'مركز عملي لفهم قائمة الطعام، اختيار الوجبة، والدفع والإكرامية في ألمانيا.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

final class _VenueSelector extends StatelessWidget {
  const _VenueSelector({required this.orchestrator, required this.dark});
  final RestaurantDiningMasterOrchestrator orchestrator;
  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.primary.withAlpha(96),
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Wrap(
          spacing: RestaurantDiningUiTokens.compactGap,
          runSpacing: RestaurantDiningUiTokens.compactGap,
          children: <Widget>[
            for (final venue in DiningVenueType.values)
              FilterChip(
                key: ValueKey<String>('restaurant-venue-${venue.name}'),
                selected: orchestrator.venue == venue,
                onSelected: (_) => orchestrator.setVenue(venue),
                label: Text(
                  '${venue.labelDe} · ${venue.labelAr}',
                  style: AppTypography.label,
                ),
              ),
          ],
        ),
      );
}

final class _SearchField extends StatelessWidget {
  const _SearchField({required this.orchestrator});
  final RestaurantDiningMasterOrchestrator orchestrator;

  @override
  Widget build(BuildContext context) => TextField(
        key: const ValueKey<String>('restaurant-search'),
        onChanged: orchestrator.setQuery,
        textDirection: TextDirection.ltr,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search),
          labelText: 'Speisekarte durchsuchen · بحث',
          hintText: 'Suppe, vegan, halal ...',
          border: OutlineInputBorder(),
        ),
      );
}

final class _MealOptions extends StatelessWidget {
  const _MealOptions({required this.orchestrator, required this.dark});
  final RestaurantDiningMasterOrchestrator orchestrator;
  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.secondary.withAlpha(96),
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'Essensoptionen · خيارات الوجبة',
              languageCode: 'de',
              style: AppTypography.label,
            ),
            const SizedBox(height: RestaurantDiningUiTokens.compactGap),
            Wrap(
              spacing: RestaurantDiningUiTokens.compactGap,
              runSpacing: RestaurantDiningUiTokens.compactGap,
              children: <Widget>[
                ChoiceChip(
                  label: const Text('Alle · الكل'),
                  selected: orchestrator.mealOption == null,
                  onSelected: (_) => orchestrator.setMealOption(null),
                ),
                for (final option in MealOption.values)
                  ChoiceChip(
                    selected: orchestrator.mealOption == option,
                    onSelected: (_) => orchestrator.setMealOption(option),
                    label: Text('${option.labelDe} · ${option.labelAr}'),
                  ),
              ],
            ),
          ],
        ),
      );
}

final class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.orchestrator, required this.dark});
  final RestaurantDiningMasterOrchestrator orchestrator;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final items = orchestrator.visibleMenu;
    return AppGlassCard(
      borderColor: AppColors.primary.withAlpha(80),
      backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppDirectionalText(
            'Speisekarte · قائمة الطعام',
            languageCode: 'de',
            style: AppTypography.title,
          ),
          const SizedBox(height: RestaurantDiningUiTokens.itemGap),
          if (items.isEmpty)
            AppDirectionalText(
              'لا توجد عناصر مطابقة. جرّب بحثاً أو خيار وجبة مختلفاً.',
              languageCode: 'ar',
              style: AppTypography.body,
            )
          else
            for (final item in items) ...<Widget>[
              AppDirectionalText(
                item.nameDe,
                languageCode: 'de',
                style: AppTypography.label,
              ),
              AppDirectionalText(
                item.nameAr,
                languageCode: 'ar',
                style: AppTypography.body,
              ),
              AppDirectionalText(
                item.descriptionDe,
                languageCode: 'de',
                style: AppTypography.body,
              ),
              const SizedBox(height: RestaurantDiningUiTokens.itemGap),
            ],
        ],
      ),
    );
  }
}

final class _BillTipCard extends StatelessWidget {
  const _BillTipCard({required this.orchestrator, required this.dark});
  final RestaurantDiningMasterOrchestrator orchestrator;
  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        glowColor: AppColors.secondary,
        borderColor: AppColors.secondary.withAlpha(96),
        backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'Rechnung & Trinkgeld · الحساب والإكرامية',
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: RestaurantDiningUiTokens.itemGap),
            for (final phrase in orchestrator.billTipPhrases) ...<Widget>[
              AppDirectionalText(
                phrase.german,
                languageCode: 'de',
                style: AppTypography.label,
              ),
              AppDirectionalText(
                phrase.arabic,
                languageCode: 'ar',
                style: AppTypography.body,
              ),
              const SizedBox(height: RestaurantDiningUiTokens.compactGap),
            ],
          ],
        ),
      );
}
