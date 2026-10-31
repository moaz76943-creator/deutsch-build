/// A proverb entry linking German idioms to authentic Arabic wisdom.
class ProverbEntry {
  final String germanProverb;
  final String literalTranslationAr;
  final String arabicEquivalent;
  final String communicativeWisdom;
  final String cefrLevel;

  const ProverbEntry({
    required this.germanProverb,
    required this.literalTranslationAr,
    required this.arabicEquivalent,
    required this.communicativeWisdom,
    required this.cefrLevel,
  });
}

/// Curated bank of ethical, inspiring German proverbs matched with Arabic equivalents.
class GermanArabicProverbsBank {
  static const List<ProverbEntry> proverbs = [
    ProverbEntry(
      germanProverb: 'Übung macht den Meister.',
      literalTranslationAr: 'التمرين والممارسة يصنعان الأستاذ المعلم.',
      arabicEquivalent: 'التكرار والمثابرة أساس الإتقان والمهارة.',
      communicativeWisdom: 'الحث على المواظبة في التعلم لأن المهارة لا تأتي إلا بالتدريب المستمر.',
      cefrLevel: 'A2',
    ),
    ProverbEntry(
      germanProverb: 'Morgenstund hat Gold im Mund.',
      literalTranslationAr: 'ساعة الصباح الباكر في فمها ذهب.',
      arabicEquivalent: 'البركة في البكور، ومن بكّر نال الظفر.',
      communicativeWisdom: 'قيمة الاستيقاظ المبكر واستثمار ساعات الفجر الأولى في العمل والتعلم.',
      cefrLevel: 'B1',
    ),
    ProverbEntry(
      germanProverb: 'Wer rastet, der rostet.',
      literalTranslationAr: 'من يخلد للراحة التامة يصيبه الصدأ.',
      arabicEquivalent: 'الحركة بركة، والكسل يفسد الطاقات.',
      communicativeWisdom: 'التحفيز الدائم للنشاط الفكري والبدني المستمر دون ركون للكسل.',
      cefrLevel: 'B1',
    ),
    ProverbEntry(
      germanProverb: 'Aller Anfang ist schwer.',
      literalTranslationAr: 'كل بداية تكون شاقة وصعبة.',
      arabicEquivalent: 'البدايات شاقة لكن العاقبة حميدة لمن ثبت.',
      communicativeWisdom: 'مواساة المتعلم وتشجيعه على عدم الاستسلام في المراحل الأولى لتعلم اللغة.',
      cefrLevel: 'A2',
    ),
    ProverbEntry(
      germanProverb: 'Geduld bringt Rosen.',
      literalTranslationAr: 'الصبر يثمر ورداً وزهوراً.',
      arabicEquivalent: 'الصبر مفتاح الفرج، والصابر ينال المنى.',
      communicativeWisdom: 'دعوة للأناة والتحلي بالصبر حتى تنضج ثمار الجهد والعمل.',
      cefrLevel: 'B1',
    ),
  ];
}
