enum PatientAgeGroup { pediatric, adult, geriatric }

class PediatricGeriatricClinicalAdapter {
  const PediatricGeriatricClinicalAdapter();
  String adaptTone(String message, PatientAgeGroup group) {
    if (group == PatientAgeGroup.pediatric) return 'أيها البطل، $message';
    return message;
  }
}
