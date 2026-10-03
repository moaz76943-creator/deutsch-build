import '../domain/shopping_models.dart';

final class GroceryShoppingAgent implements ShoppingSubAgent {
  const GroceryShoppingAgent();

  @override
  ShoppingAgentType get type => ShoppingAgentType.grocery;

  static const List<ShoppingPhrase> _items = <ShoppingPhrase>[
    ShoppingPhrase(
      id: 'grocery_a1_ingredients',
      level: ShoppingLevel.a1a2,
      agent: ShoppingAgentType.grocery,
      german: 'Welche Zutaten sind in diesem Produkt?',
      arabic: 'ما المكونات الموجودة في هذا المنتج؟',
      usageArabic: 'سؤال أساسي ومباشر للاستفسار عن مكونات المنتج.',
      searchTags: <String>['Zutaten', 'Inhalt', 'مكونات', 'منتج'],
    ),
    ShoppingPhrase(
      id: 'grocery_a1_plant_alternative',
      level: ShoppingLevel.a1a2,
      agent: ShoppingAgentType.grocery,
      german: 'Gibt es eine pflanzliche Alternative?',
      arabic: 'هل يوجد بديل نباتي؟',
      usageArabic: 'صيغة قصيرة لطلب بديل نباتي مناسب.',
      searchTags: <String>['pflanzliche', 'Alternative', 'نباتي', 'بديل'],
      isPanicPhrase: true,
    ),
    ShoppingPhrase(
      id: 'grocery_a1_weight',
      level: ShoppingLevel.a1a2,
      agent: ShoppingAgentType.grocery,
      german: 'Ich hätte gern 500 Gramm Tomaten.',
      arabic: 'أريد 500 غرام من الطماطم من فضلك.',
      usageArabic: 'Ich hätte gern صيغة مهذبة شائعة عند طلب وزن محدد.',
      searchTags: <String>['Gramm', 'Gewicht', 'wiegen', 'وزن', 'غرام'],
    ),
    ShoppingPhrase(
      id: 'grocery_a1_checkout',
      level: ShoppingLevel.a1a2,
      agent: ShoppingAgentType.grocery,
      german: 'Entschuldigung, wo ist die Kasse?',
      arabic: 'عذرًا، أين صندوق الدفع؟',
      usageArabic: 'عبارة سريعة للسؤال عن مكان الدفع.',
      searchTags: <String>['Kasse', 'bezahlen', 'checkout', 'دفع', 'صندوق'],
      isPanicPhrase: true,
    ),
    ShoppingPhrase(
      id: 'grocery_b1_vegetarian',
      level: ShoppingLevel.b1,
      agent: ShoppingAgentType.grocery,
      german: 'Ist dieses Produkt für eine vegetarische Ernährung geeignet?',
      arabic: 'هل هذا المنتج مناسب لنظام غذائي نباتي؟',
      usageArabic: 'geeignet für تستخدم للسؤال عن ملاءمة المنتج لاحتياج محدد.',
      searchTags: <String>[
        'vegetarisch',
        'geeignet',
        'Ernährung',
        'نباتي',
        'مناسب',
      ],
    ),
    ShoppingPhrase(
      id: 'grocery_b1_plant_milk',
      level: ShoppingLevel.b1,
      agent: ShoppingAgentType.grocery,
      german: 'Haben Sie eine pflanzliche Alternative zu Milch?',
      arabic: 'هل لديكم بديل نباتي للحليب؟',
      usageArabic: 'Alternative zu + Dativ صيغة عملية عند طلب بديل لمنتج.',
      searchTags: <String>[
        'pflanzliche',
        'Alternative',
        'Milch',
        'بديل',
        'حليب',
      ],
    ),
    ShoppingPhrase(
      id: 'grocery_b1_weigh',
      level: ShoppingLevel.b1,
      agent: ShoppingAgentType.grocery,
      german: 'Könnten Sie mir bitte 750 Gramm davon abwiegen?',
      arabic: 'هل يمكنكم وزن 750 غرامًا من هذا لي من فضلكم؟',
      usageArabic: 'abwiegen فعل مناسب عند طلب وزن كمية معينة في قسم الخدمة.',
      searchTags: <String>['Gramm', 'abwiegen', 'Gewicht', 'وزن', 'كمية'],
    ),
    ShoppingPhrase(
      id: 'grocery_b1_card_checkout',
      level: ShoppingLevel.b1,
      agent: ShoppingAgentType.grocery,
      german: 'Kann ich an dieser Kasse mit Karte bezahlen?',
      arabic: 'هل يمكنني الدفع بالبطاقة عند هذا الصندوق؟',
      usageArabic: 'صيغة واضحة للاستفسار عن وسيلة الدفع المتاحة.',
      searchTags: <String>['Kasse', 'Karte', 'bezahlen', 'بطاقة', 'دفع'],
    ),
    ShoppingPhrase(
      id: 'grocery_b2_allergens',
      level: ShoppingLevel.b2,
      agent: ShoppingAgentType.grocery,
      german:
          'Könnten Sie mir sagen, ob in den Zutaten bestimmte Allergene enthalten sind?',
      arabic: 'هل يمكنكم إخباري إن كانت المكونات تحتوي على مواد مسببة للحساسية؟',
      usageArabic: 'صيغة B2 دقيقة للاستفسار عن مكونات قد تكون مهمة للمستهلك.',
      searchTags: <String>[
        'Zutaten',
        'Allergene',
        'enthalten',
        'مكونات',
        'حساسية',
      ],
    ),
    ShoppingPhrase(
      id: 'grocery_b2_plant_cooking',
      level: ShoppingLevel.b2,
      agent: ShoppingAgentType.grocery,
      german:
          'Welche pflanzliche Alternative eignet sich am besten für dieses Rezept?',
      arabic: 'أي بديل نباتي يناسب هذه الوصفة بشكل أفضل؟',
      usageArabic: 'eignet sich für تستخدم للمقارنة بين بدائل بحسب الاستخدام.',
      searchTags: <String>[
        'pflanzliche',
        'Alternative',
        'Rezept',
        'بديل',
        'وصفة',
      ],
    ),
    ShoppingPhrase(
      id: 'grocery_b2_unit_price',
      level: ShoppingLevel.b2,
      agent: ShoppingAgentType.grocery,
      german: 'Wie wird der Grundpreis pro Kilogramm bei diesem Produkt berechnet?',
      arabic: 'كيف يتم حساب السعر الأساسي لكل كيلوغرام لهذا المنتج؟',
      usageArabic: 'سؤال متقدم لفهم مقارنة الأسعار بحسب الوزن.',
      searchTags: <String>[
        'Grundpreis',
        'Kilogramm',
        'Gewicht',
        'سعر',
        'كيلوغرام',
      ],
    ),
    ShoppingPhrase(
      id: 'grocery_b2_checkout_correction',
      level: ShoppingLevel.b2,
      agent: ShoppingAgentType.grocery,
      german:
          'Entschuldigung, an der Kasse wurde offenbar ein anderer Preis berechnet.',
      arabic: 'عذرًا، يبدو أنه تم احتساب سعر مختلف عند صندوق الدفع.',
      usageArabic: 'صيغة مهذبة لطلب مراجعة فرق السعر دون اتهام مباشر.',
      searchTags: <String>['Kasse', 'Preis', 'berechnet', 'دفع', 'سعر'],
    ),
  ];

  @override
  List<ShoppingPhrase> get phrases => _items;

  @override
  List<ShoppingPhrase> search(
    String query, {
    ShoppingLevel? level,
  }) =>
      _searchAgentItems(_items, query, level);

  @override
  List<ShoppingPhrase> get panicPhrases => List<ShoppingPhrase>.unmodifiable(
        _items.where((item) => item.isPanicPhrase),
      );
}

final class ReturnWarrantyShoppingAgent implements ShoppingSubAgent {
  const ReturnWarrantyShoppingAgent();

  @override
  ShoppingAgentType get type => ShoppingAgentType.returnWarranty;

  static const List<ShoppingPhrase> _items = <ShoppingPhrase>[
    ShoppingPhrase(
      id: 'return_a1_defect',
      level: ShoppingLevel.a1a2,
      agent: ShoppingAgentType.returnWarranty,
      german: 'Der Artikel ist defekt.',
      arabic: 'القطعة معطلة.',
      usageArabic: 'جملة أساسية لشرح المشكلة مباشرة.',
      searchTags: <String>['defekt', 'kaputt', 'Artikel', 'عطل', 'معطل'],
    ),
    ShoppingPhrase(
      id: 'return_a1_receipt',
      level: ShoppingLevel.a1a2,
      agent: ShoppingAgentType.returnWarranty,
      german: 'Hier ist der Kassenbon.',
      arabic: 'هذا هو إيصال الشراء.',
      usageArabic: 'Kassenbon هو إيصال الدفع الذي يطلب غالبًا عند الإرجاع.',
      searchTags: <String>['Kassenbon', 'Beleg', 'Quittung', 'إيصال', 'فاتورة'],
    ),
    ShoppingPhrase(
      id: 'return_a1_complain',
      level: ShoppingLevel.a1a2,
      agent: ShoppingAgentType.returnWarranty,
      german: 'Ich möchte diesen Artikel reklamieren.',
      arabic: 'أريد تقديم شكوى بشأن هذه القطعة.',
      usageArabic: 'reklamieren فعل أساسي عند وجود عيب أو مشكلة في المنتج.',
      searchTags: <String>[
        'reklamieren',
        'Reklamation',
        'Artikel',
        'شكوى',
        'إرجاع',
      ],
      isPanicPhrase: true,
    ),
    ShoppingPhrase(
      id: 'return_a1_help',
      level: ShoppingLevel.a1a2,
      agent: ShoppingAgentType.returnWarranty,
      german: 'Können Sie mir bitte helfen?',
      arabic: 'هل يمكنكم مساعدتي من فضلكم؟',
      usageArabic: 'طلب مساعدة قصير ومهذب عند عدم معرفة الإجراء المناسب.',
      searchTags: <String>['bitte', 'helfen', 'Hilfe', 'مساعدة'],
      isPanicPhrase: true,
    ),
    ShoppingPhrase(
      id: 'return_b1_exchange',
      level: ShoppingLevel.b1,
      agent: ShoppingAgentType.returnWarranty,
      german: 'Ich möchte den defekten Artikel gern umtauschen.',
      arabic: 'أود استبدال القطعة المعطلة.',
      usageArabic: 'umtauschen يستخدم عند طلب استبدال السلعة بسلعة أخرى.',
      searchTags: <String>['defekt', 'umtauschen', 'Artikel', 'استبدال', 'عطل'],
    ),
    ShoppingPhrase(
      id: 'return_b1_invoice',
      level: ShoppingLevel.b1,
      agent: ShoppingAgentType.returnWarranty,
      german: 'Ich habe die Rechnung und den Kassenbon dabei.',
      arabic: 'معي الفاتورة وإيصال الشراء.',
      usageArabic: 'عبارة مناسبة لتوضيح أن مستندات الشراء متوفرة.',
      searchTags: <String>[
        'Rechnung',
        'Kassenbon',
        'Beleg',
        'فاتورة',
        'إيصال',
      ],
    ),
    ShoppingPhrase(
      id: 'return_b1_refund',
      level: ShoppingLevel.b1,
      agent: ShoppingAgentType.returnWarranty,
      german: 'Könnten Sie mir bitte erklären, welche Rückgabe möglich ist?',
      arabic: 'هل يمكنكم توضيح خيار الإرجاع المتاح من فضلكم؟',
      usageArabic: 'صيغة مهذبة للسؤال عن الخيارات قبل طلب إجراء محدد.',
      searchTags: <String>['bitte', 'Rückgabe', 'erklären', 'إرجاع', 'خيار'],
    ),
    ShoppingPhrase(
      id: 'return_b1_warranty',
      level: ShoppingLevel.b1,
      agent: ShoppingAgentType.returnWarranty,
      german: 'Ist der Artikel noch innerhalb der Garantie?',
      arabic: 'هل ما زالت القطعة ضمن مدة الضمان؟',
      usageArabic: 'innerhalb der Garantie تعبير واضح للسؤال عن الضمان.',
      searchTags: <String>['Garantie', 'Artikel', 'ضمان'],
    ),
    ShoppingPhrase(
      id: 'return_b2_defect_detail',
      level: ShoppingLevel.b2,
      agent: ShoppingAgentType.returnWarranty,
      german:
          'Der Artikel weist einen Mangel auf, der bereits kurz nach dem Kauf aufgetreten ist.',
      arabic: 'توجد في القطعة مشكلة ظهرت بعد وقت قصير من الشراء.',
      usageArabic: 'einen Mangel aufweisen صيغة رسمية ودقيقة لوصف العيب.',
      searchTags: <String>['Mangel', 'Kauf', 'defekt', 'عيب', 'شراء'],
    ),
    ShoppingPhrase(
      id: 'return_b2_invoice_reference',
      level: ShoppingLevel.b2,
      agent: ShoppingAgentType.returnWarranty,
      german:
          'Auf der Rechnung sind Kaufdatum und Artikelnummer eindeutig angegeben.',
      arabic: 'تظهر في الفاتورة بوضوح بيانات تاريخ الشراء ورقم القطعة.',
      usageArabic: 'صيغة مفيدة عند الاستناد إلى بيانات الفاتورة في الشكوى.',
      searchTags: <String>[
        'Rechnung',
        'Kaufdatum',
        'Artikelnummer',
        'فاتورة',
        'تاريخ الشراء',
      ],
    ),
    ShoppingPhrase(
      id: 'return_b2_polite_complaint',
      level: ShoppingLevel.b2,
      agent: ShoppingAgentType.returnWarranty,
      german:
          'Ich möchte den Sachverhalt höflich reklamieren und bitte um eine passende Lösung.',
      arabic: 'أود تقديم الشكوى بشكل مهذب وأرجو اقتراح حل مناسب.',
      usageArabic: 'صيغة مهنية تركز على المشكلة والحل دون تصعيد في الأسلوب.',
      searchTags: <String>[
        'reklamieren',
        'bitte',
        'Lösung',
        'Sachverhalt',
        'شكوى',
        'حل',
      ],
    ),
    ShoppingPhrase(
      id: 'return_b2_warranty_solution',
      level: ShoppingLevel.b2,
      agent: ShoppingAgentType.returnWarranty,
      german:
          'Welche Lösung können Sie mir im Rahmen der Gewährleistung anbieten?',
      arabic: 'ما الحل الذي يمكنكم تقديمه لي ضمن ضمان العيوب القانوني؟',
      usageArabic: 'Gewährleistung مصطلح مهم في سياق حقوق المستهلك والعيوب.',
      searchTags: <String>[
        'Gewährleistung',
        'Lösung',
        'Mangel',
        'ضمان',
        'حل',
      ],
    ),
  ];

  @override
  List<ShoppingPhrase> get phrases => _items;

  @override
  List<ShoppingPhrase> search(
    String query, {
    ShoppingLevel? level,
  }) =>
      _searchAgentItems(_items, query, level);

  @override
  List<ShoppingPhrase> get panicPhrases => List<ShoppingPhrase>.unmodifiable(
        _items.where((item) => item.isPanicPhrase),
      );
}

List<ShoppingPhrase> _searchAgentItems(
  List<ShoppingPhrase> source,
  String query,
  ShoppingLevel? level,
) {
  final results = source.where((item) {
    final levelMatches = level == null || item.level == level;
    return levelMatches && item.matches(query);
  }).toList(growable: false);

  return List<ShoppingPhrase>.unmodifiable(results);
}
