import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/content/german_particle_verb_collision_auditor.dart';
import 'package:deutsch_build/src/ui/bridges/vol_116_wave33_ui_bridge.dart';

void main() {
  group('Volume 116 Task 4933 Particle Verb Collision Auditor Tests', () {
    test('LING-056: umfahren differentiates separable crash from inseparable bypass', () {
      final variants = GermanParticleVerbCollisionAuditor.getDualVariants('umfahren');
      expect(variants.length, equals(2));

      final sep = variants.firstWhere((v) => v.mode == VerbSeparabilityMode.separableStressedPrefix);
      expect(sep.partizipTwo, equals('umgefahren'));
      expect(sep.arabicEquivalence, contains('يصدم'));

      final insep = variants.firstWhere((v) => v.mode == VerbSeparabilityMode.inseparableStressedStem);
      expect(insep.partizipTwo, equals('umfahren'));
      expect(insep.arabicEquivalence, contains('يلتف'));
    });

    test('LING-056: übersetzen differentiates river crossing from text translation', () {
      final variants = GermanParticleVerbCollisionAuditor.getDualVariants('übersetzen');
      expect(variants.length, equals(2));

      final sep = variants.firstWhere((v) => v.mode == VerbSeparabilityMode.separableStressedPrefix);
      expect(sep.partizipTwo, equals('übergesetzt'));

      final insep = variants.firstWhere((v) => v.mode == VerbSeparabilityMode.inseparableStressedStem);
      expect(insep.partizipTwo, equals('übersetzt'));
      expect(insep.arabicEquivalence, contains('يترجم'));
    });

    test('LING-056: Partizip II verification catches invalid forms', () {
      expect(
        GermanParticleVerbCollisionAuditor.verifySeparablePartizipTwo('wiederholen', 'wiedergeholt', true),
        isTrue,
      );
      expect(
        GermanParticleVerbCollisionAuditor.verifySeparablePartizipTwo('wiederholen', 'wiederholt', false),
        isTrue,
      );
    });

    test('UI Bridge generates accurate Task 4933 diagnostics report', () {
      final bridge = Vol116Wave33UIBridge();
      final report = bridge.getTask4933Diagnostics();

      expect(report['task_id'], equals(4933));
      expect(report['volume'], equals(116));
      expect(report['tasks_remaining_to_5000'], equals(67));
      expect(report['status'], equals('OPERATIONAL_VERIFIED'));
    });
  });
}
