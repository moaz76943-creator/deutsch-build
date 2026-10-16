enum ClauseType {
  mainClauseV2,          // جملة رئيسية: الفعل المصرف في الموقع الثاني (V2)
  subordinateClauseEnd,  // جملة فرعية (Nebensatz): الأفعال في نهاية الجملة
  questionOrImperativeV1,// سؤال بنعم/لا أو صيغة أمر: الفعل في الموقع الأول (V1)
  unknown,
}

class SatzklammerAnalysis {
  final ClauseType clauseType;
  final String? leftBracket;    // Linke Satzklammer (الفعل المصرف أو أداة الربط)
  final String? middleField;    // Mittelfeld (حشو الجملة: الفاعل، المفاعيل، والظروف)
  final String? rightBracket;   // Rechte Satzklammer (سابقة الفعل المنفصل، اسم المفعول، أو المصدر)
  final String? vorfeld;        // Vorfeld (ما يسبق الفعل في V2)
  final bool hasSeparablePrefix;
  final String? separablePrefix;
  final String explanation;

  const SatzklammerAnalysis({
    required this.clauseType,
    this.leftBracket,
    this.middleField,
    this.rightBracket,
    this.vorfeld,
    this.hasSeparablePrefix = false,
    this.separablePrefix,
    required this.explanation,
  });
}

/// محلل قوس الجملة وحزام الأفعال في اللغة الألمانية (Satzklammer) - Study 50
/// يحلل موقع الفعل المصرف والقوس الأيمن (السوابق المنفصلة واسم المفعول)
class SatzklammerAnalyzer {
  static const Set<String> _separablePrefixes = {
    'ab', 'an', 'auf', 'aus', 'bei', 'ein', 'fest', 'fort', 'her',
    'hin', 'los', 'mit', 'nach', 'vor', 'weg', 'weiter', 'zu',
    'zurück', 'zusammen', 'fern', 'kennen', 'spazieren',
  };

  static const Set<String> _subordinatingConjunctions = {
    'weil', 'dass', 'daß', 'ob', 'obwohl', 'wenn', 'als', 'da',
    'während', 'bevor', 'nachdem', 'damit', 'sodass', 'falls',
    'seit', 'seitdem', 'bis', 'solange',
  };

  static const Set<String> _auxiliariesAndModals = {
    'habe', 'hast', 'hat', 'haben', 'habt', 'hatte', 'hattest', 'hatten', 'hattet',
    'bin', 'bist', 'ist', 'sind', 'seid', 'war', 'warst', 'waren', 'wart',
    'werde', 'wirst', 'wird', 'werden', 'werdet', 'wurde', 'wurdest', 'wurden',
    'kann', 'kannst', 'können', 'könnt', 'konnte', 'konnten',
    'muss', 'musst', 'müssen', 'müsst', 'musste', 'mussten',
    'darf', 'darfst', 'dürfen', 'dürft', 'durfte', 'durften',
    'soll', 'sollst', 'sollen', 'sollt', 'sollte', 'sollten',
    'will', 'willst', 'wollen', 'wollt', 'wollte', 'wollten',
    'möchte', 'möchtest', 'möchten', 'möchtet',
  };

  /// تحليل جملة ألمانية واستخراج عناصر القوس اللغوي
  static SatzklammerAnalysis analyze(String sentence) {
    final cleaned = sentence.trim().replaceAll(RegExp(r'[.!?]$'), '');
    final tokens = cleaned.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();

    if (tokens.isEmpty) {
      return const SatzklammerAnalysis(
        clauseType: ClauseType.unknown,
        explanation: 'الجملة فارغة.',
      );
    }

    final firstTokenLower = tokens.first.toLowerCase();

    // 1. فحص الجملة الفرعية (Nebensatz)
    if (_subordinatingConjunctions.contains(firstTokenLower)) {
      final left = tokens.first;
      final right = tokens.length > 1 ? tokens.last : null;
      final mid = tokens.length > 2 ? tokens.sublist(1, tokens.length - 1).join(' ') : null;

      return SatzklammerAnalysis(
        clauseType: ClauseType.subordinateClauseEnd,
        leftBracket: left,
        middleField: mid,
        rightBracket: right,
        explanation: 'جملة فرعية (Nebensatz) تبدأ بأداة الربط "$left"، '
            'والفعل المصرف يقع في نهاية الجملة ("$right").',
      );
    }

    // 2. فحص الجملة الاستفهامية بنعم/لا أو الأمر (V1)
    if (_isVerbToken(tokens.first)) {
      final left = tokens.first;
      final lastToken = tokens.last.toLowerCase();
      final hasSep = _separablePrefixes.contains(lastToken);

      final right = tokens.length > 1 && (hasSep || _isNonFiniteVerb(tokens.last))
          ? tokens.last
          : null;

      final midStart = 1;
      final midEnd = right != null ? tokens.length - 1 : tokens.length;
      final mid = midEnd > midStart ? tokens.sublist(midStart, midEnd).join(' ') : null;

      return SatzklammerAnalysis(
        clauseType: ClauseType.questionOrImperativeV1,
        leftBracket: left,
        middleField: mid,
        rightBracket: right,
        hasSeparablePrefix: hasSep,
        separablePrefix: hasSep ? tokens.last : null,
        explanation: 'جملة فعلية V1 (سؤال أو أمر): الفعل المصرف "$left" في البداية' +
            (right != null ? '، والقوس الأيمن مغلق بـ "$right".' : '.'),
      );
    }

    // 3. جملة خبرية رئيسية قياسية (V2)
    if (tokens.length >= 2) {
      final vorfeld = tokens.first;
      final leftBracket = tokens[1]; // V2

      final lastToken = tokens.last.toLowerCase();
      final hasSep = _separablePrefixes.contains(lastToken);
      final isNonFinite = _isNonFiniteVerb(tokens.last);

      final hasRightBracket = tokens.length > 2 && (hasSep || isNonFinite);
      final rightBracket = hasRightBracket ? tokens.last : null;

      final midStart = 2;
      final midEnd = hasRightBracket ? tokens.length - 1 : tokens.length;
      final mid = midEnd > midStart ? tokens.sublist(midStart, midEnd).join(' ') : null;

      final sepText = hasSep ? ' (سابقة منفصلة: "$rightBracket")' : '';
      return SatzklammerAnalysis(
        clauseType: ClauseType.mainClauseV2,
        vorfeld: vorfeld,
        leftBracket: leftBracket,
        middleField: mid,
        rightBracket: rightBracket,
        hasSeparablePrefix: hasSep,
        separablePrefix: hasSep ? tokens.last : null,
        explanation: 'جملة رئيسية (Hauptsatz): القوس الأيسر V2 هو الفعل المصرف "$leftBracket"، ' +
            (rightBracket != null
                ? 'والقوس الأيمن في نهاية الجملة هو "$rightBracket"$sepText.'
                : 'وبدون قوس أفعال مغلق في النهاية.'),
      );
    }

    return SatzklammerAnalysis(
      clauseType: ClauseType.mainClauseV2,
      leftBracket: tokens.first,
      explanation: 'جملة بسيطة قصيرة.',
    );
  }

  static bool _isVerbToken(String token) {
    final lower = token.toLowerCase();
    return _auxiliariesAndModals.contains(lower) ||
        lower.endsWith('en') ||
        lower.endsWith('t') ||
        lower.endsWith('st');
  }

  static bool _isNonFiniteVerb(String token) {
    final lower = token.toLowerCase();
    // اسم مفعول (Partizip II) يبدأ بـ ge- وينتهي بـ t أو en
    if (lower.startsWith('ge') && (lower.endsWith('t') || lower.endsWith('en'))) {
      return true;
    }
    // مصدر أفعال
    if (lower.endsWith('en') || lower.endsWith('eln') || lower.endsWith('ern')) {
      return true;
    }
    return false;
  }
}
