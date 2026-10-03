import '../rent_housing_models.dart';

final class HouseRulesSubAgent {
  const HouseRulesSubAgent();

  List<RentHousingEntry> get entries => _entries;

  static const List<RentHousingEntry> _entries = <RentHousingEntry>[
    RentHousingEntry(
      id: 'rules-hausordnung',
      section: RentHousingSection.contractAndCosts,
      titleDe: 'Hausordnung prüfen',
      titleAr: 'مراجعة نظام البناء',
      german:
          'Wo finde ich die aktuelle Hausordnung, und welche Regeln gelten für dieses Gebäude?',
      arabic:
          'أين أجد النسخة الحالية من نظام البناء، وما القواعد التي تنطبق على هذا المبنى؟',
      contextDe: 'Die tatsächlich ausgehändigte oder ausgehängte Hausordnung prüfen',
      contextAr: 'الرجوع إلى نظام البناء الفعلي الذي تم تسليمه أو تعليقه',
      keywords: <String>['Hausordnung', 'Regeln', 'Gebäude', 'Mietvertrag'],
    ),
    RentHousingEntry(
      id: 'rules-ruhezeiten',
      section: RentHousingSection.contractAndCosts,
      titleDe: 'Ruhezeiten',
      titleAr: 'فترات الهدوء',
      german:
          'Welche Ruhezeiten stehen in unserer Hausordnung oder in meinem Mietvertrag?',
      arabic:
          'ما فترات الهدوء المذكورة في نظام البناء أو في عقد الإيجار الخاص بي؟',
      contextDe: 'Konkrete Gebäude- und Vertragsregeln prüfen, statt feste Zeiten zu unterstellen',
      contextAr: 'التحقق من قواعد المبنى والعقد بدل افتراض أوقات ثابتة للجميع',
      keywords: <String>['Ruhezeiten', 'Hausordnung', 'Nachtruhe', 'Lärm'],
    ),
    RentHousingEntry(
      id: 'rules-common-areas',
      section: RentHousingSection.contractAndCosts,
      titleDe: 'Gemeinschaftsflächen',
      titleAr: 'المساحات المشتركة',
      german:
          'Welche Regeln gelten für Treppenhaus, Keller und andere Gemeinschaftsflächen?',
      arabic:
          'ما القواعد المتعلقة بدرج المبنى والقبو وبقية المساحات المشتركة؟',
      contextDe: 'Nutzung gemeinsamer Flächen anhand der Hausordnung klären',
      contextAr: 'توضيح استخدام المساحات المشتركة بالرجوع إلى نظام البناء',
      keywords: <String>['Treppenhaus', 'Keller', 'Gemeinschaftsflächen', 'Hausordnung'],
    ),
  ];
}
