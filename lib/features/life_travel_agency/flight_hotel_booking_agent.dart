import 'travel_agency_master_hub.dart';

final class FlightHotelBookingAgent {
  const FlightHotelBookingAgent();

  static const List<TravelAgencyPhrase> entries = <TravelAgencyPhrase>[
    TravelAgencyPhrase(
      id: 'flight-round-trip',
      category: TravelAgencyCategory.flights,
      topicDe: 'Hin- und Rückflug buchen',
      topicAr: 'حجز ذهاب وعودة',
      german:
          'Ich möchte einen Hin- und Rückflug nach Berlin buchen. Welche Tarife sind an meinen Reisedaten verfügbar?',
      arabic:
          'أريد حجز رحلة ذهاب وعودة إلى برلين. ما الأسعار المتاحة في تواريخ سفري؟',
      tags: <String>['Flug', 'Hinflug', 'Rückflug', 'Tarif', 'طيران', 'حجز'],
    ),
    TravelAgencyPhrase(
      id: 'flight-baggage',
      category: TravelAgencyCategory.flights,
      topicDe: 'Gepäck im Tarif',
      topicAr: 'الأمتعة ضمن السعر',
      german:
          'Ist aufgegebenes Gepäck in diesem Tarif enthalten, und wie hoch ist die Freigepäckgrenze?',
      arabic:
          'هل الأمتعة المشحونة مشمولة في هذا السعر، وما الحد المسموح للوزن؟',
      tags: <String>['Gepäck', 'Freigepäck', 'Tarif', 'أمتعة', 'وزن'],
    ),
    TravelAgencyPhrase(
      id: 'flight-change-rules',
      category: TravelAgencyCategory.flights,
      topicDe: 'Umbuchung und Stornierung',
      topicAr: 'تغيير الحجز والإلغاء',
      german:
          'Welche Bedingungen und Gebühren gelten, wenn ich den Flug umbuchen oder stornieren muss?',
      arabic:
          'ما الشروط والرسوم إذا اضطررت لتغيير الرحلة أو إلغائها؟',
      tags: <String>['Umbuchung', 'Stornierung', 'Gebühren', 'تغيير', 'إلغاء'],
    ),
    TravelAgencyPhrase(
      id: 'hotel-family-room',
      category: TravelAgencyCategory.hotels,
      topicDe: 'Familienzimmer reservieren',
      topicAr: 'حجز غرفة عائلية',
      german:
          'Ich suche ein Familienzimmer für vier Personen. Ist Frühstück im Zimmerpreis enthalten?',
      arabic:
          'أبحث عن غرفة عائلية لأربعة أشخاص. هل الإفطار مشمول في سعر الغرفة؟',
      tags: <String>['Familienzimmer', 'Frühstück', 'Hotel', 'غرفة', 'فندق'],
    ),
    TravelAgencyPhrase(
      id: 'hotel-checkin',
      category: TravelAgencyCategory.hotels,
      topicDe: 'Check-in und späte Anreise',
      topicAr: 'تسجيل الدخول والوصول المتأخر',
      german:
          'Bis wann ist der Check-in möglich, und kann ich eine späte Anreise verbindlich anmelden?',
      arabic:
          'حتى أي وقت يمكن تسجيل الدخول، وهل يمكن تسجيل وصول متأخر بشكل مؤكد؟',
      tags: <String>['Check-in', 'Anreise', 'spät', 'وصول', 'تسجيل الدخول'],
    ),
    TravelAgencyPhrase(
      id: 'hotel-cancellation',
      category: TravelAgencyCategory.hotels,
      topicDe: 'Hotel kostenlos stornieren',
      topicAr: 'إلغاء الفندق',
      german:
          'Bis zu welchem Datum kann ich diese Hotelbuchung kostenfrei stornieren?',
      arabic:
          'حتى أي تاريخ يمكنني إلغاء حجز الفندق دون رسوم؟',
      tags: <String>['Hotelbuchung', 'kostenfrei', 'stornieren', 'إلغاء', 'فندق'],
    ),
  ];
}
