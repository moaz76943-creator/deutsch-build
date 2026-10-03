import '../domain/mobility_models.dart';

class LocalMobilityRepository {
  const LocalMobilityRepository();

  static const List<MobilityLesson> _items = <MobilityLesson>[
    MobilityLesson(
      id: 'platform_change_basic',
      level: MobilityLevel.a1a2,
      mode: MobilityMode.longDistance,
      topic: MobilityTopic.platformChange,
      titleDe: 'Gleiswechsel schnell verstehen',
      phraseDe: 'Achtung, Gleiswechsel: Der Zug fährt heute von Gleis 8 ab.',
      meaningAr: 'تنبيه: تم تغيير الرصيف، القطار يغادر اليوم من الرصيف 8.',
      actionAr: 'تحقق من رقم القطار والرصيف الجديد على اللوحة قبل الانتقال.',
      keywords: <String>['Gleis', 'Bahnsteig', 'Abfahrt', 'Anzeige'],
    ),
    MobilityLesson(
      id: 'platform_change_question',
      level: MobilityLevel.b1,
      mode: MobilityMode.longDistance,
      topic: MobilityTopic.platformChange,
      titleDe: 'Nach dem neuen Gleis fragen',
      phraseDe: 'Entschuldigung, von welchem Gleis fährt der Zug jetzt ab?',
      meaningAr: 'عذرًا، من أي رصيف يغادر القطار الآن؟',
      actionAr: 'اذكر وجهتك أو رقم القطار إذا كان هناك أكثر من رحلة قريبة.',
      keywords: <String>['Gleiswechsel', 'Zugnummer', 'Information'],
    ),
    MobilityLesson(
      id: 'delay_basic',
      level: MobilityLevel.a1a2,
      mode: MobilityMode.longDistance,
      topic: MobilityTopic.delay,
      titleDe: 'Verspätung erkennen',
      phraseDe: 'Der Zug hat zehn Minuten Verspätung.',
      meaningAr: 'القطار متأخر عشر دقائق.',
      actionAr: 'راقب وقت المغادرة المحدث ولا تعتمد على الوقت الأصلي فقط.',
      keywords: <String>['Verspätung', 'Abfahrt', 'später'],
    ),
    MobilityLesson(
      id: 'delay_connection',
      level: MobilityLevel.b2,
      mode: MobilityMode.longDistance,
      topic: MobilityTopic.delay,
      titleDe: 'Anschluss bei Verspätung klären',
      phraseDe: 'Erreiche ich trotz der Verspätung meinen Anschluss?',
      meaningAr: 'هل سأتمكن من اللحاق بقطاري التالي رغم التأخير؟',
      actionAr: 'اسأل عن الوصلة التالية المتاحة إذا أصبح وقت التبديل قصيرًا.',
      keywords: <String>['Anschluss', 'Umstieg', 'Verspätung', 'Fernverkehr'],
    ),
    MobilityLesson(
      id: 'seat_reservation_basic',
      level: MobilityLevel.a1a2,
      mode: MobilityMode.longDistance,
      topic: MobilityTopic.seatReservation,
      titleDe: 'Sitzplatz reservieren',
      phraseDe: 'Ich möchte einen Sitzplatz reservieren.',
      meaningAr: 'أريد حجز مقعد.',
      actionAr: 'حدد الرحلة والدرجة المطلوبة ثم تحقق من بيانات الحجز قبل الدفع.',
      keywords: <String>['Sitzplatz', 'Reservierung', 'Platz'],
    ),
    MobilityLesson(
      id: 'seat_reservation_detail',
      level: MobilityLevel.b1,
      mode: MobilityMode.longDistance,
      topic: MobilityTopic.seatReservation,
      titleDe: 'Reservierung zur Verbindung prüfen',
      phraseDe: 'Ist für diese Verbindung noch eine Sitzplatzreservierung möglich?',
      meaningAr: 'هل ما زال من الممكن حجز مقعد لهذه الرحلة؟',
      actionAr: 'تأكد أن الحجز مرتبط بالقطار والتاريخ الصحيحين.',
      keywords: <String>['Verbindung', 'Reservierung', 'Wagen'],
    ),
    MobilityLesson(
      id: 'local_ticket_basic',
      level: MobilityLevel.a1a2,
      mode: MobilityMode.localTransit,
      topic: MobilityTopic.localTicket,
      titleDe: 'Lokale Fahrkarte kaufen',
      phraseDe: 'Wo kann ich eine Fahrkarte für den Bus kaufen?',
      meaningAr: 'أين يمكنني شراء تذكرة للحافلة؟',
      actionAr: 'تحقق من شركة النقل المحلية وطريقة شراء التذكرة قبل الصعود.',
      keywords: <String>['Fahrkarte', 'Ticket', 'Bus', 'الحافلة'],
    ),
    MobilityLesson(
      id: 'local_ticket_zone',
      level: MobilityLevel.b1,
      mode: MobilityMode.localTransit,
      topic: MobilityTopic.localTicket,
      titleDe: 'Passendes Ticket erfragen',
      phraseDe: 'Welches Ticket brauche ich für diese Strecke?',
      meaningAr: 'أي تذكرة أحتاج لهذه المسافة؟',
      actionAr: 'اذكر نقطة البداية والوجهة لأن أنظمة المناطق قد تختلف محليًا.',
      keywords: <String>['Tarif', 'Strecke', 'Zone', 'ÖPNV'],
    ),
    MobilityLesson(
      id: 'deutschlandticket_basic',
      level: MobilityLevel.b1,
      mode: MobilityMode.localTransit,
      topic: MobilityTopic.deutschlandticket,
      titleDe: 'Deutschlandticket vor der Fahrt prüfen',
      phraseDe: 'Gilt mein Deutschlandticket für diese Verbindung?',
      meaningAr: 'هل تذكرة ألمانيا الخاصة بي صالحة لهذه الرحلة؟',
      actionAr: 'تحقق من صلاحية التذكرة ونوع وسيلة النقل قبل بدء الرحلة.',
      keywords: <String>['Deutschlandticket', 'Gültigkeit', 'Nahverkehr'],
    ),
    MobilityLesson(
      id: 'deutschlandticket_conditions',
      level: MobilityLevel.b2,
      mode: MobilityMode.localTransit,
      topic: MobilityTopic.deutschlandticket,
      titleDe: 'Aktuelle Bedingungen kontrollieren',
      phraseDe: 'Ich prüfe vor der Fahrt die aktuellen Bedingungen des Deutschlandtickets.',
      meaningAr: 'أتحقق قبل الرحلة من الشروط الحالية لتذكرة ألمانيا.',
      actionAr: 'الشروط قد تتغير؛ اعتمد على معلومات الجهة الناقلة الحالية عند التخطيط.',
      keywords: <String>['Deutschlandticket', 'Bedingungen', 'Nahverkehr'],
    ),
    MobilityLesson(
      id: 'bus_connection_basic',
      level: MobilityLevel.a1a2,
      mode: MobilityMode.localTransit,
      topic: MobilityTopic.busConnection,
      titleDe: 'Busverbindung finden',
      phraseDe: 'Welche Busverbindung fährt zum Hauptbahnhof?',
      meaningAr: 'أي خط حافلة يذهب إلى المحطة الرئيسية؟',
      actionAr: 'تحقق من رقم الخط واتجاهه واسم محطة النزول.',
      keywords: <String>['Busverbindung', 'Bus', 'Haltestelle', 'الحافلة'],
    ),
    MobilityLesson(
      id: 'metro_transfer',
      level: MobilityLevel.b2,
      mode: MobilityMode.localTransit,
      topic: MobilityTopic.busConnection,
      titleDe: 'Bus und U-Bahn kombinieren',
      phraseDe: 'Wo muss ich vom Bus in die U-Bahn umsteigen?',
      meaningAr: 'أين يجب أن أبدل من الحافلة إلى المترو؟',
      actionAr: 'طابق اسم محطة التبديل مع اتجاه خط المترو قبل مغادرة الحافلة.',
      keywords: <String>['U-Bahn', 'Umstieg', 'Verbindung', 'Bus'],
    ),
  ];

  List<MobilityLesson> all() => List<MobilityLesson>.unmodifiable(_items);

  List<MobilityLesson> byLevel(MobilityLevel level) =>
      _items.where((item) => item.level == level).toList(growable: false);

  List<MobilityLesson> byTopic(MobilityTopic topic) =>
      _items.where((item) => item.topic == topic).toList(growable: false);

  List<MobilityLesson> byMode(MobilityMode mode) =>
      _items.where((item) => item.mode == mode).toList(growable: false);

  List<MobilityLesson> search(
    String query, {
    MobilityLevel? level,
  }) {
    final normalized = query.trim().toLowerCase();
    final scoped = level == null ? _items : byLevel(level);
    if (normalized.isEmpty) {
      return List<MobilityLesson>.unmodifiable(scoped);
    }

    return scoped
        .where(
          (item) => item.searchableText.toLowerCase().contains(normalized),
        )
        .toList(growable: false);
  }
}
