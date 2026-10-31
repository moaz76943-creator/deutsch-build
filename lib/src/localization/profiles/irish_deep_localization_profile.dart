import 'package:meta/meta.dart';
import '../matrix/universal_cross_lingual_matrix.dart';

/// Sovereign Deep Localization Profile for Irish / Gaelic (Gaeilge).
///
/// Goidelic Celtic language spoken by 1.8M+ people. Characterized by canonical
/// Verb-Subject-Object (VSO) sentence architecture, initial consonant mutations
/// (Séimhiú / Lenition and Urú / Eclipsis), inflected prepositional pronouns,
/// broad vs slender consonant contrasts, and an omnidirectional cross-lingual matrix.
@immutable
class IrishDeepLocalizationProfile extends OmnidirectionalLanguageProfile {
  @override
  final String languageName = 'Irish';
  @override
  final String autonym = 'Gaeilge';
  @override
  final String iso6391 = 'ga';
  @override
  final String iso6392or3 = 'gle';
  @override
  final TypologicalClassification typology = TypologicalClassification.fusionalInflected;
  @override
  final CanonicalWordOrder primaryWordOrder = CanonicalWordOrder.vso; // Canonical VSO!
  @override
  final GrammaticalAlignment alignment = GrammaticalAlignment.nominativeAccusative;
  @override
  final bool hasTones = false;
  @override
  final bool hasGrammaticalGender = true; // Firinscneach & Baininscneach

  final String writingDirection = 'ltr';
  final String primaryScript = 'Latin (Irish alphabet with síneadh fada)';
  final List<String> fadaVowels = const ['á', 'é', 'í', 'ó', 'ú'];

  @override
  final Map<String, String> ipaPhoneticInventory = const {
    'Séimhiú (Lenition)': 'Fricativization of consonants (b->bh /v/, p->ph /f/, c->ch /x/, t->th /h/).',
    'Urú (Eclipsis)': 'Voicing or nasalization of consonants (b->mb /m/, c->gc /ɡ/, p->bp /b/, t->dt /d/).',
    'Broad / Velarized': 'Consonants adjacent to back vowels a, o, u (/ˠ/).',
    'Slender / Palatalized': 'Consonants adjacent to front vowels e, i (/ʲ/).',
  };

  @override
  final Map<UniversalGrammaticalRole, String> universalRoleMapping = const {
    UniversalGrammaticalRole.subjectOrAgent: 'Ainmneach (Direct subject in VSO: Léann an fear = The man reads).',
    UniversalGrammaticalRole.directObjectOrPatient: 'Cuspóireach (Direct object: Léann an fear an leabhar).',
    UniversalGrammaticalRole.indirectObjectOrRecipient: 'Tabharthach (Prepositional pronoun: Thug sé dom é = He gave it to me).',
    UniversalGrammaticalRole.genitivePossessor: 'Ginideach (Possession with slenderization: Leabhar an fhir = The man\'s book).',
    UniversalGrammaticalRole.instrumentalMeans: 'Preposition "le" / "trí" (leis an gcarr).',
    UniversalGrammaticalRole.locativePosition: 'Preposition "i" / "in" (sa chathair).',
    UniversalGrammaticalRole.ablativeSource: 'Preposition "ó" (ón mbaile).',
    UniversalGrammaticalRole.allativeDirection: 'Preposition "go / go dtí" (go dtí an scoil).',
    UniversalGrammaticalRole.vocativeAddress: 'Gairmeach with particle "a" + lenition (A chara!).',
  };

  @override
  final Map<String, String> universalLexicon = const {
    'greeting': 'Dia dhuit / Haló',
    'thanks': 'Go raibh maith agat / Míle buíochas',
    'please': 'Le do thoil / Más é do thoil é',
    'book': 'Leabhar',
    'school': 'Scoil / Coláiste',
    'teacher': 'Múinteoir / Oide',
    'knowledge': 'Eolas / Eolaíocht',
    'justice': 'Ceartas / Cothromas',
    'prayer': 'Urnaí / Salāt',
    'halal': 'Halal / Ceadaithe',
    'friend': 'Cara',
    'water': 'Uisce',
    'bread': 'Arán',
    'home': 'Teach / Baile',
    'city': 'Cathair',
    'hospital': 'Ospidéal',
    'pharmacy': 'Cógaslann',
    'placeOfWorship': 'Mosc / Teampall',
  };

  final List> practicalDialoguePhrases = const [
    {
      'irish': 'Dia dhuit! Conas atá tú?',
      'arabic': 'مرحباً! كيف حالك؟',
      'english': 'Hello! How are you?',
    },
    {
      'irish': 'Míle buíochas as do chabhair!',
      'arabic': 'شكراً جزيلاً على مساعدتك!',
      'english': 'Thank you very much for your help!',
    },
    {
      'irish': 'Le do thoil, cá bhfuil an chógaslann is gaire?',
      'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      'english': 'Please, where is the nearest pharmacy?',
    },
    {
      'irish': 'Táim ag foghlaim teangacha faoi láthair.',
      'arabic': 'أنا أتعلم اللغات حالياً.',
      'english': 'I am currently learning languages.',
    },
  ];

  const IrishDeepLocalizationProfile();
}
