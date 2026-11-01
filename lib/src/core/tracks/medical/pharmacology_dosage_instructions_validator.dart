class PharmacologyDosageInstructionsValidator {
  const PharmacologyDosageInstructionsValidator();
  String formatDosage(int timesPerDay, bool withFood, String lang) {
    if (lang == 'ar') return 'تناول الدواء $timesPerDay مرات يومياً ${withFood ? 'بعد الطعام' : 'على معدة فارغة'}.';
    return 'Take medication $timesPerDay times daily ${withFood ? 'after meals' : 'on an empty stomach'}.';
  }
}
