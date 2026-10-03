import '../domain/imperativ_models.dart';
import '../domain/imperativ_repository.dart';

final class LocalImperativRepository implements ImperativRepository {
  const LocalImperativRepository();

  static const List<ImperativDrillItem> _drills = <ImperativDrillItem>[
    ImperativDrillItem(
      id: 'lesen_du',
      infinitive: 'lesen',
      target: ImperativTarget.duForm,
      correctForm: 'Lies!',
      vowelChange: ImperativVowelChange.eToIe,
      referenceForm: 'du liest',
      contextSentence: 'Lies vor der Einnahme die Packungsbeilage sorgfältig.',
      explanationAr:
          'مع du نحذف الضمير و-st، ويتحوّل e في lesen إلى ie: Lies!',
    ),
    ImperativDrillItem(
      id: 'sehen_du',
      infinitive: 'sehen',
      target: ImperativTarget.duForm,
      correctForm: 'Sieh!',
      vowelChange: ImperativVowelChange.eToIe,
      referenceForm: 'du siehst',
      contextSentence: 'Sieh zuerst auf das Straßenschild.',
      explanationAr:
          'مع du نحذف الضمير و-st، ويبقى تغيّر e إلى ie: Sieh!',
    ),
    ImperativDrillItem(
      id: 'geben_du',
      infinitive: 'geben',
      target: ImperativTarget.duForm,
      correctForm: 'Gib!',
      vowelChange: ImperativVowelChange.eToI,
      referenceForm: 'du gibst',
      contextSentence: 'Gib mir bitte den Hausschlüssel.',
      explanationAr:
          'مع du نحذف الضمير و-st، ويتحوّل e إلى i: Gib!',
    ),
    ImperativDrillItem(
      id: 'nehmen_du',
      infinitive: 'nehmen',
      target: ImperativTarget.duForm,
      correctForm: 'Nimm!',
      vowelChange: ImperativVowelChange.eToI,
      referenceForm: 'du nimmst',
      contextSentence: 'Nimm bitte die zweite Straße links.',
      explanationAr:
          'مع du نحذف الضمير و-st، ويظهر التغيّر الصرفي e إلى i: Nimm!',
    ),
    ImperativDrillItem(
      id: 'sprechen_du',
      infinitive: 'sprechen',
      target: ImperativTarget.duForm,
      correctForm: 'Sprich!',
      vowelChange: ImperativVowelChange.eToI,
      referenceForm: 'du sprichst',
      contextSentence: 'Sprich bitte langsam und deutlich.',
      explanationAr:
          'مع du نحذف الضمير و-st، ويتحوّل e إلى i: Sprich!',
    ),
    ImperativDrillItem(
      id: 'essen_du',
      infinitive: 'essen',
      target: ImperativTarget.duForm,
      correctForm: 'Iss!',
      vowelChange: ImperativVowelChange.eToI,
      referenceForm: 'du isst',
      contextSentence: 'Iss langsam und mach danach eine kurze Pause.',
      explanationAr:
          'صيغة du من essen شاذة في الجذر: من du isst نحصل على Iss!',
    ),
    ImperativDrillItem(
      id: 'helfen_du',
      infinitive: 'helfen',
      target: ImperativTarget.duForm,
      correctForm: 'Hilf!',
      vowelChange: ImperativVowelChange.eToI,
      referenceForm: 'du hilfst',
      contextSentence: 'Hilf bitte beim Aufräumen der Küche.',
      explanationAr:
          'مع du نحذف الضمير و-st، ويتحوّل e إلى i: Hilf!',
    ),
    ImperativDrillItem(
      id: 'fahren_du',
      infinitive: 'fahren',
      target: ImperativTarget.duForm,
      correctForm: 'Fahr!',
      vowelChange: ImperativVowelChange.umlautDropped,
      referenceForm: 'du fährst',
      contextSentence: 'Fahr an der nächsten Kreuzung rechts.',
      explanationAr:
          'في أمر du يعود ä إلى a، لذلك fährst تصبح Fahr! دون du أو -st.',
      acceptedForms: const <String>['Fahre!'],
    ),
    ImperativDrillItem(
      id: 'laufen_du',
      infinitive: 'laufen',
      target: ImperativTarget.duForm,
      correctForm: 'Lauf!',
      vowelChange: ImperativVowelChange.umlautDropped,
      referenceForm: 'du läufst',
      contextSentence: 'Lauf bis zur Ampel und warte dort.',
      explanationAr:
          'في أمر du يُحذف الـ Umlaut: läufst تصبح Lauf! مع حذف du و-st.',
      acceptedForms: const <String>['Laufe!'],
    ),
    ImperativDrillItem(
      id: 'schlafen_du',
      infinitive: 'schlafen',
      target: ImperativTarget.duForm,
      correctForm: 'Schlaf!',
      vowelChange: ImperativVowelChange.umlautDropped,
      referenceForm: 'du schläfst',
      contextSentence: 'Schlaf heute früh, wenn du morgen früh aufstehst.',
      explanationAr:
          'في أمر du يعود ä إلى a: schläfst تصبح Schlaf! دون الضمير و-st.',
      acceptedForms: const <String>['Schlafe!'],
    ),
    ImperativDrillItem(
      id: 'tragen_du',
      infinitive: 'tragen',
      target: ImperativTarget.duForm,
      correctForm: 'Trag!',
      vowelChange: ImperativVowelChange.umlautDropped,
      referenceForm: 'du trägst',
      contextSentence: 'Trag die Kiste vorsichtig ins Wohnzimmer.',
      explanationAr:
          'في أمر du يُحذف الـ Umlaut: trägst تصبح Trag! بعد حذف du و-st.',
      acceptedForms: const <String>['Trage!'],
    ),
    ImperativDrillItem(
      id: 'arbeiten_du',
      infinitive: 'arbeiten',
      target: ImperativTarget.duForm,
      correctForm: 'Arbeite!',
      vowelChange: ImperativVowelChange.none,
      referenceForm: 'du arbeitest',
      contextSentence: 'Arbeite heute zuerst die kurze Liste ab.',
      explanationAr:
          'لأن جذر arbeiten ينتهي بـ t نحتفظ بـ -e لتسهيل النطق: Arbeite!',
    ),
    ImperativDrillItem(
      id: 'warten_du',
      infinitive: 'warten',
      target: ImperativTarget.duForm,
      correctForm: 'Warte!',
      vowelChange: ImperativVowelChange.none,
      referenceForm: 'du wartest',
      contextSentence: 'Warte bitte vor der Haustür.',
      explanationAr:
          'مع الجذر المنتهي بـ t نستخدم -e في الأمر لتسهيل النطق: Warte!',
    ),
    ImperativDrillItem(
      id: 'reden_du',
      infinitive: 'reden',
      target: ImperativTarget.duForm,
      correctForm: 'Rede!',
      vowelChange: ImperativVowelChange.none,
      referenceForm: 'du redest',
      contextSentence: 'Rede bitte leiser im Flur.',
      explanationAr:
          'مع الجذر المنتهي بـ d نستخدم -e في الأمر: Rede!',
    ),
    ImperativDrillItem(
      id: 'sein_du',
      infinitive: 'sein',
      target: ImperativTarget.duForm,
      correctForm: 'Sei!',
      vowelChange: ImperativVowelChange.irregularSein,
      referenceForm: 'du bist',
      contextSentence: 'Sei ruhig und hör zuerst zu.',
      explanationAr:
          'فعل sein شاذ تماماً في أمر du: لا نقول bist، بل Sei!',
    ),
    ImperativDrillItem(
      id: 'lesen_ihr',
      infinitive: 'lesen',
      target: ImperativTarget.ihrForm,
      correctForm: 'Lest!',
      vowelChange: ImperativVowelChange.none,
      referenceForm: 'ihr lest',
      contextSentence: 'Lest die Hinweise gemeinsam.',
      explanationAr:
          'مع ihr نستخدم صيغة الحاضر نفسها ونحذف الضمير فقط: ihr lest → Lest!',
    ),
    ImperativDrillItem(
      id: 'sprechen_ihr',
      infinitive: 'sprechen',
      target: ImperativTarget.ihrForm,
      correctForm: 'Sprecht!',
      vowelChange: ImperativVowelChange.none,
      referenceForm: 'ihr sprecht',
      contextSentence: 'Sprecht bitte nacheinander.',
      explanationAr:
          'مع ihr تبقى صيغة sprecht كما هي، ونحذف الضمير ihr فقط.',
    ),
    ImperativDrillItem(
      id: 'fahren_ihr',
      infinitive: 'fahren',
      target: ImperativTarget.ihrForm,
      correctForm: 'Fahrt!',
      vowelChange: ImperativVowelChange.none,
      referenceForm: 'ihr fahrt',
      contextSentence: 'Fahrt geradeaus bis zum Kreisverkehr.',
      explanationAr:
          'مع ihr نأخذ صيغة الحاضر ihr fahrt ونحذف ihr: Fahrt!',
    ),
    ImperativDrillItem(
      id: 'arbeiten_ihr',
      infinitive: 'arbeiten',
      target: ImperativTarget.ihrForm,
      correctForm: 'Arbeitet!',
      vowelChange: ImperativVowelChange.none,
      referenceForm: 'ihr arbeitet',
      contextSentence: 'Arbeitet bitte zuerst am ersten Schritt.',
      explanationAr:
          'صيغة ihr هي arbeitet؛ في الأمر نحذف ihr فقط: Arbeitet!',
    ),
    ImperativDrillItem(
      id: 'sein_ihr',
      infinitive: 'sein',
      target: ImperativTarget.ihrForm,
      correctForm: 'Seid!',
      vowelChange: ImperativVowelChange.irregularSein,
      referenceForm: 'ihr seid',
      contextSentence: 'Seid bitte vorsichtig auf der Treppe.',
      explanationAr:
          'أمر sein مع ihr هو Seid! وهو صيغة استثنائية محفوظة.',
    ),
    ImperativDrillItem(
      id: 'lesen_sie',
      infinitive: 'lesen',
      target: ImperativTarget.sieForm,
      correctForm: 'Lesen Sie!',
      vowelChange: ImperativVowelChange.none,
      referenceForm: 'Sie lesen',
      contextSentence: 'Lesen Sie die Anleitung vor der Benutzung.',
      explanationAr:
          'مع Sie نستخدم المصدر ثم الضمير الرسمي بعده: Lesen Sie!',
    ),
    ImperativDrillItem(
      id: 'fahren_sie',
      infinitive: 'fahren',
      target: ImperativTarget.sieForm,
      correctForm: 'Fahren Sie!',
      vowelChange: ImperativVowelChange.none,
      referenceForm: 'Sie fahren',
      contextSentence: 'Fahren Sie an der Ampel links.',
      explanationAr:
          'مع Sie يأتي الفعل بصيغة المصدر أولاً ثم Sie: Fahren Sie!',
    ),
    ImperativDrillItem(
      id: 'arbeiten_sie',
      infinitive: 'arbeiten',
      target: ImperativTarget.sieForm,
      correctForm: 'Arbeiten Sie!',
      vowelChange: ImperativVowelChange.none,
      referenceForm: 'Sie arbeiten',
      contextSentence: 'Arbeiten Sie die Schritte in dieser Reihenfolge ab.',
      explanationAr:
          'مع Sie نستخدم المصدر Arbeiten ثم الضمير الرسمي Sie.',
    ),
    ImperativDrillItem(
      id: 'sprechen_sie',
      infinitive: 'sprechen',
      target: ImperativTarget.sieForm,
      correctForm: 'Sprechen Sie!',
      vowelChange: ImperativVowelChange.none,
      referenceForm: 'Sie sprechen',
      contextSentence: 'Sprechen Sie bei Unklarheiten mit medizinischem Fachpersonal.',
      explanationAr:
          'مع Sie نستخدم المصدر ثم Sie دون تغيير الجذر: Sprechen Sie!',
    ),
    ImperativDrillItem(
      id: 'sein_sie',
      infinitive: 'sein',
      target: ImperativTarget.sieForm,
      correctForm: 'Seien Sie!',
      vowelChange: ImperativVowelChange.irregularSein,
      referenceForm: 'Sie sind',
      contextSentence: 'Seien Sie vorsichtig und beachten Sie die Hinweise.',
      explanationAr:
          'sein شاذ مع Sie: الصيغة الصحيحة Seien Sie! وليست Sind Sie.',
    ),
    ImperativDrillItem(
      id: 'sprechen_wir',
      infinitive: 'sprechen',
      target: ImperativTarget.wirForm,
      correctForm: 'Sprechen wir!',
      vowelChange: ImperativVowelChange.none,
      referenceForm: 'wir sprechen',
      contextSentence: 'Sprechen wir zuerst über den nächsten Schritt.',
      explanationAr:
          'مع wir نستخدم صيغة المصدر ثم wir: Sprechen wir!',
    ),
    ImperativDrillItem(
      id: 'gehen_wir',
      infinitive: 'gehen',
      target: ImperativTarget.wirForm,
      correctForm: 'Gehen wir!',
      vowelChange: ImperativVowelChange.none,
      referenceForm: 'wir gehen',
      contextSentence: 'Gehen wir jetzt zur nächsten Haltestelle.',
      explanationAr:
          'صيغة الاقتراح مع wir: المصدر أولاً ثم wir، أي Gehen wir!',
    ),
    ImperativDrillItem(
      id: 'arbeiten_wir',
      infinitive: 'arbeiten',
      target: ImperativTarget.wirForm,
      correctForm: 'Arbeiten wir!',
      vowelChange: ImperativVowelChange.none,
      referenceForm: 'wir arbeiten',
      contextSentence: 'Arbeiten wir die Aufgaben der Reihe nach ab.',
      explanationAr:
          'مع wir نستخدم المصدر ثم wir: Arbeiten wir!',
    ),
    ImperativDrillItem(
      id: 'sein_wir',
      infinitive: 'sein',
      target: ImperativTarget.wirForm,
      correctForm: 'Seien wir!',
      vowelChange: ImperativVowelChange.irregularSein,
      referenceForm: 'wir sind',
      contextSentence: 'Seien wir bei dieser Aufgabe besonders aufmerksam.',
      explanationAr:
          'sein شاذ أيضاً مع wir: نقول Seien wir! وليس Sind wir.',
    ),
  ];

  @override
  List<ImperativDrillItem> get allDrills =>
      List<ImperativDrillItem>.unmodifiable(_drills);

  @override
  ImperativDrillItem? byId(String id) {
    final normalized = id.trim();
    for (final item in _drills) {
      if (item.id == normalized) return item;
    }
    return null;
  }

  @override
  List<ImperativDrillItem> forTarget(ImperativTarget target) =>
      List<ImperativDrillItem>.unmodifiable(
        _drills.where((item) => item.target == target),
      );

  @override
  bool isCorrect(ImperativDrillItem item, String candidate) {
    if (!respectsImperativStructure(item, candidate)) return false;
    final normalized = normalizeForComparison(candidate);
    final accepted = <String>[item.correctForm, ...item.acceptedForms];
    return accepted.any(
      (form) => normalizeForComparison(form) == normalized,
    );
  }

  @override
  bool respectsImperativStructure(
    ImperativDrillItem item,
    String candidate,
  ) {
    final normalized = normalizeForComparison(candidate);
    if (normalized.isEmpty) return false;
    final tokens = normalized.split(' ');
    final first = tokens.first;

    return switch (item.target) {
      ImperativTarget.duForm =>
        !tokens.contains('du') &&
            !first.toLowerCase().endsWith('st'),
      ImperativTarget.ihrForm => !tokens.contains('ihr'),
      ImperativTarget.sieForm =>
        tokens.contains('Sie') &&
            !tokens.contains('du') &&
            !tokens.contains('ihr'),
      ImperativTarget.wirForm =>
        tokens.contains('wir') &&
            !tokens.contains('du') &&
            !tokens.contains('ihr'),
    };
  }

  @override
  String normalizeForComparison(String value) => value
      .trim()
      .replaceAll(RegExp(r'[.!?…]+$'), '')
      .replaceAll(RegExp(r'\s+'), ' ');
}
