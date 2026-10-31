import '../domain/buergeramt_models.dart';
import '../domain/buergeramt_repository.dart';

final class LocalBuergeramtRepository implements BuergeramtRepository {
  LocalBuergeramtRepository()
      : _situations = _buildSituations(),
        _dialogues = _buildDialogues();

  final List<BureaucracyScenario> _situations;
  final Map<String, List<BureaucracyDialogueTurn>> _dialogues;

  @override
  Future<List<BureaucracyScenario>> getSituations() async =>
      List<BureaucracyScenario>.unmodifiable(_situations);

  @override
  Future<List<BureaucracyDialogueTurn>> getDialogue(String scenarioId) async {
    final turns = _dialogues[scenarioId];
    if (turns == null) return const <BureaucracyDialogueTurn>[];
    return List<BureaucracyDialogueTurn>.unmodifiable(turns);
  }

  @override
  Future<bool> checkChoice({
    required String scenarioId,
    required String turnId,
    required String choiceId,
  }) async {
    final turns = _dialogues[scenarioId];
    if (turns == null) return false;

    for (final turn in turns) {
      if (turn.id != turnId) continue;
      for (final choice in turn.choices) {
        if (choice.id == choiceId) return choice.isCorrect;
      }
    }
    return false;
  }

  static List<BureaucracyScenario> _buildSituations() {
    const situations = <BureaucracyScenario>[
      BureaucracyScenario(
        id: 'buergeramt_termin',
        type: BureaucracySituation.buergeramt,
        titleDe: 'Termin im Bürgeramt',
        titleAr: 'موعد في مكتب المواطنين',
        goalAr:
            'تتدرّب على الوصول للموظف، شرح سبب الزيارة، وطلب توضيح رسمي بأدب.',
        documents: <OfficialDocumentBadge>[
          OfficialDocumentBadge(
            id: 'passport',
            labelDe: 'Reisepass / Personalausweis',
            labelAr: 'جواز السفر / الهوية',
            required: true,
          ),
          OfficialDocumentBadge(
            id: 'appointment_confirmation',
            labelDe: 'Terminbestätigung',
            labelAr: 'تأكيد الموعد',
            required: true,
          ),
          OfficialDocumentBadge(
            id: 'supporting_documents',
            labelDe: 'Unterlagen zum Anliegen',
            labelAr: 'المستندات الخاصة بالمعاملة',
            required: false,
          ),
        ],
      ),
      BureaucracyScenario(
        id: 'bank_konto',
        type: BureaucracySituation.bank,
        titleDe: 'Konto bei der Bank',
        titleAr: 'فتح أو إدارة حساب بنكي',
        goalAr:
            'تتدرّب على طلب فتح حساب، السؤال عن الرسوم، وفهم طلبات موظف البنك.',
        documents: <OfficialDocumentBadge>[
          OfficialDocumentBadge(
            id: 'passport',
            labelDe: 'Reisepass / Personalausweis',
            labelAr: 'جواز السفر / الهوية',
            required: true,
          ),
          OfficialDocumentBadge(
            id: 'address_proof',
            labelDe: 'Adressnachweis',
            labelAr: 'إثبات العنوان',
            required: true,
          ),
          OfficialDocumentBadge(
            id: 'tax_id',
            labelDe: 'Steueridentifikationsnummer',
            labelAr: 'الرقم الضريبي',
            required: false,
          ),
        ],
      ),
      BureaucracyScenario(
        id: 'anmeldung_wohnung',
        type: BureaucracySituation.anmeldung,
        titleDe: 'Wohnsitz anmelden',
        titleAr: 'تسجيل السكن',
        goalAr:
            'تتدرّب على تسجيل العنوان الجديد وفهم أسماء المستندات الأساسية المطلوبة في الموعد.',
        documents: <OfficialDocumentBadge>[
          OfficialDocumentBadge(
            id: 'passport',
            labelDe: 'Reisepass / Personalausweis',
            labelAr: 'جواز السفر / الهوية',
            required: true,
          ),
          OfficialDocumentBadge(
            id: 'anmeldung_form',
            labelDe: 'Anmeldeformular',
            labelAr: 'نموذج تسجيل السكن',
            required: true,
          ),
          OfficialDocumentBadge(
            id: 'wohnungsgeberbestaetigung',
            labelDe: 'Wohnungsgeberbestätigung',
            labelAr: 'تأكيد السكن من المؤجّر',
            required: true,
          ),
        ],
      ),
    ];

    final ids = situations.map((item) => item.id).toSet();
    if (ids.length != situations.length) {
      throw StateError('bureaucracy situations contain duplicate ids');
    }
    return List<BureaucracyScenario>.unmodifiable(situations);
  }

  static Map<String, List<BureaucracyDialogueTurn>> _buildDialogues() {
    const dialogues = <String, List<BureaucracyDialogueTurn>>{
      'buergeramt_termin': <BureaucracyDialogueTurn>[
        BureaucracyDialogueTurn(
          id: 'ba_1',
          speaker: DialogueSpeaker.official,
          textDe: 'Guten Tag. Haben Sie einen Termin?',
          translationAr: 'مرحباً. هل لديك موعد؟',
          choices: <DialogueChoice>[
            DialogueChoice(
              id: 'ba_1_correct',
              textDe: 'Ja, ich habe um 10 Uhr einen Termin.',
              translationAr: 'نعم، لدي موعد الساعة العاشرة.',
              feedbackAr:
                  'إجابة واضحة ومهذبة، وتذكر الموعد مباشرة دون تفاصيل زائدة.',
              isCorrect: true,
            ),
            DialogueChoice(
              id: 'ba_1_wrong',
              textDe: 'Termin? Weiß ich nicht.',
              translationAr: 'موعد؟ لا أعرف.',
              feedbackAr:
                  'مفهومة لغوياً، لكنها غير مناسبة لسياق رسمي. استخدم جملة كاملة ومباشرة.',
              isCorrect: false,
            ),
          ],
        ),
        BureaucracyDialogueTurn(
          id: 'ba_2',
          speaker: DialogueSpeaker.official,
          textDe: 'Worum geht es bei Ihrem Termin?',
          translationAr: 'ما موضوع موعدك؟',
          choices: <DialogueChoice>[
            DialogueChoice(
              id: 'ba_2_correct',
              textDe: 'Ich möchte meine Unterlagen prüfen lassen.',
              translationAr: 'أرغب في فحص مستنداتي.',
              feedbackAr:
                  'صيغة مناسبة في الدوائر: möchte + Infinitiv تعطي طلباً مهذباً وواضحاً.',
              isCorrect: true,
            ),
            DialogueChoice(
              id: 'ba_2_wrong',
              textDe: 'Prüfen Sie das jetzt.',
              translationAr: 'افحص هذا الآن.',
              feedbackAr:
                  'هذه صيغة أمر مباشرة. في الموقف الرسمي الأفضل استخدام möchte أو könnten Sie.',
              isCorrect: false,
            ),
          ],
        ),
        BureaucracyDialogueTurn(
          id: 'ba_3',
          speaker: DialogueSpeaker.official,
          textDe: 'Bitte nehmen Sie im Wartebereich Platz.',
          translationAr: 'تفضل بالجلوس في منطقة الانتظار.',
        ),
      ],
      'bank_konto': <BureaucracyDialogueTurn>[
        BureaucracyDialogueTurn(
          id: 'bank_1',
          speaker: DialogueSpeaker.official,
          textDe: 'Guten Tag. Was kann ich für Sie tun?',
          translationAr: 'مرحباً. ماذا يمكنني أن أفعل لك؟',
          choices: <DialogueChoice>[
            DialogueChoice(
              id: 'bank_1_correct',
              textDe: 'Ich möchte gern ein Girokonto eröffnen.',
              translationAr: 'أرغب في فتح حساب جاري.',
              feedbackAr:
                  'gern مع möchte تجعل الطلب طبيعياً ومهذباً في البنك.',
              isCorrect: true,
            ),
            DialogueChoice(
              id: 'bank_1_wrong',
              textDe: 'Geben Sie mir ein Konto.',
              translationAr: 'أعطني حساباً.',
              feedbackAr:
                  'هذه صيغة مباشرة جداً. الأفضل في البنك استخدام Ich möchte gern ...',
              isCorrect: false,
            ),
          ],
        ),
        BureaucracyDialogueTurn(
          id: 'bank_2',
          speaker: DialogueSpeaker.official,
          textDe: 'Möchten Sie etwas über die Kontoführungsgebühren wissen?',
          translationAr: 'هل ترغب في معرفة شيء عن رسوم إدارة الحساب؟',
          choices: <DialogueChoice>[
            DialogueChoice(
              id: 'bank_2_correct',
              textDe: 'Ja. Wie hoch sind die monatlichen Gebühren?',
              translationAr: 'نعم. كم تبلغ الرسوم الشهرية؟',
              feedbackAr:
                  'سؤال عملي ودقيق باستخدام Wie hoch sind ...؟',
              isCorrect: true,
            ),
            DialogueChoice(
              id: 'bank_2_wrong',
              textDe: 'Warum kostet das so viel?',
              translationAr: 'لماذا يكلف هذا كثيراً؟',
              feedbackAr:
                  'قد تبدو العبارة اتهامية قبل معرفة الرسوم. ابدأ بسؤال محايد عن المبلغ.',
              isCorrect: false,
            ),
          ],
        ),
        BureaucracyDialogueTurn(
          id: 'bank_3',
          speaker: DialogueSpeaker.official,
          textDe: 'Dann brauche ich bitte Ihren Ausweis.',
          translationAr: 'إذن أحتاج من فضلك إلى هويتك.',
        ),
      ],
      'anmeldung_wohnung': <BureaucracyDialogueTurn>[
        BureaucracyDialogueTurn(
          id: 'an_1',
          speaker: DialogueSpeaker.official,
          textDe: 'Guten Tag. Möchten Sie Ihren Wohnsitz anmelden?',
          translationAr: 'مرحباً. هل ترغب في تسجيل عنوان سكنك؟',
          choices: <DialogueChoice>[
            DialogueChoice(
              id: 'an_1_correct',
              textDe: 'Ja, ich bin vor Kurzem umgezogen und möchte mich anmelden.',
              translationAr: 'نعم، انتقلت للسكن مؤخراً وأرغب في تسجيل عنواني.',
              feedbackAr:
                  'صياغة مناسبة: umziehen يشرح السبب و sich anmelden يعبّر عن تسجيل السكن.',
              isCorrect: true,
            ),
            DialogueChoice(
              id: 'an_1_wrong',
              textDe: 'Ich will Anmeldung.',
              translationAr: 'أريد تسجيل.',
              feedbackAr:
                  'المعنى مفهوم لكنه غير طبيعي. استخدم: Ich möchte mich anmelden.',
              isCorrect: false,
            ),
          ],
        ),
        BureaucracyDialogueTurn(
          id: 'an_2',
          speaker: DialogueSpeaker.official,
          textDe: 'Haben Sie die Wohnungsgeberbestätigung dabei?',
          translationAr: 'هل معك تأكيد السكن من المؤجّر؟',
          choices: <DialogueChoice>[
            DialogueChoice(
              id: 'an_2_correct',
              textDe: 'Ja, hier ist die Wohnungsgeberbestätigung.',
              translationAr: 'نعم، تفضل، هذا هو تأكيد السكن.',
              feedbackAr:
                  'hier ist ... صيغة بسيطة وطبيعية عند تسليم مستند.',
              isCorrect: true,
            ),
            DialogueChoice(
              id: 'an_2_wrong',
              textDe: 'Was ist das überhaupt?',
              translationAr: 'ما هذا أصلاً؟',
              feedbackAr:
                  'لو لم تعرف المستند، اسأل بأدب: Könnten Sie mir bitte erklären, was das ist?',
              isCorrect: false,
            ),
          ],
        ),
        BureaucracyDialogueTurn(
          id: 'an_3',
          speaker: DialogueSpeaker.official,
          textDe: 'Vielen Dank. Ich prüfe jetzt Ihre Angaben.',
          translationAr: 'شكراً جزيلاً. سأراجع بياناتك الآن.',
        ),
      ],
    };

    for (final entry in dialogues.entries) {
      final ids = entry.value.map((turn) => turn.id).toSet();
      if (ids.length != entry.value.length) {
        throw StateError(
          'dialogue contains duplicate turn ids: ${entry.key}',
        );
      }
    }
    return Map<String, List<BureaucracyDialogueTurn>>.unmodifiable(
      <String, List<BureaucracyDialogueTurn>>{
        for (final entry in dialogues.entries)
          entry.key: List<BureaucracyDialogueTurn>.unmodifiable(entry.value),
      },
    );
  }
}
