import 'package:flutter/foundation.dart';

import 'furniture_home_models.dart';

final class FurnitureHomeSetupModule {
  const FurnitureHomeSetupModule();

  static const String routeName = '/life/furniture-home-setup';

  FurnitureHomeSetupController createController() =>
      FurnitureHomeSetupController();
}

final class FurnitureHomeSetupController extends ChangeNotifier {
  FurnitureHomeSection _section = FurnitureHomeSection.shopping;
  String _query = '';

  final List<FurniturePurchaseRequest> _purchases =
      <FurniturePurchaseRequest>[];
  final List<FurnitureDeliveryRequest> _deliveries =
      <FurnitureDeliveryRequest>[];
  final List<FurnitureWarrantyCase> _warrantyCases =
      <FurnitureWarrantyCase>[];

  FurnitureHomeSection get section => _section;
  String get query => _query;

  List<FurniturePurchaseRequest> get purchases =>
      List<FurniturePurchaseRequest>.unmodifiable(_purchases);
  List<FurnitureDeliveryRequest> get deliveries =>
      List<FurnitureDeliveryRequest>.unmodifiable(_deliveries);
  List<FurnitureWarrantyCase> get warrantyCases =>
      List<FurnitureWarrantyCase>.unmodifiable(_warrantyCases);

  void setSection(FurnitureHomeSection value) {
    if (_section == value) return;
    _section = value;
    notifyListeners();
  }

  void setQuery(String value) {
    if (_query == value) return;
    _query = value;
    notifyListeners();
  }

  void addPurchase(FurniturePurchaseRequest request) {
    _purchases.add(request);
    notifyListeners();
  }

  void addDelivery(FurnitureDeliveryRequest request) {
    _deliveries.add(request);
    notifyListeners();
  }

  void addWarrantyCase(FurnitureWarrantyCase warrantyCase) {
    _warrantyCases.add(warrantyCase);
    notifyListeners();
  }
}
