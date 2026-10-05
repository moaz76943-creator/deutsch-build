import '../../../core/explain_why/deterministic_explain_why_engine.dart';

final ExplainWhyEngine arDeGrammarExplainWhyEngine =
    DeterministicExplainWhyEngine(
  ExplainWhyCatalog(
    userLanguageCode: 'ar',
    sourceLanguageCode: 'ar',
    targetLanguageCode: 'de',
    templates: <String, ExplainWhyTemplate>{
      'grammar.input.incomplete': ExplainWhyTemplate(
        reasonCode: 'grammar.input.incomplete',
        successTemplate: 'الإجابة مكتملة.',
        failureTemplate: 'رتّب جميع الكلمات أولًا ثم تحقّق من الجملة.',
      ),
      'grammar.word_order.main_v2': ExplainWhyTemplate(
        reasonCode: 'grammar.word_order.main_v2',
        successTemplate:
            'صحيح — في الجملة الرئيسية الألمانية يأتي الفعل المصرف في الموقع الثاني (V2).',
        failureTemplate:
            'في الجملة الرئيسية الألمانية يجب أن يكون الفعل المصرف في الموقع الثاني (V2).',
      ),
      'grammar.word_order.subordinate_final': ExplainWhyTemplate(
        reasonCode: 'grammar.word_order.subordinate_final',
        successTemplate:
            'صحيح — مع {connector} أبقيت الفعل المصرف في نهاية الجملة الفرعية.',
        failureTemplate:
            '{connector} تدخل جملة فرعية؛ الفعل المصرف يأتي في نهايتها.',
      ),
      'grammar.verb.conjugation': ExplainWhyTemplate(
        reasonCode: 'grammar.verb.conjugation',
        successTemplate:
            'صحيح — مع {pronoun}: {infinitive} → {expected}.',
        failureTemplate:
            'راجع التصريف مع الضمير {pronoun}: {infinitive} → {expected}.',
      ),
      'grammar.case.direct_object': ExplainWhyTemplate(
        reasonCode: 'grammar.case.direct_object',
        successTemplate:
            'صحيح — {noun} مذكر وهو مفعول به مباشر؛ {baseArticle} → {expected} في {caseLabel}.',
        failureTemplate:
            '{noun} مذكر وهو مفعول به مباشر؛ نحتاج {caseLabel}: {baseArticle} → {expected}.',
      ),
      'grammar.case.preposition': ExplainWhyTemplate(
        reasonCode: 'grammar.case.preposition',
        successTemplate:
            'صحيح — {preposition} يطلب {caseLabel}؛ لذلك {baseArticle} → {expected} قبل {noun}.',
        failureTemplate:
            '{preposition} يطلب {caseLabel}؛ لذلك {baseArticle} → {expected} قبل {noun}.',
      ),
    },
  ),
);
