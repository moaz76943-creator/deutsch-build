import 'buergeramt_anmeldung_scenario.dart';

/// Interactive dialogue scenario for concluding clean electricity contracts and reporting meter readings.
class EnergieversorgerScenario {
  static const List<ScenarioDialogueTurn> turns = [
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Stadtwerke Kundencenter, guten Tag! Möchten Sie einen Stromvertrag für Ihre neue Wohnung abschließen?',
      utteranceAr: 'مركز خدمة عملاء مرافق المدينة، نهاركم سعيد! هل ترغبون في إبرام عقد تزويد بالكهرباء لمسكنكم الجديد؟',
      linguisticTip: 'die Stadtwerke = شركة المرافق العامة للمدينة (كهرباء، ماء، غاز).',
    ),
    ScenarioDialogueTurn(
      speaker: 'learner',
      utteranceDe: 'Guten Tag. Ja, ich bin zum Monatsersten eingezogen und wünsche einen Tarif mit hundert Prozent Ökostrom.',
      utteranceAr: 'نهاركم سعيد. نعم، انتقلت في أول الشهر وأرغب في باقة كهرباء تعتمد 100% على الطاقة المتجددة النظيفة.',
      linguisticTip: 'der Ökostrom = الكهرباء النظيفة المولدة من مصادر متجددة (شمس ورياح).',
    ),
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Eine vorbildliche Wahl. Bitte teilen Sie mir die Zählernummer und den aktuellen Zählerstand mit.',
      utteranceAr: 'خيار واعٍ ومثالي. يُرجى تزويدي برقم عداد الكهرباء وقراءة الاستهلاك الحالية المدونة عليه.',
      linguisticTip: 'die Zählernummer = رقم العداد، der Zählerstand = قراءة أرقام العداد.',
    ),
    ScenarioDialogueTurn(
      speaker: 'learner',
      utteranceDe: 'Die Zählernummer lautet 48291 und der Zählerstand bei Wohnungsübergabe beträgt exakt 12.450 Kilowattstunden.',
      utteranceAr: 'رقم العداد هو 48291 وقراءة الاستهلاك عند استلام الشقة تبلغ بدقة 12,450 كيلوواط/ساعة.',
      linguisticTip: 'die Wohnungsübergabe = محضر تسليم الشقة بين المالك والمستأجر.',
    ),
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Vielen Dank. Ihr monatlicher Abschlag beträgt 65 Euro. Die Vertragsbestätigung geht Ihnen per Post zu.',
      utteranceAr: 'شكراً جزيلاً لكم. القسط الشهري الثابت يبلغ 65 يورو، وسنوافيكم بتأكيد العقد الرسمي عبر البريد.',
      linguisticTip: 'der monatliche Abschlag = القسط الشهري التقديري للكهرباء.',
    ),
  ];
}
