import 'travel_agency_master_hub.dart';

final class HolidayPackageAgent {
  const HolidayPackageAgent();

  static const List<TravelAgencyPhrase> entries = <TravelAgencyPhrase>[
    TravelAgencyPhrase(
      id: 'holiday-package',
      category: TravelAgencyCategory.holidays,
      topicDe: 'Pauschalreise anfragen',
      topicAr: 'الاستفسار عن باقة عطلة',
      german:
          'Ich suche eine Pauschalreise für eine Woche. Welche Leistungen sind im Gesamtpreis enthalten?',
      arabic:
          'أبحث عن باقة عطلة لمدة أسبوع. ما الخدمات المشمولة في السعر الإجمالي؟',
      tags: <String>['Pauschalreise', 'Leistungen', 'Gesamtpreis', 'عطلة', 'باقة'],
    ),
    TravelAgencyPhrase(
      id: 'holiday-board',
      category: TravelAgencyCategory.holidays,
      topicDe: 'Verpflegung vergleichen',
      topicAr: 'مقارنة نظام الوجبات',
      german:
          'Können Sie mir bitte den Unterschied zwischen Halbpension und All-inclusive bei diesem Angebot erklären?',
      arabic:
          'هل يمكنكم شرح الفرق بين نصف الإقامة الشاملة ونظام شامل كلياً في هذا العرض؟',
      tags: <String>['Halbpension', 'All-inclusive', 'Verpflegung', 'وجبات'],
    ),
    TravelAgencyPhrase(
      id: 'holiday-transfer',
      category: TravelAgencyCategory.holidays,
      topicDe: 'Flughafentransfer',
      topicAr: 'النقل من وإلى المطار',
      german:
          'Ist der Transfer vom Flughafen zum Hotel im Reisepaket enthalten?',
      arabic:
          'هل النقل من المطار إلى الفندق مشمول في باقة السفر؟',
      tags: <String>['Transfer', 'Flughafen', 'Hotel', 'نقل', 'مطار'],
    ),
    TravelAgencyPhrase(
      id: 'holiday-child-price',
      category: TravelAgencyCategory.holidays,
      topicDe: 'Kinderpreis',
      topicAr: 'سعر الطفل',
      german:
          'Gibt es für Kinder einen ermäßigten Reisepreis, und welche Altersgrenzen gelten?',
      arabic:
          'هل يوجد سعر مخفض للأطفال، وما حدود الأعمار المعتمدة؟',
      tags: <String>['Kinderpreis', 'Ermäßigung', 'Alter', 'طفل', 'خصم'],
    ),
    TravelAgencyPhrase(
      id: 'holiday-insurance',
      category: TravelAgencyCategory.holidays,
      topicDe: 'Reiserücktrittsschutz',
      topicAr: 'تأمين إلغاء الرحلة',
      german:
          'Welche Fälle deckt die angebotene Reiserücktrittsversicherung ab, und welche Ausschlüsse gibt es?',
      arabic:
          'ما الحالات التي يغطيها تأمين إلغاء الرحلة المعروض، وما الاستثناءات؟',
      tags: <String>['Reiserücktritt', 'Versicherung', 'Ausschlüsse', 'تأمين'],
    ),
    TravelAgencyPhrase(
      id: 'holiday-documents',
      category: TravelAgencyCategory.holidays,
      topicDe: 'Reiseunterlagen',
      topicAr: 'وثائق السفر',
      german:
          'Wann erhalte ich die vollständigen Reiseunterlagen und die Kontaktdaten des Veranstalters?',
      arabic:
          'متى سأحصل على وثائق السفر الكاملة وبيانات التواصل مع منظم الرحلة؟',
      tags: <String>['Reiseunterlagen', 'Veranstalter', 'Dokumente', 'وثائق'],
    ),
  ];
}
