import 'car_service_models.dart';

final class AutoWorkshopSubAgent {
  const AutoWorkshopSubAgent();

  List<CarServicePhrase> get phrases => const <CarServicePhrase>[
        CarServicePhrase(
          id: 'workshop-appointment',
          mode: CarServiceMode.workshop,
          topic: CarServiceTopic.appointment,
          titleDe: 'Werkstatttermin vereinbaren',
          titleAr: 'حجز موعد في الورشة',
          german:
              'Ich möchte einen Werkstatttermin vereinbaren. Wann ist der nächste freie Termin?',
          arabic:
              'أريد حجز موعد في ورشة الصيانة. متى أقرب موعد متاح؟',
          keywords: <String>['Termin', 'Werkstatt', 'حجز', 'موعد'],
        ),
        CarServicePhrase(
          id: 'workshop-problem-description',
          mode: CarServiceMode.workshop,
          topic: CarServiceTopic.appointment,
          titleDe: 'Problem kurz beschreiben',
          titleAr: 'وصف المشكلة باختصار',
          german:
              'Seit gestern höre ich beim Bremsen ein ungewöhnliches Geräusch. Können Sie das prüfen?',
          arabic:
              'منذ الأمس أسمع صوتًا غير معتاد عند الفرملة. هل يمكنكم فحصه؟',
          keywords: <String>['Geräusch', 'Bremsen', 'فحص', 'صوت'],
        ),
        CarServicePhrase(
          id: 'workshop-estimate',
          mode: CarServiceMode.workshop,
          topic: CarServiceTopic.costEstimate,
          titleDe: 'Kostenvoranschlag anfragen',
          titleAr: 'طلب تقدير للتكلفة',
          german:
              'Könnten Sie mir bitte vor der Reparatur einen Kostenvoranschlag erstellen?',
          arabic:
              'هل يمكنكم إعداد تقدير للتكلفة قبل إجراء الإصلاح من فضلكم؟',
          keywords: <String>['Preis', 'Kosten', 'Angebot', 'تكلفة'],
        ),
        CarServicePhrase(
          id: 'workshop-estimate-approval',
          mode: CarServiceMode.workshop,
          topic: CarServiceTopic.costEstimate,
          titleDe: 'Zusätzliche Kosten abstimmen',
          titleAr: 'الاتفاق على التكاليف الإضافية',
          german:
              'Bitte informieren Sie mich, bevor zusätzliche Arbeiten durchgeführt werden.',
          arabic:
              'يرجى إبلاغي قبل تنفيذ أي أعمال إضافية.',
          keywords: <String>['zusätzliche Arbeiten', 'Freigabe', 'موافقة'],
        ),
        CarServicePhrase(
          id: 'workshop-oil',
          mode: CarServiceMode.workshop,
          topic: CarServiceTopic.oilChange,
          titleDe: 'Ölwechsel durchführen lassen',
          titleAr: 'طلب تغيير الزيت',
          german:
              'Ich möchte einen Ölwechsel nach den Vorgaben für mein Fahrzeug durchführen lassen.',
          arabic:
              'أريد إجراء تغيير للزيت وفق المواصفات المناسبة لسيارتي.',
          keywords: <String>['Motoröl', 'Ölfilter', 'زيت'],
        ),
        CarServicePhrase(
          id: 'workshop-brakes',
          mode: CarServiceMode.workshop,
          topic: CarServiceTopic.brakePads,
          titleDe: 'Bremsbeläge prüfen lassen',
          titleAr: 'طلب فحص بطانات الفرامل',
          german:
              'Bitte prüfen Sie die Bremsbeläge und sagen Sie mir, ob ein Austausch nötig ist.',
          arabic:
              'يرجى فحص بطانات الفرامل وإخباري إن كان استبدالها ضروريًا.',
          keywords: <String>['Bremsbeläge', 'Bremsen', 'استبدال', 'فرامل'],
        ),
        CarServicePhrase(
          id: 'workshop-tire-change',
          mode: CarServiceMode.workshop,
          topic: CarServiceTopic.tires,
          titleDe: 'Reifenwechsel buchen',
          titleAr: 'حجز تبديل الإطارات',
          german:
              'Ich möchte einen Termin für den Reifenwechsel vereinbaren.',
          arabic:
              'أريد حجز موعد لتبديل الإطارات.',
          keywords: <String>['Reifenwechsel', 'Winterreifen', 'Sommerreifen'],
        ),
        CarServicePhrase(
          id: 'workshop-tire-storage',
          mode: CarServiceMode.workshop,
          topic: CarServiceTopic.tires,
          titleDe: 'Reifen einlagern',
          titleAr: 'تخزين الإطارات',
          german:
              'Bieten Sie auch die Einlagerung meiner anderen Reifen an?',
          arabic:
              'هل توفرون أيضًا خدمة تخزين مجموعة الإطارات الأخرى؟',
          keywords: <String>['Einlagerung', 'Reifenhotel', 'تخزين'],
        ),
      ];
}
