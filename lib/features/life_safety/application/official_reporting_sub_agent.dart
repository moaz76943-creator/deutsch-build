import '../domain/safety_models.dart';

final class OfficialReportingSubAgent {
  const OfficialReportingSubAgent();

  List<SafetyLearningItem> get items => const <SafetyLearningItem>[
        SafetyLearningItem(
          id: 'lost_item_fundbuero',
          category: SafetyCategory.officialReporting,
          topic: SafetyTopic.lostItem,
          german: 'Ich möchte beim Fundbüro einen verlorenen Gegenstand melden.',
          arabic: 'أريد الإبلاغ لدى مكتب المفقودات عن غرض فقدته.',
          tags: <String>['Fundbüro', 'verloren', 'Gegenstand', 'مفقودات'],
        ),
        SafetyLearningItem(
          id: 'lost_wallet_details',
          category: SafetyCategory.officialReporting,
          topic: SafetyTopic.lostItem,
          german:
              'Ich habe gestern gegen 18 Uhr meine Geldbörse am Bahnhof verloren.',
          arabic:
              'فقدت محفظتي أمس نحو الساعة السادسة مساءً في محطة القطار.',
          tags: <String>['Geldbörse', 'Bahnhof', 'verloren', 'محفظة'],
        ),
        SafetyLearningItem(
          id: 'bike_theft_report',
          category: SafetyCategory.officialReporting,
          topic: SafetyTopic.bikeTheft,
          german: 'Ich möchte bei der Polizei einen Fahrraddiebstahl anzeigen.',
          arabic: 'أريد تقديم بلاغ لدى الشرطة عن سرقة دراجة.',
          tags: <String>['Polizei', 'Fahrrad', 'Diebstahl', 'Anzeige', 'سرقة'],
        ),
        SafetyLearningItem(
          id: 'bike_frame_number',
          category: SafetyCategory.officialReporting,
          topic: SafetyTopic.bikeTheft,
          german: 'Die Rahmennummer meines Fahrrads lautet AB-123456.',
          arabic: 'رقم هيكل دراجتي هو AB-123456.',
          tags: <String>['Rahmennummer', 'Fahrrad', 'Polizei', 'رقم الهيكل'],
        ),
        SafetyLearningItem(
          id: 'insurance_claim_open',
          category: SafetyCategory.officialReporting,
          topic: SafetyTopic.insuranceClaim,
          german: 'Ich möchte einen Schaden bei meiner Versicherung melden.',
          arabic: 'أريد الإبلاغ عن ضرر لدى شركة التأمين الخاصة بي.',
          tags: <String>['Versicherung', 'Schaden', 'melden', 'تأمين', 'ضرر'],
        ),
        SafetyLearningItem(
          id: 'insurance_claim_statement',
          category: SafetyCategory.officialReporting,
          topic: SafetyTopic.insuranceClaim,
          german:
              'Der Schaden ist am Montag um 14 Uhr auf einem Parkplatz entstanden.',
          arabic:
              'وقع الضرر يوم الاثنين الساعة الثانية بعد الظهر في موقف سيارات.',
          tags: <String>[
            'Schadensmeldung',
            'Parkplatz',
            'Zeitpunkt',
            'Versicherung',
            'تأمين',
          ],
        ),
        SafetyLearningItem(
          id: 'insurance_reference',
          category: SafetyCategory.officialReporting,
          topic: SafetyTopic.insuranceClaim,
          german:
              'Welche Unterlagen benötigen Sie für die Schadensmeldung?',
          arabic:
              'ما المستندات التي تحتاجونها لبلاغ الضرر؟',
          tags: <String>['Unterlagen', 'Schadensmeldung', 'Versicherung', 'مستندات'],
        ),
      ];
}
