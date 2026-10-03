import '../domain/word_formation_models.dart';
import '../domain/word_formation_repository.dart';

final class LocalWordFormationRepository implements WordFormationRepository {
  LocalWordFormationRepository() : _drills = _buildBank();

  final List<WordDerivationItem> _drills;

  @override
  Future<List<WordDerivationItem>> getDrills({
    SuffixCategory? category,
  }) async {
    final selected = category == null
        ? _drills
        : _drills
            .where((item) => item.category == category)
            .toList(growable: false);
    return List<WordDerivationItem>.unmodifiable(selected);
  }

  @override
  Future<bool> checkDerivedWord(
    String drillId,
    String candidate,
  ) async {
    final item = _find(drillId);
    if (item == null) return false;
    return candidate.trim() == item.derivedWord;
  }

  @override
  Future<bool> checkArticle(
    String drillId,
    String article,
  ) async {
    final item = _find(drillId);
    if (item == null) return false;

    final expected = item.article;
    final candidate = article.trim().toLowerCase();
    if (expected == null) return candidate.isEmpty;
    return candidate == expected;
  }

  WordDerivationItem? _find(String id) {
    for (final item in _drills) {
      if (item.id == id) return item;
    }
    return null;
  }

  static List<WordDerivationItem> _buildBank() {
    const items = <WordDerivationItem>[
      WordDerivationItem(
        id: 'noun_freiheit',
        rootWord: 'frei',
        rootWordType: 'Adjektiv',
        suffix: '-heit',
        derivedWord: 'Freiheit',
        category: SuffixCategory.nounSuffix,
        arabicMeaning: 'الحرية',
        semanticShiftAr:
            'تتحول الصفة frei «حرّ» إلى اسم مجرد يدل على حالة الحرية.',
        exercisePromptAr:
            'حوّل الصفة frei إلى اسم مجرد يدل على الحرية.',
      ),
      WordDerivationItem(
        id: 'noun_hoffnung',
        rootWord: 'hoffen',
        rootWordType: 'Verb',
        suffix: '-ung',
        derivedWord: 'Hoffnung',
        category: SuffixCategory.nounSuffix,
        arabicMeaning: 'الأمل',
        semanticShiftAr:
            'يتحول الفعل hoffen «يأمل» إلى اسم يدل على الأمل أو التوقع الإيجابي.',
        exercisePromptAr:
            'اشتق اسماً من hoffen باستخدام اللاحقة المناسبة.',
      ),
      WordDerivationItem(
        id: 'noun_puenktlichkeit',
        rootWord: 'pünktlich',
        rootWordType: 'Adjektiv',
        suffix: '-keit',
        derivedWord: 'Pünktlichkeit',
        category: SuffixCategory.nounSuffix,
        arabicMeaning: 'الالتزام بالمواعيد',
        semanticShiftAr:
            'تتحول الصفة pünktlich «ملتزم بالوقت» إلى اسم مجرد للصفة نفسها.',
        exercisePromptAr:
            'حوّل pünktlich إلى اسم يدل على الالتزام بالمواعيد.',
      ),
      WordDerivationItem(
        id: 'noun_freundschaft',
        rootWord: 'Freund',
        rootWordType: 'Nomen',
        suffix: '-schaft',
        derivedWord: 'Freundschaft',
        category: SuffixCategory.nounSuffix,
        arabicMeaning: 'الصداقة',
        semanticShiftAr:
            'يصبح Freund «صديق» اسماً مجرداً للعلاقة: Freundschaft «صداقة».',
        exercisePromptAr:
            'اشتق من Freund اسماً يدل على العلاقة بين الأصدقاء.',
      ),
      WordDerivationItem(
        id: 'noun_sicherheit',
        rootWord: 'sicher',
        rootWordType: 'Adjektiv',
        suffix: '-heit',
        derivedWord: 'Sicherheit',
        category: SuffixCategory.nounSuffix,
        arabicMeaning: 'الأمان / السلامة',
        semanticShiftAr:
            'تتحول sicher «آمن» إلى Sicherheit للدلالة على حالة الأمان.',
        exercisePromptAr:
            'اشتق اسماً مجرداً من sicher.',
      ),
      WordDerivationItem(
        id: 'noun_moeglichkeit',
        rootWord: 'möglich',
        rootWordType: 'Adjektiv',
        suffix: '-keit',
        derivedWord: 'Möglichkeit',
        category: SuffixCategory.nounSuffix,
        arabicMeaning: 'الإمكانية / الاحتمال',
        semanticShiftAr:
            'تتحول möglich «ممكن» إلى Möglichkeit «إمكانية».',
        exercisePromptAr:
            'حوّل möglich إلى اسم يعني «إمكانية».',
      ),
      WordDerivationItem(
        id: 'noun_behandlung',
        rootWord: 'behandeln',
        rootWordType: 'Verb',
        suffix: '-ung',
        derivedWord: 'Behandlung',
        category: SuffixCategory.nounSuffix,
        arabicMeaning: 'المعالجة / العلاج',
        semanticShiftAr:
            'يتحول behandeln «يعالج» إلى Behandlung للدلالة على عملية العلاج.',
        exercisePromptAr:
            'اشتق اسماً من behandeln يدل على عملية العلاج.',
      ),
      WordDerivationItem(
        id: 'noun_entscheidung',
        rootWord: 'entscheiden',
        rootWordType: 'Verb',
        suffix: '-ung',
        derivedWord: 'Entscheidung',
        category: SuffixCategory.nounSuffix,
        arabicMeaning: 'القرار',
        semanticShiftAr:
            'يتحول entscheiden «يقرر» إلى Entscheidung «قرار».',
        exercisePromptAr:
            'اشتق الاسم الشائع من entscheiden.',
      ),
      WordDerivationItem(
        id: 'adj_hoffnungslos',
        rootWord: 'Hoffnung',
        rootWordType: 'Nomen',
        suffix: '-los',
        derivedWord: 'hoffnungslos',
        category: SuffixCategory.adjectiveSuffix,
        arabicMeaning: 'ميؤوس منه / بلا أمل',
        semanticShiftAr:
            'اللاحقة -los تضيف معنى غياب الشيء: Hoffnung → hoffnungslos.',
        exercisePromptAr:
            'كوّن صفة تعني «بلا أمل» انطلاقاً من Hoffnung.',
      ),
      WordDerivationItem(
        id: 'adj_sinnvoll',
        rootWord: 'Sinn',
        rootWordType: 'Nomen',
        suffix: '-voll',
        derivedWord: 'sinnvoll',
        category: SuffixCategory.adjectiveSuffix,
        arabicMeaning: 'ذو معنى / مفيد',
        semanticShiftAr:
            'اللاحقة -voll تعطي معنى الامتلاء أو الاتصاف: Sinn → sinnvoll.',
        exercisePromptAr:
            'كوّن صفة من Sinn تعني «ذو معنى».',
      ),
      WordDerivationItem(
        id: 'adj_machbar',
        rootWord: 'mach',
        rootWordType: 'Verbstamm',
        suffix: '-bar',
        derivedWord: 'machbar',
        category: SuffixCategory.adjectiveSuffix,
        arabicMeaning: 'قابل للتنفيذ',
        semanticShiftAr:
            'اللاحقة -bar تعطي معنى الإمكان أو القابلية: mach- → machbar.',
        exercisePromptAr:
            'كوّن صفة تعني «قابل للتنفيذ» من الجذر mach-.',
      ),
      WordDerivationItem(
        id: 'adj_dankbar',
        rootWord: 'dank',
        rootWordType: 'Wortstamm',
        suffix: '-bar',
        derivedWord: 'dankbar',
        category: SuffixCategory.adjectiveSuffix,
        arabicMeaning: 'ممتن',
        semanticShiftAr:
            'dankbar صفة شائعة مشتقة باللاحقة -bar وتدل على الامتنان.',
        exercisePromptAr:
            'اختر اللاحقة التي تكوّن الصفة dankbar.',
      ),
      WordDerivationItem(
        id: 'adj_nutzlos',
        rootWord: 'Nutz',
        rootWordType: 'Wortstamm',
        suffix: '-los',
        derivedWord: 'nutzlos',
        category: SuffixCategory.adjectiveSuffix,
        arabicMeaning: 'عديم الفائدة',
        semanticShiftAr:
            'اللاحقة -los تنفي وجود الفائدة: Nutz → nutzlos.',
        exercisePromptAr:
            'كوّن صفة تعني «عديم الفائدة».',
      ),
      WordDerivationItem(
        id: 'adj_wertvoll',
        rootWord: 'Wert',
        rootWordType: 'Nomen',
        suffix: '-voll',
        derivedWord: 'wertvoll',
        category: SuffixCategory.adjectiveSuffix,
        arabicMeaning: 'قيّم / ثمين',
        semanticShiftAr:
            'Wert «قيمة» مع -voll يعطي wertvoll «قيّم».',
        exercisePromptAr:
            'كوّن صفة من Wert تعني «قيّم».',
      ),
      WordDerivationItem(
        id: 'verb_verkaufen',
        rootWord: 'kaufen',
        rootWordType: 'Verb',
        suffix: 'ver-',
        derivedWord: 'verkaufen',
        category: SuffixCategory.verbPrefixDerivation,
        arabicMeaning: 'يبيع',
        semanticShiftAr:
            'البادئة ver- تغيّر kaufen «يشتري» إلى verkaufen «يبيع».',
        exercisePromptAr:
            'أضف البادئة الصحيحة إلى kaufen للحصول على «يبيع».',
      ),
      WordDerivationItem(
        id: 'verb_bezahlen',
        rootWord: 'zahlen',
        rootWordType: 'Verb',
        suffix: 'be-',
        derivedWord: 'bezahlen',
        category: SuffixCategory.verbPrefixDerivation,
        arabicMeaning: 'يدفع / يسدد',
        semanticShiftAr:
            'البادئة be- تحول zahlen إلى bezahlen في الاستعمال الشائع للدفع.',
        exercisePromptAr:
            'اختر البادئة التي تكوّن bezahlen من zahlen.',
      ),
      WordDerivationItem(
        id: 'verb_beantworten',
        rootWord: 'antworten',
        rootWordType: 'Verb',
        suffix: 'be-',
        derivedWord: 'beantworten',
        category: SuffixCategory.verbPrefixDerivation,
        arabicMeaning: 'يجيب عن',
        semanticShiftAr:
            'be- تجعل الفعل متعدياً مباشرة: antworten → beantworten.',
        exercisePromptAr:
            'كوّن beantworten من antworten باستخدام البادئة الصحيحة.',
      ),
      WordDerivationItem(
        id: 'verb_verstehen',
        rootWord: 'stehen',
        rootWordType: 'Verb',
        suffix: 'ver-',
        derivedWord: 'verstehen',
        category: SuffixCategory.verbPrefixDerivation,
        arabicMeaning: 'يفهم',
        semanticShiftAr:
            'في verstehen يغيّر ver- المعنى جذرياً من stehen «يقف» إلى «يفهم».',
        exercisePromptAr:
            'اختر البادئة التي تنتج الفعل verstehen.',
      ),
    ];

    final ids = items.map((item) => item.id).toSet();
    if (ids.length != items.length) {
      throw StateError('word formation bank contains duplicate ids');
    }
    return List<WordDerivationItem>.unmodifiable(items);
  }
}
