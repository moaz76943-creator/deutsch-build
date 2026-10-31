import 'social_models.dart';

final class OccasionsSubAgent {
  const OccasionsSubAgent();

  List<SocialPhrase> get phrases => _phrases;

  static const List<SocialPhrase> _phrases = <SocialPhrase>[
    SocialPhrase(
      id: 'occasion-birth',
      category: SocialCategory.occasions,
      germanDu:
          'Herzlichen Glückwunsch zur Geburt! Ich wünsche euch alles Gute.',
      germanSie:
          'Herzlichen Glückwunsch zur Geburt! Ich wünsche Ihnen und Ihrer Familie alles Gute.',
      arabic: 'أطيب التهاني بالمولود، وأتمنى لكم كل الخير.',
      contextDe: 'Zur Geburt gratulieren',
      contextAr: 'تهنئة محترمة بالمولود',
      keywords: <String>['Geburt', 'Glückwunsch', 'Familie'],
    ),
    SocialPhrase(
      id: 'occasion-graduation',
      category: SocialCategory.occasions,
      germanDu:
          'Herzlichen Glückwunsch zum Abschluss! Das hast du großartig gemacht.',
      germanSie:
          'Herzlichen Glückwunsch zu Ihrem Abschluss! Ich wünsche Ihnen viel Erfolg.',
      arabic: 'مبارك التخرج، وأتمنى لك دوام النجاح.',
      contextDe: 'Zum Abschluss gratulieren',
      contextAr: 'تهنئة بالتخرج أو إنهاء الدراسة',
      keywords: <String>['Abschluss', 'Prüfung', 'Erfolg', 'Graduation'],
    ),
    SocialPhrase(
      id: 'occasion-recovery',
      category: SocialCategory.occasions,
      germanDu: 'Gute Besserung! Ich wünsche dir eine schnelle Genesung.',
      germanSie: 'Gute Besserung! Ich wünsche Ihnen eine schnelle Genesung.',
      arabic: 'سلامتك، أتمنى لك الشفاء العاجل.',
      contextDe: 'Genesungswünsche ausdrücken',
      contextAr: 'تمنيات مهذبة بالشفاء',
      keywords: <String>['Gute Besserung', 'Genesung', 'gesund'],
    ),
    SocialPhrase(
      id: 'occasion-condolence',
      category: SocialCategory.occasions,
      germanDu:
          'Mein herzliches Beileid. Ich wünsche dir und deiner Familie viel Kraft.',
      germanSie:
          'Mein herzliches Beileid. Ich wünsche Ihnen und Ihrer Familie viel Kraft.',
      arabic: 'خالص التعازي، أتمنى لك ولعائلتك الصبر والقوة.',
      contextDe: 'Beileid respektvoll ausdrücken',
      contextAr: 'صياغة تعزية رسمية ومحترمة',
      keywords: <String>['Beileid', 'Trauer', 'Kraft'],
    ),
    SocialPhrase(
      id: 'occasion-decline-invitation',
      category: SocialCategory.occasions,
      germanDu:
          'Danke für deine Einladung. Leider kann ich diesmal nicht kommen.',
      germanSie:
          'Vielen Dank für Ihre Einladung. Leider kann ich diesmal nicht teilnehmen.',
      arabic: 'شكرًا على الدعوة. للأسف لن أتمكن من الحضور هذه المرة.',
      contextDe: 'Eine Einladung höflich ablehnen',
      contextAr: 'الاعتذار عن دعوة دون إحراج',
      keywords: <String>['Einladung', 'absagen', 'teilnehmen'],
    ),
  ];
}
