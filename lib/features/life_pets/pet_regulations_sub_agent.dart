import 'pets_models.dart';

final class PetRegulationsSubAgent {
  const PetRegulationsSubAgent();

  List<PetPhrase> get phrases => _phrases;

  static const List<PetPhrase> _phrases = <PetPhrase>[
    PetPhrase(
      id: 'regulation-dog-tax',
      category: PetsCategory.regulationsAdoption,
      german: 'Wo und wie melde ich meinen Hund für die Hundesteuer an?',
      arabic: 'أين وكيف أسجل كلبي لضريبة الكلاب؟',
      contextDe: 'Kommunale Anmeldung zur Hundesteuer erfragen',
      contextAr: 'الاستفسار عن تسجيل الكلب لدى البلدية لضريبة الكلاب',
      keywords: <String>['Hundesteuer', 'Anmeldung', 'Gemeinde', 'Stadt'],
    ),
    PetPhrase(
      id: 'regulation-leash',
      category: PetsCategory.regulationsAdoption,
      german: 'Gilt hier eine Leinenpflicht für Hunde?',
      arabic: 'هل يوجد هنا إلزام بوضع الكلب على المقود؟',
      contextDe: 'Nach örtlichen Regeln zur Leinenpflicht fragen',
      contextAr: 'السؤال عن قواعد المقود المحلية',
      keywords: <String>['Leinenpflicht', 'Leine', 'Hund', 'Regel'],
    ),
    PetPhrase(
      id: 'shelter-visit',
      category: PetsCategory.regulationsAdoption,
      german: 'Kann ich das Tierheim zu den Besuchszeiten kennenlernen?',
      arabic: 'هل يمكنني زيارة مأوى الحيوانات خلال أوقات الزيارة؟',
      contextDe: 'Einen Besuch im Tierheim anfragen',
      contextAr: 'الاستفسار عن زيارة مأوى الحيوانات',
      keywords: <String>['Tierheim', 'Besuchszeiten', 'Besuch'],
    ),
    PetPhrase(
      id: 'shelter-adoption',
      category: PetsCategory.regulationsAdoption,
      german:
          'Ich interessiere mich für eine Adoption. Welche Voraussetzungen gibt es?',
      arabic: 'أنا مهتم بالتبنّي. ما الشروط المطلوبة؟',
      contextDe: 'Verantwortungsvoll nach einer Adoption fragen',
      contextAr: 'الاستفسار المسؤول عن شروط تبنّي حيوان',
      keywords: <String>['Adoption', 'adoptieren', 'Voraussetzungen', 'Tierheim'],
    ),
  ];
}
