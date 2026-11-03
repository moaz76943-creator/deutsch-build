import 'package:meta/meta.dart';
import '../matrix/universal_cross_lingual_matrix.dart';

/// Sovereign Deep Localization Profile for Welsh (Cymraeg).
///
/// Brythonic Celtic language spoken by 900,000+ people in Wales and Chubut (Patagonia).
/// Characterized by VSO canonical constituent order, initial consonant mutations
/// (Treiglad Meddal, Trwynol, Llaes), voiceless lateral fricative 'Ll/ll' (/ɬ/),
/// inflected prepositions, and an omnidirectional cross-lingual transfer matrix.
@immutable
class WelshDeepLocalizationProfile extends OmnidirectionalLanguageProfile {
  @override
  final String languageName = 'Welsh';
  @override
  final String autonym = 'Cymraeg';
  @override
  final String iso6391 = 'cy';
  @override
  final String iso6392or3 = 'cym';
  @override
  final TypologicalClassification typology = TypologicalClassification.fusionalInflected;
  @override
  final CanonicalWordOrder primaryWordOrder = CanonicalWordOrder.vso; // Canonical VSO!
  @override
  final GrammaticalAlignment alignment = GrammaticalAlignment.nominativeAccusative;
  @override
  final bool hasTones = false;
  @override
  final bool hasGrammaticalGender = true; // Gwrywaidd & Benywaidd

  final String writingDirection = 'ltr';
  final String primaryScript = 'Latin (Welsh alphabet with circumflex accents)';
  final List<String> specialDigraphs = const ['ch', 'dd', 'ff', 'ng', 'll', 'ph', 'rh', 'th'];

  final Map<String, String> ipaPhoneticInventory = const {
    'll /ɬ/': 'Voiceless alveolar lateral fricative (e.g. llyfr, llan).',
    'ch /x/': 'Voiceless velar fricative (e.g. chwaer, uwch).',
    'dd /ð/': 'Voiced dental fricative (e.g. dyn, ffordd).',
    'th /θ/': 'Voiceless dental fricative (e.g. tŷ, byth).',
    'Treiglad Meddal (Soft Mutation)': 'Lenition of stops/liquids (c->g, p->b, t->d, b->f, d->dd, g->∅, m->f, ll->l, rh->r).',
    'Treiglad Trwynol (Nasal Mutation)': 'Nasalization (c->ngh, p->mh, t->nh, b->m, d->n, g->ng).',
    'Treiglad Llaes (Aspirate Mutation)': 'Spirantization (c->ch, p->ph, t->th).',
  };

  final Map<UniversalGrammaticalRole, String> universalRoleMapping = const {
    UniversalGrammaticalRole.subjectOrAgent: 'Goddrych (Subject in VSO: Mae\'r dyn yn darllen = The man is reading).',
    UniversalGrammaticalRole.directObjectOrPatient: 'Gwrthrych uniongyrchol (Direct object with soft mutation after verb).',
    UniversalGrammaticalRole.indirectObjectOrRecipient: 'Preposition "i" + inflected pronoun (iddynt hwy = to them).',
    UniversalGrammaticalRole.genitivePossessor: 'Genitive juxtaposition (llyfr y dyn = the man\'s book).',
    UniversalGrammaticalRole.instrumentalMeans: 'Preposition "gyda" / "â" (gyda\'r ffrind).',
    UniversalGrammaticalRole.locativePosition: 'Preposition "yn" + nasal mutation (yn y ddinas).',
    UniversalGrammaticalRole.ablativeSource: 'Preposition "o" + soft mutation (o\'r tŷ).',
    UniversalGrammaticalRole.allativeDirection: 'Preposition "i" + soft mutation (i\'r ysgol).',
    UniversalGrammaticalRole.vocativeAddress: 'Vocative with soft mutation (O ffrind!).',
  };

  final Map<String, String> universalLexicon = const {
    'greeting': 'Helo / Shwmae / Sut mae',
    'thanks': 'Diolch / Diolch yn fawr',
    'please': 'Os gwelwch yn dda',
    'book': 'Llyfr',
    'school': 'Ysgol',
    'teacher': 'Athro / Athrawes',
    'knowledge': 'Gwybodaeth / Gwyddoniaeth',
    'justice': 'Cyfiawnder',
    'prayer': 'Gweddi / Salāt',
    'halal': 'Halal / Cyfreithlon',
    'friend': 'Ffrind / Cyfaill',
    'water': 'Dŵr',
    'bread': 'Bara',
    'home': 'Tŷ / Cartref',
    'city': 'Dinas',
    'hospital': 'Ysbyty',
    'pharmacy': 'Fferyllfa',
    'placeOfWorship': 'Mosg / Eglwys',
  };

  final List<Map<String, String>> practicalDialoguePhrases = const [
    {
      'welsh': 'Shwmae! Sut dych chi?',
      'arabic': 'مرحباً! كيف حالك؟',
      'english': 'Hello! How are you?',
    },
    {
      'welsh': 'Diolch yn fawr iawn am eich help!',
      'arabic': 'شكراً جزيلاً على مساعدتك!',
      'english': 'Thank you very much for your help!',
    },
    {
      'welsh': 'Os gwelwch yn dda, ble mae\'r fferyllfa agosaf?',
      'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      'english': 'Please, where is the nearest pharmacy?',
    },
    {
      'welsh': 'Rydw i\'n dysgu ieithoedd ar hyn o bryd.',
      'arabic': 'أنا أتعلم اللغات حالياً.',
      'english': 'I am currently learning languages.',
    },
  ];

  const WelshDeepLocalizationProfile();
}
