import 'buergeramt_anmeldung_scenario.dart';

/// Interactive dialogue scenario for school enrollment and positive parent-teacher collaboration.
class SchulanmeldungScenario {
  static const List<ScenarioDialogueTurn> turns = [
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Guten Tag! Sie möchten Ihr Kind für das neue Schuljahr an unserer Grundschule anmelden?',
      utteranceAr: 'نهاركم سعيد! تودون تسجيل طفلكم للعام الدراسي الجديد في مدرستنا الابتدائية؟',
      linguisticTip: 'die Grundschule = المدرسة الابتدائية (السنوات الأربع الأولى في ألمانيا).',
    ),
    ScenarioDialogueTurn(
      speaker: 'learner',
      utteranceDe: 'Guten Tag. Ja genau. Hier sind die Geburtsurkunde, der Impfpass und die Meldebestätigung.',
      utteranceAr: 'نهاركم سعيد. نعم بالضبط. تفضلوا شهادة الميلاد، ودفتر اللقاحات، وتأكيد تسجيل السكن.',
      linguisticTip: 'الأوراق الثبوتية الأساسية لتسجيل الأطفال في المدارس الألمانية.',
    ),
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Vielen Dank. Wie gut sind die bisherigen Deutschkenntnisse Ihres Kindes?',
      utteranceAr: 'شكراً جزيلاً لكم. كيف تقيّمون المستوى اللغوي الحالي لطفلكم في الألمانية؟',
      linguisticTip: 'السؤال التربوي المعتاد لتحديد الحاجة لصفوف الدعم اللغوي الإضافي.',
    ),
    ScenarioDialogueTurn(
      speaker: 'learner',
      utteranceDe: 'Er versteht schon sehr viel und lernt jeden Tag mit großer Freude neue Wörter dazu.',
      utteranceAr: 'هو يفهم الكثير بالفعل ويتعلم كل يوم مفردات جديدة بشغف وسرور كبيرين.',
      linguisticTip: 'mit großer Freude = بشغف وسرور وحماس.',
    ),
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Wunderbar. Wir haben auch ein hervorragendes Förderprogramm für zweisprachige Kinder.',
      utteranceAr: 'رائع جداً. يتوفر لدينا أيضاً برنامج دعم تربوي متميز للأطفال ثنائيي اللغة.',
      linguisticTip: 'das Förderprogramm = برنامج الدعم والتقوية التربوية.',
    ),
  ];
}
