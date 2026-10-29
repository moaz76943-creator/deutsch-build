import 'quick_service_master_hub.dart';

final class KeyServiceAgent {
  const KeyServiceAgent();

  static const List<QuickServicePhrase> entries = <QuickServicePhrase>[
    QuickServicePhrase(
      id: 'key-copy',
      category: QuickServiceCategory.keyService,
      topicDe: 'Schlüssel nachmachen',
      topicAr: 'نسخ مفتاح',
      german:
          'Ich möchte von diesem Schlüssel eine Kopie anfertigen lassen. Können Sie prüfen, ob das möglich ist?',
      arabic:
          'أريد عمل نسخة من هذا المفتاح. هل يمكنكم التحقق مما إذا كان ذلك ممكناً؟',
      tags: <String>['Schlüssel', 'Kopie', 'nachmachen', 'نسخ', 'مفتاح'],
    ),
    QuickServicePhrase(
      id: 'key-security-card',
      category: QuickServiceCategory.keyService,
      topicDe: 'Sicherungskarte',
      topicAr: 'بطاقة الأمان للمفتاح',
      german:
          'Brauchen Sie für diesen Sicherheitsschlüssel eine Sicherungskarte oder einen Eigentumsnachweis?',
      arabic:
          'هل تحتاجون إلى بطاقة أمان أو إثبات ملكية لنسخ هذا المفتاح الأمني؟',
      tags: <String>['Sicherheitsschlüssel', 'Sicherungskarte', 'Nachweis', 'أمان'],
    ),
    QuickServicePhrase(
      id: 'key-price',
      category: QuickServiceCategory.keyService,
      topicDe: 'Preis und Dauer',
      topicAr: 'السعر والمدة',
      german:
          'Was kostet eine Kopie, und wie lange dauert die Anfertigung ungefähr?',
      arabic:
          'كم تكلفة النسخة، وكم يستغرق تجهيزها تقريباً؟',
      tags: <String>['Preis', 'Dauer', 'Anfertigung', 'سعر', 'مدة'],
    ),
    QuickServicePhrase(
      id: 'lockout-quote',
      category: QuickServiceCategory.keyService,
      topicDe: 'Türöffnung Preis vorab',
      topicAr: 'سعر فتح الباب مسبقاً',
      german:
          'Ich bin ausgesperrt. Bitte nennen Sie mir vor der Anfahrt den Gesamtpreis für Anfahrt und Türöffnung.',
      arabic:
          'أنا خارج المنزل ولا أستطيع الدخول. أرجو إبلاغي قبل وصولكم بالسعر الإجمالي لأجرة الوصول وفتح الباب.',
      tags: <String>['ausgesperrt', 'Türöffnung', 'Anfahrt', 'Gesamtpreis', 'قفل', 'باب'],
    ),
    QuickServicePhrase(
      id: 'lockout-id',
      category: QuickServiceCategory.keyService,
      topicDe: 'Berechtigung nachweisen',
      topicAr: 'إثبات حق الدخول',
      german:
          'Welche Unterlagen benötigen Sie, damit ich meine Berechtigung für die Wohnung nachweisen kann?',
      arabic:
          'ما الوثائق التي تحتاجونها حتى أثبت حقي في الدخول إلى الشقة؟',
      tags: <String>['Berechtigung', 'Wohnung', 'Ausweis', 'إثبات', 'شقة'],
    ),
  ];
}
