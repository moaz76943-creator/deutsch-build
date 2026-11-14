import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/languages/declarative_language_engine.dart';
import 'package:deutsch_build/src/core/languages/baltic_languages_registry.dart';

void main() {
  test('Registers Baltic language profiles accurately', () {
    final engine = DeclarativeLanguageEngine()..initialize();
    BalticLanguagesRegistry.registerProfiles(engine);

    final lt = engine.getProfile('lt');
    expect(lt, isNotNull);
    expect(lt!.casesCount, equals(7));

    final et = engine.getProfile('et');
    expect(et, isNotNull);
    expect(et!.casesCount, equals(14));
    expect(et.morphologyType, equals('Agglutinative'));
  });
}
