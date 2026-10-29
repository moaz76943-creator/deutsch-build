import 'products_ingredients_models.dart';

final class ProductsIngredientsSubAgent {
  const ProductsIngredientsSubAgent();

  List<ProductInquiryPhrase> get phrases => _phrases;

  List<ProductInquiryPhrase> search(String query) =>
      List<ProductInquiryPhrase>.unmodifiable(
        _phrases.where((phrase) => phrase.matches(query)),
      );

  static const List<ProductInquiryPhrase> _phrases =
      <ProductInquiryPhrase>[
    ProductInquiryPhrase(
      id: 'product-location-aisle',
      kind: ProductInquiryKind.location,
      topicDe: 'Produkt im Gang finden',
      topicAr: 'العثور على المنتج في الممر',
      german:
          'Entschuldigung, in welchem Gang finde ich Haferflocken und Müsli?',
      arabic:
          'عذرًا، في أي ممر أجد رقائق الشوفان وحبوب الإفطار؟',
      keywords: <String>['Gang', 'Abteilung', 'finden', 'مكان', 'ممر'],
    ),
    ProductInquiryPhrase(
      id: 'product-location-shelf',
      kind: ProductInquiryKind.location,
      topicDe: 'Regal oder Abteilung erfragen',
      topicAr: 'السؤال عن الرف أو القسم',
      german:
          'Können Sie mir bitte zeigen, in welchem Regal dieses Produkt steht?',
      arabic: 'هل يمكن أن تدلني من فضلك على الرف الذي يوجد فيه هذا المنتج؟',
      keywords: <String>['Regal', 'Produkt', 'Abteilung', 'رف', 'قسم'],
    ),
    ProductInquiryPhrase(
      id: 'ingredients-allergens',
      kind: ProductInquiryKind.dietaryIngredients,
      topicDe: 'Zutatenliste & Allergene',
      topicAr: 'قائمة المكونات والحساسيات',
      german:
          'Wo finde ich die Zutatenliste und die Hinweise zu Allergenen auf dieser Packung?',
      arabic:
          'أين أجد قائمة المكونات وتحذيرات المواد المسببة للحساسية على هذه العبوة؟',
      keywords: <String>[
        'Zutatenliste',
        'Allergene',
        'Zutaten',
        'مكونات',
        'حساسية',
      ],
    ),
    ProductInquiryPhrase(
      id: 'ingredients-vegan',
      kind: ProductInquiryKind.dietaryIngredients,
      topicDe: 'Vegan prüfen',
      topicAr: 'التحقق من كون المنتج نباتيًا بالكامل',
      german:
          'Ist dieses Produkt als Vegan gekennzeichnet, und enthält es tierische Zutaten?',
      arabic:
          'هل هذا المنتج مُعلّم بأنه نباتي بالكامل، وهل يحتوي على أي مكونات حيوانية؟',
      keywords: <String>['Vegan', 'tierisch', 'Zutaten', 'نباتي'],
    ),
    ProductInquiryPhrase(
      id: 'ingredients-gluten',
      kind: ProductInquiryKind.dietaryIngredients,
      topicDe: 'Glutenfrei prüfen',
      topicAr: 'التحقق من خلو المنتج من الغلوتين',
      german:
          'Ist dieses Produkt glutenfrei, und gibt es einen Hinweis auf mögliche Spuren von Gluten?',
      arabic:
          'هل هذا المنتج خالٍ من الغلوتين، وهل توجد إشارة إلى احتمال وجود آثار من الغلوتين؟',
      keywords: <String>['glutenfrei', 'Gluten', 'Spuren', 'غلوتين'],
    ),
    ProductInquiryPhrase(
      id: 'ingredients-halal',
      kind: ProductInquiryKind.dietaryIngredients,
      topicDe: 'Halal-Kennzeichnung prüfen',
      topicAr: 'التحقق من اعتماد الحلال',
      german:
          'Ist dieses Produkt Halal-zertifiziert, und wo kann ich die Zertifizierung auf der Verpackung sehen?',
      arabic:
          'هل هذا المنتج معتمد حلال، وأين يمكنني رؤية علامة الاعتماد على العبوة؟',
      keywords: <String>[
        'Halal',
        'zertifiziert',
        'Zertifizierung',
        'Verpackung',
        'حلال',
      ],
    ),
    ProductInquiryPhrase(
      id: 'ingredients-pork',
      kind: ProductInquiryKind.dietaryIngredients,
      topicDe: 'Schweinefleisch und Bestandteile prüfen',
      topicAr: 'التحقق من لحم الخنزير ومشتقاته',
      german:
          'Enthält dieses Produkt Schweinefleisch oder Zutaten, die vom Schwein stammen?',
      arabic:
          'هل يحتوي هذا المنتج على لحم الخنزير أو مكونات مشتقة من الخنزير؟',
      keywords: <String>[
        'Schweinefleisch',
        'Schwein',
        'Zutaten',
        'Gelatine',
        'خنزير',
        'مكونات',
      ],
    ),
    ProductInquiryPhrase(
      id: 'fresh-counter-cheese',
      kind: ProductInquiryKind.freshCounter,
      topicDe: 'Käse an der Frischetheke',
      topicAr: 'الجبنة من قسم المنتجات الطازجة',
      german:
          'An der Frischetheke hätte ich gern 200 Gramm von diesem Käse, bitte.',
      arabic:
          'أريد من قسم المنتجات الطازجة 200 غرام من هذه الجبنة من فضلك.',
      keywords: <String>[
        'Frischetheke',
        'Käse',
        'Gramm',
        'wiegen',
        'جبنة',
      ],
    ),
    ProductInquiryPhrase(
      id: 'fresh-counter-meat',
      kind: ProductInquiryKind.freshCounter,
      topicDe: 'Fleisch nach Gewicht bestellen',
      topicAr: 'طلب اللحم بالوزن',
      german:
          'Ich hätte gern 500 Gramm von diesem Fleisch. Können Sie es bitte frisch abwiegen?',
      arabic: 'أريد 500 غرام من هذا اللحم. هل يمكن وزنه طازجًا من فضلك؟',
      keywords: <String>[
        'Frischetheke',
        'Fleisch',
        'Gramm',
        'abwiegen',
        'لحم',
        'وزن',
      ],
    ),
    ProductInquiryPhrase(
      id: 'fresh-counter-ingredients',
      kind: ProductInquiryKind.freshCounter,
      topicDe: 'Zutaten an der Frischetheke',
      topicAr: 'مكونات المنتجات غير المعبأة',
      german:
          'Können Sie mir bitte die Zutaten und Allergene für dieses Produkt an der Frischetheke nennen?',
      arabic:
          'هل يمكن أن تذكر لي المكونات والمواد المسببة للحساسية لهذا المنتج في قسم المنتجات الطازجة؟',
      keywords: <String>[
        'Frischetheke',
        'Zutaten',
        'Allergene',
        'unverpackt',
        'مكونات',
      ],
    ),
  ];
}
