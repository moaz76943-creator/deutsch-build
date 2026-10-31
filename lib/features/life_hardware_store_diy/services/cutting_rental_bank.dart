import '../../life_diy/diy_models.dart';

abstract final class CuttingRentalBank {
  static const List<DiyPhrase> phrases = <DiyPhrase>[
    DiyPhrase(
      id: 'services-cut-exact-size',
      domain: DiyDomain.servicesRental,
      german:
          'Ich möchte den Holzzuschnitt nutzen. Bitte schneiden Sie diese Platte auf 1200 × 600 mm.',
      arabic:
          'أريد استخدام خدمة قص الخشب. يرجى قص هذا اللوح إلى 1200 × 600 مم.',
      contextDe: 'Holzzuschnitt mit exakten Maßen bestellen',
      contextAr: 'طلب قص الخشب مع ذكر المقاسات الدقيقة بوضوح',
      keywords: <String>['Holzzuschnitt', '1200 × 600 mm', 'Platte', 'Maß'],
    ),
    DiyPhrase(
      id: 'services-cut-tolerance',
      domain: DiyDomain.servicesRental,
      german:
          'Welche Zuschnitttoleranz gilt, und messen Sie das Fertigmaß vor der Übergabe noch einmal?',
      arabic:
          'ما مقدار سماحية القص، وهل يمكن قياس المقاس النهائي مرة أخرى قبل التسليم؟',
      contextDe: 'Toleranz und Endmaß vor dem Zuschnitt klären',
      contextAr: 'تأكيد سماحية القص والمقاس النهائي قبل استلام القطعة',
      keywords: <String>['Zuschnitttoleranz', 'Fertigmaß', 'Übergabe', 'Messen'],
    ),
    DiyPhrase(
      id: 'services-rental-floor-sander',
      domain: DiyDomain.servicesRental,
      german:
          'Ich möchte eine Bodenschleifmaschine mieten. Welche Einweisung und Schutzausrüstung sind vorgesehen?',
      arabic:
          'أريد استئجار آلة جلي أرضيات. ما الإرشادات ومعدات الحماية المقررة للاستخدام؟',
      contextDe: 'Großgerät mit Einweisung und Schutzanforderungen mieten',
      contextAr: 'استئجار جهاز كبير مع السؤال عن الإرشادات ومتطلبات الحماية',
      keywords: <String>['Bodenschleifmaschine', 'Mietgerät', 'Einweisung', 'Schutzausrüstung'],
    ),
    DiyPhrase(
      id: 'services-rental-drill-hammer',
      domain: DiyDomain.servicesRental,
      german:
          'Welcher Bohrhammer ist für mein Vorhaben geeignet, und welches Zubehör gehört zum Mietgerät?',
      arabic:
          'أي مطرقة حفر مناسبة للمهمة، وما الملحقات المشمولة مع الجهاز المستأجر؟',
      contextDe: 'Bohrhammer und enthaltenes Zubehör auswählen',
      contextAr: 'اختيار مطرقة الحفر والسؤال عن الملحقات المشمولة',
      keywords: <String>['Bohrhammer', 'Mietgerät', 'Zubehör', 'mieten'],
    ),
    DiyPhrase(
      id: 'services-rental-deposit',
      domain: DiyDomain.servicesRental,
      german:
          'Wie hoch ist die Kaution, welche Zahlungsart ist möglich, und wann wird sie nach der Rückgabe freigegeben?',
      arabic:
          'كم قيمة الوديعة، وما طريقة الدفع الممكنة، ومتى يتم تحريرها بعد إعادة الجهاز؟',
      contextDe: 'Kaution und Rückerstattung vor Vertragsabschluss klären',
      contextAr: 'توضيح مبلغ الوديعة واستردادها قبل إتمام عقد التأجير',
      keywords: <String>['Kaution', 'الوديعة', 'Zahlungsart', 'Rückgabe'],
    ),
    DiyPhrase(
      id: 'services-rental-return',
      domain: DiyDomain.servicesRental,
      german:
          'Bis wann muss ich das Gerät zurückgeben, in welchem Zustand, und was passiert bei verspäteter Rückgabe?',
      arabic:
          'حتى أي وقت يجب إعادة الجهاز، وبأي حالة، وما الذي يحدث عند التأخر في الإرجاع؟',
      contextDe: 'Rückgabezeit, Zustand und verspätete Rückgabe klären',
      contextAr: 'تأكيد وقت الإرجاع وحالة الجهاز وشروط التأخر',
      keywords: <String>['Rückgabe', 'Zustand', 'verspätet', 'Mietbedingungen'],
    ),
  ];
}
