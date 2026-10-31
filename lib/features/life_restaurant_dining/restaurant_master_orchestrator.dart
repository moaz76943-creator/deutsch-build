import 'package:flutter/foundation.dart';

import 'restaurant_models.dart';

final class RestaurantDiningDependencyFactory {
  const RestaurantDiningDependencyFactory();

  RestaurantDiningMasterOrchestrator create() =>
      RestaurantDiningMasterOrchestrator();
}

final class RestaurantDiningMasterOrchestrator extends ChangeNotifier {
  DiningVenueType _venue = DiningVenueType.restaurant;
  MealOption? _mealOption;
  String _query = '';

  DiningVenueType get venue => _venue;
  MealOption? get mealOption => _mealOption;
  String get query => _query;

  List<RestaurantMenuItem> get visibleMenu => List<RestaurantMenuItem>.unmodifiable(
        _menu.where(
          (item) =>
              item.matches(_query) &&
              (_mealOption == null || item.options.contains(_mealOption)),
        ),
      );

  List<BillTipPhrase> get billTipPhrases => _billTipPhrases;

  void setVenue(DiningVenueType value) {
    if (_venue == value) return;
    _venue = value;
    notifyListeners();
  }

  void setMealOption(MealOption? value) {
    if (_mealOption == value) return;
    _mealOption = value;
    notifyListeners();
  }

  void setQuery(String value) {
    if (_query == value) return;
    _query = value;
    notifyListeners();
  }

  void clearSearch() => setQuery('');

  static const List<RestaurantMenuItem> _menu = <RestaurantMenuItem>[
    RestaurantMenuItem(
      id: 'menu-tomato-soup',
      nameDe: 'Tomatensuppe',
      nameAr: 'شوربة الطماطم',
      descriptionDe: 'Beispiel für einen Eintrag auf der Speisekarte.',
      descriptionAr: 'مثال على بند في قائمة الطعام.',
      options: <MealOption>{
        MealOption.vegetarian,
        MealOption.glutenFree,
      },
      keywords: <String>['Suppe', 'Speisekarte', 'Vorspeise'],
    ),
    RestaurantMenuItem(
      id: 'menu-vegetable-bowl',
      nameDe: 'Gemüse-Bowl',
      nameAr: 'طبق خضار',
      descriptionDe: 'Beispiel für eine pflanzliche Mahlzeit.',
      descriptionAr: 'مثال على وجبة نباتية.',
      options: <MealOption>{
        MealOption.vegetarian,
        MealOption.vegan,
        MealOption.glutenFree,
      },
      keywords: <String>['Gemüse', 'Bowl', 'vegan'],
    ),
    RestaurantMenuItem(
      id: 'menu-grilled-chicken',
      nameDe: 'Gegrilltes Hähnchen',
      nameAr: 'دجاج مشوي',
      descriptionDe:
          'Bei Halal-Anforderungen immer ausdrücklich nach Herkunft und Zubereitung fragen.',
      descriptionAr:
          'عند طلب الحلال يجب الاستفسار صراحة عن المصدر وطريقة التحضير.',
      options: <MealOption>{MealOption.halalRequested},
      keywords: <String>['Hähnchen', 'halal', 'Fleisch'],
    ),
  ];

  static const List<BillTipPhrase> _billTipPhrases = <BillTipPhrase>[
    BillTipPhrase(
      id: 'bill-together',
      german: 'Wir möchten zusammen bezahlen, bitte.',
      arabic: 'نود الدفع معاً، من فضلك.',
      contextDe: 'Rechnung gemeinsam bezahlen',
      splitMode: BillSplitMode.together,
    ),
    BillTipPhrase(
      id: 'bill-separate',
      german: 'Wir möchten getrennt bezahlen, bitte.',
      arabic: 'نود الدفع بشكل منفصل، من فضلك.',
      contextDe: 'Rechnung getrennt bezahlen',
      splitMode: BillSplitMode.separate,
    ),
    BillTipPhrase(
      id: 'tip-stimmt-so',
      german: 'Stimmt so, danke.',
      arabic: 'الباقي لك، شكراً.',
      contextDe: 'Einen Endbetrag inklusive Trinkgeld bestätigen',
    ),
  ];
}
