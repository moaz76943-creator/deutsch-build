import 'automatic_carwash_models.dart';

abstract final class AutomaticCarwashPhraseBank {
  static const List<CarwashPhrase> all = <CarwashPhrase>[
    CarwashPhrase(
      id: 'program-basic',
      topic: CarwashTopic.program,
      german:
          'Welches Waschprogramm empfehlen Sie für eine normale Außenwäsche ohne besondere Zusatzbehandlung?',
      arabic:
          'أي برنامج غسيل تنصحون به لغسيل خارجي عادي من دون معالجة إضافية خاصة؟',
      contextDe: 'Passendes Grundprogramm wählen',
      contextAr: 'اختيار برنامج أساسي مناسب',
      keywords: <String>['Waschprogramm', 'Außenwäsche', 'برنامج'],
    ),
    CarwashPhrase(
      id: 'program-wax',
      topic: CarwashTopic.program,
      german:
          'Was ist bei diesem Programm zusätzlich enthalten, zum Beispiel Unterbodenwäsche, Wachs oder Trocknung?',
      arabic:
          'ما الإضافات الموجودة في هذا البرنامج، مثل غسيل أسفل السيارة أو الشمع أو التجفيف؟',
      contextDe: 'Leistungsumfang vergleichen',
      contextAr: 'مقارنة تفاصيل البرامج',
      keywords: <String>['Unterbodenwäsche', 'Wachs', 'Trocknung', 'شمع'],
    ),
    CarwashPhrase(
      id: 'program-code',
      topic: CarwashTopic.program,
      german:
          'Wo gebe ich den Waschcode ein, und wie lange ist der gekaufte Code gültig?',
      arabic:
          'أين أدخل رمز الغسيل، وكم مدة صلاحية الرمز الذي اشتريته؟',
      contextDe: 'Waschcode korrekt verwenden',
      contextAr: 'استخدام رمز الغسيل بالشكل الصحيح',
      keywords: <String>['Waschcode', 'Code', 'gültig', 'رمز'],
    ),
    CarwashPhrase(
      id: 'prep-mirrors',
      topic: CarwashTopic.preparation,
      german:
          'Soll ich die Außenspiegel einklappen, oder müssen sie bei dieser Anlage in Fahrposition bleiben?',
      arabic:
          'هل أطوي المرايا الجانبية أم يجب أن تبقى في وضع القيادة في هذه المغسلة؟',
      contextDe: 'Anlagenspezifische Spiegelregel prüfen',
      contextAr: 'التحقق من تعليمات المرايا الخاصة بالمغسلة',
      keywords: <String>['Außenspiegel', 'einklappen', 'مرايا'],
    ),
    CarwashPhrase(
      id: 'prep-antenna',
      topic: CarwashTopic.preparation,
      german:
          'Muss ich die Antenne abschrauben oder versenken, bevor ich in die Anlage fahre?',
      arabic:
          'هل يجب فك الهوائي أو خفضه قبل دخول المغسلة؟',
      contextDe: 'Antenne vor Schäden schützen',
      contextAr: 'حماية الهوائي قبل الغسيل',
      keywords: <String>['Antenne', 'abschrauben', 'هوائي'],
    ),
    CarwashPhrase(
      id: 'prep-windows',
      topic: CarwashTopic.preparation,
      german:
          'Ich schließe Fenster, Schiebedach und Türen vollständig und prüfe, ob außen etwas lose befestigt ist.',
      arabic:
          'أغلق النوافذ وفتحة السقف والأبواب بالكامل وأتأكد من عدم وجود شيء خارجي مثبت بشكل غير محكم.',
      contextDe: 'Fahrzeug vor der Einfahrt sichern',
      contextAr: 'تجهيز السيارة قبل الدخول',
      keywords: <String>['Fenster', 'Schiebedach', 'lose Teile', 'نوافذ'],
    ),
    CarwashPhrase(
      id: 'prep-special-equipment',
      topic: CarwashTopic.preparation,
      german:
          'Mein Auto hat Dachträger und besondere Anbauteile. Ist es für diese Waschanlage freigegeben?',
      arabic:
          'سيارتي عليها حامل سقف وملحقات خارجية. هل يسمح بدخولها إلى هذه المغسلة؟',
      contextDe: 'Sonderausstattung vor Einfahrt melden',
      contextAr: 'إبلاغ المغسلة بالملحقات الخارجية',
      keywords: <String>['Dachträger', 'Anbauteile', 'freigegeben', 'حامل'],
    ),
    CarwashPhrase(
      id: 'conveyor-neutral',
      topic: CarwashTopic.conveyor,
      german:
          'Welche Stellung soll das Getriebe auf dem Förderband haben, und was soll ich mit Bremse oder Parkbremse tun?',
      arabic:
          'ما وضع ناقل الحركة المطلوب على السير، وماذا أفعل بالفرامل أو فرامل التوقف؟',
      contextDe: 'Nur die konkrete Anlagenanweisung befolgen',
      contextAr: 'اتباع تعليمات المغسلة المحددة فقط',
      keywords: <String>['Leerlauf', 'N', 'Förderband', 'Parkbremse', 'ناقل'],
    ),
    CarwashPhrase(
      id: 'conveyor-engine',
      topic: CarwashTopic.conveyor,
      german:
          'Soll der Motor während der Durchfahrt laufen oder ausgeschaltet sein? Ich folge der Anzeige dieser Anlage.',
      arabic:
          'هل يبقى المحرك يعمل أثناء المرور أم يجب إطفاؤه؟ سأتبع شاشة تعليمات هذه المغسلة.',
      contextDe: 'Motorstatus nicht pauschal annehmen',
      contextAr: 'عدم افتراض حالة المحرك',
      keywords: <String>['Motor', 'Anzeige', 'Durchfahrt', 'محرك'],
    ),
    CarwashPhrase(
      id: 'conveyor-stop',
      topic: CarwashTopic.conveyor,
      german:
          'Wenn eine Warnanzeige erscheint oder etwas ungewöhnlich wirkt, befolge ich die Stoppsignale und Anweisungen des Personals.',
      arabic:
          'إذا ظهرت إشارة تحذير أو شيء غير طبيعي، أتبع إشارات التوقف وتعليمات الموظفين.',
      contextDe: 'Bei Störung nicht improvisieren',
      contextAr: 'عدم الاجتهاد عند حدوث عطل',
      keywords: <String>['Stopp', 'Warnanzeige', 'Personal', 'تحذير'],
    ),
    CarwashPhrase(
      id: 'after-exit',
      topic: CarwashTopic.aftercare,
      german:
          'Wann darf ich nach dem Trockner wieder einlegen und aus der Anlage herausfahren?',
      arabic:
          'متى يمكنني تعشيق ناقل الحركة مجددًا والخروج بعد مرحلة التجفيف؟',
      contextDe: 'Ausfahrtssignal abwarten',
      contextAr: 'انتظار إشارة الخروج',
      keywords: <String>['Ausfahrt', 'Trockner', 'Signal', 'خروج'],
    ),
    CarwashPhrase(
      id: 'after-vacuum',
      topic: CarwashTopic.aftercare,
      german:
          'Wo finde ich die Staubsaugerplätze, und wird dafür ein eigener Tarif oder eine Münze benötigt?',
      arabic:
          'أين أماكن المكنسة الكهربائية، وهل تحتاج رسومًا منفصلة أو قطعة نقدية؟',
      contextDe: 'Innenreinigung nach der Wäsche organisieren',
      contextAr: 'تنظيم تنظيف الداخل بعد الغسيل',
      keywords: <String>['Staubsauger', 'Innenreinigung', 'Münze', 'مكنسة'],
    ),
  ];
}
