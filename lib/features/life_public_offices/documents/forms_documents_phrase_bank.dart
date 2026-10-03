import 'documents_models.dart';

abstract final class FormsDocumentsPhraseBank {
  static const List<DocumentsPhrase> all = <DocumentsPhrase>[
    DocumentsPhrase(
      id: 'form-purpose',
      topic: DocumentsTopic.formFilling,
      german:
          'Welches Formular brauche ich für mein Anliegen, und wo bekomme ich die aktuelle Version?',
      arabic:
          'ما الاستمارة المطلوبة لمعاملتي، وأين أحصل على النسخة الحالية منها؟',
      contextDe: 'Passendes Formular auswählen',
      contextAr: 'اختيار الاستمارة الصحيحة',
      keywords: <String>['Formular', 'Antrag', 'aktuelle Version', 'استمارة'],
    ),
    DocumentsPhrase(
      id: 'form-field-help',
      topic: DocumentsTopic.formFilling,
      german:
          'Was muss ich in dieses Feld eintragen? Können Sie mir bitte die Bedeutung erklären?',
      arabic:
          'ماذا يجب أن أكتب في هذه الخانة؟ هل يمكنكم شرح معناها من فضلكم؟',
      contextDe: 'Unklares Formularfeld verstehen',
      contextAr: 'فهم خانة غير واضحة في الطلب',
      keywords: <String>['Feld', 'eintragen', 'ausfüllen', 'خانة'],
    ),
    DocumentsPhrase(
      id: 'form-personal-data',
      topic: DocumentsTopic.formFilling,
      german:
          'Soll ich hier meine aktuelle Anschrift und meine persönlichen Daten so eintragen, wie sie im Ausweis stehen?',
      arabic:
          'هل أكتب هنا عنواني الحالي وبياناتي الشخصية كما تظهر في وثيقة الهوية؟',
      contextDe: 'Persönliche Angaben korrekt übernehmen',
      contextAr: 'إدخال البيانات الشخصية بشكل صحيح',
      keywords: <String>['Anschrift', 'Geburtsdatum', 'persönliche Daten', 'بيانات'],
    ),
    DocumentsPhrase(
      id: 'form-signature',
      topic: DocumentsTopic.formFilling,
      german:
          'Wo muss ich den Antrag unterschreiben, und muss ich das Datum ebenfalls eintragen?',
      arabic:
          'أين يجب أن أوقّع الطلب، وهل يجب أن أكتب التاريخ أيضًا؟',
      contextDe: 'Unterschrift und Datum prüfen',
      contextAr: 'التأكد من التوقيع والتاريخ',
      keywords: <String>['Unterschrift', 'Datum', 'unterschreiben', 'توقيع'],
    ),
    DocumentsPhrase(
      id: 'identity-original',
      topic: DocumentsTopic.identityProof,
      german:
          'Reicht eine Kopie meines Ausweises, oder müssen Sie das Original sehen?',
      arabic:
          'هل تكفي نسخة من وثيقة الهوية، أم يجب إبراز الأصل؟',
      contextDe: 'Form des Identitätsnachweises klären',
      contextAr: 'تحديد شكل إثبات الهوية المطلوب',
      keywords: <String>['Ausweis', 'Pass', 'Original', 'Kopie', 'هوية'],
    ),
    DocumentsPhrase(
      id: 'identity-validity',
      topic: DocumentsTopic.identityProof,
      german:
          'Welche Anforderungen gelten für den Identitätsnachweis bei diesem Antrag?',
      arabic:
          'ما المتطلبات الخاصة بإثبات الهوية لهذه المعاملة؟',
      contextDe: 'Behördenspezifische Anforderungen erfragen',
      contextAr: 'السؤال عن متطلبات الدائرة المحددة',
      keywords: <String>['Identitätsnachweis', 'Anforderungen', 'هوية'],
    ),
    DocumentsPhrase(
      id: 'certification-needed',
      topic: DocumentsTopic.certification,
      german:
          'Benötige ich für dieses Dokument eine Beglaubigung oder genügt eine einfache Kopie?',
      arabic:
          'هل تحتاج هذه الوثيقة إلى تصديق، أم تكفي نسخة عادية؟',
      contextDe: 'Beglaubigungspflicht klären',
      contextAr: 'التأكد من الحاجة إلى التصديق',
      keywords: <String>['Beglaubigung', 'beglaubigt', 'Kopie', 'تصديق'],
    ),
    DocumentsPhrase(
      id: 'certification-place',
      topic: DocumentsTopic.certification,
      german:
          'Wo kann ich diese Kopie für meinen konkreten Zweck beglaubigen lassen?',
      arabic:
          'أين يمكنني تصديق هذه النسخة للغرض المحدد من معاملتي؟',
      contextDe: 'Zuständige Stelle für die Beglaubigung erfragen',
      contextAr: 'معرفة الجهة المختصة بالتصديق',
      keywords: <String>['beglaubigen', 'zuständige Stelle', 'نسخة مصدقة'],
    ),
    DocumentsPhrase(
      id: 'power-scope',
      topic: DocumentsTopic.powerOfAttorney,
      german:
          'Welche Angaben muss die Vollmacht enthalten, damit die bevollmächtigte Person dieses Anliegen für mich erledigen kann?',
      arabic:
          'ما البيانات التي يجب أن تتضمنها الوكالة حتى يتمكن الشخص المفوض من إنجاز هذه المعاملة عني؟',
      contextDe: 'Umfang der Vollmacht klären',
      contextAr: 'تحديد نطاق الوكالة المطلوبة',
      keywords: <String>['Vollmacht', 'bevollmächtigt', 'Vertretung', 'وكالة'],
    ),
    DocumentsPhrase(
      id: 'power-id',
      topic: DocumentsTopic.powerOfAttorney,
      german:
          'Welche Identitätsnachweise müssen die bevollmächtigte Person und ich vorlegen?',
      arabic:
          'ما إثباتات الهوية التي يجب أن يقدمها الشخص المفوض وأنا؟',
      contextDe: 'Nachweise bei Vertretung prüfen',
      contextAr: 'التحقق من إثباتات الهوية عند التوكيل',
      keywords: <String>['Vollmacht', 'Ausweis', 'Vertreter', 'مفوض'],
    ),
    DocumentsPhrase(
      id: 'missing-list',
      topic: DocumentsTopic.missingDocuments,
      german:
          'Welche Unterlagen fehlen noch, und wie kann ich sie nachreichen?',
      arabic:
          'ما المستندات التي ما زالت ناقصة، وكيف يمكنني استكمالها؟',
      contextDe: 'Fehlende Unterlagen konkretisieren',
      contextAr: 'تحديد المستندات الناقصة وطريقة استكمالها',
      keywords: <String>['fehlen', 'Unterlagen', 'nachreichen', 'ناقص'],
    ),
    DocumentsPhrase(
      id: 'missing-extension',
      topic: DocumentsTopic.missingDocuments,
      german:
          'Ich kann die fehlenden Unterlagen nicht rechtzeitig beschaffen. Kann ich eine Fristverlängerung beantragen?',
      arabic:
          'لا أستطيع توفير المستندات الناقصة في الوقت المحدد. هل يمكنني طلب تمديد للمهلة؟',
      contextDe: 'Zusätzliche Frist erfragen',
      contextAr: 'طلب مهلة إضافية لاستكمال المستندات',
      keywords: <String>['Fristverlängerung', 'Frist', 'Nachreichen', 'مهلة'],
    ),
    DocumentsPhrase(
      id: 'missing-confirmation',
      topic: DocumentsTopic.missingDocuments,
      german:
          'Können Sie mir bitte bestätigen, dass die nachgereichten Unterlagen eingegangen sind?',
      arabic:
          'هل يمكنكم تأكيد استلام المستندات التي أرسلتها لاحقًا؟',
      contextDe: 'Eingang nachgereichter Unterlagen bestätigen',
      contextAr: 'تأكيد وصول المستندات المستكملة',
      keywords: <String>['Eingang', 'Bestätigung', 'nachgereicht', 'استلام'],
    ),
  ];
}
