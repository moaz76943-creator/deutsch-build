enum AdverbialCategory {
  temporal,  // Wann? Wie lange? Wie oft? (الزمان)
  kausal,    // Warum? Aus welchem Grund? (السبب والعلة)
  modal,     // Wie? Auf welche Art? (الكيفية والوسيلة)
  lokal,     // Wo? Wohin? Woher? (المكان والاتجاه)
  unknown;

  String get arabicLabel => switch (this) {
    AdverbialCategory.temporal => 'ظرف زمان (Temporal)',
    AdverbialCategory.kausal => 'ظرف سبب/علّة (Kausal)',
    AdverbialCategory.modal => 'ظرف حال/كيفية (Modal)',
    AdverbialCategory.lokal => 'ظرف مكان (Lokal)',
    AdverbialCategory.unknown => 'غير محدد',
  };

  int get canonicalRank => switch (this) {
    AdverbialCategory.temporal => 1,
    AdverbialCategory.kausal => 2,
    AdverbialCategory.modal => 3,
    AdverbialCategory.lokal => 4,
    AdverbialCategory.unknown => 99,
  };
}

class ClassifiedAdverbial {
  final String phrase;
  final AdverbialCategory category;
  final String reason;

  const ClassifiedAdverbial({
    required this.phrase,
    required this.category,
    required this.reason,
  });
}

class TeKaMoLoValidationResult {
  final bool isCanonicalOrder;
  final List<ClassifiedAdverbial> classifiedElements;
  final List<String> correctedOrder;
  final String feedback;

  const TeKaMoLoValidationResult({
    required this.isCanonicalOrder,
    required this.classifiedElements,
    required this.correctedOrder,
    required this.feedback,
  });
}

/// محرك التحقق من قاعدة TeKaMoLo لترتيب الظروف في الجملة الألمانية (Study 56)
/// الترتيب الطبيعي المعياري: Temporal (متى) -> Kausal (لماذا) -> Modal (كيف) -> Lokal (أين/إلى أين)
class TeKaMoLoEngine {
  static const Set<String> _temporalKeywords = {
    'heute', 'gestern', 'morgen', 'übermorgen', 'vorgestern',
    'jetzt', 'bald', 'damals', 'früher', 'später', 'sofort', 'gleich',
    'immer', 'oft', 'manchmal', 'selten', 'nie', 'niemals', 'stets',
    'täglich', 'wöchentlich', 'monatlich', 'jährlich',
    'vormittags', 'nachmittags', 'abends', 'nachts', 'morgens',
  };

  static const List<String> _temporalPrepositions = [
    'am montag', 'am dienstag', 'am mittwoch', 'am donnerstag',
    'am freitag', 'am samstag', 'am sonntag', 'am wochenende',
    'um ', 'im sommer', 'im winter', 'im herbst', 'im frühling',
    'im januar', 'im februar', 'im märz', 'im april', 'im mai', 'im juni',
    'im juli', 'im august', 'im september', 'im oktober', 'im november', 'im dezember',
    'seit ', 'während ', 'binnen ',
    'nach dem ', 'nach der ', 'nach einem ', 'nach einer ',
    'vor dem ', 'vor der ', 'vor einem ', 'vor einer ',
  ];

  static const Set<String> _kausalKeywords = {
    'deshalb', 'deswegen', 'daher', 'darum',
  };

  static const List<String> _kausalPrepositions = [
    'wegen ', 'aus liebe', 'aus angst', 'aus neugier', 'aus versehen',
    'vor freude', 'vor angst', 'vor wut', 'vor schreck',
    'trotz ', 'dank ', 'infolge ', 'zwecks ', 'anlässlich ',
  ];

  static const Set<String> _modalKeywords = {
    'gern', 'gerne', 'schnell', 'langsam', 'gut', 'schlecht',
    'allein', 'gemeinsam', 'zusammen', 'vorsichtig', 'plötzlich',
    'heimlich', 'absichtlich', 'mutig', 'bequem', 'fleißig',
  };

  static const List<String> _modalPrepositions = [
    'mit dem bus', 'mit dem zug', 'mit dem auto', 'mit dem fahrrad',
    'mit dem flugzeug', 'mit der bahn', 'mit der u-bahn', 'mit dem taxi',
    'zu fuß', 'mit freude', 'mit begeisterung', 'mit mühe',
    'ohne zweifel', 'auf diese weise', 'auf deutsch', 'auf arabisch',
  ];

  static const Set<String> _lokalKeywords = {
    'hier', 'dort', 'da', 'überall', 'nirgends', 'oben', 'unten',
    'vorn', 'hinten', 'rechts', 'links', 'draußen', 'drinnen',
    'heim', 'nach hause', 'zu hause',
  };

  static const List<String> _lokalPrepositions = [
    'nach berlin', 'nach deutschland', 'nach hause', 'in die stadt',
    'in die schule', 'in die türkei', 'in die schweiz', 'in den usa',
    'nach ', 'in ', 'im ', 'ins ', 'zu ', 'zum ', 'zur ',
    'an ', 'am ', 'ans ', 'auf ', 'aufs ', 'aus ', 'von ',
    'bei ', 'hinter ', 'neben ', 'unter ', 'über ',
  ];

  /// تصنيف العبارة الظرفية إلى إحدى فئات TeKaMoLo
  static ClassifiedAdverbial classifyAdverbial(String phrase) {
    final normalized = phrase.trim().toLowerCase();

    // 0. التحقق أولاً من الوجهات المكانية المعروفة بحرف nach (مثل nach Berlin, nach Hause)
    if (_lokalKeywords.contains(normalized) ||
        normalized.startsWith('nach berlin') ||
        normalized.startsWith('nach deutschland') ||
        normalized.startsWith('nach hause') ||
        normalized.startsWith('in die stadt')) {
      return ClassifiedAdverbial(
        phrase: phrase,
        category: AdverbialCategory.lokal,
        reason: 'تدل على موقع أو اتجاه أو وجهة (Wo? / Wohin? / Woher?)',
      );
    }

    // 1. فحص الزمان (Temporal)
    if (_temporalKeywords.contains(normalized) ||
        _temporalPrepositions.any((p) => normalized.startsWith(p))) {
      return ClassifiedAdverbial(
        phrase: phrase,
        category: AdverbialCategory.temporal,
        reason: 'تدل على توقيت أو مدة زمنية (Wann? / Wie lange?)',
      );
    }

    // 2. فحص السبب (Kausal)
    if (_kausalKeywords.contains(normalized) ||
        _kausalPrepositions.any((p) => normalized.startsWith(p))) {
      return ClassifiedAdverbial(
        phrase: phrase,
        category: AdverbialCategory.kausal,
        reason: 'تدل على سبب أو علة أو دافع (Warum? / Aus welchem Grund?)',
      );
    }

    // 3. فحص الحال والكيفية والوسيلة (Modal)
    if (_modalKeywords.contains(normalized) ||
        _modalPrepositions.any((p) => normalized.startsWith(p))) {
      return ClassifiedAdverbial(
        phrase: phrase,
        category: AdverbialCategory.modal,
        reason: 'تدل على كيفية أو حال أو وسيلة تنقل (Wie? / Auf welche Art?)',
      );
    }

    // 4. فحص المكان والاتجاه (Lokal)
    if (_lokalKeywords.contains(normalized) ||
        _lokalPrepositions.any((p) => normalized.startsWith(p))) {
      return ClassifiedAdverbial(
        phrase: phrase,
        category: AdverbialCategory.lokal,
        reason: 'تدل على موقع أو اتجاه أو وجهة (Wo? / Wohin? / Woher?)',
      );
    }

    return ClassifiedAdverbial(
      phrase: phrase,
      category: AdverbialCategory.unknown,
      reason: 'سياق ظرفي مركب يتطلب تحليلاً نحوياً أعمق',
    );
  }

  /// التحقق من توافق ترتيب قائمة من الظروف مع قاعدة TeKaMoLo
  static TeKaMoLoValidationResult verifyOrder(List<String> adverbials) {
    if (adverbials.length <= 1) {
      final classified = adverbials.map(classifyAdverbial).toList();
      return TeKaMoLoValidationResult(
        isCanonicalOrder: true,
        classifiedElements: classified,
        correctedOrder: List.from(adverbials),
        feedback: 'عبارة ظرفية وحيدة أو فارغة، الترتيب سليم تلقائياً.',
      );
    }

    final classified = adverbials.map(classifyAdverbial).toList();

    var isCanonical = true;
    var previousRank = -1;

    for (final item in classified) {
      if (item.category == AdverbialCategory.unknown) continue;
      final currentRank = item.category.canonicalRank;
      if (currentRank < previousRank) {
        isCanonical = false;
        break;
      }
      previousRank = currentRank;
    }

    // بناء الترتيب المعياري المصحح
    final sortedClassified = List<ClassifiedAdverbial>.from(classified);
    sortedClassified.sort((a, b) => a.category.canonicalRank.compareTo(b.category.canonicalRank));
    final correctedList = sortedClassified.map((e) => e.phrase).toList();

    final feedback = isCanonical
        ? 'أحسنت! ترتيب الظروف يتبع تسلسل TeKaMoLo الطبيعي بالألمانية.'
        : 'تنبيه: الترتيب الأفضل والأكثر فصاحة في الألمانية هو TeKaMoLo '
          '(الزمان أولاً، ثم السبب، ثم الحال، ثم المكان). الترتيب المقترح: ${correctedList.join(" ")}.';

    return TeKaMoLoValidationResult(
      isCanonicalOrder: isCanonical,
      classifiedElements: classified,
      correctedOrder: correctedList,
      feedback: feedback,
    );
  }

  /// إعادة ترتيب قائمة من العبارات الظرفية وفق تسلسل TeKaMoLo
  static List<String> arrangeInTeKaMoLo(List<String> adverbials) {
    return verifyOrder(adverbials).correctedOrder;
  }
}
