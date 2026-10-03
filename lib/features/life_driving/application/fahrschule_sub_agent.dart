import '../domain/driving_models.dart';

final class FahrschuleSubAgent {
  const FahrschuleSubAgent();

  List<DrivingLearningItem> get items => _items;

  static const List<DrivingLearningItem> _items = <DrivingLearningItem>[
    DrivingLearningItem(
      id: 'school_enrollment',
      category: DrivingCategory.fahrschule,
      topic: DrivingTopic.enrollment,
      titleDe: 'Bei der Fahrschule anmelden',
      german: 'Ich möchte mich bei Ihrer Fahrschule anmelden.',
      arabic: 'أريد التسجيل في مدرسة القيادة لديكم.',
      tags: <String>['Fahrschule', 'Anmeldung', 'anmelden', 'تسجيل'],
    ),
    DrivingLearningItem(
      id: 'school_theory_booking',
      category: DrivingCategory.fahrschule,
      topic: DrivingTopic.theoryClass,
      titleDe: 'Theorieunterricht buchen',
      german: 'Wann findet der nächste Theorieunterricht statt?',
      arabic: 'متى موعد درس النظري القادم؟',
      tags: <String>[
        'Theorieunterricht',
        'Theoriestunde',
        'Termin',
        'نظري',
      ],
    ),
    DrivingLearningItem(
      id: 'school_theory_schedule',
      category: DrivingCategory.fahrschule,
      topic: DrivingTopic.theoryClass,
      titleDe: 'Theorieplan erfragen',
      german: 'Muss ich mich für die Theoriestunde vorher anmelden?',
      arabic: 'هل يجب أن أسجل مسبقاً لدرس النظري؟',
      tags: <String>['Theorie', 'Stundenplan', 'anmelden', 'موعد'],
    ),
    DrivingLearningItem(
      id: 'school_practical_turn',
      category: DrivingCategory.fahrschule,
      topic: DrivingTopic.practicalLesson,
      titleDe: 'Anweisung in der Fahrstunde',
      german: 'Bitte biegen Sie an der nächsten Kreuzung rechts ab.',
      arabic: 'من فضلك انعطف يميناً عند التقاطع القادم.',
      tags: <String>['Fahrstunde', 'Kreuzung', 'rechts abbiegen', 'انعطف'],
    ),
    DrivingLearningItem(
      id: 'school_practical_check',
      category: DrivingCategory.fahrschule,
      topic: DrivingTopic.practicalLesson,
      titleDe: 'Spiegel und Schulterblick',
      german: 'Spiegel, Blinker und Schulterblick nicht vergessen.',
      arabic: 'لا تنسَ المرآة والإشارة والنظر فوق الكتف.',
      tags: <String>[
        'Spiegel',
        'Blinker',
        'Schulterblick',
        'Fahrlehrer',
        'مرآة',
      ],
    ),
    DrivingLearningItem(
      id: 'school_first_aid_requirement',
      category: DrivingCategory.fahrschule,
      topic: DrivingTopic.firstAid,
      titleDe: 'Erste-Hilfe-Kurs nachweisen',
      german: 'Brauche ich eine Bescheinigung über den Erste-Hilfe-Kurs?',
      arabic: 'هل أحتاج إلى شهادة دورة الإسعافات الأولية؟',
      tags: <String>[
        'Erste-Hilfe-Kurs',
        'Bescheinigung',
        'Nachweis',
        'إسعافات أولية',
      ],
    ),
  ];
}
