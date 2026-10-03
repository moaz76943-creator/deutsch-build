import '../domain/bureaucracy_models.dart';

final class CityRegistrationSubAgent {
  const CityRegistrationSubAgent();

  List<BureaucracyGuide> get guides => _guides;

  static const List<BureaucracyGuide> _guides = <BureaucracyGuide>[
    BureaucracyGuide(
      id: 'buergeramt_anmeldung_appointment',
      category: BureaucracyCategory.cityRegistration,
      intent: BureaucracyIntent.registrationAppointment,
      register: BureaucracyRegister.formalSie,
      titleDe: 'Termin für die Anmeldung',
      titleAr: 'موعد تسجيل السكن',
      phraseDe:
          'Guten Tag. Ich möchte gern einen Termin für die Anmeldung meines Wohnsitzes vereinbaren.',
      phraseAr: 'مرحبًا. أود حجز موعد لتسجيل عنوان سكني.',
      explanationAr:
          'صيغة رسمية ومحايدة لبدء المعاملة. استخدم Sie مع الموظف واذكر نوع المعاملة بوضوح.',
      documents: <OfficialDocument>[
        OfficialDocument(
          id: 'city_identity_document',
          nameDe: 'Personalausweis oder Reisepass',
          nameAr: 'بطاقة الهوية أو جواز السفر',
          noteAr: 'تحقق من الوثيقة المقبولة لدى مكتب المدينة قبل الموعد.',
        ),
        OfficialDocument(
          id: 'city_wohnungsgeberbestaetigung',
          nameDe: 'Wohnungsgeberbestätigung',
          nameAr: 'تأكيد المؤجر أو مزوّد السكن',
          noteAr: 'يُطلب عادة لإثبات الانتقال إلى السكن عند Anmeldung.',
        ),
        OfficialDocument(
          id: 'city_registration_form',
          nameDe: 'Anmeldeformular',
          nameAr: 'نموذج تسجيل السكن',
          noteAr:
              'توفر بعض المدن النموذج مسبقًا؛ طريقة التقديم والتوقيع قد تختلف محليًا.',
        ),
      ],
    ),
    BureaucracyGuide(
      id: 'buergeramt_housing_confirmation',
      category: BureaucracyCategory.cityRegistration,
      intent: BureaucracyIntent.housingConfirmation,
      register: BureaucracyRegister.formalSie,
      titleDe: 'Wohnungsgeberbestätigung prüfen',
      titleAr: 'التحقق من تأكيد السكن',
      phraseDe:
          'Könnten Sie mir bitte sagen, ob die Wohnungsgeberbestätigung vollständig ausgefüllt ist?',
      phraseAr: 'هل يمكنكم إخباري من فضلكم إن كان تأكيد السكن معبأ بالكامل؟',
      explanationAr:
          'Könnten Sie ... bitte صيغة مهذبة جدًا للسؤال عن اكتمال مستند رسمي دون افتراض وجود خطأ.',
      documents: <OfficialDocument>[
        OfficialDocument(
          id: 'city_wohnungsgeberbestaetigung',
          nameDe: 'Wohnungsgeberbestätigung',
          nameAr: 'تأكيد المؤجر أو مزوّد السكن',
          noteAr: 'راجع الاسم والعنوان وتاريخ الانتقال والبيانات المطلوبة.',
        ),
        OfficialDocument(
          id: 'city_identity_document',
          nameDe: 'Personalausweis oder Reisepass',
          nameAr: 'بطاقة الهوية أو جواز السفر',
          noteAr: 'احتفظ بوثيقة الهوية معك عند مراجعة المكتب.',
        ),
      ],
    ),
    BureaucracyGuide(
      id: 'buergeramt_registration_certificate',
      category: BureaucracyCategory.cityRegistration,
      intent: BureaucracyIntent.certificateRequest,
      register: BureaucracyRegister.formalSie,
      titleDe: 'Meldebescheinigung beantragen',
      titleAr: 'طلب شهادة تسجيل السكن',
      phraseDe:
          'Ich möchte bitte eine Meldebescheinigung beantragen. Welche Unterlagen benötigen Sie dafür?',
      phraseAr:
          'أود طلب شهادة تسجيل السكن من فضلكم. ما المستندات التي تحتاجونها لذلك؟',
      explanationAr:
          'اجمع بين الطلب المهذب والسؤال المفتوح عن المتطلبات لأن الرسوم والإجراءات قد تختلف بين المدن.',
      documents: <OfficialDocument>[
        OfficialDocument(
          id: 'city_identity_document',
          nameDe: 'Personalausweis oder Reisepass',
          nameAr: 'بطاقة الهوية أو جواز السفر',
          noteAr: 'وثيقة هوية سارية مناسبة عادة لإثبات الشخصية.',
        ),
        OfficialDocument(
          id: 'city_request_details',
          nameDe: 'Angaben zum gewünschten Nachweis',
          nameAr: 'بيانات الشهادة المطلوبة',
          noteAr: 'حدد نوع الشهادة والغرض منها إذا طلب الموظف ذلك.',
        ),
      ],
    ),
  ];
}
