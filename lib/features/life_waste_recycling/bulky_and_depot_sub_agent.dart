import 'waste_models.dart';

final class BulkyAndDepotSubAgent {
  const BulkyAndDepotSubAgent();

  List<WastePhrase> get phrases => _phrases;

  static const List<WastePhrase> _phrases = <WastePhrase>[
    WastePhrase(
      id: 'bulky-pickup-request',
      category: WasteCategory.bulkyWasteDepot,
      german:
          'Ich möchte Sperrmüll beantragen. Wie vereinbare ich einen Abholtermin bei der Stadt?',
      arabic:
          'أريد طلب جمع النفايات كبيرة الحجم. كيف أحجز موعد الاستلام مع البلدية؟',
      contextDe: 'Kommunale Sperrmüllabholung beantragen',
      contextAr: 'طلب موعد رسمي لجمع النفايات كبيرة الحجم',
      keywords: <String>[
        'Sperrmüll',
        'beantragen',
        'Abholtermin',
        'Abholung',
        'Stadt',
      ],
    ),
    WastePhrase(
      id: 'bulky-pickup-rules',
      category: WasteCategory.bulkyWasteDepot,
      german:
          'Welche Gegenstände darf ich zum Sperrmüll stellen, ab wann dürfen sie bereitstehen und welche Mengen gelten hier?',
      arabic:
          'ما الأشياء التي يسمح بوضعها للنفايات كبيرة الحجم، ومتى يمكن إخراجها، وما الكمية المسموح بها هنا؟',
      contextDe: 'Bereitstellung und lokale Sperrmüllgrenzen klären',
      contextAr: 'التأكد من قواعد الإخراج والكمية محلياً',
      keywords: <String>[
        'Sperrmüllregeln',
        'Menge',
        'bereitstellen',
        'Straße',
        'Gehweg',
      ],
    ),
    WastePhrase(
      id: 'depot-hazardous-batteries',
      category: WasteCategory.bulkyWasteDepot,
      german:
          'Wo kann ich Batterien, Akkus oder andere problematische Stoffe sicher abgeben? Gibt es eine Sammelstelle oder ein Schadstoffmobil?',
      arabic:
          'أين يمكنني تسليم البطاريات أو المواد الخطرة بأمان؟ هل توجد نقطة تجميع أو مركبة مخصصة للمواد الخطرة؟',
      contextDe: 'Sondermüll und Batterien getrennt abgeben',
      contextAr: 'تسليم البطاريات والمواد الخطرة عبر مسار مخصص',
      keywords: <String>[
        'Sondermüll',
        'Batterien',
        'Akkus',
        'Schadstoffmobil',
        'Sammelstelle',
      ],
    ),
    WastePhrase(
      id: 'depot-visit-rules',
      category: WasteCategory.bulkyWasteDepot,
      german:
          'Was darf ich zum Wertstoffhof bringen, welche Öffnungszeiten gelten und brauche ich einen Nachweis oder muss ich Gebühren beachten?',
      arabic:
          'ما الذي يمكنني إحضاره إلى مركز التدوير، وما ساعات العمل، وهل أحتاج إثباتاً أو توجد رسوم يجب الانتباه لها؟',
      contextDe: 'Besuch am Wertstoffhof vorbereiten',
      contextAr: 'الاستعداد لزيارة مركز إعادة التدوير وفق القواعد المحلية',
      keywords: <String>[
        'Wertstoffhof',
        'Recyclinghof',
        'Öffnungszeiten',
        'Nachweis',
        'Gebühren',
      ],
    ),
    WastePhrase(
      id: 'depot-electronics',
      category: WasteCategory.bulkyWasteDepot,
      german:
          'Kann ich dieses alte Elektrogerät hier abgeben, oder gibt es dafür eine andere Rücknahmestelle?',
      arabic:
          'هل يمكنني تسليم هذا الجهاز الكهربائي القديم هنا، أم توجد نقطة استرجاع أخرى مخصصة له؟',
      contextDe: 'Elektroaltgeräte über den passenden Rückgabeweg entsorgen',
      contextAr: 'التأكد من مسار تسليم الأجهزة الكهربائية القديمة',
      keywords: <String>[
        'Elektrogerät',
        'Elektroschrott',
        'Rücknahmestelle',
        'E-Schrott',
      ],
    ),
  ];
}
