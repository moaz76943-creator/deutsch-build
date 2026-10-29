import '../../audio/domain/entities/audio_request.dart';
import '../../audio/domain/services/i_audio_runtime.dart';
import '../domain/dialogue_engine.dart';
import '../domain/dialogue_models.dart';

abstract final class DefaultDialogueScenarios {
  static final DialogueScenario bakery = DialogueScenario(
    id: 'bakery',
    titleGerman: 'Beim Bäcker',
    titleArabic: 'في المخبز',
    startNodeId: 'bakery-start',
    nodes: <String, DialogueNode>{
      'bakery-start': const DialogueNode(
        id: 'bakery-start',
        turn: DialogueTurn(
          id: 'bakery-start-turn',
          speaker: DialogueSpeaker.interlocutor,
          germanText: 'Guten Morgen. Was darf es sein?',
          arabicTranslation: 'صباح الخير. ماذا ترغب؟',
          audioConceptId: 'dialogue-bakery-start',
        ),
        choices: <DialogueChoice>[
          DialogueChoice(
            id: 'bakery-two-rolls',
            germanText: 'Ich hätte gern zwei Brötchen, bitte.',
            arabicTranslation: 'أريد قطعتين من الخبز الصغير، من فضلك.',
            nextNodeId: 'bakery-more',
            points: 10,
          ),
          DialogueChoice(
            id: 'bakery-two-bread',
            germanText: 'Zwei Brot, bitte.',
            arabicTranslation: 'خبزان، من فضلك.',
            nextNodeId: 'bakery-more',
            points: 4,
          ),
        ],
      ),
      'bakery-more': const DialogueNode(
        id: 'bakery-more',
        turn: DialogueTurn(
          id: 'bakery-more-turn',
          speaker: DialogueSpeaker.interlocutor,
          germanText: 'Gern. Sonst noch etwas?',
          arabicTranslation: 'بكل سرور. هل تريد شيئًا آخر؟',
          audioConceptId: 'dialogue-bakery-more',
        ),
        choices: <DialogueChoice>[
          DialogueChoice(
            id: 'bakery-price',
            germanText: 'Nein, danke. Was kostet das?',
            arabicTranslation: 'لا، شكرًا. كم السعر؟',
            nextNodeId: 'bakery-end',
            points: 10,
          ),
          DialogueChoice(
            id: 'bakery-no',
            germanText: 'Nein, danke.',
            arabicTranslation: 'لا، شكرًا.',
            nextNodeId: 'bakery-end',
            points: 6,
          ),
        ],
      ),
      'bakery-end': const DialogueNode(
        id: 'bakery-end',
        turn: DialogueTurn(
          id: 'bakery-end-turn',
          speaker: DialogueSpeaker.interlocutor,
          germanText: 'Das macht drei Euro. Vielen Dank!',
          arabicTranslation: 'الحساب ثلاثة يورو. شكرًا جزيلًا!',
          audioConceptId: 'dialogue-bakery-end',
        ),
      ),
    },
  );

  static final DialogueScenario trainStation = DialogueScenario(
    id: 'train-station',
    titleGerman: 'Am Bahnhof',
    titleArabic: 'في محطة القطار',
    startNodeId: 'station-start',
    nodes: <String, DialogueNode>{
      'station-start': const DialogueNode(
        id: 'station-start',
        turn: DialogueTurn(
          id: 'station-start-turn',
          speaker: DialogueSpeaker.interlocutor,
          germanText: 'Guten Tag. Wohin möchten Sie fahren?',
          arabicTranslation: 'مرحبًا. إلى أين تريد الذهاب؟',
          audioConceptId: 'dialogue-station-start',
        ),
        choices: <DialogueChoice>[
          DialogueChoice(
            id: 'station-berlin',
            germanText: 'Ich möchte nach Berlin fahren.',
            arabicTranslation: 'أريد الذهاب إلى برلين.',
            nextNodeId: 'station-ticket',
            points: 10,
          ),
          DialogueChoice(
            id: 'station-berlin-short',
            germanText: 'Nach Berlin, bitte.',
            arabicTranslation: 'إلى برلين، من فضلك.',
            nextNodeId: 'station-ticket',
            points: 8,
          ),
        ],
      ),
      'station-ticket': const DialogueNode(
        id: 'station-ticket',
        turn: DialogueTurn(
          id: 'station-ticket-turn',
          speaker: DialogueSpeaker.interlocutor,
          germanText: 'Einfach oder hin und zurück?',
          arabicTranslation: 'ذهاب فقط أم ذهاب وإياب؟',
          audioConceptId: 'dialogue-station-ticket',
        ),
        choices: <DialogueChoice>[
          DialogueChoice(
            id: 'station-one-way',
            germanText: 'Einfach, bitte. Wann fährt der nächste Zug?',
            arabicTranslation: 'ذهاب فقط، من فضلك. متى يغادر القطار القادم؟',
            nextNodeId: 'station-end',
            points: 10,
          ),
          DialogueChoice(
            id: 'station-return',
            germanText: 'Hin und zurück, bitte.',
            arabicTranslation: 'ذهاب وإياب، من فضلك.',
            nextNodeId: 'station-end',
            points: 8,
          ),
        ],
      ),
      'station-end': const DialogueNode(
        id: 'station-end',
        turn: DialogueTurn(
          id: 'station-end-turn',
          speaker: DialogueSpeaker.interlocutor,
          germanText: 'Der nächste Zug fährt um 14:20 Uhr von Gleis 6.',
          arabicTranslation: 'القطار القادم يغادر الساعة 14:20 من الرصيف 6.',
          audioConceptId: 'dialogue-station-end',
        ),
      ),
    },
  );

  static final DialogueScenario residenceAppointment = DialogueScenario(
    id: 'residence-appointment',
    titleGerman: 'Bei der Ausländerbehörde',
    titleArabic: 'في دائرة شؤون الأجانب',
    startNodeId: 'residence-start',
    nodes: <String, DialogueNode>{
      'residence-start': const DialogueNode(
        id: 'residence-start',
        turn: DialogueTurn(
          id: 'residence-start-turn',
          speaker: DialogueSpeaker.interlocutor,
          germanText: 'Guten Tag. Haben Sie einen Termin?',
          arabicTranslation: 'مرحبًا. هل لديك موعد؟',
          audioConceptId: 'dialogue-residence-start',
        ),
        choices: <DialogueChoice>[
          DialogueChoice(
            id: 'residence-has-appointment',
            germanText: 'Ja, ich habe heute um zehn Uhr einen Termin.',
            arabicTranslation: 'نعم، لدي موعد اليوم الساعة العاشرة.',
            nextNodeId: 'residence-purpose',
            points: 10,
          ),
          DialogueChoice(
            id: 'residence-appointment-short',
            germanText: 'Ja, um zehn Uhr.',
            arabicTranslation: 'نعم، الساعة العاشرة.',
            nextNodeId: 'residence-purpose',
            points: 7,
          ),
        ],
      ),
      'residence-purpose': const DialogueNode(
        id: 'residence-purpose',
        turn: DialogueTurn(
          id: 'residence-purpose-turn',
          speaker: DialogueSpeaker.interlocutor,
          germanText: 'Worum geht es bei Ihrem Termin?',
          arabicTranslation: 'ما موضوع موعدك؟',
          audioConceptId: 'dialogue-residence-purpose',
        ),
        choices: <DialogueChoice>[
          DialogueChoice(
            id: 'residence-extension',
            germanText: 'Ich möchte meinen Aufenthaltstitel verlängern.',
            arabicTranslation: 'أريد تمديد تصريح الإقامة الخاص بي.',
            nextNodeId: 'residence-documents',
            points: 10,
          ),
          DialogueChoice(
            id: 'residence-permit',
            germanText: 'Es geht um meinen Aufenthaltstitel.',
            arabicTranslation: 'الموضوع يتعلق بتصريح إقامتي.',
            nextNodeId: 'residence-documents',
            points: 8,
          ),
        ],
      ),
      'residence-documents': const DialogueNode(
        id: 'residence-documents',
        turn: DialogueTurn(
          id: 'residence-documents-turn',
          speaker: DialogueSpeaker.interlocutor,
          germanText: 'Haben Sie Ihren Pass und die Unterlagen dabei?',
          arabicTranslation: 'هل معك جواز السفر والمستندات؟',
          audioConceptId: 'dialogue-residence-documents',
        ),
        choices: <DialogueChoice>[
          DialogueChoice(
            id: 'residence-documents-yes',
            germanText: 'Ja, hier sind mein Pass und meine Unterlagen.',
            arabicTranslation: 'نعم، هذا جواز سفري وهذه مستنداتي.',
            nextNodeId: 'residence-end',
            points: 10,
          ),
          DialogueChoice(
            id: 'residence-documents-here',
            germanText: 'Ja, hier bitte.',
            arabicTranslation: 'نعم، تفضل.',
            nextNodeId: 'residence-end',
            points: 7,
          ),
        ],
      ),
      'residence-end': const DialogueNode(
        id: 'residence-end',
        turn: DialogueTurn(
          id: 'residence-end-turn',
          speaker: DialogueSpeaker.interlocutor,
          germanText: 'Danke. Bitte nehmen Sie im Wartebereich Platz.',
          arabicTranslation: 'شكرًا. تفضل بالجلوس في منطقة الانتظار.',
          audioConceptId: 'dialogue-residence-end',
        ),
      ),
    },
  );

  static List<DialogueScenario> get all => <DialogueScenario>[
        bakery,
        trainStation,
        residenceAppointment,
      ];
}

final class InMemoryDialogueRepository implements DialogueRepository {
  InMemoryDialogueRepository({List<DialogueScenario>? scenarios})
      : _scenarios = List<DialogueScenario>.unmodifiable(
          scenarios ?? DefaultDialogueScenarios.all,
        );

  final List<DialogueScenario> _scenarios;
  final Map<String, DialogueProgress> _progress = <String, DialogueProgress>{};

  @override
  List<DialogueScenario> get scenarios => _scenarios;

  @override
  DialogueScenario? scenarioById(String scenarioId) {
    for (final scenario in _scenarios) {
      if (scenario.id == scenarioId) return scenario;
    }
    return null;
  }

  @override
  DialogueProgress progressFor(String scenarioId) {
    return _progress[scenarioId] ?? DialogueProgress.empty(scenarioId);
  }

  @override
  void recordCompletion(
    DialogueSessionResult result, {
    DateTime? completedAt,
  }) {
    if (scenarioById(result.scenarioId) == null) {
      throw ArgumentError.value(
        result.scenarioId,
        'result.scenarioId',
        'Unknown dialogue scenario.',
      );
    }
    final previous = progressFor(result.scenarioId);
    _progress[result.scenarioId] = DialogueProgress(
      scenarioId: result.scenarioId,
      completedRuns: previous.completedRuns + 1,
      bestScorePercent: result.scorePercent > previous.bestScorePercent
          ? result.scorePercent
          : previous.bestScorePercent,
      lastScorePercent: result.scorePercent,
      lastCompletedAt: completedAt ?? DateTime.now().toUtc(),
    );
  }
}

final class DialogueAudioRuntimeAdapter implements DialogueAudioPort {
  const DialogueAudioRuntimeAdapter({
    required this.runtime,
    this.languageCode = 'de',
  });

  final IAudioRuntime runtime;
  final String languageCode;

  @override
  Future<bool> speak(DialogueTurn turn) async {
    if (turn.germanText.trim().isEmpty) return false;
    final result = await runtime.play(
      AudioRequest(
        text: turn.germanText,
        languageCode: languageCode,
        conceptId: turn.audioConceptId ?? turn.id,
        variant: AudioVariant.sentence,
      ),
    );
    return result.played;
  }
}
