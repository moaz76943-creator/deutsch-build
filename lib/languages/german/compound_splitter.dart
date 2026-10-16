import 'package:deutsch_bilarabi/models/linguistics/german_grammar_types.dart';

class CompoundPart {
  final String text;
  final bool isFugenlaut;
  final bool isHead;
  final GermanGender? gender;
  final String? meaningHint;

  const CompoundPart({
    required this.text,
    this.isFugenlaut = false,
    this.isHead = false,
    this.gender,
    this.meaningHint,
  });
}

class CompoundAnalysisResult {
  final String originalCompound;
  final bool isCompound;
  final List<CompoundPart> parts;
  final String? headWord;
  final GermanGender headGender;
  final String? determiningWord;
  final String? fugenElement;
  final String explanation;

  const CompoundAnalysisResult({
    required this.originalCompound,
    required this.isCompound,
    required this.parts,
    this.headWord,
    this.headGender = GermanGender.none,
    this.determiningWord,
    this.fugenElement,
    required this.explanation,
  });
}

/// محرك تفكيك وتحليل الكلمات الألمانية المركبة (Komposita) - Study 08
/// يفكك الكلمة المركبة إلى مفرداتها، ويحدد أداة الربط (Fugenelement)،
/// ويستخرج الكلمة الرأسية (Grundwort) التي تحدد جنس الكلمة وجمعها.
class GermanCompoundSplitter {
  /// معجم المفردات الرأسية الشائعة مع تحديد جنسها
  static const Map<String, GermanGender> _commonHeads = {
    'haus': GermanGender.neuter,
    'buch': GermanGender.neuter,
    'karte': GermanGender.feminine,
    'platz': GermanGender.masculine,
    'schuh': GermanGender.masculine,
    'tür': GermanGender.feminine,
    'uhr': GermanGender.feminine,
    'zeit': GermanGender.feminine,
    'tag': GermanGender.masculine,
    'bahn': GermanGender.feminine,
    'hof': GermanGender.masculine,
    'bahnhof': GermanGender.masculine,
    'hafen': GermanGender.masculine,
    'flughafen': GermanGender.masculine,
    'zimmer': GermanGender.neuter,
    'schrank': GermanGender.masculine,
    'tasche': GermanGender.feminine,
    'lampe': GermanGender.feminine,
    'auto': GermanGender.neuter,
    'wagen': GermanGender.masculine,
    'zug': GermanGender.masculine,
    'plan': GermanGender.masculine,
    'essen': GermanGender.neuter,
    'geld': GermanGender.neuter,
    'stunde': GermanGender.feminine,
    'schule': GermanGender.feminine,
    'lehrer': GermanGender.masculine,
    'kurs': GermanGender.masculine,
    'sprache': GermanGender.feminine,
    'wort': GermanGender.neuter,
    'bild': GermanGender.neuter,
    'fenster': GermanGender.neuter,
    'apfel': GermanGender.masculine,
    'baum': GermanGender.masculine,
    'stadt': GermanGender.feminine,
    'land': GermanGender.neuter,
    'freund': GermanGender.masculine,
    'arbeit': GermanGender.feminine,
    'arzt': GermanGender.masculine,
    'krankenhaus': GermanGender.neuter,
    'ausweis': GermanGender.masculine,
    'nummer': GermanGender.feminine,
    'adresse': GermanGender.feminine,
    'formular': GermanGender.neuter,
    'wasser': GermanGender.neuter,
    'tee': GermanGender.masculine,
    'kaffee': GermanGender.masculine,
    'brot': GermanGender.neuter,
    'kuchen': GermanGender.masculine,
    'teller': GermanGender.masculine,
    'tisch': GermanGender.masculine,
    'stuhl': GermanGender.masculine,
  };

  /// معجم المفردات المحددة الشائعة (Bestimmungswörter)
  static const Map<String, String> _commonModifiers = {
    'hand': 'يد',
    'flug': 'طيران',
    'fahr': 'قيادة/سفر',
    'krank': 'مريض',
    'arbeit': 'عمل',
    'geburt': 'ميلاد',
    'tod': 'موت',
    'sonne': 'شمس',
    'schnee': 'ثلج',
    'sommer': 'صيف',
    'winter': 'شتاء',
    'wörter': 'كلمات',
    'wort': 'كلمة',
    'haupt': 'رئيسي',
    'groß': 'كبير',
    'klein': 'صغير',
    'alt': 'قديم',
    'neu': 'جديد',
    'haus': 'منزل',
    'kinder': 'أطفال',
    'kind': 'طفل',
    'tisch': 'طاولة',
    'tasche': 'حقيبة/جيب',
    'taschen': 'حقائب',
    'schul': 'مدرسة',
    'sprach': 'لغة',
    'reise': 'سفر',
    'wohn': 'سكن',
    'schlaf': 'نوم',
    'bad': 'حمام',
    'küch': 'مطبخ',
    'kauf': 'شراء',
    'verkaufs': 'بيع',
    'stadt': 'مدينة',
    'volks': 'شعب/عام',
  };

  static const List<String> _fugenlaute = ['s', 'es', 'en', 'n', 'er', 'e'];

  /// تفكيك الكلمة المركبة
  static CompoundAnalysisResult split(String word) {
    final trimmed = word.trim();
    final lower = trimmed.toLowerCase();

    // الكلمات القصيرة جداً ليست مركبة
    if (lower.length < 6) {
      return CompoundAnalysisResult(
        originalCompound: trimmed,
        isCompound: false,
        parts: [CompoundPart(text: trimmed, isHead: true)],
        explanation: 'الكلمة "$trimmed" مفردة بسيطة وليست مركبة.',
      );
    }

    // البحث عن أطول كلمة رأسية تطابق نهاية الكلمة
    String? matchedHead;
    GermanGender matchedGender = GermanGender.none;

    for (final entry in _commonHeads.entries) {
      final head = entry.key;
      if (lower.endsWith(head) && lower.length > head.length + 2) {
        if (matchedHead == null || head.length > matchedHead.length) {
          matchedHead = head;
          matchedGender = entry.value;
        }
      }
    }

    if (matchedHead == null) {
      return CompoundAnalysisResult(
        originalCompound: trimmed,
        isCompound: false,
        parts: [CompoundPart(text: trimmed, isHead: true)],
        explanation: 'لم يتم التعرف على مقاطع مركبة شائعة في "$trimmed".',
      );
    }

    final prefix = lower.substring(0, lower.length - matchedHead.length);

    // فحص أدوات الربط (Fugenlaute)
    String modifier = prefix;
    String? fugen;

    for (final f in _fugenlaute) {
      if (prefix.endsWith(f) && prefix.length > f.length + 2) {
        final candidate = prefix.substring(0, prefix.length - f.length);
        if (_commonModifiers.containsKey(candidate) || candidate.length >= 3) {
          modifier = candidate;
          fugen = f;
          break;
        }
      }
    }

    // تنسيق الكلمات بحروف مطابقة
    final capitalizedModifier = modifier.substring(0, 1).toUpperCase() + modifier.substring(1);
    final capitalizedHead = matchedHead.substring(0, 1).toUpperCase() + matchedHead.substring(1);

    final parts = <CompoundPart>[
      CompoundPart(
        text: capitalizedModifier,
        meaningHint: _commonModifiers[modifier],
      ),
    ];

    if (fugen != null) {
      parts.add(CompoundPart(text: '-$fugen-', isFugenlaut: true));
    }

    parts.add(CompoundPart(
      text: capitalizedHead,
      isHead: true,
      gender: matchedGender,
    ));

    final genderArticle = switch (matchedGender) {
      GermanGender.masculine => 'der',
      GermanGender.feminine => 'die',
      GermanGender.neuter => 'das',
      _ => '',
    };

    final fugenText = fugen != null ? ' مع أداة ربط صوتية (Fugenelement: "-$fugen-")' : '';
    final explanation = 'الكلمة المركبة تتكون من المقطع المحدد ($capitalizedModifier) '
        'والكلمة الرأسية ($capitalizedHead)$fugenText. '
        'تكتسب الكلمة جنسها من الكلمة الأخيرة: $genderArticle $trimmed.';

    return CompoundAnalysisResult(
      originalCompound: trimmed,
      isCompound: true,
      parts: parts,
      headWord: capitalizedHead,
      headGender: matchedGender,
      determiningWord: capitalizedModifier,
      fugenElement: fugen,
      explanation: explanation,
    );
  }
}
