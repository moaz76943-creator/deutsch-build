import 'shopping_models.dart';

final class DeliveryTransportAgent {
  const DeliveryTransportAgent();

  List<FurnitureShoppingScenario> get scenarios => _scenarios;

  static const List<FurnitureShoppingScenario> _scenarios =
      <FurnitureShoppingScenario>[
    FurnitureShoppingScenario(
      id: 'delivery-curbside',
      service: FurnitureService.curbside,
      titleDe: 'Bis zur Bordsteinkante',
      titleAr: 'التوصيل حتى الرصيف',
      german:
          'Ist die Lieferung bis zur Bordsteinkante im Preis enthalten?',
      arabic: 'هل التوصيل حتى الرصيف مشمول في السعر؟',
      keywords: <String>['Bordsteinkante', 'Lieferung', 'Preis'],
    ),
    FurnitureShoppingScenario(
      id: 'delivery-apartment',
      service: FurnitureService.apartment,
      titleDe: 'Bis in die Wohnung',
      titleAr: 'التوصيل إلى داخل الشقة',
      german:
          'Was kostet die Lieferung bis in die Wohnung, und tragen Sie die Möbel bis in den dritten Stock?',
      arabic:
          'كم تكلفة التوصيل إلى داخل الشقة، وهل تنقلون الأثاث حتى الطابق الثالث؟',
      keywords: <String>['Wohnung', 'Stock', 'tragen', 'Aufzug'],
    ),
    FurnitureShoppingScenario(
      id: 'rent-transporter-license',
      service: FurnitureService.transporter,
      titleDe: 'Transporter und Führerschein',
      titleAr: 'استئجار سيارة النقل والرخصة',
      german:
          'Kann ich hier einen Transporter mieten? Welchen Führerschein und welche Kaution brauche ich?',
      arabic:
          'هل يمكنني استئجار سيارة نقل صغيرة هنا؟ ما فئة رخصة القيادة وما مبلغ التأمين المطلوب؟',
      keywords: <String>[
        'Transporter',
        'mieten',
        'Führerschein',
        'Kaution',
      ],
    ),
    FurnitureShoppingScenario(
      id: 'rent-transporter-return',
      service: FurnitureService.transporter,
      titleDe: 'Rückgabe klären',
      titleAr: 'شروط إعادة سيارة النقل',
      german:
          'Bis wann muss ich den Transporter zurückbringen, und muss der Tank voll sein?',
      arabic:
          'حتى متى يجب أن أعيد سيارة النقل، وهل يجب أن يكون خزان الوقود ممتلئًا؟',
      keywords: <String>['Rückgabe', 'Tank', 'zurückbringen'],
    ),
  ];
}
