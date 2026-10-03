import '../domain/prefix_models.dart';
import '../domain/prefix_repository.dart';

final class LocalPrefixRepository implements PrefixRepository {
  LocalPrefixRepository() : _drills = _buildValidatedBank();

  final List<PrefixDrillItem> _drills;

  @override
  Future<List<PrefixDrillItem>> getDrills({
    VerbPrefixClass? verbClass,
  }) async {
    final selected = verbClass == null
        ? _drills
        : _drills
            .where((item) => item.verbClass == verbClass)
            .toList(growable: false);
    return List<PrefixDrillItem>.unmodifiable(selected);
  }

  @override
  Future<bool> checkAnswer({
    required String drillId,
    required String answer,
  }) async {
    final drill = _findById(drillId);
    if (drill == null) return false;
    return _normalize(answer) == _normalize(drill.correctSentence);
  }

  PrefixDrillItem? _findById(String id) {
    for (final drill in _drills) {
      if (drill.id == id) return drill;
    }
    return null;
  }

  static String _normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(' .', '.')
        .replaceAll(' ,', ',');
  }

  static List<PrefixDrillItem> _buildValidatedBank() {
    const drills = <PrefixDrillItem>[
      PrefixDrillItem(
        id: 'travel_ankommen',
        infinitive: 'ankommen',
        prefix: 'an',
        stem: 'kommen',
        verbClass: VerbPrefixClass.trennbar,
        context: PrefixContext.travel,
        isSeparableInContext: true,
        sentencePrompt: 'Der Zug ___ um 18 Uhr in Berlin ___.',
        correctSentence: 'Der Zug kommt um 18 Uhr in Berlin an.',
        partizipII: 'angekommen',
        translationAr: 'يصل القطار إلى برلين الساعة السادسة مساءً.',
        explanationAr:
            'الفعل ankommen منفصل: في الجملة الرئيسية يأتي kommen في الموقع الثاني وتنتقل an إلى النهاية. في Partizip II تدخل ge بين السابقة والجذر: angekommen.',
      ),
      PrefixDrillItem(
        id: 'technology_einschalten',
        infinitive: 'einschalten',
        prefix: 'ein',
        stem: 'schalten',
        verbClass: VerbPrefixClass.trennbar,
        context: PrefixContext.technology,
        isSeparableInContext: true,
        sentencePrompt: 'Der Techniker ___ den Server ___.',
        correctSentence: 'Der Techniker schaltet den Server ein.',
        partizipII: 'eingeschaltet',
        translationAr: 'يشغّل الفني الخادم.',
        explanationAr:
            'einschalten فعل منفصل. السابقة ein تنتقل إلى نهاية الجملة الرئيسية، وPartizip II هو eingeschaltet.',
      ),
      PrefixDrillItem(
        id: 'literature_vorlesen',
        infinitive: 'vorlesen',
        prefix: 'vor',
        stem: 'lesen',
        verbClass: VerbPrefixClass.trennbar,
        context: PrefixContext.literature,
        isSeparableInContext: true,
        sentencePrompt: 'Die Autorin ___ einen Abschnitt aus dem Roman ___.',
        correctSentence:
            'Die Autorin liest einen Abschnitt aus dem Roman vor.',
        partizipII: 'vorgelesen',
        translationAr: 'تقرأ الكاتبة مقطعاً من الرواية بصوت مرتفع.',
        explanationAr:
            'vorlesen فعل منفصل: liest ... vor. في Partizip II تصبح الصيغة vorgelesen.',
      ),
      PrefixDrillItem(
        id: 'engineering_einbauen',
        infinitive: 'einbauen',
        prefix: 'ein',
        stem: 'bauen',
        verbClass: VerbPrefixClass.trennbar,
        context: PrefixContext.engineering,
        isSeparableInContext: true,
        sentencePrompt: 'Die Ingenieurin ___ den neuen Sensor ___.',
        correctSentence: 'Die Ingenieurin baut den neuen Sensor ein.',
        partizipII: 'eingebaut',
        translationAr: 'تركّب المهندسة المستشعر الجديد.',
        explanationAr:
            'einbauen منفصل: baut ... ein. في Partizip II نضع ge بين ein و bauen: eingebaut.',
      ),
      PrefixDrillItem(
        id: 'travel_erreichen',
        infinitive: 'erreichen',
        prefix: 'er',
        stem: 'reichen',
        verbClass: VerbPrefixClass.untrennbar,
        context: PrefixContext.travel,
        isSeparableInContext: false,
        sentencePrompt: 'Der Zug ___ München gegen 20 Uhr.',
        correctSentence: 'Der Zug erreicht München gegen 20 Uhr.',
        partizipII: 'erreicht',
        translationAr: 'يصل القطار إلى ميونخ قرابة الساعة الثامنة مساءً.',
        explanationAr:
            'السابقة er- غير منفصلة. تبقى مع الفعل في الحاضر، وPartizip II لا يأخذ ge: erreicht.',
      ),
      PrefixDrillItem(
        id: 'technology_verarbeiten',
        infinitive: 'verarbeiten',
        prefix: 'ver',
        stem: 'arbeiten',
        verbClass: VerbPrefixClass.untrennbar,
        context: PrefixContext.technology,
        isSeparableInContext: false,
        sentencePrompt: 'Das System ___ die Daten automatisch.',
        correctSentence: 'Das System verarbeitet die Daten automatisch.',
        partizipII: 'verarbeitet',
        translationAr: 'يعالج النظام البيانات تلقائياً.',
        explanationAr:
            'السابقة ver- غير منفصلة ولا تسمح بإضافة ge في Partizip II، لذلك نقول verarbeitet.',
      ),
      PrefixDrillItem(
        id: 'literature_beschreiben',
        infinitive: 'beschreiben',
        prefix: 'be',
        stem: 'schreiben',
        verbClass: VerbPrefixClass.untrennbar,
        context: PrefixContext.literature,
        isSeparableInContext: false,
        sentencePrompt: 'Die Autorin ___ die Landschaft sehr präzise.',
        correctSentence: 'Die Autorin beschreibt die Landschaft sehr präzise.',
        partizipII: 'beschrieben',
        translationAr: 'تصف الكاتبة المنظر الطبيعي بدقة كبيرة.',
        explanationAr:
            'be- من السوابق غير المنفصلة. يبقى الفعل كلمة واحدة، وPartizip II هو beschrieben من دون ge.',
      ),
      PrefixDrillItem(
        id: 'engineering_berechnen',
        infinitive: 'berechnen',
        prefix: 'be',
        stem: 'rechnen',
        verbClass: VerbPrefixClass.untrennbar,
        context: PrefixContext.engineering,
        isSeparableInContext: false,
        sentencePrompt: 'Der Ingenieur ___ die maximale Belastung.',
        correctSentence: 'Der Ingenieur berechnet die maximale Belastung.',
        partizipII: 'berechnet',
        translationAr: 'يحسب المهندس الحمولة القصوى.',
        explanationAr:
            'berechnen غير منفصل بسبب السابقة be-. في Partizip II نقول berechnet من دون ge.',
      ),
      PrefixDrillItem(
        id: 'literature_uebersetzen_translate',
        infinitive: 'übersetzen',
        prefix: 'über',
        stem: 'setzen',
        verbClass: VerbPrefixClass.doppeldeutig,
        context: PrefixContext.literature,
        isSeparableInContext: false,
        sentencePrompt: 'Sie ___ den Roman ins Arabische.',
        correctSentence: 'Sie übersetzt den Roman ins Arabische.',
        partizipII: 'übersetzt',
        translationAr: 'تترجم الرواية إلى العربية.',
        explanationAr:
            'عندما يعني übersetzen «يترجم»، يكون غير منفصل وتكون النبرة على الجذر. لذلك: sie übersetzt، وPartizip II هو übersetzt من دون ge.',
      ),
      PrefixDrillItem(
        id: 'travel_uebersetzen_cross',
        infinitive: 'übersetzen',
        prefix: 'über',
        stem: 'setzen',
        verbClass: VerbPrefixClass.doppeldeutig,
        context: PrefixContext.travel,
        isSeparableInContext: true,
        sentencePrompt: 'Der Fährmann ___ die Reisenden ans andere Ufer ___.',
        correctSentence:
            'Der Fährmann setzt die Reisenden ans andere Ufer über.',
        partizipII: 'übergesetzt',
        translationAr: 'ينقل عامل العبّارة المسافرين إلى الضفة الأخرى.',
        explanationAr:
            'عندما يعني über|setzen «ينقل إلى الجهة الأخرى»، يكون منفصلاً: setzt ... über. وPartizip II هو übergesetzt.',
      ),
      PrefixDrillItem(
        id: 'engineering_umfahren_avoid',
        infinitive: 'umfahren',
        prefix: 'um',
        stem: 'fahren',
        verbClass: VerbPrefixClass.doppeldeutig,
        context: PrefixContext.engineering,
        isSeparableInContext: false,
        sentencePrompt: 'Der Testwagen ___ das Hindernis automatisch.',
        correctSentence: 'Der Testwagen umfährt das Hindernis automatisch.',
        partizipII: 'umfahren',
        translationAr: 'تلتف سيارة الاختبار حول العائق تلقائياً.',
        explanationAr:
            'عندما يعني umfahren «يلتف حول شيء»، يكون غير منفصل. لذلك نقول umfährt وPartizip II هو umfahren من دون ge.',
      ),
      PrefixDrillItem(
        id: 'engineering_umfahren_knock',
        infinitive: 'umfahren',
        prefix: 'um',
        stem: 'fahren',
        verbClass: VerbPrefixClass.doppeldeutig,
        context: PrefixContext.engineering,
        isSeparableInContext: true,
        sentencePrompt: 'Beim Test ___ das Fahrzeug einen Kegel ___.',
        correctSentence: 'Beim Test fährt das Fahrzeug einen Kegel um.',
        partizipII: 'umgefahren',
        translationAr: 'أثناء الاختبار تطيح المركبة بمخروط مروري.',
        explanationAr:
            'عندما يعني um|fahren «يُسقط شيئاً بالاصطدام به»، يكون منفصلاً: fährt ... um. وPartizip II هو umgefahren.',
      ),
    ];

    final ids = drills.map((item) => item.id).toSet();
    if (ids.length != drills.length) {
      throw StateError('prefix drill bank contains duplicate ids');
    }

    for (final drill in drills) {
      if (!drill.infinitive.startsWith(drill.prefix)) {
        throw StateError('prefix does not match infinitive: ${drill.id}');
      }
      if (drill.verbClass == VerbPrefixClass.trennbar &&
          !drill.isSeparableInContext) {
        throw StateError('trennbar drill must separate: ${drill.id}');
      }
      if (drill.verbClass == VerbPrefixClass.untrennbar &&
          drill.isSeparableInContext) {
        throw StateError('untrennbar drill must not separate: ${drill.id}');
      }
      if (drill.correctSentence.trim().isEmpty ||
          drill.translationAr.trim().isEmpty ||
          drill.explanationAr.trim().isEmpty) {
        throw StateError('incomplete prefix drill: ${drill.id}');
      }
    }

    return List<PrefixDrillItem>.unmodifiable(drills);
  }
}
