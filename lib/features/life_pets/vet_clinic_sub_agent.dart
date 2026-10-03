import 'pets_models.dart';

final class VetClinicSubAgent {
  const VetClinicSubAgent();

  List<PetPhrase> get phrases => _phrases;

  static const List<PetPhrase> _phrases = <PetPhrase>[
    PetPhrase(
      id: 'vet-appointment',
      category: PetsCategory.veterinary,
      german: 'Ich möchte einen Termin für mein Haustier vereinbaren.',
      arabic: 'أود حجز موعد لحيواني الأليف.',
      contextDe: 'Einen Tierarzttermin vereinbaren',
      contextAr: 'حجز موعد لدى العيادة البيطرية',
      keywords: <String>['Termin', 'Tierarzt', 'Tierklinik', 'vereinbaren'],
    ),
    PetPhrase(
      id: 'vet-symptoms',
      category: PetsCategory.veterinary,
      german:
          'Mein Tier frisst seit gestern nicht und wirkt ungewöhnlich müde.',
      arabic: 'حيواني لا يأكل منذ أمس ويبدو متعبًا بشكل غير معتاد.',
      contextDe: 'Beobachtete Symptome sachlich beschreiben',
      contextAr: 'وصف الأعراض التي تمت ملاحظتها دون تشخيص ذاتي',
      keywords: <String>['Symptome', 'frisst nicht', 'müde', 'Beschwerden'],
    ),
    PetPhrase(
      id: 'vet-vaccinations',
      category: PetsCategory.veterinary,
      german: 'Welche Impfungen sind für mein Tier jetzt fällig?',
      arabic: 'ما التطعيمات المستحقة لحيواني الآن؟',
      contextDe: 'Nach routinemäßigen Impfungen fragen',
      contextAr: 'السؤال عن التطعيمات الروتينية',
      keywords: <String>['Impfung', 'Impfungen', 'Impfschutz', 'fällig'],
    ),
    PetPhrase(
      id: 'vet-pet-passport',
      category: PetsCategory.veterinary,
      german: 'Was brauche ich für einen EU-Heimtierausweis?',
      arabic: 'ما الذي أحتاجه لاستخراج جواز سفر أوروبي للحيوان الأليف؟',
      contextDe: 'Informationen zum EU-Heimtierausweis erfragen',
      contextAr: 'الاستفسار عن جواز سفر الحيوان الأليف الأوروبي',
      keywords: <String>['EU-Heimtierausweis', 'Heimtierausweis', 'Reise'],
    ),
  ];
}
