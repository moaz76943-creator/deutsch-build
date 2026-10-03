import '../domain/doctor_appointment_models.dart';

enum ConsultationStage {
  symptoms,
  medicalHistory,
  sickNote,
  reportReferral;

  String get german => switch (this) {
        ConsultationStage.symptoms => 'Beschwerden',
        ConsultationStage.medicalHistory => 'Vorgeschichte',
        ConsultationStage.sickNote => 'AU / Krankschreibung',
        ConsultationStage.reportReferral => 'Befund & Überweisung',
      };

  String get arabic => switch (this) {
        ConsultationStage.symptoms => 'الأعراض ومدة الألم',
        ConsultationStage.medicalHistory => 'الحساسية والأدوية',
        ConsultationStage.sickNote => 'الإجازة المرضية',
        ConsultationStage.reportReferral => 'التقرير والإحالة',
      };
}

final class ConsultationSickNoteAgent {
  const ConsultationSickNoteAgent();

  static const Map<ConsultationStage, List<DoctorHubPhrase>> _items =
      <ConsultationStage, List<DoctorHubPhrase>>{
    ConsultationStage.symptoms: <DoctorHubPhrase>[
      DoctorHubPhrase(
        id: 'symptom_throat',
        german: 'Ich habe seit drei Tagen Halsschmerzen.',
        arabic: 'لدي ألم في الحلق منذ ثلاثة أيام.',
        tags: <String>['Beschwerden', 'Seit', 'Dauer', 'ألم'],
      ),
      DoctorHubPhrase(
        id: 'symptom_pain_stronger',
        german: 'Der Schmerz ist seit gestern stärker.',
        arabic: 'الألم أصبح أقوى منذ أمس.',
        tags: <String>['Schmerz', 'seit gestern', 'ألم'],
      ),
      DoctorHubPhrase(
        id: 'symptom_location',
        german: 'Es tut hier weh.',
        arabic: 'يؤلمني هنا.',
        tags: <String>['Schmerz', 'weh', 'ألم'],
      ),
      DoctorHubPhrase(
        id: 'symptom_duration',
        german: 'Die Beschwerden dauern seit einer Woche an.',
        arabic: 'الأعراض مستمرة منذ أسبوع.',
        tags: <String>['Beschwerden', 'Dauer', 'Seit'],
      ),
    ],
    ConsultationStage.medicalHistory: <DoctorHubPhrase>[
      DoctorHubPhrase(
        id: 'history_allergy',
        german: 'Ich bin gegen Penicillin allergisch.',
        arabic: 'لدي حساسية من البنسلين.',
        tags: <String>['allergisch', 'Allergie', 'Medikament'],
      ),
      DoctorHubPhrase(
        id: 'history_intolerance',
        german: 'Ich vertrage dieses Medikament nicht.',
        arabic: 'لا أتحمل هذا الدواء.',
        tags: <String>['Medikament', 'vertragen', 'حساسية'],
      ),
      DoctorHubPhrase(
        id: 'history_current_meds',
        german: 'Ich nehme zurzeit diese Medikamente.',
        arabic: 'أتناول هذه الأدوية حالياً.',
        tags: <String>['Medikamente', 'Vorgeschichte'],
      ),
      DoctorHubPhrase(
        id: 'history_no_allergies',
        german: 'Ich habe keine bekannten Allergien.',
        arabic: 'ليست لدي حساسية معروفة.',
        tags: <String>['Allergien', 'bekannt'],
      ),
    ],
    ConsultationStage.sickNote: <DoctorHubPhrase>[
      DoctorHubPhrase(
        id: 'au_question',
        german:
            'Brauche ich eine Arbeitsunfähigkeitsbescheinigung (AU)?',
        arabic: 'هل أحتاج إلى شهادة عدم القدرة على العمل (AU)؟',
        tags: <String>['AU', 'Arbeitsunfähigkeitsbescheinigung'],
      ),
      DoctorHubPhrase(
        id: 'sicknote_duration',
        german: 'Wie lange gilt die Krankschreibung?',
        arabic: 'إلى متى تسري الإجازة المرضية؟',
        tags: <String>['Krankschreibung', 'Dauer', 'AU'],
      ),
      DoctorHubPhrase(
        id: 'employer_question',
        german: 'Was soll ich meinem Arbeitgeber mitteilen?',
        arabic: 'ماذا ينبغي أن أبلغ جهة عملي؟',
        tags: <String>['Arbeitgeber', 'AU', 'Krankschreibung'],
      ),
      DoctorHubPhrase(
        id: 'certificate_request',
        german: 'Kann ich eine Bescheinigung bekommen?',
        arabic: 'هل يمكنني الحصول على شهادة؟',
        tags: <String>['Bescheinigung', 'AU'],
      ),
    ],
    ConsultationStage.reportReferral: <DoctorHubPhrase>[
      DoctorHubPhrase(
        id: 'report_request',
        german: 'Kann ich den Befundbericht bekommen?',
        arabic: 'هل يمكنني الحصول على تقرير الفحص؟',
        tags: <String>['Befundbericht', 'Bericht'],
      ),
      DoctorHubPhrase(
        id: 'referral_request',
        german: 'Bekomme ich eine Überweisung zum Facharzt?',
        arabic: 'هل أحصل على إحالة إلى طبيب مختص؟',
        tags: <String>['Überweisung', 'Facharzt'],
      ),
      DoctorHubPhrase(
        id: 'specialist_question',
        german: 'Zu welchem Facharzt soll ich gehen?',
        arabic: 'إلى أي طبيب مختص ينبغي أن أذهب؟',
        tags: <String>['Facharzt', 'Überweisung'],
      ),
      DoctorHubPhrase(
        id: 'follow_up',
        german: 'Wann soll ich wiederkommen?',
        arabic: 'متى ينبغي أن أعود للمراجعة؟',
        tags: <String>['Kontrolle', 'Termin'],
      ),
    ],
  };

  List<DoctorHubPhrase> get allItems => List<DoctorHubPhrase>.unmodifiable(
        <DoctorHubPhrase>[
          for (final stage in ConsultationStage.values) ..._items[stage]!,
        ],
      );

  List<DoctorHubPhrase> itemsFor(ConsultationStage stage) =>
      List<DoctorHubPhrase>.unmodifiable(_items[stage]!);

  List<DoctorHubPhrase> search(
    String query, {
    ConsultationStage? stage,
  }) {
    final source = stage == null ? allItems : itemsFor(stage);
    return List<DoctorHubPhrase>.unmodifiable(
      source.where((item) => item.matches(query)),
    );
  }
}
