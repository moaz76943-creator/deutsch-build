import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../../design_system/design_system.dart';
import 'delivery_transport_agent.dart';
import 'shopping_models.dart';
import 'store_shopping_agent.dart';

final class ShoppingDeliveryHubController extends ChangeNotifier {
  ShoppingDeliveryHubController({
    FurnitureStoreShoppingAgent storeAgent =
        const FurnitureStoreShoppingAgent(),
    DeliveryTransportAgent deliveryAgent = const DeliveryTransportAgent(),
  }) : _scenarios = <FurnitureShoppingScenario>[
          ...storeAgent.scenarios,
          ...deliveryAgent.scenarios,
        ];

  final List<FurnitureShoppingScenario> _scenarios;
  FurnitureService _service = FurnitureService.store;
  String _query = '';

  FurnitureService get service => _service;
  String get query => _query;

  List<FurnitureShoppingScenario> get visibleScenarios =>
      List<FurnitureShoppingScenario>.unmodifiable(
        _scenarios.where(
          (scenario) =>
              scenario.service == _service && scenario.matches(_query),
        ),
      );

  void setService(FurnitureService value) {
    if (_service == value) return;
    _service = value;
    notifyListeners();
  }

  void setQuery(String value) {
    if (_query == value) return;
    _query = value;
    notifyListeners();
  }
}

final class ShoppingDeliveryScreen extends StatefulWidget {
  const ShoppingDeliveryScreen({super.key});

  @override
  State<ShoppingDeliveryScreen> createState() => _ShoppingDeliveryScreenState();
}

final class _ShoppingDeliveryScreenState extends State<ShoppingDeliveryScreen> {
  late final ShoppingDeliveryHubController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ShoppingDeliveryHubController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface = dark ? AppColors.darkSurface : AppColors.lightSurface;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            dark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: AppBar(
          title: const Text('شراء وتوصيل الأثاث · Möbelkauf & Lieferung'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextField(
                    onChanged: _controller.setQuery,
                    textDirection: TextDirection.ltr,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      labelText: 'Suche · بحث',
                      hintText: 'Maße, Lager, Führerschein ...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppGlassCard(
                    backgroundColor: surface,
                    borderColor: AppColors.primary.withAlpha(88),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        for (final service in FurnitureService.values)
                          FilterChip(
                            selected: _controller.service == service,
                            onSelected: (_) => _controller.setService(service),
                            label: Text(_serviceLabel(service)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final scenario in _controller.visibleScenarios) ...<Widget>[
                    AppGlassCard(
                      backgroundColor: surface,
                      borderColor: AppColors.secondary.withAlpha(88),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          AppDirectionalText(
                            scenario.titleDe,
                            languageCode: 'de',
                            style: AppTypography.title,
                          ),
                          AppDirectionalText(
                            scenario.titleAr,
                            languageCode: 'ar',
                            style: AppTypography.label,
                          ),
                          const SizedBox(height: 8),
                          AppDirectionalText(
                            scenario.german,
                            languageCode: 'de',
                            style: AppTypography.body,
                          ),
                          const SizedBox(height: 6),
                          AppDirectionalText(
                            scenario.arabic,
                            languageCode: 'ar',
                            style: AppTypography.body,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _serviceLabel(FurnitureService service) => switch (service) {
        FurnitureService.store => 'Im Markt',
        FurnitureService.curbside => 'Bordsteinkante',
        FurnitureService.apartment => 'Wohnung',
        FurnitureService.transporter => 'Transporter',
      };
}
