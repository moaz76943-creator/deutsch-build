import '../domain/passiv_models.dart';
import '../domain/passiv_repository.dart';

final class LocalPassivRepository implements PassivRepository {
  LocalPassivRepository() : _drills = _buildValidatedBank();

  final List<PassivDrillItem> _drills;

  @override
  Future<List<PassivDrillItem>> getDrills({
    PassivType? type,
  }) async {
    final selected = type == null
        ? _drills
        : _drills
            .where((item) => item.type == type)
            .toList(growable: false);
    return List<PassivDrillItem>.unmodifiable(selected);
  }

  @override
  Future<bool> checkTransformation({
    required String drillId,
    required String auxiliaryForm,
    required String agentPreposition,
    required String partizipII,
  }) async {
    final auxiliary = _normalize(auxiliaryForm);
    final preposition = _normalize(agentPreposition);
    final participle = _normalize(partizipII);

    for (final drill in _drills) {
      if (drill.id != drillId) continue;
      return auxiliary == _normalize(drill.auxiliaryForm) &&
          preposition == _normalize(drill.agentPreposition) &&
          participle == _normalize(drill.partizipII);
    }
    return false;
  }

  static String _normalize(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  static List<PassivDrillItem> _buildValidatedBank() {
    const drills = <PassivDrillItem>[
      PassivDrillItem(
        id: 'vorgang_praesens_person',
        activeSentence: 'Der Mechaniker repariert den Motor.',
        passiveSentence: 'Der Motor wird von dem Mechaniker repariert.',
        originalAgent: 'der Mechaniker',
        agentPreposition: 'von',
        agentCaseLabel: 'Dativ',
        akkusativObject: 'den Motor',
        nominativSubject: 'der Motor',
        auxiliaryForm: 'wird',
        partizipII: 'repariert',
        type: PassivType.vorgangspassiv,
        tense: PassivTense.praesens,
        explanationAr:
            'المفعول به den Motor في Akkusativ يصبح الفاعل النحوي الجديد der Motor في Nominativ. نستخدم wird + Partizip II، وإذا ذكرنا الشخص الذي قام بالفعل فنستخدم von + Dativ.',
      ),
      PassivDrillItem(
        id: 'vorgang_praesens_instrument',
        activeSentence: 'Die Maschine schneidet das Metall.',
        passiveSentence: 'Das Metall wird durch die Maschine geschnitten.',
        originalAgent: 'die Maschine',
        agentPreposition: 'durch',
        agentCaseLabel: 'Akkusativ',
        akkusativObject: 'das Metall',
        nominativSubject: 'das Metall',
        auxiliaryForm: 'wird',
        partizipII: 'geschnitten',
        type: PassivType.vorgangspassiv,
        tense: PassivTense.praesens,
        explanationAr:
            'das Metall ينتقل من Akkusativ إلى Nominativ. عندما تكون الأداة أو الوسيلة هي سبب التنفيذ نستخدم durch + Akkusativ، وهنا durch die Maschine.',
      ),
      PassivDrillItem(
        id: 'vorgang_praesens_plural',
        activeSentence: 'Die Techniker prüfen die Geräte.',
        passiveSentence: 'Die Geräte werden von den Technikern geprüft.',
        originalAgent: 'die Techniker',
        agentPreposition: 'von',
        agentCaseLabel: 'Dativ',
        akkusativObject: 'die Geräte',
        nominativSubject: 'die Geräte',
        auxiliaryForm: 'werden',
        partizipII: 'geprüft',
        type: PassivType.vorgangspassiv,
        tense: PassivTense.praesens,
        explanationAr:
            'die Geräte تصبح Nominativ جمع، لذلك نصرف werden بصيغة الجمع: werden. الشخص المنفذ يأتي مع von + Dativ: von den Technikern.',
      ),
      PassivDrillItem(
        id: 'vorgang_praeteritum_package',
        activeSentence: 'Der Kurier lieferte das Paket.',
        passiveSentence: 'Das Paket wurde von dem Kurier geliefert.',
        originalAgent: 'der Kurier',
        agentPreposition: 'von',
        agentCaseLabel: 'Dativ',
        akkusativObject: 'das Paket',
        nominativSubject: 'das Paket',
        auxiliaryForm: 'wurde',
        partizipII: 'geliefert',
        type: PassivType.vorgangspassiv,
        tense: PassivTense.praeteritum,
        explanationAr:
            'في Vorgangspassiv الماضي البسيط نستخدم wurde + Partizip II. das Paket يصبح فاعلًا نحويًا جديدًا، والفاعل الأصلي شخص لذلك يأتي مع von + Dativ.',
      ),
      PassivDrillItem(
        id: 'vorgang_praeteritum_storm',
        activeSentence: 'Der Sturm beschädigte das Dach.',
        passiveSentence: 'Das Dach wurde durch den Sturm beschädigt.',
        originalAgent: 'der Sturm',
        agentPreposition: 'durch',
        agentCaseLabel: 'Akkusativ',
        akkusativObject: 'das Dach',
        nominativSubject: 'das Dach',
        auxiliaryForm: 'wurde',
        partizipII: 'beschädigt',
        type: PassivType.vorgangspassiv,
        tense: PassivTense.praeteritum,
        explanationAr:
            'das Dach يصبح Nominativ. عند التعبير عن سبب أو قوة غير شخصية يمكن استخدام durch + Akkusativ: durch den Sturm، مع wurde + beschädigt.',
      ),
      PassivDrillItem(
        id: 'vorgang_perfekt_report',
        activeSentence: 'Die Mitarbeiterin hat den Bericht geschrieben.',
        passiveSentence:
            'Der Bericht ist von der Mitarbeiterin geschrieben worden.',
        originalAgent: 'die Mitarbeiterin',
        agentPreposition: 'von',
        agentCaseLabel: 'Dativ',
        akkusativObject: 'den Bericht',
        nominativSubject: 'der Bericht',
        auxiliaryForm: 'ist',
        partizipII: 'geschrieben',
        type: PassivType.vorgangspassiv,
        tense: PassivTense.perfekt,
        explanationAr:
            'في Perfekt للمبني للمجهول الحدثي نستخدم sein + Partizip II + worden. den Bericht يتحول إلى der Bericht، والشخص المنفذ يأتي مع von + Dativ.',
      ),
      PassivDrillItem(
        id: 'vorgang_perfekt_documents',
        activeSentence: 'Die Assistenten haben die Dokumente kopiert.',
        passiveSentence:
            'Die Dokumente sind von den Assistenten kopiert worden.',
        originalAgent: 'die Assistenten',
        agentPreposition: 'von',
        agentCaseLabel: 'Dativ',
        akkusativObject: 'die Dokumente',
        nominativSubject: 'die Dokumente',
        auxiliaryForm: 'sind',
        partizipII: 'kopiert',
        type: PassivType.vorgangspassiv,
        tense: PassivTense.perfekt,
        explanationAr:
            'الفاعل النحوي الجديد جمع، لذلك نستخدم sind في Perfekt: Die Dokumente sind ... kopiert worden. المنفذ البشري يأتي مع von + Dativ.',
      ),
      PassivDrillItem(
        id: 'zustand_praesens_window',
        activeSentence: 'Der Hausmeister öffnet das Fenster.',
        passiveSentence: 'Das Fenster ist geöffnet.',
        originalAgent: 'der Hausmeister',
        agentPreposition: 'von',
        agentCaseLabel: 'Dativ',
        akkusativObject: 'das Fenster',
        nominativSubject: 'das Fenster',
        auxiliaryForm: 'ist',
        partizipII: 'geöffnet',
        type: PassivType.zustandspassiv,
        tense: PassivTense.praesens,
        explanationAr:
            'هنا نهتم بالحالة الناتجة لا بعملية الفتح: النافذة الآن مفتوحة. لذلك نستخدم sein + Partizip II: Das Fenster ist geöffnet. ويمكن ذكر الشخص مع von + Dativ عند الحاجة.',
      ),
      PassivDrillItem(
        id: 'zustand_praesens_computer',
        activeSentence: 'Die Techniker schalten den Computer ein.',
        passiveSentence: 'Der Computer ist eingeschaltet.',
        originalAgent: 'die Techniker',
        agentPreposition: 'von',
        agentCaseLabel: 'Dativ',
        akkusativObject: 'den Computer',
        nominativSubject: 'der Computer',
        auxiliaryForm: 'ist',
        partizipII: 'eingeschaltet',
        type: PassivType.zustandspassiv,
        tense: PassivTense.praesens,
        explanationAr:
            'den Computer يصبح der Computer في Nominativ. Zustandspassiv يصف النتيجة الحالية، لذلك نستخدم ist + eingeschaltet بدل wird + eingeschaltet.',
      ),
      PassivDrillItem(
        id: 'zustand_praeteritum_door',
        activeSentence: 'Jemand schloss die Tür.',
        passiveSentence: 'Die Tür war geschlossen.',
        originalAgent: 'jemand',
        agentPreposition: 'von',
        agentCaseLabel: 'Dativ',
        akkusativObject: 'die Tür',
        nominativSubject: 'die Tür',
        auxiliaryForm: 'war',
        partizipII: 'geschlossen',
        type: PassivType.zustandspassiv,
        tense: PassivTense.praeteritum,
        explanationAr:
            'في الماضي نستخدم Präteritum من sein: war + Partizip II. الجملة تصف أن الباب كان في حالة الإغلاق، وليس لحظة تنفيذ الإغلاق.',
      ),
      PassivDrillItem(
        id: 'zustand_praeteritum_lights',
        activeSentence: 'Jemand schaltete die Lichter aus.',
        passiveSentence: 'Die Lichter waren ausgeschaltet.',
        originalAgent: 'jemand',
        agentPreposition: 'von',
        agentCaseLabel: 'Dativ',
        akkusativObject: 'die Lichter',
        nominativSubject: 'die Lichter',
        auxiliaryForm: 'waren',
        partizipII: 'ausgeschaltet',
        type: PassivType.zustandspassiv,
        tense: PassivTense.praeteritum,
        explanationAr:
            'لأن الفاعل النحوي الجديد جمع نستخدم waren. Zustandspassiv يصف حالة الأضواء بعد إطفائها: Die Lichter waren ausgeschaltet.',
      ),
      PassivDrillItem(
        id: 'zustand_perfekt_room',
        activeSentence: 'Jemand hat das Zimmer vorbereitet.',
        passiveSentence: 'Das Zimmer ist vorbereitet gewesen.',
        originalAgent: 'jemand',
        agentPreposition: 'von',
        agentCaseLabel: 'Dativ',
        akkusativObject: 'das Zimmer',
        nominativSubject: 'das Zimmer',
        auxiliaryForm: 'ist',
        partizipII: 'vorbereitet',
        type: PassivType.zustandspassiv,
        tense: PassivTense.perfekt,
        explanationAr:
            'Perfekt لـ Zustandspassiv يتكون من sein + Partizip II + gewesen. الجملة تركز على أن الغرفة كانت في حالة الجاهزية، لا على عملية تجهيزها.',
      ),
    ];

    final ids = drills.map((item) => item.id).toSet();
    if (ids.length != drills.length) {
      throw StateError('passiv drill bank contains duplicate ids');
    }

    for (final drill in drills) {
      final expectedCase =
          drill.agentPreposition == 'von' ? 'Dativ' : 'Akkusativ';
      if (drill.agentPreposition != 'von' &&
          drill.agentPreposition != 'durch') {
        throw StateError('unsupported agent preposition: ${drill.id}');
      }
      if (drill.agentCaseLabel != expectedCase) {
        throw StateError('agent case does not match preposition: ${drill.id}');
      }
      if (!drill.passiveSentence.contains(drill.auxiliaryForm) ||
          !drill.passiveSentence.contains(drill.partizipII)) {
        throw StateError('passive sentence does not match drill: ${drill.id}');
      }
    }

    return List<PassivDrillItem>.unmodifiable(drills);
  }
}
