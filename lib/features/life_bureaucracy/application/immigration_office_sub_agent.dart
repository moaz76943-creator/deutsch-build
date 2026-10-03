import '../domain/bureaucracy_models.dart';

final class ImmigrationOfficeSubAgent {
  const ImmigrationOfficeSubAgent();

  List<BureaucracyGuide> get guides => _guides;

  static const List<BureaucracyGuide> _guides = <BureaucracyGuide>[
    BureaucracyGuide(
      id: 'immigration_residence_extension',
      category: BureaucracyCategory.immigrationOffice,
      intent: BureaucracyIntent.residencePermitExtension,
      register: BureaucracyRegister.formalSie,
      titleDe: 'Aufenthaltstitel verlängern',
      titleAr: 'تمديد تصريح الإقامة',
      phraseDe:
          'Guten Tag. Ich möchte meinen Aufenthaltstitel verlängern lassen. Welche Unterlagen benötigen Sie von mir?',
      phraseAr:
          'مرحبًا. أود تمديد تصريح إقامتي. ما المستندات التي تحتاجونها مني؟',
      explanationAr:
          'ابدأ بنوع الطلب ثم اسأل بصيغة Sie عن القائمة الحالية؛ المستندات الإضافية تختلف بحسب نوع الإقامة والجهة.',
      documents: <OfficialDocument>[
        OfficialDocument(
          id: 'immigration_passport',
          nameDe: 'Gültiger Reisepass',
          nameAr: 'جواز سفر ساري المفعول',
          noteAr: 'تحقق من صلاحية جواز السفر قبل الموعد.',
        ),
        OfficialDocument(
          id: 'immigration_current_permit',
          nameDe: 'Aktueller Aufenthaltstitel',
          nameAr: 'تصريح الإقامة الحالي',
          noteAr: 'أحضر البطاقة أو الإثبات الحالي المتعلق بإقامتك.',
        ),
        OfficialDocument(
          id: 'immigration_biometric_photo',
          nameDe: 'Biometrisches Lichtbild',
          nameAr: 'صورة شخصية بيومترية',
          noteAr:
              'تحقق من طريقة تقديم الصورة المعتمدة حاليًا لدى دائرتك، بما في ذلك الإرسال الرقمي إن كان مطلوبًا.',
        ),
        OfficialDocument(
          id: 'immigration_application_form',
          nameDe: 'Antragsformular und fallbezogene Nachweise',
          nameAr: 'نموذج الطلب والإثباتات الخاصة بالحالة',
          noteAr:
              'القائمة الدقيقة تعتمد على نوع Aufenthaltstitel؛ استخدم قائمة الجهة الرسمية لمعاملتك.',
        ),
      ],
    ),
    BureaucracyGuide(
      id: 'immigration_biometric_photo_check',
      category: BureaucracyCategory.immigrationOffice,
      intent: BureaucracyIntent.biometricPhoto,
      register: BureaucracyRegister.formalSie,
      titleDe: 'Biometrisches Lichtbild klären',
      titleAr: 'الاستفسار عن الصورة البيومترية',
      phraseDe:
          'Könnten Sie mir bitte sagen, in welcher Form ich das biometrische Lichtbild einreichen soll?',
      phraseAr:
          'هل يمكنكم إخباري من فضلكم بأي صيغة يجب أن أقدم الصورة البيومترية؟',
      explanationAr:
          'السؤال لا يفترض ورقًا أو ملفًا رقميًا، لذلك يبقى صحيحًا عند اختلاف طريقة الاستلام بين الجهات.',
      documents: <OfficialDocument>[
        OfficialDocument(
          id: 'immigration_biometric_photo',
          nameDe: 'Biometrisches Lichtbild',
          nameAr: 'صورة شخصية بيومترية',
          noteAr: 'استخدم فقط طريقة الالتقاط أو النقل المقبولة رسميًا لدى الجهة.',
        ),
        OfficialDocument(
          id: 'immigration_photo_reference',
          nameDe: 'Termin- oder Vorgangsangaben',
          nameAr: 'بيانات الموعد أو المعاملة',
          noteAr: 'احتفظ ببيانات المعاملة لربط الصورة بالطلب إذا طلبت الجهة ذلك.',
        ),
      ],
    ),
    BureaucracyGuide(
      id: 'immigration_status_inquiry',
      category: BureaucracyCategory.immigrationOffice,
      intent: BureaucracyIntent.statusInquiry,
      register: BureaucracyRegister.formalSie,
      titleDe: 'Bearbeitungsstand erfragen',
      titleAr: 'الاستفسار عن حالة المعاملة',
      phraseDe:
          'Könnten Sie mir bitte mitteilen, wie der aktuelle Bearbeitungsstand meines Antrags ist?',
      phraseAr: 'هل يمكنكم إبلاغي من فضلكم بالحالة الحالية لمعالجة طلبي؟',
      explanationAr:
          'Bearbeitungsstand كلمة رسمية مناسبة للاستفسار عن مرحلة الطلب دون لهجة ضغط.',
      documents: <OfficialDocument>[
        OfficialDocument(
          id: 'immigration_case_number',
          nameDe: 'Aktenzeichen oder Vorgangsnummer',
          nameAr: 'رقم الملف أو رقم المعاملة',
          noteAr: 'يساعد الرقم الموظف في العثور على الطلب بسرعة.',
        ),
        OfficialDocument(
          id: 'immigration_identity_reference',
          nameDe: 'Identitäts- und Kontaktdaten',
          nameAr: 'بيانات الهوية والتواصل',
          noteAr: 'قد تحتاج الجهة بيانات كافية لتحديد الطلب والتحقق من صاحبه.',
        ),
      ],
    ),
  ];
}
