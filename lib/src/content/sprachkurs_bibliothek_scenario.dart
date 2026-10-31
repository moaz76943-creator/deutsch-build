import 'buergeramt_anmeldung_scenario.dart';

/// Interactive dialogue scenario for enrolling in advanced language courses and obtaining a public library card.
class SprachkursBibliothekScenario {
  static const List<ScenarioDialogueTurn> turns = [
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Guten Tag! Willkommen in der Stadtbibliothek und im Weiterbildungszentrum. Wie kann ich helfen?',
      utteranceAr: 'نهاركم سعيد! أهلاً بكم في مكتبة المدينة العامة ومركز التعليم المستمر. كيف أستطيع خدمتكم؟',
      linguisticTip: 'die Stadtbibliothek = المكتبة العامة للمدينة.',
    ),
    ScenarioDialogueTurn(
      speaker: 'learner',
      utteranceDe: 'Guten Tag. Ich möchte mich für den neuen B2-Sprachkurs anmelden und einen Bibliotheksausweis beantragen.',
      utteranceAr: 'نهاركم سعيد. أود التسجيل في دورة اللغة الألمانية الجديدة لمستوى B2، والتقديم لاستخراج بطاقة اشتراك المكتبة.',
      linguisticTip: 'einen Ausweis beantragen = يقدم طلباً رسمياً لاستخراج بطاقة عضوية.',
    ),
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Ausgezeichnet. Für den Kurs machen wir einen kurzen Einstufungstest, um das optimale Lernniveau sicherzustellen.',
      utteranceAr: 'ممتاز جداً. بالنسبة للدورة سنجري اختبار تحديد مستوى قصيراً لضمان اختيار المستوى التعليمي الأنسب لكم.',
      linguisticTip: 'der Einstufungstest = اختبار تحديد المستوى اللغوي.',
    ),
    ScenarioDialogueTurn(
      speaker: 'learner',
      utteranceDe: 'Sehr gerne. Welche Unterlagen benötigen Sie für die Ausstellung des Bibliotheksausweises?',
      utteranceAr: 'بكل سرور. ما هي الأوراق الثبوتية التي تحتاجونها لإصدار بطاقة عضوية المكتبة؟',
      linguisticTip: 'die Ausstellung = إصدار الوثيقة أو البطاقة رسمياً.',
    ),
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Lediglich Ihren Personalausweis und die Meldebescheinigung. Damit können Sie ab heute tausende Bücher kostenlos ausleihen.',
      utteranceAr: 'فقط إثبات هويتكم الشخصية وشهادة تسجيل السكن. وبذلك يمكنكم من اليوم استعارة آلاف الكتب القيمة مجاناً.',
      linguisticTip: 'ausleihen = يستعير كتاباً (خلاف kaufen = يشتري).',
    ),
  ];
}
