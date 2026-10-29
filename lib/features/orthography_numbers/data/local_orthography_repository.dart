import '../domain/orthography_models.dart';
import '../domain/orthography_repository.dart';

final class LocalOrthographyRepository implements OrthographyRepository {
  LocalOrthographyRepository();

  static final List<OrthographyExercise> _exercises =
      <OrthographyExercise>[
    OrthographyExercise(
      id: 'comma_weil',
      topic: OrthographyTopic.comma,
      kind: OrthographyExerciseKind.commaPlacement,
      promptDe: 'Ich bleibe zu Hause weil ich krank bin.',
      instructionAr: 'ضع الفاصلة في مكانها الصحيح قبل الجملة الثانوية.',
      explanationAr:
          'الجملة التي تبدأ بـ weil جملة ثانوية، لذلك نفصلها بفاصلة عن الجملة الرئيسية.',
      tokens: <String>[
        'Ich',
        'bleibe',
        'zu',
        'Hause',
        'weil',
        'ich',
        'krank',
        'bin.',
      ],
      correctCommaGaps: <int>{3},
    ),
    OrthographyExercise(
      id: 'comma_dass',
      topic: OrthographyTopic.comma,
      kind: OrthographyExerciseKind.commaPlacement,
      promptDe: 'Ich weiß dass du heute arbeitest.',
      instructionAr: 'حدد موضع الفاصلة قبل جملة dass.',
      explanationAr:
          'قبل الجملة الثانوية التي تبدأ بـ dass توضع فاصلة.',
      tokens: <String>[
        'Ich',
        'weiß',
        'dass',
        'du',
        'heute',
        'arbeitest.',
      ],
      correctCommaGaps: <int>{1},
    ),
    OrthographyExercise(
      id: 'comma_relative',
      topic: OrthographyTopic.comma,
      kind: OrthographyExerciseKind.commaPlacement,
      promptDe: 'Das Buch das ich lese ist spannend.',
      instructionAr: 'ضع الفاصلتين حول الجملة الموصولة.',
      explanationAr:
          'الجملة الموصولة das ich lese تدخل وسط الجملة، لذلك تُحاط بفاصلتين.',
      tokens: <String>[
        'Das',
        'Buch',
        'das',
        'ich',
        'lese',
        'ist',
        'spannend.',
      ],
      correctCommaGaps: <int>{1, 4},
    ),
    OrthographyExercise(
      id: 'comma_infinitive',
      topic: OrthographyTopic.comma,
      kind: OrthographyExerciseKind.commaPlacement,
      promptDe: 'Er lernt viel um die Prüfung zu bestehen.',
      instructionAr: 'ضع الفاصلة قبل تركيب um ... zu.',
      explanationAr:
          'تركيب um ... zu يُفصل بفاصلة عن الجملة الأساسية.',
      tokens: <String>[
        'Er',
        'lernt',
        'viel',
        'um',
        'die',
        'Prüfung',
        'zu',
        'bestehen.',
      ],
      correctCommaGaps: <int>{2},
    ),
    OrthographyExercise(
      id: 'spelling_dass',
      topic: OrthographyTopic.spelling,
      kind: OrthographyExerciseKind.textEntry,
      promptDe: 'Ich glaube, ___ er heute kommt.',
      instructionAr: 'أكمل بالكلمة الصحيحة: das أم dass؟',
      explanationAr:
          'dass أداة ربط لجملة ثانوية، أما das فقد تكون أداة تعريف أو ضميراً.',
      acceptedAnswers: <String>['dass'],
    ),
    OrthographyExercise(
      id: 'spelling_strasse',
      topic: OrthographyTopic.spelling,
      kind: OrthographyExerciseKind.textEntry,
      promptDe: 'Wie schreibt man das Wort korrekt: Straße oder Strase?',
      instructionAr: 'اكتب الشكل الإملائي الصحيح.',
      explanationAr:
          'بعد الصوت الطويل في Straße نكتب ß في الإملاء القياسي الألماني.',
      acceptedAnswers: <String>['Straße'],
    ),
    OrthographyExercise(
      id: 'spelling_vielleicht',
      topic: OrthographyTopic.spelling,
      kind: OrthographyExerciseKind.textEntry,
      promptDe: '___ komme ich morgen später.',
      instructionAr: 'اكتب vielleicht بالشكل الصحيح.',
      explanationAr:
          'الكلمة الصحيحة هي vielleicht وتُكتب ei ثم ll ثم ei.',
      acceptedAnswers: <String>['Vielleicht', 'vielleicht'],
    ),
    OrthographyExercise(
      id: 'capitalization_noun',
      topic: OrthographyTopic.capitalization,
      kind: OrthographyExerciseKind.textEntry,
      promptDe: 'Am ___ habe ich einen Termin.',
      instructionAr: 'اكتب كلمة Morgen باعتبارها اسماً في هذا السياق.',
      explanationAr:
          'الأسماء في الألمانية تبدأ بحرف كبير، وهنا Morgen اسم.',
      acceptedAnswers: <String>['Morgen'],
    ),
    OrthographyExercise(
      id: 'capitalization_verb',
      topic: OrthographyTopic.capitalization,
      kind: OrthographyExerciseKind.textEntry,
      promptDe: 'Wir gehen morgen früh ___ .',
      instructionAr: 'اكتب الفعل arbeiten بالحروف المناسبة داخل الجملة.',
      explanationAr:
          'الأفعال العادية داخل الجملة تُكتب بحرف صغير: arbeiten.',
      acceptedAnswers: <String>['arbeiten'],
    ),
    OrthographyExercise(
      id: 'punctuation_question',
      topic: OrthographyTopic.punctuation,
      kind: OrthographyExerciseKind.textEntry,
      promptDe: 'Wann beginnt der Kurs__',
      instructionAr: 'اكتب علامة الترقيم المناسبة في نهاية السؤال.',
      explanationAr:
          'السؤال المباشر ينتهي بعلامة استفهام.',
      acceptedAnswers: <String>['?'],
    ),
    OrthographyExercise(
      id: 'punctuation_colon',
      topic: OrthographyTopic.punctuation,
      kind: OrthographyExerciseKind.textEntry,
      promptDe: 'Ich brauche drei Dinge__ Brot, Milch und Wasser.',
      instructionAr: 'اختر علامة الترقيم التي تقدم القائمة.',
      explanationAr:
          'يمكن استعمال النقطتين قبل قائمة تأتي بعد جملة مكتملة المعنى.',
      acceptedAnswers: <String>[':'],
    ),
    OrthographyExercise(
      id: 'date_long',
      topic: OrthographyTopic.date,
      kind: OrthographyExerciseKind.textEntry,
      promptDe: 'Schreibe 2026-10-03 als deutsches Datum mit Monatsname.',
      instructionAr: 'اكتب التاريخ بصيغة ألمانية طويلة.',
      explanationAr:
          'في الصيغة الطويلة يأتي اليوم ثم اسم الشهر ثم السنة.',
      acceptedAnswers: <String>['3. Oktober 2026'],
    ),
    OrthographyExercise(
      id: 'date_numeric',
      topic: OrthographyTopic.date,
      kind: OrthographyExerciseKind.textEntry,
      promptDe: 'Schreibe 2026-10-03 als numerisches deutsches Datum.',
      instructionAr: 'اكتب التاريخ الرقمي الألماني.',
      explanationAr:
          'الصيغة الرقمية الشائعة هي يوم.شهر.سنة.',
      acceptedAnswers: <String>['03.10.2026'],
    ),
    OrthographyExercise(
      id: 'number_decimal',
      topic: OrthographyTopic.number,
      kind: OrthographyExerciseKind.textEntry,
      promptDe: 'Schreibe 12345.67 in deutscher Zahlenschreibweise.',
      instructionAr:
          'حوّل الرقم إلى الصيغة الألمانية بعلامة الآلاف والفاصلة العشرية.',
      explanationAr:
          'في الألمانية نستخدم النقطة لفصل الآلاف والفاصلة للأجزاء العشرية.',
      acceptedAnswers: <String>['12.345,67'],
    ),
    OrthographyExercise(
      id: 'number_million',
      topic: OrthographyTopic.number,
      kind: OrthographyExerciseKind.textEntry,
      promptDe: 'Schreibe -1000000.5 in deutscher Zahlenschreibweise.',
      instructionAr: 'اكتب العدد السالب بالصيغة الألمانية.',
      explanationAr:
          'تبقى إشارة السالب في البداية، وتُفصل الآلاف بنقاط والكسور بفاصلة.',
      acceptedAnswers: <String>['-1.000.000,5'],
    ),
  ];

  static final List<String> _months = <String>[
    'Januar',
    'Februar',
    'März',
    'April',
    'Mai',
    'Juni',
    'Juli',
    'August',
    'September',
    'Oktober',
    'November',
    'Dezember',
  ];

  @override
  List<OrthographyExercise> get allExercises =>
      List<OrthographyExercise>.unmodifiable(_exercises);

  @override
  OrthographyExercise? byId(String id) {
    final normalized = id.trim();
    for (final exercise in _exercises) {
      if (exercise.id == normalized) return exercise;
    }
    return null;
  }

  @override
  List<OrthographyExercise> forTopic(OrthographyTopic topic) =>
      List<OrthographyExercise>.unmodifiable(
        _exercises.where((exercise) => exercise.topic == topic),
      );

  @override
  bool isCommaPlacementCorrect(
    OrthographyExercise exercise,
    Set<int> selectedGaps,
  ) {
    if (!exercise.isCommaPlacement) return false;
    return _setEquals(exercise.correctCommaGaps, selectedGaps);
  }

  @override
  bool isTextAnswerCorrect(
    OrthographyExercise exercise,
    String answer,
  ) {
    if (exercise.kind != OrthographyExerciseKind.textEntry) return false;
    final normalized = normalizeTextAnswer(answer);
    return exercise.acceptedAnswers.any(
      (candidate) => normalizeTextAnswer(candidate) == normalized,
    );
  }

  @override
  String formatDateLong(DateTime date) =>
      '${date.day}. ${_months[date.month - 1]} ${date.year}';

  @override
  String formatDateNumeric(DateTime date) =>
      '${_twoDigits(date.day)}.${_twoDigits(date.month)}.${date.year}';

  @override
  String formatNumber(String canonicalNumber) {
    final normalized = canonicalNumber.trim();
    final match = RegExp(r'^(-?)(\d+)(?:\.(\d+))?$').firstMatch(normalized);
    if (match == null) {
      throw FormatException(
        'Expected canonical decimal number',
        canonicalNumber,
      );
    }

    final sign = match.group(1) ?? '';
    final integer = match.group(2)!;
    final fraction = match.group(3);
    final grouped = _groupThousands(integer);
    return fraction == null || fraction.isEmpty
        ? '$sign$grouped'
        : '$sign$grouped,$fraction';
  }

  @override
  String renderCommaSentence(
    OrthographyExercise exercise,
    Set<int> selectedGaps,
  ) {
    if (!exercise.isCommaPlacement) return exercise.promptDe;
    final parts = <String>[];
    for (var index = 0; index < exercise.tokens.length; index++) {
      final suffix = selectedGaps.contains(index) ? ',' : '';
      parts.add('${exercise.tokens[index]}$suffix');
    }
    return parts.join(' ');
  }

  @override
  String normalizeTextAnswer(String value) =>
      value.trim().replaceAll(RegExp(r'\s+'), ' ');

  bool _setEquals(Set<int> left, Set<int> right) =>
      left.length == right.length && left.containsAll(right);

  String _groupThousands(String digits) {
    final buffer = StringBuffer();
    final firstGroup = digits.length % 3;
    var index = 0;
    if (firstGroup > 0) {
      buffer.write(digits.substring(0, firstGroup));
      index = firstGroup;
    }
    while (index < digits.length) {
      if (buffer.isNotEmpty) buffer.write('.');
      buffer.write(digits.substring(index, index + 3));
      index += 3;
    }
    return buffer.toString();
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');
}
