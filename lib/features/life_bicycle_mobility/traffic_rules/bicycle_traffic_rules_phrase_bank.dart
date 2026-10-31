import 'bicycle_traffic_rules_models.dart';

abstract final class BicycleTrafficRulesPhraseBank {
  static const List<BicycleRulePhrase> all = <BicycleRulePhrase>[
    BicycleRulePhrase(
      id: 'lane-sign',
      topic: BicycleRuleTopic.cycleLane,
      german:
          'Ist dieser Radweg durch ein blaues Verkehrszeichen benutzungspflichtig, oder darf ich auf der Fahrbahn bleiben?',
      arabic:
          'هل هذا المسار إلزامي بسبب إشارة المرور الزرقاء، أم يمكنني البقاء على الطريق؟',
      contextDe: 'Beschilderung des Radwegs prüfen',
      contextAr: 'التحقق من إشارة مسار الدراجة',
      keywords: <String>['Radweg', 'Zeichen 237', 'Fahrbahn', 'مسار'],
    ),
    BicycleRulePhrase(
      id: 'lane-direction',
      topic: BicycleRuleTopic.cycleLane,
      german:
          'Darf ich diesen Radweg in meiner Fahrtrichtung benutzen, oder ist er nur für die Gegenrichtung freigegeben?',
      arabic:
          'هل يسمح باستخدام هذا المسار في اتجاهي أم هو مخصص للاتجاه المقابل فقط؟',
      contextDe: 'Fahrtrichtung und Freigabe beachten',
      contextAr: 'مراعاة اتجاه السير والسماح',
      keywords: <String>['Fahrtrichtung', 'Radverkehr frei', 'اتجاه'],
    ),
    BicycleRulePhrase(
      id: 'lane-pedestrian',
      topic: BicycleRuleTopic.cycleLane,
      german:
          'Hier teilen sich Fuß- und Radverkehr den Weg. Ich fahre langsam und nehme Rücksicht auf zu Fuß Gehende.',
      arabic:
          'هنا يشترك المشاة وراكبو الدراجات في المسار. سأقود ببطء وأراعي المشاة.',
      contextDe: 'Gemeinsamen Weg rücksichtsvoll nutzen',
      contextAr: 'استخدام المسار المشترك بحذر',
      keywords: <String>['gemeinsamer Geh- und Radweg', 'Rücksicht', 'مشاة'],
    ),
    BicycleRulePhrase(
      id: 'signal-bike-light',
      topic: BicycleRuleTopic.trafficSignals,
      german:
          'Gibt es hier ein besonderes Lichtzeichen für den Radverkehr, das ich beachten muss?',
      arabic:
          'هل توجد هنا إشارة ضوئية خاصة بالدراجات يجب أن أتبعها؟',
      contextDe: 'Radverkehrsampel erkennen',
      contextAr: 'تمييز إشارة الدراجات',
      keywords: <String>['Ampel', 'Lichtzeichen', 'Radverkehr', 'إشارة'],
    ),
    BicycleRulePhrase(
      id: 'signal-red',
      topic: BicycleRuleTopic.trafficSignals,
      german:
          'Die für mich geltende Ampel zeigt Rot. Ich halte vor der Haltlinie und fahre erst bei Freigabe weiter.',
      arabic:
          'الإشارة التي تنطبق علي حمراء. أتوقف قبل خط الوقوف وأتابع فقط عند السماح.',
      contextDe: 'Rotes Lichtzeichen beachten',
      contextAr: 'الالتزام بالإشارة الحمراء',
      keywords: <String>['Rot', 'Haltlinie', 'Ampel', 'أحمر'],
    ),
    BicycleRulePhrase(
      id: 'signal-right-before-left',
      topic: BicycleRuleTopic.trafficSignals,
      german:
          'An dieser Kreuzung sehe ich keine andere Vorfahrtsregelung. Ich prüfe deshalb besonders aufmerksam, ob rechts vor links gilt.',
      arabic:
          'لا أرى تنظيمًا آخر للأولوية في هذا التقاطع، لذلك أتحقق بعناية مما إذا كانت أولوية القادم من اليمين تنطبق.',
      contextDe: 'Vorfahrt nicht vermuten, sondern Beschilderung prüfen',
      contextAr: 'عدم افتراض الأولوية والتحقق من الإشارات',
      keywords: <String>['Vorfahrt', 'rechts vor links', 'تقاطع'],
    ),
    BicycleRulePhrase(
      id: 'light-darkness',
      topic: BicycleRuleTopic.lighting,
      german:
          'Bei Dämmerung, Dunkelheit oder schlechter Sicht schalte ich die vorgeschriebene Fahrradbeleuchtung ein.',
      arabic:
          'عند الغسق أو الظلام أو ضعف الرؤية أشغّل إضاءة الدراجة المطلوبة.',
      contextDe: 'Beleuchtung rechtzeitig einschalten',
      contextAr: 'تشغيل الإضاءة في الوقت المناسب',
      keywords: <String>['Dämmerung', 'Dunkelheit', 'Beleuchtung', 'إضاءة'],
    ),
    BicycleRulePhrase(
      id: 'light-clean',
      topic: BicycleRuleTopic.lighting,
      german:
          'Sind Scheinwerfer, Rücklicht und Rückstrahler sauber, sichtbar und funktionsbereit?',
      arabic:
          'هل المصباح الأمامي والخلفي والعواكس نظيفة وواضحة وتعمل بشكل سليم؟',
      contextDe: 'Lichttechnik vor der Fahrt kontrollieren',
      contextAr: 'فحص تجهيزات الإضاءة قبل الانطلاق',
      keywords: <String>['Scheinwerfer', 'Rücklicht', 'Rückstrahler', 'مصباح'],
    ),
    BicycleRulePhrase(
      id: 'safe-turn',
      topic: BicycleRuleTopic.safeRiding,
      german:
          'Vor dem Abbiegen schaue ich nach hinten, gebe rechtzeitig ein Handzeichen und achte weiter auf den Verkehr.',
      arabic:
          'قبل الانعطاف أنظر خلفي وأعطي إشارة باليد في الوقت المناسب وأواصل مراقبة المرور.',
      contextDe: 'Abbiegen klar ankündigen',
      contextAr: 'إعلان الانعطاف بوضوح',
      keywords: <String>['Abbiegen', 'Handzeichen', 'انعطاف'],
    ),
    BicycleRulePhrase(
      id: 'safe-side-by-side',
      topic: BicycleRuleTopic.safeRiding,
      german:
          'Wir fahren nur nebeneinander, wenn wir dadurch den übrigen Verkehr nicht behindern.',
      arabic:
          'نسير جنبًا إلى جنب فقط إذا لم نعرقل حركة المرور الأخرى.',
      contextDe: 'Nebeneinanderfahren situationsgerecht entscheiden',
      contextAr: 'تحديد السير المتوازي حسب حالة الطريق',
      keywords: <String>['nebeneinander', 'behindern', 'جنبًا'],
    ),
    BicycleRulePhrase(
      id: 'safe-phone',
      topic: BicycleRuleTopic.safeRiding,
      german:
          'Ich bediene während der Fahrt kein Handy in der Hand und bleibe mit meiner Aufmerksamkeit beim Verkehr.',
      arabic:
          'لا أستخدم الهاتف بيدي أثناء القيادة وأبقي انتباهي على حركة المرور.',
      contextDe: 'Ablenkung vermeiden',
      contextAr: 'تجنب التشتت أثناء القيادة',
      keywords: <String>['Handy', 'Ablenkung', 'هاتف'],
    ),
    BicycleRulePhrase(
      id: 'safe-crosswalk',
      topic: BicycleRuleTopic.safeRiding,
      german:
          'Wenn ich den Fußgängerüberweg wie ein Fußgänger nutzen will, steige ich ab und schiebe das Fahrrad.',
      arabic:
          'إذا أردت استخدام ممر المشاة كمشاة، أنزل عن الدراجة وأدفعها بجانبي.',
      contextDe: 'Zebrastreifen sicher und eindeutig nutzen',
      contextAr: 'استخدام ممر المشاة بصورة واضحة وآمنة',
      keywords: <String>['Zebrastreifen', 'Fußgängerüberweg', 'schieben', 'ممر'],
    ),
  ];
}
