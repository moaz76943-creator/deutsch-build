import 'environment_models.dart';

final class GardeningBalconySubAgent {
  const GardeningBalconySubAgent();

  List<EnvironmentEntry> get entries => _entries;

  static const List<EnvironmentEntry> _entries = <EnvironmentEntry>[
    EnvironmentEntry(
      id: 'garden-balcony-planting',
      category: EnvironmentCategory.gardeningBalcony,
      titleDe: 'Balkon bepflanzen',
      titleAr: 'زراعة الشرفة',
      german:
          'Welche Pflanzen eignen sich für meinen Balkon, und wie oft sollte ich sie gießen?',
      arabic:
          'ما النباتات المناسبة لشرفتي، وكم مرة ينبغي أن أسقيها؟',
      contextDe: 'Nach Standort, Sonne, Wasserbedarf und Pflanzgefäßen fragen',
      contextAr: 'السؤال عن الشمس والري والأصص المناسبة للنباتات',
      keywords: <String>['Balkon', 'Pflanzen', 'gießen', 'Blumentopf', 'Sonne'],
    ),
    EnvironmentEntry(
      id: 'garden-kleingarten-rules',
      category: EnvironmentCategory.gardeningBalcony,
      titleDe: 'Kleingartenverein & Gartenordnung',
      titleAr: 'جمعية الحدائق وقواعد الحديقة',
      german:
          'Welche Gartenordnung gilt in diesem Kleingartenverein, und wann sind Ruhezeiten?',
      arabic:
          'ما قواعد الحديقة المعمول بها في جمعية الحدائق هذه، ومتى تكون أوقات الهدوء؟',
      contextDe: 'Örtliche Vereins- und Ruhezeitregeln ausdrücklich erfragen',
      contextAr: 'السؤال مباشرة عن قواعد الجمعية وأوقات الهدوء المحلية',
      keywords: <String>[
        'Kleingartenverein',
        'Gartenordnung',
        'Ruhezeiten',
        'Verein',
      ],
    ),
    EnvironmentEntry(
      id: 'garden-lawn-hours',
      category: EnvironmentCategory.gardeningBalcony,
      titleDe: 'Rasenmäher & Ruhezeiten',
      titleAr: 'جزازة العشب وأوقات الهدوء',
      german:
          'Darf ich den Rasenmäher werktags zwischen 7 und 20 Uhr benutzen, oder gelten hier zusätzliche Ruhezeiten?',
      arabic:
          'هل يمكنني استخدام جزازة العشب في أيام العمل بين السابعة صباحًا والثامنة مساءً، أم توجد هنا أوقات هدوء إضافية؟',
      contextDe:
          'In Wohngebieten gilt für Geräte wie Rasenmäher grundsätzlich: nicht an Sonn- und Feiertagen und nicht zwischen 20 und 7 Uhr; örtliche Regeln können strenger sein.',
      contextAr:
          'في المناطق السكنية يسري عمومًا حظر استخدام أجهزة مثل جزازات العشب أيام الأحد والعطل وبين 20:00 و07:00، وقد توجد قواعد محلية أشد.',
      sourceLabel: '32. BImSchV § 7',
      keywords: <String>['Rasenmäher', 'mähen', '7 Uhr', '20 Uhr', 'Ruhezeit'],
    ),
    EnvironmentEntry(
      id: 'garden-hedge-period',
      category: EnvironmentCategory.gardeningBalcony,
      titleDe: 'Hecke schneiden & Naturschutz',
      titleAr: 'قص السياج وحماية الطبيعة',
      german:
          'Darf ich die Hecke jetzt stark zurückschneiden, oder fällt das in die Schutzzeit vom 1. März bis 30. September?',
      arabic:
          'هل يمكنني تقليم السياج بقوة الآن، أم أن ذلك يقع ضمن فترة الحماية من 1 مارس إلى 30 سبتمبر؟',
      contextDe:
          'Starkes Abschneiden, Auf-den-Stock-Setzen oder Beseitigen von Hecken ist in dieser Zeit grundsätzlich verboten; schonende Form- und Pflegeschnitte bleiben möglich.',
      contextAr:
          'القص القوي أو إزالة السياج محظور عمومًا خلال هذه الفترة، بينما يبقى التقليم اللطيف للشكل والعناية ممكنًا.',
      sourceLabel: 'Bundesnaturschutzgesetz § 39 Abs. 5',
      keywords: <String>[
        'Hecke',
        '1. März',
        '30. September',
        'Bundesnaturschutzgesetz',
        'Pflegeschnitt',
      ],
    ),
    EnvironmentEntry(
      id: 'garden-tree-check',
      category: EnvironmentCategory.gardeningBalcony,
      titleDe: 'Baumschnitt richtig prüfen',
      titleAr: 'التحقق من قواعد تقليم الأشجار',
      german:
          'Welche Schutzregeln gelten für diesen Baum an diesem Standort, und gibt es ein geschütztes Nest?',
      arabic:
          'ما قواعد الحماية التي تنطبق على هذه الشجرة في هذا الموقع، وهل يوجد عش محمي؟',
      contextDe:
          'Bei Bäumen hängt die Rechtslage unter anderem vom Standort und von zusätzlichen Artenschutz- oder örtlichen Baumschutzregeln ab.',
      contextAr:
          'بالنسبة للأشجار تعتمد القاعدة على الموقع وعلى حماية الأنواع أو قواعد حماية الأشجار المحلية الإضافية.',
      sourceLabel: 'BNatSchG § 39 · örtliche Regeln zusätzlich prüfen',
      keywords: <String>['Baum', 'Baumschnitt', 'Nest', 'Artenschutz', 'Baumschutz'],
    ),
  ];
}
