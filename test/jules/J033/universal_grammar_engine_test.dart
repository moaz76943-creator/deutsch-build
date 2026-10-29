import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/language_intelligence/language_grammar_rule_provider.dart';
import 'package:deutsch_bilarabi/core/language_intelligence/universal_grammar_provider.dart';
import 'package:deutsch_bilarabi/core/language_intelligence/universal_grammar_engine.dart';

// Mocks

class EnglishGrammarProvider extends UniversalGrammarProvider {
  @override
  String get languageCode => 'en';

  @override
  GrammarProfile get profile => const GrammarProfile(
        supportedFeatures: {GrammarFeature.analytic, GrammarFeature.number, GrammarFeature.tense, GrammarFeature.person},
      );

  @override
  GrammaticalNumber extractNumber(String word) {
    if (word.endsWith('s')) return GrammaticalNumber.plural;
    return GrammaticalNumber.singular;
  }
}

class TurkishGrammarProvider extends UniversalGrammarProvider {
  @override
  String get languageCode => 'tr';

  @override
  GrammarProfile get profile => const GrammarProfile(
        supportedFeatures: {GrammarFeature.agglutinative, GrammarFeature.grammaticalCase, GrammarFeature.number},
      );

  @override
  GrammaticalCase extractCase(String word) {
    if (word.endsWith('ı') || word.endsWith('i') || word.endsWith('u') || word.endsWith('ü')) {
      return GrammaticalCase.accusative;
    }
    return GrammaticalCase.nominative;
  }
}

class ArabicGrammarProvider extends UniversalGrammarProvider {
  @override
  String get languageCode => 'ar';

  @override
  GrammarProfile get profile => const GrammarProfile(
        supportedFeatures: {
          GrammarFeature.rootPattern,
          GrammarFeature.gender,
          GrammarFeature.number,
          GrammarFeature.grammaticalCase,
        },
      );

  @override
  GrammaticalGender extractGender(String word, {String? article}) {
    if (word.endsWith('ة')) return GrammaticalGender.feminine;
    return GrammaticalGender.masculine;
  }
}

class RussianGrammarProvider extends UniversalGrammarProvider {
  @override
  String get languageCode => 'ru';

  @override
  GrammarProfile get profile => const GrammarProfile(
        supportedFeatures: {
          GrammarFeature.inflectional,
          GrammarFeature.gender,
          GrammarFeature.grammaticalCase,
          GrammarFeature.number,
        },
      );

  @override
  GrammaticalGender extractGender(String word, {String? article}) {
    if (word.endsWith('а') || word.endsWith('я')) return GrammaticalGender.feminine;
    if (word.endsWith('о') || word.endsWith('е')) return GrammaticalGender.neuter;
    return GrammaticalGender.masculine;
  }
}

void main() {
  group('UniversalGrammarEngine & Providers', () {
    late UniversalGrammarEngine engine;

    setUp(() {
      engine = UniversalGrammarEngine();
      engine.registerProvider(EnglishGrammarProvider());
      engine.registerProvider(TurkishGrammarProvider());
      engine.registerProvider(ArabicGrammarProvider());
      engine.registerProvider(RussianGrammarProvider());
    });

    test('Analytic Language (English) - ignores unsupported categories', () {
      final en = engine.getProvider('en')!;

      // Supported capability
      expect(en.determineNumber('cats'), GrammaticalNumber.plural);
      expect(en.determineNumber('cat'), GrammaticalNumber.singular);

      // Unsupported capability should gracefully return none without crashing
      expect(en.determineGender('cat'), GrammaticalGender.none);
      expect(en.determineCase('cat'), GrammaticalCase.none);
    });

    test('Agglutinative Language (Turkish) - applies supported logic', () {
      final tr = engine.getProvider('tr')!;

      // Supported capabilities
      expect(tr.determineCase('kitabı'), GrammaticalCase.accusative);
      expect(tr.determineCase('kitap'), GrammaticalCase.nominative);

      // Unsupported capabilities
      expect(tr.determineGender('kadın'), GrammaticalGender.none);
    });

    test('Root-Pattern Language (Arabic) - applies supported logic', () {
      final ar = engine.getProvider('ar')!;

      expect(ar.determineGender('سيارة'), GrammaticalGender.feminine);
      expect(ar.determineGender('كتاب'), GrammaticalGender.masculine);
    });

    test('Inflectional Language (Russian) - applies supported logic', () {
      final ru = engine.getProvider('ru')!;

      expect(ru.determineGender('собака'), GrammaticalGender.feminine);
      expect(ru.determineGender('окно'), GrammaticalGender.neuter);
      expect(ru.determineGender('дом'), GrammaticalGender.masculine);
    });

    test('Engine clear', () {
      expect(engine.getProvider('en'), isNotNull);
      engine.clear();
      expect(engine.getProvider('en'), isNull);
    });
  });
}
