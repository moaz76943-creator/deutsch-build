import 'package:deutsch_bilarabi/features/life_furniture_home_setup/shopping/delivery_transport_agent.dart';
import 'package:deutsch_bilarabi/features/life_furniture_home_setup/shopping/store_shopping_agent.dart';
import 'package:deutsch_bilarabi/features/life_furniture_home_setup/shopping/shopping_delivery_hub.dart';
import 'package:deutsch_bilarabi/features/life_furniture_home_setup/shopping/shopping_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('store agent covers dimensions and warehouse availability', () {
    const agent = FurnitureStoreShoppingAgent();

    expect(agent.scenarios.any((x) => x.id == 'ask-dimensions'), isTrue);
    expect(agent.scenarios.any((x) => x.id == 'warehouse-stock'), isTrue);
    expect(
      agent.scenarios
          .firstWhere((x) => x.id == 'ask-dimensions')
          .german,
      contains('Höhe'),
    );
  });

  test('delivery agent distinguishes curbside, apartment, and transporter', () {
    const agent = DeliveryTransportAgent();

    expect(
      agent.scenarios.any((x) => x.service == FurnitureService.curbside),
      isTrue,
    );
    expect(
      agent.scenarios.any((x) => x.service == FurnitureService.apartment),
      isTrue,
    );
    expect(
      agent.scenarios.any((x) => x.service == FurnitureService.transporter),
      isTrue,
    );
  });

  test('hub filters scenarios by query and selected service', () {
    final hub = ShoppingDeliveryHubController();
    hub
      ..setService(FurnitureService.transporter)
      ..setQuery('Führerschein');

    expect(hub.visibleScenarios, hasLength(1));
    expect(hub.visibleScenarios.single.id, 'rent-transporter-license');
    hub.dispose();
  });
}
