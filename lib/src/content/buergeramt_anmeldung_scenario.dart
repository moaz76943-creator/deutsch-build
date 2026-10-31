/// A discrete turn in a situational roleplay scenario.
class ScenarioDialogueTurn {
  final String speaker; // 'clerk', 'learner'
  final String utteranceDe;
  final String utteranceAr;
  final String linguisticTip;

  const ScenarioDialogueTurn({
    required this.speaker,
    required this.utteranceDe,
    required this.utteranceAr,
    required this.linguisticTip,
  });
}

/// Fully scripted interactive roleplay for German municipal registration (Bürgeramt).
class BuergeramtAnmeldungScenario {
  static const List<ScenarioDialogueTurn> turns = [
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Guten Tag! Haben Sie einen Termin zur Anmeldung?',
      utteranceAr: 'نهاركم سعيد! هل لديكم موعد محجوز لتسجيل السكن؟',
      linguisticTip: 'صيغة السؤال المهذبة الرسمية باستخدام Siezen.',
    ),
    ScenarioDialogueTurn(
      speaker: 'learner',
      utteranceDe: 'Guten Tag. Ja, hier ist meine Terminbestätigung und mein Pass.',
      utteranceAr: 'نهاركم سعيد. نعم، تفضل هذا تأكيد موعدي وجواز سفري.',
      linguisticTip: 'تقديم الوثائق بهدوء وثقة مع التحية اللبقة.',
    ),
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Vielen Dank. Haben Sie auch die Wohnungsgeberbestätigung vom Vermieter dabei?',
      utteranceAr: 'شكراً جزيلاً. هل أحضرتم معكم أيضاً وثيقة تأكيد السكن من المؤجر؟',
      linguisticTip: 'Wohnungsgeberbestätigung وثيقة إلزامية قانونياً من صاحب السكن.',
    ),
    ScenarioDialogueTurn(
      speaker: 'learner',
      utteranceDe: 'Ja, hier ist das unterschriebene Formular vom Vermieter.',
      utteranceAr: 'نعم، تفضل هذه هي الاستمارة الموقعة من صاحب السكن.',
      linguisticTip: 'unterschrieben = موقعة رسمياً.',
    ),
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Perfekt. Ihre Anmeldung ist abgeschlossen. Hier ist Ihre Meldebescheinigung.',
      utteranceAr: 'ممتاز. اكتمل تسجيل سكنكم بنجاح. تفضل هذه هي شهادة تسجيل السكن الرسمية.',
      linguisticTip: 'Meldebescheinigung هي أهم ورقة لفتح حساب بنكي وتثبيت الإقامة.',
    ),
  ];
}
