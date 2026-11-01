enum TriageUrgencyLevel { nonUrgent, standard, urgent, resuscitation }

class ClinicalPatientTriageEngine {
  const ClinicalPatientTriageEngine();
  TriageUrgencyLevel evaluateVitals(int heartRate, int systolicBp) {
    if (heartRate > 130 || systolicBp < 80) return TriageUrgencyLevel.urgent;
    return TriageUrgencyLevel.standard;
  }
}
