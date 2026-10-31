import 'package:test/test.dart';
import 'package:deutsch_build/src/core/dialogue/dialogue_persona_fabricator.dart';

void main() {
  group('DialoguePersonaFabricator Tests', () {
    const fabricator = DialoguePersonaFabricator();

    test('Herr Schmidt enforces formal bureaucratic persona with precise pacing', () {
      final persona = fabricator.resolvePersona('herr_schmidt');

      expect(persona.name, equals('Herr Schmidt'));
      expect(persona.temperament, equals(PersonaTemperament.formalBureaucratic));
      expect(persona.systemPromptPersona, contains('formeller deutscher Beamter'));
      expect(persona.pacing.rateMultiplier, greaterThanOrEqualTo(1.0));
    });

    test('Opa Heinrich provides deliberate, slow pacing (0.82x) for low-stress beginners', () {
      final persona = fabricator.resolvePersona('opa_heinrich');

      expect(persona.name, equals('Opa Heinrich'));
      expect(persona.temperament, equals(PersonaTemperament.patientDeliberateTutor));
      expect(persona.pacing.rateMultiplier, lessThan(0.9));
      expect(persona.pacing.interSentencePauseMs, greaterThanOrEqualTo(400));
    });

    test('Anna student persona serializes to valid UI dialogue metadata', () {
      final persona = fabricator.resolvePersona('anna_student');
      final json = persona.toJson();

      expect(json['id'], equals('anna_student'));
      expect(json['temperament'], equals('warmFriendlyPeer'));
      expect(json['baseGreeting'], contains('Hi!'));
    });
  });
}
