import '../domain/education_models.dart';

abstract final class EducationCatalog {
  static const List<EducationEntry> entries = <EducationEntry>[
    EducationEntry(
      id: 'kita-dropoff-a1',
      area: EducationArea.daycare,
      level: EducationLevel.a1a2,
      topic: EducationTopic.dropOffPickup,
      titleDe: 'Bringen & Abholen',
      titleAr: 'التوصيل والاستلام',
      germanText:
          'Guten Morgen. Mein Kind bleibt heute bis 15 Uhr in der Kita. '
          'Ich hole es um 15 Uhr ab.',
      arabicText:
          'صباح الخير. سيبقى طفلي اليوم في الحضانة حتى الساعة الثالثة، '
          'وسآتي لاستلامه الساعة الثالثة.',
      keywords: <String>[
        'bringen',
        'abholen',
        'drop-off',
        'pick-up',
        'توصيل',
        'استلام',
        'kita',
      ],
    ),
    EducationEntry(
      id: 'kita-allergy-a1',
      area: EducationArea.daycare,
      level: EducationLevel.a1a2,
      topic: EducationTopic.allergy,
      titleDe: 'Allergie melden',
      titleAr: 'إبلاغ الحضانة عن الحساسية',
      germanText:
          'Mein Kind hat eine Allergie gegen Nüsse. Bitte geben Sie ihm '
          'keine Speisen mit Nüssen.',
      arabicText:
          'لدى طفلي حساسية من المكسرات. يرجى عدم إعطائه أي طعام يحتوي '
          'على المكسرات.',
      noteAr: 'استخدم اسم المادة المسببة للحساسية بدلا من Nüsse عند الحاجة.',
      keywords: <String>[
        'allergie',
        'allergy',
        'nüsse',
        'حساسية',
        'طعام',
        'kita',
      ],
      formalRegister: true,
    ),
    EducationEntry(
      id: 'kita-routine-b1',
      area: EducationArea.daycare,
      level: EducationLevel.b1,
      topic: EducationTopic.dailyRoutine,
      titleDe: 'Tagesablauf erklären',
      titleAr: 'شرح الروتين اليومي',
      germanText:
          'Zu Hause macht mein Kind nach dem Mittagessen normalerweise '
          'eine kurze Ruhepause. Können Sie mir sagen, wie die Ruhezeit '
          'in der Gruppe organisiert ist?',
      arabicText:
          'في المنزل يأخذ طفلي عادة فترة راحة قصيرة بعد الغداء. هل يمكنكم '
          'إخباري كيف يتم تنظيم وقت الراحة في المجموعة؟',
      keywords: <String>[
        'tagesablauf',
        'routine',
        'ruhezeit',
        'mittagessen',
        'روتين',
        'راحة',
      ],
      formalRegister: true,
    ),
    EducationEntry(
      id: 'kita-caretime-b1',
      area: EducationArea.daycare,
      level: EducationLevel.b1,
      topic: EducationTopic.careTimes,
      titleDe: 'Betreuungszeit klären',
      titleAr: 'الاستفسار عن أوقات الرعاية',
      germanText:
          'Könnten Sie mir bitte bestätigen, bis wann die Betreuung heute '
          'möglich ist und wann die Abholzeit endet?',
      arabicText:
          'هل يمكنكم تأكيد حتى أي ساعة تتوفر الرعاية اليوم، ومتى ينتهي '
          'وقت استلام الأطفال؟',
      keywords: <String>[
        'betreuungszeit',
        'öffnungszeit',
        'abholzeit',
        'care time',
        'رعاية',
        'دوام',
      ],
      formalRegister: true,
    ),
    EducationEntry(
      id: 'kita-allergy-b2',
      area: EducationArea.daycare,
      level: EducationLevel.b2,
      topic: EducationTopic.allergy,
      titleDe: 'Allergiehinweise abstimmen',
      titleAr: 'تنسيق تعليمات الحساسية',
      germanText:
          'Wegen einer ärztlich bestätigten Allergie möchte ich gern '
          'abstimmen, wie die Information im Kita-Alltag dokumentiert wird '
          'und wer bei Rückfragen zuständig ist.',
      arabicText:
          'بسبب حساسية مؤكدة طبيا، أود الاتفاق على طريقة توثيق هذه المعلومة '
          'في روتين الحضانة ومن هي الجهة المسؤولة عند وجود استفسار.',
      noteAr: 'هذه صياغة إدارية؛ لا تستبدل تعليمات الطبيب بتعليمات لغوية عامة.',
      keywords: <String>[
        'allergie',
        'allergiehinweise',
        'dokumentiert',
        'حساسية',
        'توثيق',
      ],
      formalRegister: true,
    ),
    EducationEntry(
      id: 'kita-caretime-b2',
      area: EducationArea.daycare,
      level: EducationLevel.b2,
      topic: EducationTopic.careTimes,
      titleDe: 'Änderung der Betreuungszeit',
      titleAr: 'طلب تغيير وقت الرعاية',
      germanText:
          'Ich möchte nachfragen, ob eine vorübergehende Anpassung der '
          'Betreuungszeit möglich ist. Welche Fristen und Unterlagen muss '
          'ich dafür beachten?',
      arabicText:
          'أود الاستفسار عما إذا كان من الممكن تعديل وقت الرعاية مؤقتا. '
          'ما المهل أو المستندات التي يجب مراعاتها لذلك؟',
      keywords: <String>[
        'betreuungszeit',
        'anpassung',
        'frist',
        'unterlagen',
        'رعاية',
        'تعديل',
      ],
      formalRegister: true,
    ),
    EducationEntry(
      id: 'schule-homework-a1',
      area: EducationArea.school,
      level: EducationLevel.a1a2,
      topic: EducationTopic.homework,
      titleDe: 'Hausaufgaben erfragen',
      titleAr: 'الاستفسار عن الواجبات',
      germanText:
          'Entschuldigung, welche Hausaufgaben hat die Klasse für morgen?',
      arabicText: 'عذرا، ما الواجبات المطلوبة من الصف للغد؟',
      keywords: <String>[
        'hausaufgaben',
        'homework',
        'morgen',
        'واجب',
        'واجبات',
        'schule',
      ],
    ),
    EducationEntry(
      id: 'schule-sicknote-a1',
      area: EducationArea.school,
      level: EducationLevel.a1a2,
      topic: EducationTopic.sickLeave,
      titleDe: 'Kurze Entschuldigung',
      titleAr: 'اعتذار رسمي قصير عن الغياب',
      germanText:
          'Sehr geehrte Frau / sehr geehrter Herr ..., mein Kind kann heute '
          'wegen Krankheit nicht am Unterricht teilnehmen. Bitte '
          'entschuldigen Sie das Fehlen. Mit freundlichen Grüßen',
      arabicText:
          'السيدة المحترمة / السيد المحترم، لا يستطيع طفلي حضور الدروس اليوم '
          'بسبب المرض. يرجى قبول اعتذارنا عن الغياب. مع خالص التحية.',
      keywords: <String>[
        'entschuldigung',
        'krank',
        'krankheit',
        'fehlen',
        'غياب',
        'مرض',
      ],
      formalRegister: true,
    ),
    EducationEntry(
      id: 'schule-parentmeeting-b1',
      area: EducationArea.school,
      level: EducationLevel.b1,
      topic: EducationTopic.parentTeacherConference,
      titleDe: 'Elterngespräch vereinbaren',
      titleAr: 'حجز موعد مع المعلم',
      germanText:
          'Ich würde gern einen Termin für ein Elterngespräch vereinbaren. '
          'Wann hätten Sie in den nächsten Tagen Zeit?',
      arabicText:
          'أود تحديد موعد لمحادثة بين ولي الأمر والمعلم. متى يتوفر لديكم '
          'وقت خلال الأيام القادمة؟',
      keywords: <String>[
        'elterngespräch',
        'elternabend',
        'termin',
        'lehrer',
        'ولي الأمر',
        'اجتماع',
      ],
      formalRegister: true,
    ),
    EducationEntry(
      id: 'schule-homework-b1',
      area: EducationArea.school,
      level: EducationLevel.b1,
      topic: EducationTopic.homework,
      titleDe: 'Versäumte Hausaufgaben',
      titleAr: 'السؤال عن الواجبات بعد الغياب',
      germanText:
          'Mein Kind hat gestern gefehlt. Könnten Sie mir bitte mitteilen, '
          'welche Hausaufgaben nachgeholt werden sollen?',
      arabicText:
          'تغيب طفلي أمس. هل يمكنكم إخباري ما الواجبات التي ينبغي تعويضها؟',
      keywords: <String>[
        'hausaufgaben',
        'nachholen',
        'gefehlt',
        'واجبات',
        'غياب',
      ],
      formalRegister: true,
    ),
    EducationEntry(
      id: 'schule-parentmeeting-b2',
      area: EducationArea.school,
      level: EducationLevel.b2,
      topic: EducationTopic.parentTeacherConference,
      titleDe: 'Lernstand im Elterngespräch',
      titleAr: 'مناقشة مستوى الطالب مع المعلم',
      germanText:
          'Könnten Sie bitte erläutern, in welchen Bereichen mein Kind '
          'derzeit zusätzliche Unterstützung benötigt und welche Maßnahmen '
          'Sie für zu Hause empfehlen?',
      arabicText:
          'هل يمكنكم توضيح المجالات التي يحتاج فيها طفلي حاليا إلى دعم إضافي، '
          'وما الإجراءات التي تنصحون بها في المنزل؟',
      keywords: <String>[
        'lernstand',
        'elterngespräch',
        'unterstützung',
        'maßnahmen',
        'مستوى',
        'دعم',
      ],
      formalRegister: true,
    ),
    EducationEntry(
      id: 'schule-sicknote-b2',
      area: EducationArea.school,
      level: EducationLevel.b2,
      topic: EducationTopic.sickLeave,
      titleDe: 'Formelles Entschuldigungsschreiben',
      titleAr: 'خطاب اعتذار رسمي عن غياب الطالب',
      germanText:
          'Sehr geehrte Damen und Herren, hiermit entschuldige ich das '
          'Fehlen meines Kindes am heutigen Tag aus Krankheitsgründen. '
          'Bitte teilen Sie mir mit, falls weitere Unterlagen benötigt '
          'werden. Mit freundlichen Grüßen',
      arabicText:
          'السادة المحترمون، أعتذر بموجب هذه الرسالة عن غياب طفلي اليوم '
          'لأسباب مرضية. يرجى إبلاغي إذا كانت هناك حاجة إلى مستندات إضافية. '
          'مع خالص التحية.',
      keywords: <String>[
        'entschuldigungsschreiben',
        'krankheitsgründe',
        'unterlagen',
        'fehlen',
        'غياب',
        'اعتذار',
      ],
      formalRegister: true,
    ),
  ];

  static const EmergencyAbsenceMessage daycareAbsence =
      EmergencyAbsenceMessage(
    area: EducationArea.daycare,
    level: EducationLevel.a1a2,
    titleDe: 'Kita: kurzfristige Abmeldung',
    titleAr: 'غياب عاجل عن الحضانة',
    germanText:
        'Guten Morgen. Mein Kind kommt heute leider nicht in die Kita, '
        'weil es krank ist. Vielen Dank für Ihr Verständnis.',
    arabicGuidance:
        'أرسلها في الصباح عند الغياب المفاجئ، وعدّل السبب فقط إذا لزم.',
    isFormal: false,
  );

  static const EmergencyAbsenceMessage schoolAbsence =
      EmergencyAbsenceMessage(
    area: EducationArea.school,
    level: EducationLevel.b1,
    titleDe: 'Schule: formelle Entschuldigung',
    titleAr: 'غياب عاجل عن المدرسة',
    germanText:
        'Sehr geehrte Damen und Herren, hiermit entschuldige ich das '
        'Fehlen meines Kindes am heutigen Tag aus Krankheitsgründen. '
        'Mit freundlichen Grüßen',
    arabicGuidance:
        'صياغة رسمية مختصرة للمدرسة. أضف اسم الطفل والتاريخ قبل الإرسال.',
    isFormal: true,
  );
}
