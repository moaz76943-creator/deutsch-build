import '../emergency_health_models.dart';
import 'notdienst_phrase_bank.dart';
import 'urgent_medical_terms.dart';

final class NotdienstDoctorSubAgent implements EmergencyHealthContentSource {
  const NotdienstDoctorSubAgent({
    this.medicalTerms = const UrgentMedicalTerms(),
  });

  final UrgentMedicalTerms medicalTerms;

  @override
  EmergencyHealthDomain get domain => EmergencyHealthDomain.medicalOnCall;

  @override
  List<EmergencyPhrase> get items => NotdienstPhraseBank.items;
}
