import '../domain/health_models.dart';

final class PharmacyAgent {
  const PharmacyAgent();

  List<HealthLearningItem> get items =>
      const <HealthLearningItem>[
        HealthLearningItem(
          id: 'rx_have_prescription',
          level: HealthLevel.a1a2,
          service: HealthService.pharmacy,
          topic: HealthTopic.prescription,
          german: 'Ich habe ein Rezept.',
          arabic: 'لدي وصفة طبية.',
          tags: <String>['Rezept', 'Verschreibung', 'وصفة'],
        ),
        HealthLearningItem(
          id: 'rx_need_prescription',
          level: HealthLevel.b1,
          service: HealthService.pharmacy,
          topic: HealthTopic.prescription,
          german: 'Brauche ich dafür ein Rezept?',
          arabic: 'هل أحتاج إلى وصفة طبية لهذا؟',
          tags: <String>['Rezept', 'rezeptpflichtig', 'وصفة'],
        ),
        HealthLearningItem(
          id: 'dose_how_take',
          level: HealthLevel.a1a2,
          service: HealthService.pharmacy,
          topic: HealthTopic.dosage,
          german: 'Wie soll ich dieses Medikament einnehmen?',
          arabic: 'كيف ينبغي أن أتناول هذا الدواء؟',
          tags: <String>['Dosierung', 'einnehmen', 'جرعة', 'دواء'],
        ),
        HealthLearningItem(
          id: 'dose_leaflet',
          level: HealthLevel.b1,
          service: HealthService.pharmacy,
          topic: HealthTopic.dosage,
          german: 'Wo finde ich die Dosierungsangaben in der Packungsbeilage?',
          arabic: 'أين أجد معلومات الجرعة في النشرة المرفقة؟',
          tags: <String>['Dosierung', 'Packungsbeilage', 'جرعة', 'نشرة'],
        ),
        HealthLearningItem(
          id: 'ingredient_ask',
          level: HealthLevel.a1a2,
          service: HealthService.pharmacy,
          topic: HealthTopic.activeIngredient,
          german: 'Welcher Wirkstoff ist enthalten?',
          arabic: 'ما المادة الفعالة الموجودة؟',
          tags: <String>['Wirkstoff', 'Inhaltsstoff', 'مادة فعالة'],
        ),
        HealthLearningItem(
          id: 'ingredient_compare',
          level: HealthLevel.b2,
          service: HealthService.pharmacy,
          topic: HealthTopic.activeIngredient,
          german:
              'Enthält dieses Präparat denselben Wirkstoff wie mein bisheriges Medikament?',
          arabic:
              'هل يحتوي هذا المستحضر على المادة الفعالة نفسها الموجودة في دوائي السابق؟',
          tags: <String>['Wirkstoff', 'Präparat', 'Medikament', 'مادة فعالة'],
        ),
        HealthLearningItem(
          id: 'remedy_headache',
          level: HealthLevel.a1a2,
          service: HealthService.pharmacy,
          topic: HealthTopic.commonRemedy,
          german: 'Haben Sie etwas gegen Kopfschmerzen?',
          arabic: 'هل لديكم شيء للصداع؟',
          tags: <String>['Kopfschmerzen', 'Schmerzen', 'صداع', 'ألم'],
        ),
        HealthLearningItem(
          id: 'remedy_cold',
          level: HealthLevel.b1,
          service: HealthService.pharmacy,
          topic: HealthTopic.commonRemedy,
          german:
              'Was kann ich in der Apotheke bei einer leichten Erkältung erfragen?',
          arabic:
              'ما الذي يمكنني السؤال عنه في الصيدلية عند الإصابة بزكام خفيف؟',
          tags: <String>['Erkältung', 'Husten', 'Schnupfen', 'زكام'],
        ),
        HealthLearningItem(
          id: 'remedy_interaction',
          level: HealthLevel.b2,
          service: HealthService.pharmacy,
          topic: HealthTopic.commonRemedy,
          german:
              'Können Sie prüfen, ob es Wechselwirkungen mit meinen anderen Medikamenten gibt?',
          arabic:
              'هل يمكنكم التحقق مما إذا كانت هناك تداخلات مع أدويتي الأخرى؟',
          tags: <String>[
            'Wechselwirkungen',
            'Medikamente',
            'Arzneimittel',
            'تداخلات'
          ],
        ),
      ];
}
