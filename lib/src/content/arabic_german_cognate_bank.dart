import 'a1_core_lexical_bank.dart';

/// Cultural loanword and etymological bridge entry.
class CognateEntry {
  final String germanWord;
  final String arabicOrigin;
  final String etymologicalRoute;
  final String modernUsageDe;
  final String modernUsageAr;

  const CognateEntry({
    required this.germanWord,
    required this.arabicOrigin,
    required this.etymologicalRoute,
    required this.modernUsageDe,
    required this.modernUsageAr,
  });
}

/// Curated bank highlighting historic linguistic bridges between German and Arabic.
class ArabicGermanCognateBank {
  static const List<CognateEntry> cognates = [
    CognateEntry(
      germanWord: 'Zucker',
      arabicOrigin: 'سُكَّر (Sukkar)',
      etymologicalRoute: 'انتقلت عبر التجارة المتوسطية في العصور الوسطى إلى الألمانية العليا القديمة.',
      modernUsageDe: 'Möchten Sie Zucker in Ihren Pfefferminztee?',
      modernUsageAr: 'هل ترغب في وضع السكر في شاي النعناع؟',
    ),
    CognateEntry(
      germanWord: 'Kaffee',
      arabicOrigin: 'قَهْوَة (Qahwah)',
      etymologicalRoute: 'انتقلت عبر الدولة العثمانية وإيطاليا إلى أوروبا وألمانيا.',
      modernUsageDe: 'Am Morgen trinken viele Menschen gerne warmen Kaffee.',
      modernUsageAr: 'في الصباح يفضل الكثيرون شرب القهوة الدافئة.',
    ),
    CognateEntry(
      germanWord: 'Magazin',
      arabicOrigin: 'مَخَازِن (Makhāzin - جمع مخزن)',
      etymologicalRoute: 'أطلقت على مستودعات البضائع ثم تطورت لتعني مستودع المقالات والمعارف (المجلة).',
      modernUsageDe: 'Dieses Magazin berichtet über wissenschaftliche Entdeckungen.',
      modernUsageAr: 'تقدم هذه المجلة تقارير عن الاكتشافات العلمية الحديثة.',
    ),
    CognateEntry(
      germanWord: 'Ziffer',
      arabicOrigin: 'صِفْر (Sifr)',
      etymologicalRoute: 'دخلت اللغات الأوروبية عبر الرياضيات العربية لتعني الرمز الرقمي الحسابي.',
      modernUsageDe: 'Die mathematische Ziffer ist eindeutig definiert.',
      modernUsageAr: 'الرمز الرقمي الحسابي محدد بدقة ووضوح.',
    ),
    CognateEntry(
      germanWord: 'Admiral',
      arabicOrigin: 'أَمِيرُ البَحْر (Amīr al-Baḥr)',
      etymologicalRoute: 'لقب قيادة الأساطيل البحرية الذي تبنته اللغات الجرمانية واللاتينية.',
      modernUsageDe: 'Der Admiral befehligt die friedliche Küstenwache.',
      modernUsageAr: 'يقود الأدميرال خفر السواحل لحماية المياه الإقليمية.',
    ),
  ];
}
