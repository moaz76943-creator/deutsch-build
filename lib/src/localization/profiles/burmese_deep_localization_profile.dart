import 'package:meta/meta.dart';
import '../matrix/universal_cross_lingual_matrix.dart';

/// Sovereign Deep Localization Profile for Burmese (မြန်မာစာ / Myanmaza).
///
/// Sino-Tibetan language (Lolo-Burmese branch) spoken by 33M+ people. Characterized by
/// circular Burmese script, 4 tones, strict SOV sentence architecture (verb-final mirror
/// to German subordinate clauses, Japanese, and Turkish), Wibat postpositional case
/// particles (ko, ah, e/ye), and polite particle hierarchies.
@immutable
class BurmeseDeepLocalizationProfile extends OmnidirectionalLanguageProfile {
  @override
  final String languageName;
  @override
  final String autonym;
  @override
  final String iso6391;
  @override
  final String iso6392or3;
  @override
  final TypologicalClassification typology;
  @override
  final CanonicalWordOrder primaryWordOrder;
  @override
  final GrammaticalAlignment alignment;
  @override
  final bool hasTones;
  @override
  final bool hasGrammaticalGender;

  final String writingDirection;
  final String primaryScript;
  final int toneCount;
  final Map<String, String> wibatCaseAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List> practicalDialoguePhrases;

  const BurmeseDeepLocalizationProfile({
    this.languageName = 'Burmese',
    this.autonym = 'မြန်မာစာ',
    this.iso6391 = 'my',
    this.iso6392or3 = 'mya',
    this.typology = TypologicalClassification.agglutinative,
    this.primaryWordOrder = CanonicalWordOrder.sov, // Strict verb-final!
    this.alignment = GrammaticalAlignment.nominativeAccusative,
    this.hasTones = true,
    this.hasGrammaticalGender = false,
    this.writingDirection = 'ltr',
    this.primaryScript = 'Burmese script (မြန်မာအက္ခရာ)',
    this.toneCount = 4, // Low, High, Creaky, Killed/Checked
    this.wibatCaseAlignment = const {
      'Subject Wibat (က / ka & သည် / thi)': 'Nominative subject particle (သူကဖတ်သည်). Maps to German Nominativ (er liest).',
      'Object Wibat (ကို / ko)': 'Accusative direct object particle (စာအုပ်ကိုဖတ်သည်). Maps to German Akkusativ (das Buch lesen).',
      'Dative Wibat (အား / ah & သို့ / thoh)': 'Recipient and directional particle (သူ့အားပေးသည်). Maps to German Dativ & "zu/nach".',
      'Genitive Wibat (၏ / e & ရဲ့ / ye)': 'Possessive connector (ဆရာ့ရဲ့စာအုပ်). Directly maps to German Genitiv (des Lehrers Buch).',
      'Instrumental Wibat (ဖြင့် / hpyin)': 'Means or instrument (ကားဖြင့်). Maps to German Dativ with preposition "mit".',
      'Locative Wibat (၌ / hnaik & မှာ / hma)': 'Static location (မြို့မှာ). Maps to German Dativ with prepositions "in" and "an".',
    },
    this.culturalIslamicLexicon = const {
      'မင်္ဂလာပါ / စလာမ်': 'Hallo / Begrüßung / Friede (Arabic: سلام)',
      'ကျေးဇူးတင်ပါတယ် / ကျေးဇူးအများကြီးတင်ပါတယ်': 'Danke / Vielen Dank',
      'ကျေးဇူးပြု၍': 'Bitte',
      'စာအုပ် / ကီသဗ်': 'Buch (Arabic: كتاب)',
      'ကျောင်း / မဒရဆာ': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'ဆရာ / ဆရာမ': 'Lehrer / Dozent',
      'ပညာ / သိပ္ပံ': 'Wissen / Wissenschaft',
      'တရားမျှတမှု': 'Gerechtigkeit',
      'ဝတ်ပြုဆုတောင်းခြင်း / ဆွလာတ်': 'Gebet / Salāt (Arabic: صلاة)',
      'ဟလာလ်': 'Erlaubt / Halal (Arabic: حلال)',
      'သူငယ်ချင်း': 'Freund',
      'ရေ': 'Wasser',
      'ပေါင်မုန့်': 'Brot / Nahrung (Portuguese loan: pão)',
      'အိမ်': 'Haus / Heim',
      'မြို့': 'Stadt',
      'ဆေးရုံ': 'Krankenhaus',
      'ဆေးဆိုင်': 'Apotheke',
      'ဗလီ / မတ်စ်ဂျစ်ဒ်': 'Moschee (Arabic: مسجد)',
    },
    this.germanPhoneticBridges = const {
      'sch /ʃ/': 'Direct 1:1 match to Burmese "ရှ" (/ʃ/) (ရှမ်း, Schule, schön).',
      'tsch /tʃ/': 'Direct match to Burmese aspirated "ချ" (/tʃʰ/) (ချစ်, Deutschland).',
      'z /ts/': 'German "z" is an affricate /ts/, practiced as compound "တ+စ" (tsunami -> Zeit).',
      'SOV Verb-Final Advantage': 'Burmese speakers intuitively master German subordinate clause verb-final placement (weil ich Deutsch lerne) because Burmese is strictly SOV with verbs always at the end!',
    },
    this.coreA1Vocabulary = const {
      'မင်္ဂလာပါ': 'Hallo / Guten Tag',
      'မင်္ဂလာနံနက်ခင်းပါ': 'Guten Morgen',
      'မင်္ဂလာနေ့လယ်ခင်းပါ': 'Guten Tag',
      'မင်္ဂလာညနေခင်းပါ': 'Guten Abend',
      'ကျေးဇူးအများကြီးတင်ပါတယ်': 'Vielen Dank',
      'ကျေးဇူးပြု၍': 'Bitte',
      'ဟုတ်ကဲ့ / ဟုတ်ပါတယ်': 'Ja',
      'မဟုတ်ပါ': 'Nein',
      'ကျွန်တော့်/ကျွန်မ နာမည်က ... ပါ': 'Mein Name ist ...',
      'ဘယ်ကလာပါသလဲ?': 'Woher kommen Sie?',
      'ကျွန်တော်/ကျွန်မ ... ကလာပါတယ်': 'Ich komme aus ...',
      'ရေ': 'Wasser',
      'ပေါင်မုန့်': 'Brot',
      'ဆေးရုံ': 'Krankenhaus',
      'ဆေးဆိုင်': 'Apotheke',
      'မီးရထားဘူတာ': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'burmese': 'မင်္ဂလာပါ! ဂျာမန်စကား ပြောတတ်ပါသလား?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'burmese': 'ဟုတ်ကဲ့၊ ကျွန်တော် အခု ဂျာမန်ဘာသာစကားကို လေ့လာနေပါတယ်။',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'burmese': 'ကျေးဇူးပြု၍ အနီးဆုံး ဆေးဆိုင် ဘယ်မှာရှိသလဲ ပြောပြပေးပါ?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'burmese': 'ကူညီပေးတဲ့အတွက် အများကြီး ကျေးဇူးတင်ပါတယ်!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates a Burmese Wibat postposition into its German case equivalent.
  String? getGermanCaseBridge(String wibatName) {
    for (final entry in wibatCaseAlignment.entries) {
      if (entry.key.toLowerCase().contains(wibatName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
