import 'secondhand_models.dart';

final class FleaMarketAndAdsSubAgent {
  const FleaMarketAndAdsSubAgent();

  List<SecondhandEntry> get entries => _entries;

  static const List<SecondhandEntry> _entries = <SecondhandEntry>[
    SecondhandEntry(
      id: 'flea-market-stall',
      domain: SecondhandDomain.fleaMarketsAndAds,
      titleDe: 'Flohmarktstand reservieren',
      titleAr: 'حجز طاولة في سوق المستعمل',
      german:
          'Ich möchte für Samstag einen Stand reservieren. Wie hoch ist die Standgebühr, und darf ich einen Tapeziertisch mitbringen?',
      arabic:
          'أريد حجز مكان ليوم السبت. كم رسوم الطاولة، وهل يمكنني إحضار طاولة ورق جدران قابلة للطي؟',
      contextDe:
          'Nach Standgebühr, Aufbauzeit und erlaubter Tischgröße fragen',
      contextAr:
          'السؤال عن رسوم المكان ووقت التجهيز وحجم الطاولة المسموح',
      keywords: <String>[
        'Flohmarkt',
        'Stand',
        'Standgebühr',
        'Tapeziertisch',
        'reservieren',
      ],
    ),
    SecondhandEntry(
      id: 'flea-market-negotiation',
      domain: SecondhandDomain.fleaMarketsAndAds,
      titleDe: 'Höflich handeln',
      titleAr: 'التفاوض بأدب',
      german:
          'Ist der Preis noch verhandelbar? Was ist Ihr letzter Preis? Wie wäre es mit 25 Euro?',
      arabic:
          'هل السعر قابل للتفاوض؟ ما آخر سعر لديكم؟ ما رأيكم في 25 يورو؟',
      contextDe:
          'Freundlich nach Verhandlungsspielraum fragen und einen konkreten Vorschlag machen',
      contextAr:
          'السؤال بلطف عن إمكانية التفاوض ثم تقديم عرض واضح',
      keywords: <String>[
        'handeln',
        'verhandeln',
        'letzter Preis',
        'Wie wäre es mit',
        'VB',
      ],
    ),
    SecondhandEntry(
      id: 'local-ad-posting',
      domain: SecondhandDomain.fleaMarketsAndAds,
      titleDe: 'Kleinanzeige schreiben',
      titleAr: 'كتابة إعلان محلي',
      german:
          'Zustand: wie neu. Nur Selbstabholung. Barzahlung bei Abholung. Preis: 30 Euro VB.',
      arabic:
          'الحالة: كالجديد. الاستلام الشخصي فقط. الدفع نقدًا عند الاستلام. السعر: 30 يورو قابل للتفاوض.',
      contextDe:
          'Zustand, Abholung, Zahlungsart und Verhandlungsbasis klar angeben',
      contextAr:
          'توضيح حالة السلعة وطريقة الاستلام والدفع وقابلية السعر للتفاوض',
      keywords: <String>[
        'Kleinanzeigen',
        'Zustand wie neu',
        'Nur Selbstabholung',
        'Barzahlung bei Abholung',
        'VB',
      ],
    ),
    SecondhandEntry(
      id: 'local-ad-reservation',
      domain: SecondhandDomain.fleaMarketsAndAds,
      titleDe: 'Abholung abstimmen',
      titleAr: 'تنسيق الاستلام',
      german:
          'Der Artikel ist noch da. Ich kann ihn bis heute Abend reservieren. Passt Ihnen die Abholung um 18 Uhr?',
      arabic:
          'السلعة ما زالت متوفرة. يمكنني حجزها حتى هذا المساء. هل يناسبكم الاستلام الساعة السادسة؟',
      contextDe:
          'Eine kurze Reservierung und einen konkreten Abholtermin vereinbaren',
      contextAr:
          'تحديد حجز قصير وموعد واضح للاستلام',
      keywords: <String>['Abholung', 'reservieren', 'Termin', 'Artikel'],
    ),
  ];
}
