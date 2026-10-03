import 'ordering_models.dart';

final class MenuOrderingAgent {
  const MenuOrderingAgent();

  List<OrderingPhrase> get phrases => _phrases;

  static const List<OrderingPhrase> _phrases = <OrderingPhrase>[
    OrderingPhrase(
      id: 'order-dish',
      stage: OrderingStage.menuOrdering,
      german: 'Ich nehme bitte die Gemüsepfanne.',
      arabic: 'سآخذ طبق الخضار، من فضلك.',
      contextDe: 'Ein Gericht bestellen',
      contextAr: 'طلب طبق من قائمة الطعام',
      keywords: <String>['bestellen', 'Gericht', 'Speisekarte'],
    ),
    OrderingPhrase(
      id: 'order-drink',
      stage: OrderingStage.menuOrdering,
      german: 'Für mich bitte ein Mineralwasser ohne Kohlensäure.',
      arabic: 'أريد ماءً معدنياً دون غاز، من فضلك.',
      contextDe: 'Ein Getränk genauer bestellen',
      contextAr: 'طلب مشروب مع تحديد النوع',
      keywords: <String>['Getränk', 'Mineralwasser', 'ohne Kohlensäure'],
    ),
    OrderingPhrase(
      id: 'order-ingredients',
      stage: OrderingStage.menuOrdering,
      german: 'Welche Zutaten sind in diesem Gericht enthalten?',
      arabic: 'ما المكونات الموجودة في هذا الطبق؟',
      contextDe: 'Nach Zutaten fragen',
      contextAr: 'الاستفسار عن مكونات الطبق',
      keywords: <String>['Zutaten', 'Inhalt', 'Gericht'],
    ),
    OrderingPhrase(
      id: 'order-daily-special',
      stage: OrderingStage.menuOrdering,
      german: 'Was ist heute das Tagesgericht?',
      arabic: 'ما طبق اليوم؟',
      contextDe: 'Nach dem Tagesgericht fragen',
      contextAr: 'السؤال عن طبق اليوم',
      keywords: <String>['Tagesgericht', 'Tagesangebot', 'heute'],
    ),
    OrderingPhrase(
      id: 'modify-no-sauce',
      stage: OrderingStage.menuOrdering,
      german: 'Könnte ich das bitte ohne Soße bekommen?',
      arabic: 'هل يمكنني الحصول عليه من دون صلصة، من فضلك؟',
      contextDe: 'Eine Mahlzeit ohne Soße bestellen',
      contextAr: 'طلب الوجبة دون صلصة',
      keywords: <String>['ohne Soße', 'ändern', 'Anpassung'],
    ),
    OrderingPhrase(
      id: 'modify-gluten-free',
      stage: OrderingStage.menuOrdering,
      german: 'Gibt es dieses Gericht auch glutenfrei?',
      arabic: 'هل يتوفر هذا الطبق أيضاً خالياً من الغلوتين؟',
      contextDe: 'Glutenfreie Option erfragen',
      contextAr: 'الاستفسار عن خيار خالٍ من الغلوتين',
      keywords: <String>['glutenfrei', 'Gluten', 'Allergie'],
    ),
    OrderingPhrase(
      id: 'modify-halal-question',
      stage: OrderingStage.menuOrdering,
      german: 'Ist das Fleisch halal, und wird es getrennt zubereitet?',
      arabic: 'هل اللحم حلال، وهل يتم تحضيره بشكل منفصل؟',
      contextDe: 'Halal-Eignung ausdrücklich erfragen, nicht voraussetzen',
      contextAr: 'الاستفسار صراحة عن الحلال وطريقة التحضير دون افتراض',
      keywords: <String>['halal', 'Fleisch', 'Zubereitung'],
    ),
  ];
}
