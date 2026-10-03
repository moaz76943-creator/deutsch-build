import '../domain/doctor_appointment_models.dart';

final class DoctorAppointmentMasterOrchestrator {
  const DoctorAppointmentMasterOrchestrator();

  List<DoctorClinicType> get clinicTypes =>
      const <DoctorClinicType>[
        DoctorClinicType.hausarzt,
        DoctorClinicType.facharzt,
      ];

  List<DoctorDocumentCard> get documents =>
      const <DoctorDocumentCard>[
        DoctorDocumentCard(
          id: 'gesundheitskarte',
          kind: DoctorDocumentKind.gesundheitskarte,
          titleDe: 'Gesundheitskarte',
          titleAr: 'بطاقة التأمين الصحي',
          promptDe: 'Hier ist meine Gesundheitskarte.',
          explanationAr:
              'جملة محايدة لتسليم بطاقة التأمين عند الاستقبال.',
        ),
        DoctorDocumentCard(
          id: 'ueberweisung',
          kind: DoctorDocumentKind.ueberweisung,
          titleDe: 'Überweisung',
          titleAr: 'إحالة طبية',
          promptDe: 'Brauche ich eine Überweisung zum Facharzt?',
          explanationAr:
              'صيغة سؤال آمنة لأن الحاجة إلى الإحالة تختلف حسب الحالة والجهة.',
          clinicType: DoctorClinicType.facharzt,
        ),
      ];

  List<DoctorAppointmentChecklistItem> get appointmentChecklist =>
      const <DoctorAppointmentChecklistItem>[
        DoctorAppointmentChecklistItem(
          id: 'termin',
          titleDe: 'Termin',
          titleAr: 'الموعد',
          detailDe: 'Datum, Uhrzeit und Praxis notieren.',
          detailAr: 'دوّن التاريخ والوقت واسم العيادة.',
        ),
        DoctorAppointmentChecklistItem(
          id: 'karte',
          titleDe: 'Gesundheitskarte',
          titleAr: 'بطاقة التأمين',
          detailDe: 'Die Karte für die Anmeldung bereithalten.',
          detailAr: 'جهّز البطاقة عند التسجيل في الاستقبال.',
        ),
        DoctorAppointmentChecklistItem(
          id: 'unterlagen',
          titleDe: 'Unterlagen',
          titleAr: 'المستندات',
          detailDe: 'Vorhandene Unterlagen oder Überweisung mitnehmen.',
          detailAr: 'خذ المستندات المتوفرة أو الإحالة إن كانت لديك.',
        ),
      ];

  List<DoctorHubPhrase> get overviewPhrases =>
      const <DoctorHubPhrase>[
        DoctorHubPhrase(
          id: 'hausarzt_termin',
          german: 'Ich habe einen Termin beim Hausarzt.',
          arabic: 'لدي موعد عند طبيب الأسرة.',
          tags: <String>['Termin', 'Praxis', 'Hausarzt'],
          clinicType: DoctorClinicType.hausarzt,
        ),
        DoctorHubPhrase(
          id: 'facharzt_termin',
          german: 'Ich habe einen Termin beim Facharzt.',
          arabic: 'لدي موعد عند الطبيب المختص.',
          tags: <String>['Termin', 'Praxis', 'Facharzt'],
          clinicType: DoctorClinicType.facharzt,
        ),
        DoctorHubPhrase(
          id: 'karte_abgeben',
          german: 'Wo kann ich meine Gesundheitskarte abgeben?',
          arabic: 'أين يمكنني تسليم بطاقة التأمين الصحي؟',
          tags: <String>['Gesundheitskarte', 'Empfang'],
        ),
        DoctorHubPhrase(
          id: 'ueberweisung_frage',
          german: 'Ist eine Überweisung nötig?',
          arabic: 'هل الإحالة الطبية مطلوبة؟',
          tags: <String>['Überweisung', 'إحالة', 'Facharzt'],
          clinicType: DoctorClinicType.facharzt,
        ),
      ];

  List<DoctorHubPhrase> search(
    String query, {
    DoctorClinicType? clinicType,
  }) =>
      List<DoctorHubPhrase>.unmodifiable(
        overviewPhrases.where(
          (item) =>
              (clinicType == null ||
                  item.clinicType == null ||
                  item.clinicType == clinicType) &&
              item.matches(query),
        ),
      );
}
