final class UrgentMedicalTermEntry {
  const UrgentMedicalTermEntry({
    required this.id,
    required this.labelDe,
    required this.labelAr,
    required this.exampleDe,
    required this.exampleAr,
  });

  final String id;
  final String labelDe;
  final String labelAr;
  final String exampleDe;
  final String exampleAr;
}

final class UrgentMedicalTerms {
  const UrgentMedicalTerms();

  List<UrgentMedicalTermEntry> get entries => _entries;

  String painScalePhraseDe(int score) {
    _validateScore(score);
    return 'Die Schmerzen sind $score von 10.';
  }

  String painScalePhraseAr(int score) {
    _validateScore(score);
    return 'شدة الألم $score من 10.';
  }

  static void _validateScore(int score) {
    if (score < 0 || score > 10) {
      throw RangeError.range(score, 0, 10, 'score');
    }
  }

  static const List<UrgentMedicalTermEntry> _entries =
      <UrgentMedicalTermEntry>[
    UrgentMedicalTermEntry(
      id: 'pain_location',
      labelDe: 'Schmerzort',
      labelAr: 'موضع الألم',
      exampleDe: 'Die Schmerzen sind im rechten Unterbauch.',
      exampleAr: 'الألم في أسفل البطن من الجهة اليمنى.',
    ),
    UrgentMedicalTermEntry(
      id: 'pain_severity',
      labelDe: 'Schmerzstärke',
      labelAr: 'شدة الألم',
      exampleDe: 'Die Schmerzen sind acht von zehn.',
      exampleAr: 'شدة الألم ثمانية من عشرة.',
    ),
    UrgentMedicalTermEntry(
      id: 'pain_quality',
      labelDe: 'Schmerzart',
      labelAr: 'طبيعة الألم',
      exampleDe: 'Der Schmerz ist stechend und kommt in Wellen.',
      exampleAr: 'الألم طاعن ويأتي على شكل موجات.',
    ),
    UrgentMedicalTermEntry(
      id: 'pain_onset',
      labelDe: 'Beginn',
      labelAr: 'بداية الألم',
      exampleDe: 'Die Schmerzen haben plötzlich angefangen.',
      exampleAr: 'بدأ الألم بشكل مفاجئ.',
    ),
    UrgentMedicalTermEntry(
      id: 'pain_duration',
      labelDe: 'Dauer',
      labelAr: 'مدة الألم',
      exampleDe: 'Ich habe die Schmerzen seit drei Stunden.',
      exampleAr: 'لدي هذا الألم منذ ثلاث ساعات.',
    ),
    UrgentMedicalTermEntry(
      id: 'fever',
      labelDe: 'Fieber',
      labelAr: 'الحمّى',
      exampleDe: 'Ich habe 39,2 Grad Fieber.',
      exampleAr: 'درجة حرارتي 39.2.',
    ),
    UrgentMedicalTermEntry(
      id: 'nausea',
      labelDe: 'Übelkeit und Erbrechen',
      labelAr: 'الغثيان والقيء',
      exampleDe: 'Mir ist übel und ich habe dreimal erbrochen.',
      exampleAr: 'أشعر بالغثيان وتقيأت ثلاث مرات.',
    ),
    UrgentMedicalTermEntry(
      id: 'medication',
      labelDe: 'Medikamente',
      labelAr: 'الأدوية',
      exampleDe: 'Ich nehme regelmäßig Blutdruckmedikamente.',
      exampleAr: 'أتناول أدوية ضغط الدم بانتظام.',
    ),
    UrgentMedicalTermEntry(
      id: 'allergy',
      labelDe: 'Allergien',
      labelAr: 'الحساسية',
      exampleDe: 'Ich bin allergisch gegen Penicillin.',
      exampleAr: 'لدي حساسية من البنسلين.',
    ),
  ];
}
