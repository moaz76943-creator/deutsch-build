import '../emergency_health_models.dart';
import 'ambulance_112_phrase_bank.dart';
import 'ambulance_112_w_questions.dart';

final class Ambulance112SubAgent implements EmergencyHealthContentSource {
  const Ambulance112SubAgent({
    this.wQuestions = const Ambulance112WQuestions(),
  });

  final Ambulance112WQuestions wQuestions;

  @override
  EmergencyHealthDomain get domain => EmergencyHealthDomain.ambulance112;

  @override
  List<EmergencyPhrase> get items => Ambulance112PhraseBank.items;
}
