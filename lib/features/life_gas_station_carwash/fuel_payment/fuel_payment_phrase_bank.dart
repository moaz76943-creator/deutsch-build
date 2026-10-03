import 'fuel_payment_models.dart';

abstract final class FuelPaymentPhraseBank {
  static const List<FuelPaymentPhrase> all = <FuelPaymentPhrase>[
    FuelPaymentPhrase(
      id: 'fuel-check-flap',
      topic: FuelPaymentTopic.fuelChoice,
      german:
          'Ich möchte sicher sein: Welcher Kraftstoff ist laut Tankdeckel und Fahrzeugangaben für dieses Auto freigegeben?',
      arabic:
          'أريد التأكد: ما نوع الوقود المسموح لهذه السيارة حسب غطاء الخزان وبيانات المركبة؟',
      contextDe: 'Freigabe vor dem Tanken prüfen',
      contextAr: 'التأكد من الوقود المسموح قبل التعبئة',
      keywords: <String>['Tankdeckel', 'Freigabe', 'Kraftstoff', 'وقود'],
    ),
    FuelPaymentPhrase(
      id: 'fuel-e5-e10',
      topic: FuelPaymentTopic.fuelChoice,
      german:
          'Mein Fahrzeug verträgt Benzin. Wie erkenne ich hier Super E5 und Super E10 eindeutig an der Zapfsäule?',
      arabic:
          'سيارتي تعمل بالبنزين. كيف أميز هنا بوضوح بين Super E5 وSuper E10 على المضخة؟',
      contextDe: 'Benzinsorten an der Kennzeichnung unterscheiden',
      contextAr: 'تمييز أنواع البنزين من العلامات',
      keywords: <String>['E5', 'E10', 'Super', 'Benzin', 'بنزين'],
    ),
    FuelPaymentPhrase(
      id: 'fuel-diesel',
      topic: FuelPaymentTopic.fuelChoice,
      german:
          'Wo ist hier die Dieselsäule, und welche Kennzeichnung soll ich mit meiner Fahrzeugfreigabe vergleichen?',
      arabic:
          'أين مضخة الديزل هنا، وما العلامة التي يجب مقارنتها بما هو مسموح لسيارتي؟',
      contextDe: 'Diesel nicht mit Benzin verwechseln',
      contextAr: 'تجنب الخلط بين الديزل والبنزين',
      keywords: <String>['Diesel', 'B7', 'Zapfsäule', 'ديزل'],
    ),
    FuelPaymentPhrase(
      id: 'fuel-uncertain',
      topic: FuelPaymentTopic.fuelChoice,
      german:
          'Ich bin beim Kraftstoff nicht sicher. Ich tanke erst, nachdem die Freigabe eindeutig geklärt ist.',
      arabic:
          'لست متأكدًا من نوع الوقود. لن أعبئ حتى أتأكد بشكل واضح من النوع المسموح.',
      contextDe: 'Bei Unsicherheit nicht auf Verdacht tanken',
      contextAr: 'عدم التخمين عند الشك بنوع الوقود',
      keywords: <String>['unsicher', 'nicht tanken', 'شك'],
    ),
    FuelPaymentPhrase(
      id: 'pump-start',
      topic: FuelPaymentTopic.pumpUse,
      german:
          'Muss ich diese Zapfsäule zuerst an der Kasse freischalten oder kann ich direkt tanken?',
      arabic:
          'هل يجب تفعيل هذه المضخة أولًا من الصندوق أم يمكنني التعبئة مباشرة؟',
      contextDe: 'Ablauf an der konkreten Station klären',
      contextAr: 'فهم خطوات المحطة المحددة',
      keywords: <String>['freischalten', 'Kasse', 'Zapfsäule', 'مضخة'],
    ),
    FuelPaymentPhrase(
      id: 'pump-number',
      topic: FuelPaymentTopic.pumpUse,
      german:
          'Ich habe an Zapfsäule Nummer sechs getankt. Brauchen Sie nur die Säulennummer zum Bezahlen?',
      arabic:
          'عبأت من المضخة رقم ستة. هل يكفي رقم المضخة للدفع؟',
      contextDe: 'Zapfsäule an der Kasse nennen',
      contextAr: 'ذكر رقم المضخة عند الدفع',
      keywords: <String>['Säulennummer', 'Nummer', 'Kasse', 'رقم'],
    ),
    FuelPaymentPhrase(
      id: 'pump-stop',
      topic: FuelPaymentTopic.pumpUse,
      german:
          'Die Zapfpistole hat automatisch abgeschaltet. Ich beende den Tankvorgang und hänge sie wieder sicher ein.',
      arabic:
          'مسدس التعبئة توقف تلقائيًا. أنهي التعبئة وأعيده إلى مكانه بأمان.',
      contextDe: 'Automatische Abschaltung respektieren',
      contextAr: 'احترام التوقف التلقائي للمضخة',
      keywords: <String>['Zapfpistole', 'abschalten', 'تعبئة'],
    ),
    FuelPaymentPhrase(
      id: 'payment-card',
      topic: FuelPaymentTopic.payment,
      german:
          'Kann ich den Betrag kontaktlos mit Karte bezahlen, oder muss ich die Karte einstecken?',
      arabic:
          'هل يمكنني دفع المبلغ بالبطاقة دون تلامس، أم يجب إدخال البطاقة؟',
      contextDe: 'Zahlungsart erfragen',
      contextAr: 'السؤال عن طريقة الدفع',
      keywords: <String>['Karte', 'kontaktlos', 'bezahlen', 'بطاقة'],
    ),
    FuelPaymentPhrase(
      id: 'payment-cash',
      topic: FuelPaymentTopic.payment,
      german:
          'Kann ich bar bezahlen, und ist die Zahlung für Zapfsäule sechs bereits im Kassensystem sichtbar?',
      arabic:
          'هل يمكنني الدفع نقدًا، وهل ظهرت عملية المضخة رقم ستة في نظام الصندوق؟',
      contextDe: 'Barzahlung eindeutig zuordnen',
      contextAr: 'ربط الدفع النقدي بالمضخة الصحيحة',
      keywords: <String>['bar', 'Kassensystem', 'نقد'],
    ),
    FuelPaymentPhrase(
      id: 'receipt',
      topic: FuelPaymentTopic.receiptHelp,
      german:
          'Ich brauche bitte einen Beleg mit Datum, Betrag und ausgewiesenem Kraftstoff.',
      arabic:
          'أحتاج إيصالًا يتضمن التاريخ والمبلغ ونوع الوقود الموضح.',
      contextDe: 'Kassenbeleg anfordern',
      contextAr: 'طلب إيصال واضح',
      keywords: <String>['Beleg', 'Quittung', 'Rechnung', 'فاتورة', 'إيصال'],
    ),
    FuelPaymentPhrase(
      id: 'wrong-pump-help',
      topic: FuelPaymentTopic.receiptHelp,
      german:
          'Ich glaube, ich habe die falsche Zapfsäule genannt. Können wir den Betrag bitte vor der Zahlung prüfen?',
      arabic:
          'أعتقد أنني ذكرت رقم مضخة خاطئًا. هل يمكننا التحقق من المبلغ قبل الدفع؟',
      contextDe: 'Zuordnung vor Zahlung korrigieren',
      contextAr: 'تصحيح رقم المضخة قبل الدفع',
      keywords: <String>['falsche Zapfsäule', 'prüfen', 'خطأ'],
    ),
    FuelPaymentPhrase(
      id: 'misfuel-stop',
      topic: FuelPaymentTopic.receiptHelp,
      german:
          'Ich vermute, dass falscher Kraftstoff eingefüllt wurde. Ich starte den Motor nicht und brauche sofort Hilfe.',
      arabic:
          'أشتبه في تعبئة وقود خاطئ. لن أشغل المحرك وأحتاج مساعدة فورًا.',
      contextDe: 'Fehlbetankung ohne Motorstart melden',
      contextAr: 'الإبلاغ عن الوقود الخاطئ دون تشغيل المحرك',
      keywords: <String>['Fehlbetankung', 'Motor nicht starten', 'وقود خاطئ'],
    ),
  ];
}
