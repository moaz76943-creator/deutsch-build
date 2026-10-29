import '../postal_models.dart';
import 'packstation_models.dart';

final class PackstationSubAgent {
  const PackstationSubAgent();

  List<PackstationPhrase> get phrases => _phrases;

  static const List<PackstationPhrase> _phrases = <PackstationPhrase>[
    PackstationPhrase(
      id: 'packstation-scan-barcode',
      scenario: PackstationScenario.packstation,
      german:
          'Ich möchte meine Sendung an der Packstation abholen. Wo scanne ich den Barcode?',
      arabic:
          'أريد استلام شحنتي من ماكينة Packstation. أين أمسح الباركود؟',
      contextDe: 'Schritt 1: Barcode an der Packstation scannen',
      contextAr: 'الخطوة 1: مسح الباركود على ماكينة الطرود',
      carriers: <PostalCarrier>[PostalCarrier.dhl],
      keywords: <String>[
        'Packstation',
        'Barcode',
        'scannen',
        'Abholung',
      ],
    ),
    PackstationPhrase(
      id: 'packstation-enter-code',
      scenario: PackstationScenario.packstation,
      german:
          'Der Barcode wurde erkannt. Wo gebe ich jetzt den Abholcode ein?',
      arabic:
          'تم التعرف على الباركود. أين أدخل الآن رمز الاستلام؟',
      contextDe: 'Schritt 2: Abholcode eingeben',
      contextAr: 'الخطوة 2: إدخال رمز الاستلام',
      carriers: <PostalCarrier>[PostalCarrier.dhl],
      keywords: <String>[
        'Abholcode',
        'Code',
        'eingeben',
        'Packstation',
      ],
    ),
    PackstationPhrase(
      id: 'packstation-open-locker',
      scenario: PackstationScenario.packstation,
      german:
          'Welches Fach ist für meine Sendung geöffnet, und wie schließe ich es danach wieder?',
      arabic:
          'أي خزانة فُتحت لشحنتي، وكيف أغلقها بعد ذلك؟',
      contextDe: 'Schritt 3: Fach öffnen, Sendung entnehmen und schließen',
      contextAr: 'الخطوة 3: فتح الخزانة وأخذ الشحنة ثم إغلاقها',
      carriers: <PostalCarrier>[PostalCarrier.dhl],
      keywords: <String>[
        'Fach',
        'öffnen',
        'Schließfach',
        'entnehmen',
      ],
    ),
    PackstationPhrase(
      id: 'delivery-neighbor',
      scenario: PackstationScenario.deliveryProblems,
      german:
          'In der Sendungsverfolgung steht „Beim Nachbarn abgegeben“. Bei welchem Nachbarn wurde das Paket hinterlegt?',
      arabic:
          'يظهر في التتبع أن الطرد سُلّم إلى أحد الجيران. لدى أي جار تم ترك الطرد؟',
      contextDe: 'Nachfragen, wenn die Sendung beim Nachbarn abgegeben wurde',
      contextAr: 'الاستفسار عندما تكون الشحنة قد تُركت لدى أحد الجيران',
      carriers: <PostalCarrier>[
        PostalCarrier.dhl,
        PostalCarrier.hermes,
        PostalCarrier.deutschePost,
      ],
      keywords: <String>[
        'Beim Nachbarn abgegeben',
        'Nachbarn',
        'hinterlegt',
        'Sendungsverfolgung',
      ],
    ),
    PackstationPhrase(
      id: 'delivery-loss',
      scenario: PackstationScenario.deliveryProblems,
      german:
          'Meine Sendung ist laut Tracking zugestellt, aber nicht auffindbar. Wie melde ich einen möglichen Sendungsverlust?',
      arabic:
          'يظهر في التتبع أن الشحنة تم تسليمها، لكنني لا أجدها. كيف أبلغ عن احتمال فقدان الشحنة؟',
      contextDe: 'Möglichen Sendungsverlust melden und nächste Schritte klären',
      contextAr: 'الإبلاغ عن احتمال فقدان الشحنة والاستفسار عن الخطوات التالية',
      carriers: <PostalCarrier>[
        PostalCarrier.dhl,
        PostalCarrier.hermes,
        PostalCarrier.deutschePost,
      ],
      keywords: <String>[
        'Sendungsverlust',
        'verloren',
        'nicht auffindbar',
        'zugestellt',
        'Tracking',
      ],
    ),
    PackstationPhrase(
      id: 'return-free-label',
      scenario: PackstationScenario.deliveryProblems,
      german:
          'Ich möchte diese Online-Bestellung zurückschicken. Wo finde oder drucke ich den kostenlosen Retourenschein?',
      arabic:
          'أريد إرجاع هذا الطلب الإلكتروني. أين أجد أو أطبع ملصق الإرجاع المجاني؟',
      contextDe: 'Online-Bestellung mit Retourenschein zurücksenden',
      contextAr: 'إرجاع مشتريات الإنترنت باستخدام ملصق الإرجاع',
      carriers: <PostalCarrier>[
        PostalCarrier.dhl,
        PostalCarrier.hermes,
      ],
      keywords: <String>[
        'Retourenschein',
        'Retoure',
        'Rücksendung',
        'kostenlos',
        'Online-Bestellung',
        'إرجاع',
      ],
    ),
    PackstationPhrase(
      id: 'return-dropoff',
      scenario: PackstationScenario.deliveryProblems,
      german:
          'Ist der Retourenschein schon bezahlt, und kann ich die Rücksendung hier direkt abgeben?',
      arabic:
          'هل ملصق الإرجاع مدفوع مسبقًا، وهل يمكنني تسليم الشحنة المرتجعة هنا مباشرة؟',
      contextDe: 'Vor der Retoure Label und Abgabeort prüfen',
      contextAr: 'التأكد من الملصق ومكان تسليم المرتجع قبل الإرسال',
      carriers: <PostalCarrier>[
        PostalCarrier.dhl,
        PostalCarrier.hermes,
      ],
      keywords: <String>[
        'Retoure',
        'bezahlt',
        'Abgabe',
        'Rücksendung',
      ],
    ),
  ];
}
