import 'anmeldung_models.dart';

abstract final class AnmeldungPhraseBank {
  static const List<AnmeldungPhrase> all = <AnmeldungPhrase>[
    AnmeldungPhrase(
      id: 'anmeldung-counter-open',
      registrationAction: RegistrationAction.anmeldung,
      german:
          'Guten Tag. Ich möchte meinen Wohnsitz anmelden. Bin ich hier richtig?',
      arabic:
          'مرحبًا. أريد تسجيل عنوان سكني. هل أنا في المكان الصحيح؟',
      contextDe: 'Am Schalter das Anliegen nennen',
      contextAr: 'توضيح المعاملة عند شباك الموظف',
      keywords: <String>['Bürgeramt', 'Wohnsitz', 'Meldebehörde', 'سكن'],
    ),
    AnmeldungPhrase(
      id: 'anmeldung-documents',
      registrationAction: RegistrationAction.anmeldung,
      german:
          'Welche Unterlagen brauche ich für die Anmeldung, und muss ich Originale mitbringen?',
      arabic:
          'ما المستندات المطلوبة لتسجيل السكن، وهل يجب أن أحضر النسخ الأصلية؟',
      contextDe: 'Unterlagen vor dem Termin prüfen',
      contextAr: 'التحقق من الأوراق قبل الموعد',
      keywords: <String>['Unterlagen', 'Originale', 'Dokumente', 'أوراق'],
    ),
    AnmeldungPhrase(
      id: 'anmeldung-landlord-proof',
      registrationAction: RegistrationAction.anmeldung,
      german:
          'Benötigen Sie für meinen Fall eine Wohnungsgeberbestätigung?',
      arabic:
          'هل تحتاجون في حالتي إلى تأكيد من مؤجر السكن؟',
      contextDe: 'Erforderliche Nachweise konkret erfragen',
      contextAr: 'السؤال تحديدًا عن الإثباتات المطلوبة',
      keywords: <String>['Wohnungsgeberbestätigung', 'Nachweis', 'مؤجر'],
    ),
    AnmeldungPhrase(
      id: 'ummeldung-address',
      registrationAction: RegistrationAction.ummeldung,
      german:
          'Ich bin innerhalb der Stadt umgezogen und möchte meine neue Adresse ummelden.',
      arabic:
          'انتقلت إلى عنوان جديد داخل المدينة وأريد تحديث تسجيل عنواني.',
      contextDe: 'Neue Anschrift mitteilen',
      contextAr: 'إبلاغ الدائرة بعنوان السكن الجديد',
      keywords: <String>['Ummeldung', 'umgezogen', 'Adresse', 'عنوان'],
    ),
    AnmeldungPhrase(
      id: 'ummeldung-data-check',
      registrationAction: RegistrationAction.ummeldung,
      german:
          'Könnten Sie bitte prüfen, ob meine neue Anschrift vollständig erfasst wurde?',
      arabic:
          'هل يمكنكم التحقق من تسجيل عنواني الجديد بشكل كامل؟',
      contextDe: 'Erfasste Daten kontrollieren',
      contextAr: 'التأكد من البيانات المسجلة',
      keywords: <String>['Anschrift', 'Daten', 'prüfen', 'بيانات'],
    ),
    AnmeldungPhrase(
      id: 'meldebestaetigung-request',
      registrationAction: RegistrationAction.meldebestaetigung,
      german:
          'Bekomme ich nach der Anmeldung eine Meldebestätigung, und wie erhalte ich sie?',
      arabic:
          'هل أحصل بعد تسجيل السكن على شهادة تسجيل، وكيف أستلمها؟',
      contextDe: 'Meldebestätigung erfragen',
      contextAr: 'السؤال عن شهادة تسجيل السكن',
      keywords: <String>['Meldebestätigung', 'Bescheinigung', 'شهادة'],
    ),
    AnmeldungPhrase(
      id: 'meldebestaetigung-copy',
      registrationAction: RegistrationAction.meldebestaetigung,
      german:
          'Ich benötige einen Nachweis über meine gemeldete Anschrift. Welche Bescheinigung ist dafür passend?',
      arabic:
          'أحتاج إثباتًا لعنواني المسجل. ما الشهادة المناسبة لذلك؟',
      contextDe: 'Passenden Meldedatennachweis klären',
      contextAr: 'تحديد نوع إثبات التسجيل المناسب',
      keywords: <String>['Meldebescheinigung', 'Nachweis', 'Anschrift', 'إثبات'],
    ),
    AnmeldungPhrase(
      id: 'appointment-book',
      registrationAction: RegistrationAction.anmeldung,
      appointmentAction: AppointmentAction.book,
      german:
          'Ich möchte einen Termin für die Anmeldung vereinbaren. Welche Zeiten sind verfügbar?',
      arabic:
          'أريد حجز موعد لتسجيل السكن. ما الأوقات المتاحة؟',
      contextDe: 'Termin buchen',
      contextAr: 'حجز موعد رسمي',
      keywords: <String>['Terminvereinbarung', 'Termin', 'verfügbar', 'موعد'],
    ),
    AnmeldungPhrase(
      id: 'appointment-book-ummeldung',
      registrationAction: RegistrationAction.ummeldung,
      appointmentAction: AppointmentAction.book,
      german:
          'Kann ich für die Ummeldung online einen Termin buchen, oder muss ich persönlich vorsprechen?',
      arabic:
          'هل يمكنني حجز موعد تغيير السكن عبر الإنترنت، أم يجب الحضور شخصيًا؟',
      contextDe: 'Buchungsweg klären',
      contextAr: 'معرفة طريقة حجز الموعد',
      keywords: <String>['online', 'persönlich', 'buchen', 'حجز'],
    ),
    AnmeldungPhrase(
      id: 'appointment-confirm',
      registrationAction: RegistrationAction.anmeldung,
      appointmentAction: AppointmentAction.confirm,
      german:
          'Ich möchte meinen Termin bestätigen. Die Termin- oder Vorgangsnummer lautet …',
      arabic:
          'أريد تأكيد موعدي. رقم الموعد أو المعاملة هو …',
      contextDe: 'Vorhandenen Termin bestätigen',
      contextAr: 'تأكيد الموعد الموجود',
      keywords: <String>['bestätigen', 'Vorgangsnummer', 'Terminnummer', 'تأكيد'],
    ),
    AnmeldungPhrase(
      id: 'appointment-reschedule',
      registrationAction: RegistrationAction.anmeldung,
      appointmentAction: AppointmentAction.reschedule,
      german:
          'Ich kann den Termin nicht wahrnehmen. Kann ich ihn bitte auf einen anderen Tag verschieben?',
      arabic:
          'لا أستطيع الحضور في الموعد. هل يمكن نقله إلى يوم آخر من فضلكم؟',
      contextDe: 'Termin verschieben',
      contextAr: 'تعديل موعد رسمي',
      keywords: <String>['verschieben', 'ändern', 'neuer Termin', 'تعديل'],
    ),
    AnmeldungPhrase(
      id: 'appointment-reschedule-reference',
      registrationAction: RegistrationAction.ummeldung,
      appointmentAction: AppointmentAction.reschedule,
      german:
          'Welche Angaben brauchen Sie, um meinen bestehenden Termin zu ändern?',
      arabic:
          'ما البيانات التي تحتاجونها لتعديل موعدي الحالي؟',
      contextDe: 'Änderung mit Referenzdaten vorbereiten',
      contextAr: 'تجهيز بيانات الموعد قبل طلب التعديل',
      keywords: <String>['Referenz', 'Termin ändern', 'بيانات الموعد'],
    ),
  ];
}
