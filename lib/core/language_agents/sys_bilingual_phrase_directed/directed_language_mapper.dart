import 'bilingual_models.dart';

final class DirectedLanguageMapper {
  const DirectedLanguageMapper({this.catalog = _catalog});

  final List<DirectedPhrase> catalog;

  DirectedPhrase? map({
    required String sourceLanguageId,
    required String targetLanguageId,
    required String sourceText,
    required LifeContext context,
  }) {
    final source = _normalize(sourceText);
    for (final phrase in catalog) {
      if (phrase.sourceLanguageId != sourceLanguageId ||
          phrase.targetLanguageId != targetLanguageId ||
          phrase.context != context) {
        continue;
      }
      if (_normalize(phrase.sourceText) == source) return phrase;
    }
    return null;
  }

  List<DirectedPhrase> entriesFor({
    required String sourceLanguageId,
    required String targetLanguageId,
    LifeContext? context,
  }) =>
      List<DirectedPhrase>.unmodifiable(
        catalog.where(
          (phrase) =>
              phrase.sourceLanguageId == sourceLanguageId &&
              phrase.targetLanguageId == targetLanguageId &&
              (context == null || phrase.context == context),
        ),
      );

  static String _normalize(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAll('„', '"')
      .replaceAll('“', '"');
}

const List<DirectedPhrase> _catalog = <DirectedPhrase>[
  DirectedPhrase(
    id: 'de-ar-greeting-hello',
    sourceLanguageId: 'de',
    targetLanguageId: 'ar',
    sourceText: 'Guten Tag!',
    targetText: 'مرحبًا!',
    context: LifeContext.greeting,
    register: PhraseRegister.polite,
  ),
  DirectedPhrase(
    id: 'de-ar-greeting-thanks',
    sourceLanguageId: 'de',
    targetLanguageId: 'ar',
    sourceText: 'Vielen Dank.',
    targetText: 'شكرًا جزيلاً.',
    context: LifeContext.greeting,
    register: PhraseRegister.polite,
  ),
  DirectedPhrase(
    id: 'de-ar-shopping-price',
    sourceLanguageId: 'de',
    targetLanguageId: 'ar',
    sourceText: 'Wie viel kostet das?',
    targetText: 'كم سعر هذا؟',
    context: LifeContext.shopping,
    register: PhraseRegister.polite,
  ),
  DirectedPhrase(
    id: 'de-ar-shopping-card',
    sourceLanguageId: 'de',
    targetLanguageId: 'ar',
    sourceText: 'Kann ich mit Karte bezahlen?',
    targetText: 'هل يمكنني الدفع بالبطاقة؟',
    context: LifeContext.shopping,
    register: PhraseRegister.polite,
  ),
  DirectedPhrase(
    id: 'de-ar-shopping-method-slot',
    sourceLanguageId: 'de',
    targetLanguageId: 'ar',
    sourceText: 'Kann ich mit {method} bezahlen?',
    targetText: 'هل يمكنني الدفع بواسطة {method}؟',
    context: LifeContext.shopping,
    register: PhraseRegister.polite,
    semanticSlots: <String>['method'],
  ),
  DirectedPhrase(
    id: 'de-ar-housing-rent',
    sourceLanguageId: 'de',
    targetLanguageId: 'ar',
    sourceText: 'Wie hoch ist die monatliche Miete?',
    targetText: 'كم قيمة الإيجار الشهري؟',
    context: LifeContext.housing,
    register: PhraseRegister.polite,
  ),
  DirectedPhrase(
    id: 'de-ar-housing-repair',
    sourceLanguageId: 'de',
    targetLanguageId: 'ar',
    sourceText: 'Die Heizung funktioniert nicht.',
    targetText: 'التدفئة لا تعمل.',
    context: LifeContext.housing,
    register: PhraseRegister.neutral,
  ),
  DirectedPhrase(
    id: 'de-ar-transport-ticket',
    sourceLanguageId: 'de',
    targetLanguageId: 'ar',
    sourceText: 'Wo kann ich eine Fahrkarte kaufen?',
    targetText: 'أين يمكنني شراء تذكرة؟',
    context: LifeContext.transport,
    register: PhraseRegister.polite,
  ),
  DirectedPhrase(
    id: 'de-ar-transport-platform',
    sourceLanguageId: 'de',
    targetLanguageId: 'ar',
    sourceText: 'Von welchem Gleis fährt der Zug ab?',
    targetText: 'من أي رصيف ينطلق القطار؟',
    context: LifeContext.transport,
    register: PhraseRegister.polite,
  ),
  DirectedPhrase(
    id: 'de-ar-health-appointment',
    sourceLanguageId: 'de',
    targetLanguageId: 'ar',
    sourceText: 'Ich möchte einen Termin vereinbaren.',
    targetText: 'أريد حجز موعد.',
    context: LifeContext.health,
    register: PhraseRegister.polite,
  ),
  DirectedPhrase(
    id: 'de-ar-health-pain',
    sourceLanguageId: 'de',
    targetLanguageId: 'ar',
    sourceText: 'Ich habe seit gestern starke Schmerzen.',
    targetText: 'لدي ألم شديد منذ الأمس.',
    context: LifeContext.health,
    register: PhraseRegister.neutral,
  ),
  DirectedPhrase(
    id: 'de-ar-work-hours',
    sourceLanguageId: 'de',
    targetLanguageId: 'ar',
    sourceText: 'Wie sind die Arbeitszeiten?',
    targetText: 'ما ساعات العمل؟',
    context: LifeContext.work,
    register: PhraseRegister.polite,
  ),
  DirectedPhrase(
    id: 'de-ar-work-application',
    sourceLanguageId: 'de',
    targetLanguageId: 'ar',
    sourceText: 'Ich möchte mich auf diese Stelle bewerben.',
    targetText: 'أرغب في التقدم لهذه الوظيفة.',
    context: LifeContext.work,
    register: PhraseRegister.formal,
  ),
  DirectedPhrase(
    id: 'de-ar-bureaucracy-form',
    sourceLanguageId: 'de',
    targetLanguageId: 'ar',
    sourceText: 'Welches Formular muss ich ausfüllen?',
    targetText: 'أي نموذج يجب أن أعبئه؟',
    context: LifeContext.bureaucracy,
    register: PhraseRegister.polite,
  ),
  DirectedPhrase(
    id: 'de-ar-bureaucracy-documents',
    sourceLanguageId: 'de',
    targetLanguageId: 'ar',
    sourceText: 'Welche Unterlagen muss ich mitbringen?',
    targetText: 'ما الوثائق التي يجب أن أحضرها؟',
    context: LifeContext.bureaucracy,
    register: PhraseRegister.polite,
  ),
  DirectedPhrase(
    id: 'de-ar-social-recovery',
    sourceLanguageId: 'de',
    targetLanguageId: 'ar',
    sourceText: 'Gute Besserung!',
    targetText: 'سلامتك، أتمنى لك الشفاء العاجل!',
    context: LifeContext.social,
    register: PhraseRegister.polite,
  ),
  DirectedPhrase(
    id: 'de-ar-social-condolence',
    sourceLanguageId: 'de',
    targetLanguageId: 'ar',
    sourceText: 'Mein herzliches Beileid.',
    targetText: 'خالص التعازي.',
    context: LifeContext.social,
    register: PhraseRegister.formal,
  ),
  DirectedPhrase(
    id: 'de-ar-emergency-help',
    sourceLanguageId: 'de',
    targetLanguageId: 'ar',
    sourceText: 'Bitte rufen Sie einen Krankenwagen.',
    targetText: 'من فضلك اتصل بالإسعاف.',
    context: LifeContext.emergency,
    register: PhraseRegister.formal,
  ),
  DirectedPhrase(
    id: 'ar-de-greeting-hello',
    sourceLanguageId: 'ar',
    targetLanguageId: 'de',
    sourceText: 'مرحبًا!',
    targetText: 'Guten Tag!',
    context: LifeContext.greeting,
    register: PhraseRegister.polite,
  ),
  DirectedPhrase(
    id: 'ar-de-greeting-thanks',
    sourceLanguageId: 'ar',
    targetLanguageId: 'de',
    sourceText: 'شكرًا جزيلاً.',
    targetText: 'Vielen Dank.',
    context: LifeContext.greeting,
    register: PhraseRegister.polite,
  ),
  DirectedPhrase(
    id: 'ar-de-shopping-price',
    sourceLanguageId: 'ar',
    targetLanguageId: 'de',
    sourceText: 'كم سعر هذا؟',
    targetText: 'Wie viel kostet das?',
    context: LifeContext.shopping,
    register: PhraseRegister.polite,
  ),
  DirectedPhrase(
    id: 'ar-de-shopping-card',
    sourceLanguageId: 'ar',
    targetLanguageId: 'de',
    sourceText: 'هل يمكنني الدفع بالبطاقة؟',
    targetText: 'Kann ich mit Karte bezahlen?',
    context: LifeContext.shopping,
    register: PhraseRegister.polite,
  ),
  DirectedPhrase(
    id: 'ar-de-shopping-method-slot',
    sourceLanguageId: 'ar',
    targetLanguageId: 'de',
    sourceText: 'هل يمكنني الدفع بواسطة {method}؟',
    targetText: 'Kann ich mit {method} bezahlen?',
    context: LifeContext.shopping,
    register: PhraseRegister.polite,
    semanticSlots: <String>['method'],
  ),
  DirectedPhrase(
    id: 'ar-de-housing-rent',
    sourceLanguageId: 'ar',
    targetLanguageId: 'de',
    sourceText: 'كم قيمة الإيجار الشهري؟',
    targetText: 'Wie hoch ist die monatliche Miete?',
    context: LifeContext.housing,
    register: PhraseRegister.polite,
  ),
  DirectedPhrase(
    id: 'ar-de-housing-repair',
    sourceLanguageId: 'ar',
    targetLanguageId: 'de',
    sourceText: 'التدفئة لا تعمل.',
    targetText: 'Die Heizung funktioniert nicht.',
    context: LifeContext.housing,
    register: PhraseRegister.neutral,
  ),
  DirectedPhrase(
    id: 'ar-de-transport-ticket',
    sourceLanguageId: 'ar',
    targetLanguageId: 'de',
    sourceText: 'أين يمكنني شراء تذكرة؟',
    targetText: 'Wo kann ich eine Fahrkarte kaufen?',
    context: LifeContext.transport,
    register: PhraseRegister.polite,
  ),
  DirectedPhrase(
    id: 'ar-de-transport-platform',
    sourceLanguageId: 'ar',
    targetLanguageId: 'de',
    sourceText: 'من أي رصيف ينطلق القطار؟',
    targetText: 'Von welchem Gleis fährt der Zug ab?',
    context: LifeContext.transport,
    register: PhraseRegister.polite,
  ),
  DirectedPhrase(
    id: 'ar-de-health-appointment',
    sourceLanguageId: 'ar',
    targetLanguageId: 'de',
    sourceText: 'أريد حجز موعد.',
    targetText: 'Ich möchte einen Termin vereinbaren.',
    context: LifeContext.health,
    register: PhraseRegister.polite,
  ),
  DirectedPhrase(
    id: 'ar-de-health-pain',
    sourceLanguageId: 'ar',
    targetLanguageId: 'de',
    sourceText: 'لدي ألم شديد منذ الأمس.',
    targetText: 'Ich habe seit gestern starke Schmerzen.',
    context: LifeContext.health,
    register: PhraseRegister.neutral,
  ),
  DirectedPhrase(
    id: 'ar-de-work-hours',
    sourceLanguageId: 'ar',
    targetLanguageId: 'de',
    sourceText: 'ما ساعات العمل؟',
    targetText: 'Wie sind die Arbeitszeiten?',
    context: LifeContext.work,
    register: PhraseRegister.polite,
  ),
  DirectedPhrase(
    id: 'ar-de-work-application',
    sourceLanguageId: 'ar',
    targetLanguageId: 'de',
    sourceText: 'أرغب في التقدم لهذه الوظيفة.',
    targetText: 'Ich möchte mich auf diese Stelle bewerben.',
    context: LifeContext.work,
    register: PhraseRegister.formal,
  ),
  DirectedPhrase(
    id: 'ar-de-bureaucracy-form',
    sourceLanguageId: 'ar',
    targetLanguageId: 'de',
    sourceText: 'أي نموذج يجب أن أعبئه؟',
    targetText: 'Welches Formular muss ich ausfüllen?',
    context: LifeContext.bureaucracy,
    register: PhraseRegister.polite,
  ),
  DirectedPhrase(
    id: 'ar-de-bureaucracy-documents',
    sourceLanguageId: 'ar',
    targetLanguageId: 'de',
    sourceText: 'ما الوثائق التي يجب أن أحضرها؟',
    targetText: 'Welche Unterlagen muss ich mitbringen?',
    context: LifeContext.bureaucracy,
    register: PhraseRegister.polite,
  ),
  DirectedPhrase(
    id: 'ar-de-social-recovery',
    sourceLanguageId: 'ar',
    targetLanguageId: 'de',
    sourceText: 'سلامتك، أتمنى لك الشفاء العاجل!',
    targetText: 'Gute Besserung!',
    context: LifeContext.social,
    register: PhraseRegister.polite,
  ),
  DirectedPhrase(
    id: 'ar-de-social-condolence',
    sourceLanguageId: 'ar',
    targetLanguageId: 'de',
    sourceText: 'خالص التعازي.',
    targetText: 'Mein herzliches Beileid.',
    context: LifeContext.social,
    register: PhraseRegister.formal,
  ),
  DirectedPhrase(
    id: 'ar-de-emergency-help',
    sourceLanguageId: 'ar',
    targetLanguageId: 'de',
    sourceText: 'من فضلك اتصل بالإسعاف.',
    targetText: 'Bitte rufen Sie einen Krankenwagen.',
    context: LifeContext.emergency,
    register: PhraseRegister.formal,
  ),
];
