import 'package:flutter/foundation.dart';

import 'supermarket_models.dart';

final class SupermarketMasterOrchestrator extends ChangeNotifier {
  SupermarketMasterOrchestrator({
    List<GroceryProduct> products = _defaultProducts,
    List<GroceryOffer> offers = _defaultOffers,
    Kassenbon receipt = _defaultReceipt,
  })  : products = List<GroceryProduct>.unmodifiable(products),
        offers = List<GroceryOffer>.unmodifiable(offers),
        receipt = receipt;

  final List<GroceryProduct> products;
  final List<GroceryOffer> offers;
  final Kassenbon receipt;

  String _query = '';

  String get query => _query;

  List<GroceryProduct> get visibleProducts => List<GroceryProduct>.unmodifiable(
        products.where((product) => product.matches(_query)),
      );

  List<GroceryOffer> get visibleOffers => List<GroceryOffer>.unmodifiable(
        offers.where((offer) {
          if (offer.matches(_query)) return true;
          final product = products.where((item) => item.id == offer.productId);
          return product.isNotEmpty && product.first.matches(_query);
        }),
      );

  void setQuery(String value) {
    if (_query == value) return;
    _query = value;
    notifyListeners();
  }

  void clearSearch() => setQuery('');

  static const List<GroceryProduct> _defaultProducts = <GroceryProduct>[
    GroceryProduct(
      id: 'product-oats',
      nameDe: 'Haferflocken',
      nameAr: 'رقائق الشوفان',
      aisleDe: 'Frühstück & Müsli',
      aisleAr: 'قسم الفطور والحبوب',
      ingredientNoteDe:
          'Beispieldatensatz: Kennzeichnungen immer auf der aktuellen Packung prüfen.',
      ingredientNoteAr:
          'بيانات تعليمية: يجب دائمًا التحقق من العلامات على العبوة الحالية.',
      dietaryFlags: <GroceryDietFlag>{
        GroceryDietFlag.vegan,
        GroceryDietFlag.glutenFree,
      },
    ),
    GroceryProduct(
      id: 'product-milk',
      nameDe: 'Vollmilch',
      nameAr: 'حليب كامل الدسم',
      aisleDe: 'Kühlregal',
      aisleAr: 'الثلاجات',
      ingredientNoteDe: 'Milchprodukt; Zutaten- und Allergenhinweise prüfen.',
      ingredientNoteAr: 'منتج حليب؛ تحقق من المكونات وتحذيرات الحساسية.',
    ),
    GroceryProduct(
      id: 'product-cheese',
      nameDe: 'Gouda am Stück',
      nameAr: 'جبنة غودا قطعة كاملة',
      aisleDe: 'Kühlregal / Käsetheke',
      aisleAr: 'الثلاجات أو قسم الأجبان',
      ingredientNoteDe:
          'Bei loser Ware Zutaten und Allergene direkt an der Theke erfragen.',
      ingredientNoteAr:
          'عند شراء منتج غير معبأ اسأل موظف القسم مباشرة عن المكونات والحساسيات.',
    ),
  ];

  static const List<GroceryOffer> _defaultOffers = <GroceryOffer>[
    GroceryOffer(
      id: 'offer-oats',
      productId: 'product-oats',
      labelDe: 'Angebot: Haferflocken',
      labelAr: 'عرض: رقائق الشوفان',
      priceEuro: 1.49,
      unitLabel: '500 g',
    ),
    GroceryOffer(
      id: 'offer-milk',
      productId: 'product-milk',
      labelDe: 'Angebot: Vollmilch',
      labelAr: 'عرض: حليب كامل الدسم',
      priceEuro: 1.19,
      unitLabel: '1 l',
    ),
  ];

  static const Kassenbon _defaultReceipt = Kassenbon(
    id: 'receipt-example',
    lines: <ReceiptLine>[
      ReceiptLine(
        label: 'Haferflocken',
        quantity: 1,
        unitPriceEuro: 1.49,
      ),
      ReceiptLine(
        label: 'Vollmilch',
        quantity: 2,
        unitPriceEuro: 1.19,
      ),
    ],
  );
}

final class SupermarketGroceriesModule {
  const SupermarketGroceriesModule();

  List<SupermarketModuleRoute> get routes => const <SupermarketModuleRoute>[
        SupermarketModuleRoute(
          id: 'products-ingredients',
          labelDe: 'Produkte & Zutaten',
          labelAr: 'المنتجات والمكونات',
          relativePath: 'products',
        ),
        SupermarketModuleRoute(
          id: 'checkout-pfand',
          labelDe: 'Kasse & Pfand',
          labelAr: 'الصندوق واسترجاع العبوات',
          relativePath: 'checkout',
        ),
      ];

  SupermarketMasterOrchestrator createOrchestrator() =>
      SupermarketMasterOrchestrator();
}
