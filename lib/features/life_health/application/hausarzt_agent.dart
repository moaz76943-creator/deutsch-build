import '../domain/health_models.dart';

final class HausarztAgent {
  const HausarztAgent();

  List<HealthLearningItem> get items =>
      const <HealthLearningItem>[
        HealthLearningItem(
          id: 'appointment_simple',
          level: HealthLevel.a1a2,
          service: HealthService.hausarzt,
          topic: HealthTopic.appointment,
          german: 'Ich möchte einen Termin beim Hausarzt vereinbaren.',
          arabic: 'أريد حجز موعد عند طبيب الأسرة.',
          tags: <String>['Termin', 'Hausarzt', 'موعد', 'طبيب'],
        ),
        HealthLearningItem(
          id: 'appointment_urgent',
          level: HealthLevel.b1,
          service: HealthService.hausarzt,
          topic: HealthTopic.appointment,
          german:
              'Haben Sie heute noch einen Termin, weil meine Beschwerden stärker geworden sind?',
          arabic:
              'هل لديكم موعد اليوم لأن الأعراض أصبحت أشد؟',
          tags: <String>['Termin', 'Beschwerden', 'dringend', 'موعد', 'أعراض'],
        ),
        HealthLearningItem(
          id: 'appointment_followup',
          level: HealthLevel.b2,
          service: HealthService.hausarzt,
          topic: HealthTopic.appointment,
          german:
              'Ich würde gern einen Kontrolltermin zur Besprechung der Untersuchungsergebnisse vereinbaren.',
          arabic:
              'أود حجز موعد متابعة لمناقشة نتائج الفحوصات.',
          tags: <String>[
            'Kontrolltermin',
            'Untersuchungsergebnisse',
            'متابعة',
            'فحوصات'
          ],
        ),
        HealthLearningItem(
          id: 'symptom_headache',
          level: HealthLevel.a1a2,
          service: HealthService.hausarzt,
          topic: HealthTopic.symptom,
          german: 'Ich habe seit gestern Kopfschmerzen.',
          arabic: 'لدي صداع منذ أمس.',
          tags: <String>['Kopfschmerzen', 'Schmerzen', 'صداع', 'ألم'],
        ),
        HealthLearningItem(
          id: 'symptom_duration',
          level: HealthLevel.b1,
          service: HealthService.hausarzt,
          topic: HealthTopic.symptom,
          german:
              'Die Schmerzen treten seit drei Tagen vor allem am Abend auf.',
          arabic:
              'تظهر الآلام منذ ثلاثة أيام وخاصة في المساء.',
          tags: <String>['Schmerzen', 'Dauer', 'abends', 'ألم', 'مدة'],
        ),
        HealthLearningItem(
          id: 'symptom_precise',
          level: HealthLevel.b2,
          service: HealthService.hausarzt,
          topic: HealthTopic.symptom,
          german:
              'Die Beschwerden werden bei Belastung stärker und lassen in Ruhe wieder nach.',
          arabic:
              'تزداد الأعراض مع الجهد وتخف مرة أخرى أثناء الراحة.',
          tags: <String>[
            'Beschwerden',
            'Belastung',
            'Ruhe',
            'Symptome',
            'أعراض'
          ],
        ),
        HealthLearningItem(
          id: 'au_simple',
          level: HealthLevel.a1a2,
          service: HealthService.hausarzt,
          topic: HealthTopic.sickLeaveNote,
          german: 'Brauche ich eine Arbeitsunfähigkeitsbescheinigung?',
          arabic: 'هل أحتاج إلى شهادة عدم القدرة على العمل؟',
          tags: <String>[
            'Arbeitsunfähigkeit',
            'AU',
            'Krankschreibung',
            'إجازة مرضية'
          ],
        ),
        HealthLearningItem(
          id: 'au_duration',
          level: HealthLevel.b1,
          service: HealthService.hausarzt,
          topic: HealthTopic.sickLeaveNote,
          german:
              'Für welchen Zeitraum gilt die Arbeitsunfähigkeitsbescheinigung?',
          arabic:
              'لأي مدة تسري شهادة عدم القدرة على العمل؟',
          tags: <String>['Arbeitsunfähigkeit', 'Zeitraum', 'AU', 'مدة'],
        ),
        HealthLearningItem(
          id: 'au_employer',
          level: HealthLevel.b2,
          service: HealthService.hausarzt,
          topic: HealthTopic.sickLeaveNote,
          german:
              'Wie wird die Arbeitsunfähigkeit gegenüber dem Arbeitgeber nachgewiesen?',
          arabic:
              'كيف يتم إثبات عدم القدرة على العمل أمام صاحب العمل؟',
          tags: <String>[
            'Arbeitsunfähigkeit',
            'Arbeitgeber',
            'Nachweis',
            'AU',
            'صاحب العمل'
          ],
        ),
      ];
}
