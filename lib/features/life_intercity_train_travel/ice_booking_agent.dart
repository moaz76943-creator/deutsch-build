import 'intercity_train_master_hub.dart';

final class IceBookingAgent {
  const IceBookingAgent();

  static const List<IntercityPhrase> entries = <IntercityPhrase>[
    IntercityPhrase(
      id: 'ice-connection',
      category: IntercityTravelCategory.iceBooking,
      topicDe: 'ICE-Verbindung buchen',
      topicAr: 'حجز رحلة ICE',
      german:
          'Ich möchte eine ICE-Verbindung von Frankfurt nach Berlin buchen. Welche Abfahrten sind an diesem Tag verfügbar?',
      arabic:
          'أريد حجز رحلة ICE من فرانكفورت إلى برلين. ما مواعيد الانطلاق المتاحة في ذلك اليوم؟',
      tags: <String>['ICE', 'Verbindung', 'Abfahrt', 'حجز', 'قطار'],
    ),
    IntercityPhrase(
      id: 'ice-fare',
      category: IntercityTravelCategory.iceBooking,
      topicDe: 'Flexpreis und Sparpreis vergleichen',
      topicAr: 'مقارنة أنواع الأسعار',
      german:
          'Können Sie mir bitte die Unterschiede bei Preis, Zugbindung und Umbuchung zwischen diesen Tarifen erklären?',
      arabic:
          'هل يمكنكم شرح الفروق في السعر والالتزام بقطار محدد وإمكانية تغيير الحجز بين هذه التعرفات؟',
      tags: <String>['Flexpreis', 'Sparpreis', 'Zugbindung', 'Tarif', 'سعر'],
    ),
    IntercityPhrase(
      id: 'ice-seat',
      category: IntercityTravelCategory.iceBooking,
      topicDe: 'Sitzplatz reservieren',
      topicAr: 'حجز مقعد',
      german:
          'Ich möchte einen Sitzplatz reservieren. Gibt es noch einen Fensterplatz in einem ruhigen Bereich?',
      arabic:
          'أريد حجز مقعد. هل يوجد مقعد بجانب النافذة في منطقة هادئة؟',
      tags: <String>['Sitzplatz', 'Reservierung', 'Fensterplatz', 'مقعد'],
    ),
    IntercityPhrase(
      id: 'ice-transfer',
      category: IntercityTravelCategory.iceBooking,
      topicDe: 'Umsteigezeit prüfen',
      topicAr: 'التحقق من وقت التبديل',
      german:
          'Reicht die geplante Umsteigezeit aus, und an welchem Bahnhof muss ich umsteigen?',
      arabic:
          'هل وقت التبديل المخطط كافٍ، وفي أي محطة يجب أن أبدّل القطار؟',
      tags: <String>['Umstieg', 'Umsteigezeit', 'Bahnhof', 'تبديل', 'محطة'],
    ),
    IntercityPhrase(
      id: 'ice-platform',
      category: IntercityTravelCategory.iceBooking,
      topicDe: 'Gleis finden',
      topicAr: 'معرفة الرصيف',
      german:
          'Von welchem Gleis fährt der ICE ab, und wo sehe ich kurzfristige Gleisänderungen?',
      arabic:
          'من أي رصيف ينطلق قطار ICE، وأين أرى تغييرات الرصيف التي تحدث في آخر لحظة؟',
      tags: <String>['Gleis', 'Gleisänderung', 'Abfahrt', 'رصيف'],
    ),
    IntercityPhrase(
      id: 'ice-ticket-check',
      category: IntercityTravelCategory.iceBooking,
      topicDe: 'Digitales Ticket',
      topicAr: 'التذكرة الرقمية',
      german:
          'Reicht das digitale Ticket in der App für die Kontrolle, oder muss ich zusätzlich etwas mitführen?',
      arabic:
          'هل تكفي التذكرة الرقمية في التطبيق عند التفتيش، أم يجب أن أحمل شيئاً إضافياً؟',
      tags: <String>['Digitales Ticket', 'Kontrolle', 'App', 'تذكرة'],
    ),
  ];
}
