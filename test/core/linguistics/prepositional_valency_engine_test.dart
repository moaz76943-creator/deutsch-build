import 'package:deutsch_build/core/linguistics/prepositional_valency_engine.dart';

void main() {
  final engine = PrepositionalValencyEngine();

  // 1. صحيح: warten auf + Akkusativ
  final resWartenValid = engine.auditUsage(
    verb: 'warten',
    usedPreposition: 'auf',
    usedCase: GovernedCase.accusative,
  );
  assert(resWartenValid.isValid);

  // 2. خطأ إعرابي: استخدام Dativ مع warten auf
  final resWartenWrongCase = engine.auditUsage(
    verb: 'warten',
    usedPreposition: 'auf',
    usedCase: GovernedCase.dative,
  );
  assert(!resWartenWrongCase.isValid);
  assert(resWartenWrongCase.errorMessage!.contains('خطأ إعرابي'));

  // 3. خطأ في حرف الجر: استخدام für مع warten
  final resWartenWrongPrep = engine.auditUsage(
    verb: 'warten',
    usedPreposition: 'für',
    usedCase: GovernedCase.accusative,
  );
  assert(!resWartenWrongPrep.isValid);
  assert(resWartenWrongPrep.errorMessage!.contains('خطأ في حرف الجر'));

  // 4. التمييز الدقيق: teilnehmen an + Dativ
  final resTeilnehmen = engine.auditUsage(
    verb: 'teilnehmen',
    usedPreposition: 'an',
    usedCase: GovernedCase.dative,
  );
  assert(resTeilnehmen.isValid);

  print('Prepositional valency engine assertions passed.');
}
