import '../domain/culture_models.dart';

final class AdultEducationSubAgent {
  const AdultEducationSubAgent();

  static const List<CultureGuide> _guides = <CultureGuide>[
    CultureGuide(
      id: 'vhs-course-registration',
      domain: CultureDomain.adultEducation,
      intent: CultureIntent.vhsCourseRegistration,
      titleDe: 'VHS-Kurs anmelden',
      titleAr: 'التسجيل في دورة VHS',
      phraseDe:
          'Ich möchte mich für einen Kurs an der Volkshochschule anmelden. Gibt es noch freie Plätze?',
      phraseAr:
          'أريد التسجيل في دورة في مركز تعليم الكبار. هل ما زالت هناك أماكن شاغرة؟',
      noteAr:
          'اسأل أيضاً عن مستوى الدورة والرسوم وطريقة التسجيل قبل الدفع أو تأكيد الحجز.',
      searchTerms: <String>[
        'VHS',
        'Kurs',
        'Anmeldung',
        'freie Plätze',
        'دورة',
        'تسجيل',
      ],
    ),
    CultureGuide(
      id: 'vhs-schedule',
      domain: CultureDomain.adultEducation,
      intent: CultureIntent.scheduleInquiry,
      titleDe: 'Kurszeiten erfragen',
      titleAr: 'الاستفسار عن مواعيد الدورة',
      phraseDe:
          'An welchen Tagen und zu welchen Uhrzeiten findet der Kurs statt?',
      phraseAr:
          'في أي أيام وفي أي ساعات تُعقد الدورة؟',
      noteAr:
          'يمكنك إضافة سؤال عن تاريخ البداية والنهاية والعطل إذا كان جدولك محدوداً.',
      searchTerms: <String>[
        'Kursplan',
        'Termine',
        'Uhrzeit',
        'مواعيد',
        'جدول',
      ],
    ),
    CultureGuide(
      id: 'vhs-materials',
      domain: CultureDomain.adultEducation,
      intent: CultureIntent.materialsInquiry,
      titleDe: 'Unterrichtsmaterialien',
      titleAr: 'مواد الدورة',
      phraseDe:
          'Welche Unterrichtsmaterialien brauche ich für den Kurs, und sind sie in der Kursgebühr enthalten?',
      phraseAr:
          'ما مواد الدورة التي أحتاجها، وهل هي مشمولة في رسوم الدورة؟',
      noteAr:
          'تحقق من الكتب أو الملفات أو الأدوات المطلوبة قبل بداية الدورة لتجنب شراء مواد غير لازمة.',
      searchTerms: <String>[
        'Material',
        'Buch',
        'Lehrbuch',
        'Kursgebühr',
        'مواد',
        'كتاب',
      ],
    ),
    CultureGuide(
      id: 'vhs-attendance-certificate',
      domain: CultureDomain.adultEducation,
      intent: CultureIntent.attendanceCertificate,
      titleDe: 'Teilnahmebescheinigung',
      titleAr: 'شهادة الحضور',
      phraseDe:
          'Bekomme ich nach dem Kurs eine Teilnahmebescheinigung, und welche Voraussetzungen gelten dafür?',
      phraseAr:
          'هل أحصل بعد الدورة على شهادة الحضور، وما الشروط المطلوبة للحصول عليها؟',
      noteAr:
          'اسأل إن كانت الشهادة تتطلب نسبة حضور محددة أو طلباً مسبقاً أو رسوماً إضافية.',
      searchTerms: <String>[
        'Bescheinigung',
        'Zertifikat',
        'Nachweis',
        'شهادة الحضور',
      ],
    ),
  ];

  List<CultureGuide> get guides => _guides;
}
