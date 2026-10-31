import 'package:deutsch_build/core/linguistics/infinitiv_mit_zu_engine.dart';

void main() {
  final engine = InfinitivMitZuEngine();

  // 1. كشف الخطأ الحاسم: حظر zu مع أفعال المودال (Ich kann schwimmen وليس *zu schwimmen)
  final resModalError = engine.auditUsage(
    mainVerb: 'können',
    dependentVerb: 'schwimmen',
    learnerUsedZu: true,
  );
  assert(!resModalError.isValid);
  assert(resModalError.errorMessage!.contains('دون "zu"'));

  // 2. صحة المصدر مع أفعال الرغبة والمحاولة: versuchen + zu lernen
  final resVersuchen = engine.auditUsage(
    mainVerb: 'versuchen',
    dependentVerb: 'lernen',
    learnerUsedZu: true,
  );
  assert(resVersuchen.isValid);
  assert(resVersuchen.correctForm == 'zu lernen');

  // 3. الفعل المنفصل مع zu في الوسط: aufstehen -> aufzustehen
  final resSeparable = engine.auditUsage(
    mainVerb: 'hoffen',
    dependentVerb: 'stehen',
    learnerUsedZu: true,
    isSeparableDependent: true,
    separablePrefix: 'auf',
  );
  assert(resSeparable.isValid);
  assert(resSeparable.correctForm == 'aufzustehen');

  // 4. فحص شرط تطابق الفاعل في (um ... zu)
  assert(engine.isValidUmZuSubject(subjectsAreIdentical: true));
  assert(!engine.isValidUmZuSubject(subjectsAreIdentical: false)); // يتطلب damit

  print('Infinitiv mit zu engine assertions passed.');
}
