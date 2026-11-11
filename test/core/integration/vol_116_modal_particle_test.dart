import 'package:test/test.dart';
import 'package:deutsch_build/src/core/content/german_modal_particle_engine.dart';
import 'package:deutsch_build/src/ui/bridges/vol_116_wave3_ui_bridge.dart';

void main() {
  group('Volume 116 Task 4903 Modal Particle Engine Tests', () {
    test('LING-026: mal softens imperative commands into friendly requests', () {
      final res = GermanModalParticleEngine.injectParticle(
        subject: 'Sie',
        verb: 'Kommen',
        particle: 'mal',
        remainder: 'herein',
        mood: SentencePragmaticMood.imperative,
      );

      expect(res.particle, equals('mal'));
      expect(res.nuance, equals(ParticlePragmaticNuance.politeSoftener));
      expect(res.nuancedSentence, equals('Kommen Sie mal herein!'));
      expect(res.arabicExplanation, contains('تلطيف'));
    });

    test('LING-026: denn injects genuine interest into questions', () {
      final res = GermanModalParticleEngine.injectParticle(
        subject: 'du',
        verb: 'Wie heißt',
        particle: 'denn',
        remainder: '',
        mood: SentencePragmaticMood.question,
      );

      expect(res.particle, equals('denn'));
      expect(res.nuance, equals(ParticlePragmaticNuance.genuineInterest));
      expect(res.nuancedSentence, equals('Wie heißt du denn?'));
    });

    test('LING-026: ja expresses shared consensus in statements', () {
      final res = GermanModalParticleEngine.injectParticle(
        subject: 'Das',
        verb: 'ist',
        particle: 'ja',
        remainder: 'wunderbar',
        mood: SentencePragmaticMood.statement,
      );

      expect(res.particle, equals('ja'));
      expect(res.nuance, equals(ParticlePragmaticNuance.sharedCommonKnowledge));
      expect(res.nuancedSentence, equals('Das ist ja wunderbar.'));
    });

    test('UI Bridge generates accurate Task 4903 diagnostics report', () {
      final bridge = Vol116Wave3UIBridge();
      final report = bridge.getTask4903Diagnostics();

      expect(report['task_id'], equals(4903));
      expect(report['volume'], equals(116));
      expect(report['tasks_remaining_to_5000'], equals(97));
      expect(report['status'], equals('OPERATIONAL_VERIFIED'));
    });
  });
}
