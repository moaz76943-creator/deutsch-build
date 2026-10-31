import 'package:deutsch_build/core/linguistics/tekamolo_engine.dart';

void main() {
  final engine = TeKaMoLoEngine();

  // اختبار الترتيب الصحيح: اليوم (Te) -> بسبب المطر (Ka) -> بالحافلة (Mo) -> إلى البيت (Lo)
  final validCase = [
    const AdverbialSegment('heute', AdverbialType.temporal),
    const AdverbialSegment('wegen des Regens', AdverbialType.kausal),
    const AdverbialSegment('mit dem Bus', AdverbialType.modal),
    const AdverbialSegment('nach Hause', AdverbialType.lokal),
  ];
  final resValid = engine.validateOrder(validCase);
  if (!resValid.isValid) {
    throw StateError('TeKaMoLo engine falsely rejected a valid sequence');
  }

  // اختبار الترتيب الخاطئ: إلى البيت (Lo) قبل اليوم (Te)
  final invalidCase = [
    const AdverbialSegment('nach Hause', AdverbialType.lokal),
    const AdverbialSegment('heute', AdverbialType.temporal),
  ];
  final resInvalid = engine.validateOrder(invalidCase);
  if (resInvalid.isValid || resInvalid.violations.isEmpty) {
    throw StateError('TeKaMoLo engine failed to detect topological inversion');
  }

  print('TeKaMoLo unit verification passed.');
}
