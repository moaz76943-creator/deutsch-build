import 'utilities_models.dart';

final class EnergyContractsSubAgent {
  const EnergyContractsSubAgent();

  List<UtilitiesPhrase> get phrases => _phrases;

  static const List<UtilitiesPhrase> _phrases = <UtilitiesPhrase>[
    UtilitiesPhrase(
      id: 'contract-register-move-in',
      category: UtilitiesCategory.contractsSwitching,
      german:
          'Ich bin neu eingezogen und möchte mich für Strom beim Grundversorger anmelden. Welche Angaben brauchen Sie?',
      arabic:
          'انتقلت حديثاً وأريد التسجيل للكهرباء لدى المزوّد الأساسي. ما البيانات التي تحتاجونها؟',
      contextDe: 'Nach dem Einzug beim Grundversorger anmelden',
      contextAr: 'التسجيل لدى المزوّد الأساسي بعد الانتقال إلى السكن',
      keywords: <String>[
        'Grundversorger',
        'Anmeldung',
        'Einzug',
        'Strom anmelden',
        'انتقال',
        'تسجيل الكهرباء',
      ],
    ),
    UtilitiesPhrase(
      id: 'contract-compare-tariffs',
      category: UtilitiesCategory.contractsSwitching,
      german:
          'Wie hoch sind bei diesem Tarif der kWh-Preis und der monatliche Grundpreis, und gibt es eine Preisgarantie?',
      arabic:
          'كم سعر الكيلوواط/ساعة في هذه التعرفة، وكم السعر الأساسي الشهري، وهل توجد ضمانة للسعر؟',
      contextDe: 'Tarifvergleich: kWh-Preis und Grundpreis prüfen',
      contextAr: 'مقارنة التعرفات عبر سعر الاستهلاك والسعر الأساسي',
      keywords: <String>[
        'Tarifvergleich',
        'Tarif',
        'kWh-Preis',
        'Grundpreis',
        'Preisgarantie',
        'تعرفة',
        'سعر',
      ],
    ),
    UtilitiesPhrase(
      id: 'contract-cancellation-period',
      category: UtilitiesCategory.contractsSwitching,
      german:
          'Welche Kündigungsfrist gilt für meinen Vertrag, und zu welchem Termin kann ich frühestens kündigen?',
      arabic:
          'ما مهلة الإلغاء المطبقة على عقدي، وما أقرب موعد يمكنني إنهاء العقد فيه؟',
      contextDe: 'Kündigungsfrist und Vertragsende klären',
      contextAr: 'معرفة مهلة الإلغاء وموعد انتهاء العقد',
      keywords: <String>[
        'Kündigungsfrist',
        'kündigen',
        'Vertragsende',
        'Laufzeit',
        'إلغاء العقد',
        'مدة العقد',
      ],
    ),
  ];
}
