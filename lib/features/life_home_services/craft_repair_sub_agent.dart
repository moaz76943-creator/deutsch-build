import 'home_services_models.dart';

final class CraftRepairSubAgent {
  const CraftRepairSubAgent();

  List<HomeServicePhrase> get phrases => _phrases;

  static const List<HomeServicePhrase> _phrases = <HomeServicePhrase>[
    HomeServicePhrase(
      id: 'repair-heating-winter',
      domain: HomeServicesDomain.urgentRepairs,
      german:
          'Die Heizung ist komplett ausgefallen, und es ist Winter. '
          'Können Sie bitte den Notdienst schicken?',
      arabic:
          'التدفئة متوقفة بالكامل والوقت شتاء. هل يمكنكم إرسال خدمة الطوارئ؟',
      contextDe: 'Heizungsausfall im Winter dringend melden',
      contextAr:
          'الإبلاغ بشكل واضح عن توقف التدفئة في الشتاء وطلب خدمة الطوارئ',
      keywords: <String>[
        'Heizungsausfall',
        'Heizung',
        'Winter',
        'Notdienst',
        'تدفئة',
        'شتاء',
      ],
    ),
    HomeServicePhrase(
      id: 'repair-heating-landlord',
      domain: HomeServicesDomain.urgentRepairs,
      german:
          'Ich habe einen Heizungsausfall in der Wohnung. '
          'Welche Notfallnummer der Hausverwaltung soll ich anrufen?',
      arabic:
          'لدي عطل في التدفئة داخل الشقة. ما رقم طوارئ إدارة العقار الذي يجب أن أتصل به؟',
      contextDe: 'Notdienst der Hausverwaltung erfragen',
      contextAr:
          'طلب رقم خدمة الطوارئ التابعة لإدارة العقار',
      keywords: <String>[
        'Hausverwaltung',
        'Notfallnummer',
        'Notdienst',
        'Heizung',
        'إدارة العقار',
      ],
    ),
    HomeServicePhrase(
      id: 'repair-clogged-drain',
      domain: HomeServicesDomain.urgentRepairs,
      german:
          'Der Abfluss ist vollständig verstopft, und das Wasser läuft '
          'nicht mehr ab.',
      arabic:
          'المصرف مسدود بالكامل والماء لم يعد يتصـرف.',
      contextDe: 'Verstopften Abfluss genau beschreiben',
      contextAr:
          'وصف انسداد المصرف بشكل مباشر قبل طلب خدمة السباكة',
      keywords: <String>[
        'Abfluss',
        'verstopft',
        'Wasser',
        'Rohr',
        'صرف',
        'مسدود',
      ],
    ),
    HomeServicePhrase(
      id: 'repair-water-leak',
      domain: HomeServicesDomain.urgentRepairs,
      german:
          'Unter dem Waschbecken tritt Wasser aus. Ich habe, soweit möglich, '
          'das Wasser abgestellt und melde den Schaden sofort.',
      arabic:
          'يوجد تسرب ماء تحت المغسلة. أوقفت الماء قدر الإمكان وأبلغ عن الضرر فوراً.',
      contextDe: 'Wasserleck sachlich und dringend melden',
      contextAr:
          'الإبلاغ عن تسرب الماء بشكل واضح وعاجل',
      keywords: <String>[
        'Wasserleck',
        'Wasser',
        'tritt aus',
        'Schaden',
        'تسرب',
        'ماء',
      ],
    ),
    HomeServicePhrase(
      id: 'repair-water-leak-management',
      domain: HomeServicesDomain.urgentRepairs,
      german:
          'Ich melde einen akuten Wasseraustritt in der Wohnung. '
          'Bitte verbinden Sie mich mit dem Notdienst der Hausverwaltung.',
      arabic:
          'أبلغ عن تسرب ماء عاجل داخل الشقة. يرجى تحويلي إلى خدمة طوارئ إدارة العقار.',
      contextDe: 'Bei akutem Leck die Hausverwaltung erreichen',
      contextAr:
          'التواصل مع طوارئ إدارة العقار عند وجود تسرب عاجل',
      keywords: <String>[
        'Hausverwaltung',
        'Notdienst',
        'Wasseraustritt',
        'Leck',
        'تسرب',
        'طوارئ',
      ],
    ),
    HomeServicePhrase(
      id: 'repair-price-before-work',
      domain: HomeServicesDomain.urgentRepairs,
      german:
          'Bitte erklären Sie mir vor Beginn, welche Arbeiten nötig sind '
          'und welche Kosten voraussichtlich entstehen.',
      arabic:
          'يرجى شرح الأعمال المطلوبة والتكلفة المتوقعة قبل بدء العمل.',
      contextDe: 'Umfang und Kosten vor Arbeitsbeginn klären',
      contextAr:
          'طلب توضيح العمل والتكلفة قبل البدء بالإصلاح',
      keywords: <String>[
        'Kosten',
        'vor Beginn',
        'Arbeiten',
        'Preis',
        'تكلفة',
      ],
    ),
  ];
}
