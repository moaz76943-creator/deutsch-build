import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/languages/declarative_language_engine.dart';
import 'package:deutsch_build/src/core/languages/dravidian_languages_registry.dart';

void main() {
  test('Registers Dravidian agglutinative language profiles accurately', () {
    final engine = DeclarativeLanguageEngine()..initialize();
    DravidianLanguagesRegistry.registerProfiles(engine);

    final ta = engine.getProfile('ta');
    expect(ta, isNotNull);
    expect(ta!.morphologyType, equals('Agglutinative'));
    expect(ta.casesCount, equals(8));

    final ml = engine.getProfile('ml');
    expect(ml, isNotNull);
    expect(ml!.typology, equals('SOV'));
  });
}
