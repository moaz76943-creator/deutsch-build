import 'package:deutsch_bilarabi/models/linguistics/german_grammar_types.dart';

enum PrepositionCaseType {
  accusativeOnly,
  dativeOnly,
  twoWay, // Wechselpräposition (Dativ für Ort / Akkusativ für Richtung)
  genitiveOnly,
}

class PrepositionRule {
  final String preposition;
  final PrepositionCaseType type;
  final GermanCase requiredCase;
  final String explanation;

  const PrepositionRule({
    required this.preposition,
    required this.type,
    required this.requiredCase,
    required this.explanation,
  });
}

class VerbValencyInfo {
  final String verb;
  final GermanCase primaryCase;
  final String? governedPreposition;
  final GermanCase? prepositionCase;
  final String explanation;

  const VerbValencyInfo({
    required this.verb,
    required this.primaryCase,
    this.governedPreposition,
    this.prepositionCase,
    required this.explanation,
  });
}

/// محرك تعدية الأفعال وحالات الجر والنصب (Verb Valency & Preposition Cases) - Study 44
/// يحدد الحالة الإعرابية التي يفرضها الفعل وحروف الجر الألمانية الثابتة والمشتركة
class VerbValencyEngine {
  /// أشهر أفعال المجرور (Dativ-Verben)
  static const Map<String, String> _dativeVerbs = {
    'helfen': 'يساعد شخصاً (jemandem helfen)',
    'danken': 'يشكر شخصاً (jemandem danken)',
    'gehören': 'ينتمي/يخص شخصاً (jemandem gehören)',
    'gratulieren': 'يهنئ شخصاً (jemandem gratulieren)',
    'schmecken': 'يعجب ذوقه (jemandem schmecken)',
    'passen': 'يناسب شخصاً (jemandem passen)',
    'antworten': 'يجيب شخصاً (jemandem antworten)',
    'fehlen': 'يفتقده شخص (jemandem fehlen)',
    'folgen': 'يتبع شخصاً (jemandem folgen)',
    'vertrauen': 'يثق بشخص (jemandem vertrauen)',
    'wehtun': 'يؤلم شخصاً (jemandem wehtun)',
    'zustimmen': 'يوافق شخصاً (jemandem zustimmen)',
    'gefallen': 'يعجب شخصاً (jemandem gefallen)',
    'zuflüstern': 'يهمس لشخص (jemandem zuflüstern)',
    'raten': 'ينصح شخصاً (jemandem raten)',
    'schaden': 'يضر شخصاً (jemandem schaden)',
    'genügen': 'يكفي شخصاً (jemandem genügen)',
    'gehorchen': 'يطيع شخصاً (jemandem gehorchen)',
  };

  /// حروف الجر التي تأخذ النصب دائماً (Akkusativ)
  static const Set<String> _accusativePrepositions = {
    'durch', 'für', 'gegen', 'ohne', 'um', 'bis', 'entlang',
  };

  /// حروف الجر التي تأخذ المجرور دائماً (Dativ)
  static const Set<String> _dativePrepositions = {
    'aus', 'außer', 'bei', 'mit', 'nach', 'seit', 'von', 'zu', 'gegenüber',
  };

  /// حروف الجر المشتركة (Wechselpräpositionen): Dativ للموقع وAkkusativ للحركة
  static const Set<String> _twoWayPrepositions = {
    'an', 'auf', 'hinter', 'in', 'neben', 'über', 'unter', 'vor', 'zwischen',
  };

  /// حروف الجر التي تأخذ الإضافة (Genitiv)
  static const Set<String> _genitivePrepositions = {
    'während', 'wegen', 'trotz', 'statt', 'anstatt', 'infolge', 'innerhalb', 'außerhalb',
  };

  /// استعلام عن الحالة الإعرابية التي يطلبها الفعل
  static VerbValencyInfo getVerbValency(String verb) {
    final lower = verb.trim().toLowerCase();

    if (_dativeVerbs.containsKey(lower)) {
      return VerbValencyInfo(
        verb: verb,
        primaryCase: GermanCase.dative,
        explanation: 'الفعل "$verb" يطلب مفعولاً به في حالة الجر (Dativ): ${_dativeVerbs[lower]}.',
      );
    }

    // الغالبية العظمى من الأفعال المتعدية في الألمانية تطلب مفعولاً به منصوباً (Akkusativ)
    return VerbValencyInfo(
      verb: verb,
      primaryCase: GermanCase.accusative,
      explanation: 'الفعل "$verb" فعل متعدٍ قياسي يطلب مفعولاً به في حالة النصب (Akkusativ).',
    );
  }

  /// فحص حرف الجر وتحديد الحالة الإعرابية الملزمة
  static PrepositionRule evaluatePreposition(String preposition, {bool isDirectionalMotion = false}) {
    final lower = preposition.trim().toLowerCase();

    if (_accusativePrepositions.contains(lower)) {
      return PrepositionRule(
        preposition: preposition,
        type: PrepositionCaseType.accusativeOnly,
        requiredCase: GermanCase.accusative,
        explanation: 'حرف الجر "$preposition" يلزم حالة النصب (Akkusativ) دائماً.',
      );
    }

    if (_dativePrepositions.contains(lower)) {
      return PrepositionRule(
        preposition: preposition,
        type: PrepositionCaseType.dativeOnly,
        requiredCase: GermanCase.dative,
        explanation: 'حرف الجر "$preposition" يلزم حالة الجر (Dativ) دائماً.',
      );
    }

    if (_twoWayPrepositions.contains(lower)) {
      if (isDirectionalMotion) {
        return PrepositionRule(
          preposition: preposition,
          type: PrepositionCaseType.twoWay,
          requiredCase: GermanCase.accusative,
          explanation: 'حرف الجر المشترك "$preposition" مع حركة متجهة (Wohin?) يأخذ حالة النصب (Akkusativ).',
        );
      } else {
        return PrepositionRule(
          preposition: preposition,
          type: PrepositionCaseType.twoWay,
          requiredCase: GermanCase.dative,
          explanation: 'حرف الجر المشترك "$preposition" مع موقع ثابت وسكون (Wo?) يأخذ حالة الجر (Dativ).',
        );
      }
    }

    if (_genitivePrepositions.contains(lower)) {
      return PrepositionRule(
        preposition: preposition,
        type: PrepositionCaseType.genitiveOnly,
        requiredCase: GermanCase.genitive,
        explanation: 'حرف الجر "$preposition" يلزم حالة الإضافة (Genitiv).',
      );
    }

    return PrepositionRule(
      preposition: preposition,
      type: PrepositionCaseType.dativeOnly,
      requiredCase: GermanCase.dative,
      explanation: 'حرف الجر "$preposition" يتبع القواعد العامة.',
    );
  }
}
