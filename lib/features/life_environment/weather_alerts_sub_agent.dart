import 'environment_models.dart';

final class WeatherAlertsSubAgent {
  const WeatherAlertsSubAgent();

  List<EnvironmentEntry> get entries => _entries;

  static const List<EnvironmentEntry> _entries = <EnvironmentEntry>[
    EnvironmentEntry(
      id: 'weather-dwd',
      category: EnvironmentCategory.severeWeather,
      titleDe: 'DWD-Wetterwarnung',
      titleAr: 'تحذير خدمة الطقس الألمانية',
      german: 'Gibt es für meinen Landkreis eine aktuelle DWD-Wetterwarnung?',
      arabic: 'هل يوجد تحذير طقس حالي من DWD لمنطقتي؟',
      contextDe: 'Nach einer amtlichen Warnung für den eigenen Landkreis fragen',
      contextAr: 'السؤال عن تحذير رسمي للمنطقة أو المقاطعة',
      sourceLabel: 'DWD · Deutscher Wetterdienst',
      keywords: <String>[
        'DWD',
        'WarnWetter',
        'Wetterwarnung',
        'Warnstufe',
        'Landkreis',
      ],
    ),
    EnvironmentEntry(
      id: 'weather-storm',
      category: EnvironmentCategory.severeWeather,
      titleDe: 'Sturmtief & Sturmwarnung',
      titleAr: 'منخفض جوي وتحذير عاصفة',
      german:
          'Für unsere Region wurde ein Sturmtief angekündigt. Was sollte ich auf dem Balkon sichern?',
      arabic:
          'تم الإعلان عن منخفض عاصف لمنطقتنا. ما الأشياء التي يجب تثبيتها على الشرفة؟',
      contextDe: 'Vor Sturm lose Gegenstände sichern und eine Warnung verstehen',
      contextAr: 'فهم تحذير العاصفة وتأمين الأشياء غير المثبتة',
      sourceLabel: 'DWD-Warnsystem',
      keywords: <String>['Sturmtief', 'Sturm', 'Sturmböen', 'Unwetter', 'Wind'],
    ),
    EnvironmentEntry(
      id: 'weather-ice',
      category: EnvironmentCategory.severeWeather,
      titleDe: 'Frost & Glättegefahr',
      titleAr: 'الصقيع وخطر الانزلاق',
      german:
          'Es besteht Glättegefahr. Sind Straßen und Gehwege in meiner Gegend betroffen?',
      arabic:
          'هناك خطر انزلاق بسبب الجليد. هل الطرق والأرصفة في منطقتي متأثرة؟',
      contextDe: 'Nach Glätte, Glatteis oder Frostfolgen fragen',
      contextAr: 'السؤال عن الجليد والصقيع وتأثيرهما على الطرق',
      sourceLabel: 'DWD-Warnkategorien · Frost / Glätte',
      keywords: <String>[
        'Glätte',
        'Glatteis',
        'Frost',
        'Eis',
        'Gehweg',
      ],
    ),
    EnvironmentEntry(
      id: 'weather-heat',
      category: EnvironmentCategory.severeWeather,
      titleDe: 'Hitzewelle & Hitzewarnung',
      titleAr: 'موجة حر وتحذير من الحرارة',
      german:
          'Gibt es für heute oder morgen eine Hitzewarnung des DWD? Wann ist es draußen am heißesten?',
      arabic:
          'هل يوجد تحذير من الحرارة من DWD لليوم أو غدًا؟ ومتى تكون الحرارة في الخارج في أعلى مستوياتها؟',
      contextDe: 'Eine Hitzewarnung prüfen und Aktivitäten sinnvoll planen',
      contextAr: 'التحقق من تحذير الحرارة وتنظيم الأنشطة الخارجية',
      sourceLabel: 'DWD · Hitzewarnungen',
      keywords: <String>['Hitzewelle', 'Hitze', 'Hitzewarnung', 'Wärmebelastung'],
    ),
  ];
}
