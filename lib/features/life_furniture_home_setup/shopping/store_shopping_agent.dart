import 'shopping_models.dart';

final class FurnitureStoreShoppingAgent {
  const FurnitureStoreShoppingAgent();

  List<FurnitureShoppingScenario> get scenarios => _scenarios;

  static const List<FurnitureShoppingScenario> _scenarios =
      <FurnitureShoppingScenario>[
    FurnitureShoppingScenario(
      id: 'ask-dimensions',
      service: FurnitureService.store,
      titleDe: 'Maße prüfen',
      titleAr: 'الاستفسار عن القياسات',
      german:
          'Wie sind die Maße genau? Ich brauche Höhe, Breite und Tiefe in Zentimetern.',
      arabic:
          'ما القياسات بالضبط؟ أحتاج الارتفاع والعرض والعمق بالسنتيمتر.',
      keywords: <String>['Maße', 'Höhe', 'Breite', 'Tiefe', 'Zentimeter'],
    ),
    FurnitureShoppingScenario(
      id: 'warehouse-stock',
      service: FurnitureService.store,
      titleDe: 'Lagerbestand prüfen',
      titleAr: 'التحقق من توفر القطعة',
      german:
          'Ist dieser Artikel heute im Lager verfügbar, oder muss ich ihn bestellen?',
      arabic:
          'هل هذه القطعة متوفرة اليوم في المستودع أم يجب أن أطلبها؟',
      keywords: <String>['Lager', 'verfügbar', 'Bestand', 'bestellen'],
    ),
    FurnitureShoppingScenario(
      id: 'reserve-item',
      service: FurnitureService.store,
      titleDe: 'Artikel reservieren',
      titleAr: 'حجز القطعة',
      german:
          'Können Sie den Artikel bitte bis heute Abend für mich reservieren?',
      arabic: 'هل يمكنكم حجز القطعة لي حتى هذا المساء؟',
      keywords: <String>['reservieren', 'Abholung', 'Artikel'],
    ),
  ];
}
