import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/languages/declarative_language_engine.dart';
import 'package:deutsch_build/src/core/languages/vietnamese_language_registry.dart';

void main() {
  test('Registers Vietnamese language profile accurately', () {
    final engine = DeclarativeLanguageEngine()..initialize();
    VietnameseLanguageRegistry.registerProfiles(engine);

    final vi = engine.getProfile('vi');
    expect(vi, isNotNull);
    expect(vi!.autonym, equals('Tiếng Việt'));
    expect(vi.morphologyType, equals('Isolating'));
    expect(vi.typology, equals('SVO'));
  });
}
