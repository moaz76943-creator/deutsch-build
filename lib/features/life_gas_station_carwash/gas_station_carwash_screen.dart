import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../design_system/app_colors.dart';
import '../../design_system/app_glass_card.dart';
import '../../design_system/app_typography.dart' hide AppDirectionalText;
import 'gas_station_carwash_master_orchestrator.dart';
import 'gas_station_carwash_models.dart';

abstract final class _Ui {
  static const double inset = 16;
  static const double gap = 14;
  static const double small = 8;
}

class GasStationCarwashMasterHub extends StatefulWidget {
  const GasStationCarwashMasterHub({
    this.orchestrator,
    this.onRouteSelected,
    super.key,
  });

  final GasStationCarwashMasterOrchestrator? orchestrator;
  final ValueChanged<GasStationRouteDescriptor>? onRouteSelected;

  @override
  State<GasStationCarwashMasterHub> createState() =>
      _GasStationCarwashMasterHubState();
}

class _GasStationCarwashMasterHubState
    extends State<GasStationCarwashMasterHub> {
  late final GasStationCarwashMasterOrchestrator _orchestrator;
  late final bool _owns;
  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();
    _owns = widget.orchestrator == null;
    _orchestrator =
        widget.orchestrator ?? GasStationCarwashMasterOrchestrator();
    _search = TextEditingController(text: _orchestrator.query);
  }

  @override
  void dispose() {
    _search.dispose();
    if (_owns) _orchestrator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _orchestrator,
      builder: (context, _) {
        final dark = Theme.of(context).brightness == Brightness.dark;
        return Scaffold(
          appBar: AppBar(
            title: AppDirectionalText(
              'Tankstelle & Autowäsche',
              languageCode: 'de',
              style: AppTypography.title,
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(_Ui.inset),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  AppGlassCard(
                    glowColor: AppColors.primary,
                    borderColor: AppColors.primary.withAlpha(76),
                    backgroundColor:
                        dark ? AppColors.darkSurface : AppColors.lightSurface,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        AppDirectionalText(
                          'Tanken und Waschen ohne Unsicherheit',
                          languageCode: 'de',
                          style: AppTypography.title,
                        ),
                        AppDirectionalText(
                          'عبارات عملية لاختيار الوقود والدفع واستخدام الغسيل الآلي.',
                          languageCode: 'ar',
                          style: AppTypography.body,
                        ),
                        const SizedBox(height: _Ui.small),
                        AppDirectionalText(
                          _orchestrator.safetyNoteDe,
                          languageCode: 'de',
                          style: AppTypography.label,
                        ),
                        AppDirectionalText(
                          _orchestrator.safetyNoteAr,
                          languageCode: 'ar',
                          style: AppTypography.label,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: _Ui.gap),
                  AppGlassCard(
                    borderColor: AppColors.secondary.withAlpha(72),
                    backgroundColor:
                        dark ? AppColors.darkSurface : AppColors.lightSurface,
                    child: Wrap(
                      spacing: _Ui.small,
                      runSpacing: _Ui.small,
                      children: <Widget>[
                        for (final domain in GasStationDomain.values)
                          ChoiceChip(
                            key: ValueKey<String>(
                              'gas-station-domain-' + domain.name,
                            ),
                            selected: _orchestrator.domain == domain,
                            onSelected: (_) => _orchestrator.setDomain(domain),
                            label: Column(
                              mainAxisSize: MainAxisSize.min,
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
                  ),
                  const SizedBox(height: _Ui.gap),
                  AppGlassCard(
                    borderColor: AppColors.primary.withAlpha(64),
                    backgroundColor:
                        dark ? AppColors.darkSurface : AppColors.lightSurface,
                    child: TextField(
                      key: const ValueKey<String>(
                        'gas-station-master-search',
                      ),
                      controller: _search,
                      onChanged: _orchestrator.setQuery,
                      textDirection: TextDirection.rtl,
                      style: AppTypography.body,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search_rounded),
                        hintText: 'Kraftstoff, Waschcode / وقود، غسيل',
                      ),
                    ),
                  ),
                  const SizedBox(height: _Ui.gap),
                  for (final route in _orchestrator.visibleRoutes) ...<Widget>[
                    AppGlassCard(
                      onTap: widget.onRouteSelected == null
                          ? null
                          : () => widget.onRouteSelected!(route),
                      borderColor: AppColors.secondary.withAlpha(70),
                      glowColor: AppColors.secondary,
                      backgroundColor:
                          dark ? AppColors.darkSurface : AppColors.lightSurface,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          AppDirectionalText(
                            route.titleDe,
                            languageCode: 'de',
                            style: AppTypography.title,
                          ),
                          AppDirectionalText(
                            route.titleAr,
                            languageCode: 'ar',
                            style: AppTypography.label,
                          ),
                          const SizedBox(height: _Ui.small),
                          AppDirectionalText(
                            route.descriptionDe,
                            languageCode: 'de',
                            style: AppTypography.body,
                          ),
                          AppDirectionalText(
                            route.descriptionAr,
                            languageCode: 'ar',
                            style: AppTypography.body,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: _Ui.small),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
