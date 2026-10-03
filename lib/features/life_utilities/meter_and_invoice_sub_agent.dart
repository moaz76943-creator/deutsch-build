import 'utilities_models.dart';

final class MeterAndInvoiceSubAgent {
  const MeterAndInvoiceSubAgent();

  List<UtilitiesPhrase> get phrases => _phrases;

  UtilitiesPhrase get quickMeterReadingGuide => _phrases[1];

  static const List<UtilitiesPhrase> _phrases = <UtilitiesPhrase>[
    UtilitiesPhrase(
      id: 'meter-identify-number',
      category: UtilitiesCategory.meterReadingsInvoices,
      german:
          'Wo finde ich die Zählernummer für meinen Strom- oder Gaszähler, und welche Nummer soll ich angeben?',
      arabic:
          'أين أجد رقم العداد للكهرباء أو الغاز، وأي رقم يجب أن أذكره؟',
      contextDe: 'Zählernummer sicher identifizieren',
      contextAr: 'تمييز رقم العداد الصحيح قبل إرسال أي بيانات',
      keywords: <String>[
        'Zählernummer',
        'Stromzähler',
        'Gaszähler',
        'Nummer',
        'رقم العداد',
      ],
    ),
    UtilitiesPhrase(
      id: 'meter-submit-reading',
      category: UtilitiesCategory.meterReadingsInvoices,
      german:
          'Ich möchte den Zählerstand melden. Die Zählernummer ist auf meinem Zähler angegeben.',
      arabic:
          'أريد إرسال قراءة العداد. رقم العداد مذكور على العداد لدي.',
      contextDe: 'Zählerstand melden',
      contextAr: 'إرسال قراءة العداد للكهرباء أو الغاز',
      keywords: <String>[
        'Zählerstand melden',
        'Zählerstand',
        'Ablesung',
        'ablesen',
        'قراءة العداد',
        'إرسال القراءة',
      ],
    ),
    UtilitiesPhrase(
      id: 'invoice-annual-settlement',
      category: UtilitiesCategory.meterReadingsInvoices,
      german:
          'Können Sie mir bitte erklären, warum ich bei der Jahresabrechnung eine Nachzahlung habe oder wie mein Guthaben verrechnet wird?',
      arabic:
          'هل يمكن أن تشرح لي لماذا لدي مبلغ إضافي مستحق في التسوية السنوية، أو كيف سيتم احتساب الرصيد الدائن؟',
      contextDe: 'Jahresabrechnung: Nachzahlung und Guthaben verstehen',
      contextAr: 'فهم التسوية السنوية والمبلغ المستحق أو الرصيد الدائن',
      keywords: <String>[
        'Jahresabrechnung',
        'Nachzahlung',
        'Guthaben',
        'Abrechnung',
        'فاتورة سنوية',
        'رصيد',
      ],
    ),
    UtilitiesPhrase(
      id: 'invoice-adjust-payment',
      category: UtilitiesCategory.meterReadingsInvoices,
      german:
          'Kann ich meinen monatlichen Abschlag an den aktuellen Verbrauch anpassen?',
      arabic:
          'هل يمكنني تعديل الدفعة الشهرية لتتناسب مع الاستهلاك الحالي؟',
      contextDe: 'Monatlichen Abschlag anpassen',
      contextAr: 'تعديل الدفعة الشهرية حسب الاستهلاك',
      keywords: <String>[
        'Abschlag',
        'monatlicher Abschlag',
        'Verbrauch',
        'anpassen',
        'دفعة شهرية',
        'استهلاك',
      ],
    ),
  ];
}
