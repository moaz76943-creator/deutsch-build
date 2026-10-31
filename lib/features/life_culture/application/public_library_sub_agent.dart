import '../domain/culture_models.dart';

final class PublicLibrarySubAgent {
  const PublicLibrarySubAgent();

  static const List<CultureGuide> _guides = <CultureGuide>[
    CultureGuide(
      id: 'library-card-issuance',
      domain: CultureDomain.publicLibrary,
      intent: CultureIntent.libraryCardIssuance,
      titleDe: 'Bibliotheksausweis beantragen',
      titleAr: 'إصدار بطاقة مكتبة',
      phraseDe:
          'Ich möchte einen Bibliotheksausweis beantragen. Welche Unterlagen brauche ich?',
      phraseAr:
          'أريد تقديم طلب للحصول على بطاقة مكتبة. ما الوثائق التي أحتاجها؟',
      noteAr:
          'اسأل عن الوثائق والرسوم ومدة صلاحية البطاقة لأن التفاصيل تختلف حسب المدينة والمكتبة.',
      searchTerms: <String>[
        'Ausweis',
        'Anmeldung',
        'Mitgliedskarte',
        'بطاقة المكتبة',
      ],
    ),
    CultureGuide(
      id: 'library-card-renewal',
      domain: CultureDomain.publicLibrary,
      intent: CultureIntent.libraryCardRenewal,
      titleDe: 'Bibliotheksausweis verlängern',
      titleAr: 'تجديد بطاقة المكتبة',
      phraseDe:
          'Ich möchte meinen Bibliotheksausweis verlängern. Was muss ich dafür mitbringen?',
      phraseAr:
          'أريد تجديد بطاقة المكتبة الخاصة بي. ماذا يجب أن أحضر معي؟',
      noteAr:
          'هذه العبارة مخصصة لشريط التجديد السريع، ويمكن استخدامها للسؤال عن المتطلبات قبل انتهاء البطاقة.',
      searchTerms: <String>[
        'verlängern',
        'Verlängerung',
        'Gültigkeit',
        'تجديد البطاقة',
      ],
    ),
    CultureGuide(
      id: 'library-loan-extension',
      domain: CultureDomain.publicLibrary,
      intent: CultureIntent.loanExtension,
      titleDe: 'Leihfrist verlängern',
      titleAr: 'تمديد مدة استعارة كتاب',
      phraseDe:
          'Kann ich die Leihfrist für dieses Buch verlängern, und bis wann ist die neue Rückgabefrist?',
      phraseAr:
          'هل يمكنني تمديد مدة استعارة هذا الكتاب، وإلى أي تاريخ تصبح مهلة الإرجاع الجديدة؟',
      noteAr:
          'استخدمها للسؤال عن التمديد وموعد الإرجاع الجديد، وتحقق من وجود حجوزات على الكتاب.',
      searchTerms: <String>[
        'ausleihen',
        'Rückgabe',
        'Rückgabefrist',
        'كتاب',
        'استعارة',
      ],
    ),
    CultureGuide(
      id: 'library-onleihe',
      domain: CultureDomain.publicLibrary,
      intent: CultureIntent.digitalMediaOnleihe,
      titleDe: 'Digitale Medien mit der Onleihe',
      titleAr: 'استعارة الوسائط الرقمية عبر Onleihe',
      phraseDe:
          'Wie kann ich mit meinem Bibliotheksausweis die Onleihe nutzen und digitale Medien ausleihen?',
      phraseAr:
          'كيف أستخدم بطاقة المكتبة للدخول إلى Onleihe واستعارة الوسائط الرقمية؟',
      noteAr:
          'اسأل عن تسجيل الدخول والأجهزة المدعومة وفترة الاستعارة الرقمية إذا احتجت مساعدة تقنية.',
      searchTerms: <String>[
        'E-Book',
        'E-Books',
        'digital',
        'digitale Medien',
        'كتب إلكترونية',
      ],
    ),
    CultureGuide(
      id: 'library-study-room',
      domain: CultureDomain.publicLibrary,
      intent: CultureIntent.studyRoomEtiquette,
      titleDe: 'Lernraum und Ruhe',
      titleAr: 'آداب غرفة الدراسة والهدوء',
      phraseDe:
          'Ist dieser Lernraum frei, und soll ich hier bitte besonders leise sprechen?',
      phraseAr:
          'هل غرفة الدراسة هذه متاحة، وهل يجب أن أتحدث هنا بصوت منخفض جداً؟',
      noteAr:
          'احترم مناطق الهدوء وقواعد الحجز والطعام والمكالمات كما تحددها المكتبة.',
      searchTerms: <String>[
        'Ruhe',
        'Lernen',
        'Arbeitsplatz',
        'دراسة',
        'هدوء',
      ],
    ),
  ];

  List<CultureGuide> get guides => _guides;

  CultureGuide get quickCardRenewalGuide => _guides[1];
}
