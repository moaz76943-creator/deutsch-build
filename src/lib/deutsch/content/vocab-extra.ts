// vocab-extra.ts — A1/A2 vocabulary expansion for Deutsch بالعربي
// Auth/DB remain OFF. Offline content only.

export interface VerbConjugation {
  ich: string;
  du: string;
  er: string;
  wir: string;
  ihr: string;
  sie: string;
  präteritum: string;
  perfekt: string;
  aux: 'haben' | 'sein';
}

export interface VocabExtraItem {
  id: string;
  type: 'verb' | 'noun';
  level: 'A1' | 'A2';
  de: string;
  ar: string;
  article?: 'der' | 'die' | 'das';
  plural?: string;
  conjugations?: VerbConjugation;
  exampleDe: string;
  exampleAr: string;
}

export const vocabExtra: VocabExtraItem[] = [
  {
    id: 'v-extra-1',
    type: 'verb',
    level: 'A1',
    de: 'sein',
    ar: 'يكون',
    conjugations: {
      ich: 'bin',
      du: 'bist',
      er: 'ist',
      wir: 'sind',
      ihr: 'seid',
      sie: 'sind',
      präteritum: 'war',
      perfekt: 'gewesen',
      aux: 'sein'
    },
    exampleDe: 'Ich bin müde nach der Arbeit.',
    exampleAr: 'أنا متعب بعد العمل.'
  },
  {
    id: 'v-extra-2',
    type: 'verb',
    level: 'A1',
    de: 'haben',
    ar: 'يملك / لديه',
    conjugations: {
      ich: 'habe',
      du: 'hast',
      er: 'hat',
      wir: 'haben',
      ihr: 'habt',
      sie: 'haben',
      präteritum: 'hatte',
      perfekt: 'gehabt',
      aux: 'haben'
    },
    exampleDe: 'Wir haben heute keine Zeit.',
    exampleAr: 'ليس لدينا وقت اليوم.'
  },
  {
    id: 'v-extra-3',
    type: 'verb',
    level: 'A1',
    de: 'gehen',
    ar: 'يذهب',
    conjugations: {
      ich: 'gehe',
      du: 'gehst',
      er: 'geht',
      wir: 'gehen',
      ihr: 'geht',
      sie: 'gehen',
      präteritum: 'ging',
      perfekt: 'gegangen',
      aux: 'sein'
    },
    exampleDe: 'Sie geht jeden Morgen zur Schule.',
    exampleAr: 'هي تذهب كل صباح إلى المدرسة.'
  },
  {
    id: 'v-extra-4',
    type: 'verb',
    level: 'A1',
    de: 'kommen',
    ar: 'يأتي',
    conjugations: {
      ich: 'komme',
      du: 'kommst',
      er: 'kommt',
      wir: 'kommen',
      ihr: 'kommt',
      sie: 'kommen',
      präteritum: 'kam',
      perfekt: 'gekommen',
      aux: 'sein'
    },
    exampleDe: 'Wann kommst du nach Hause?',
    exampleAr: 'متى تأتي إلى المنزل؟'
  },
  {
    id: 'v-extra-5',
    type: 'verb',
    level: 'A1',
    de: 'machen',
    ar: 'يفعل / يصنع',
    conjugations: {
      ich: 'mache',
      du: 'machst',
      er: 'macht',
      wir: 'machen',
      ihr: 'macht',
      sie: 'machen',
      präteritum: 'machte',
      perfekt: 'gemacht',
      aux: 'haben'
    },
    exampleDe: 'Was machst du am Wochenende?',
    exampleAr: 'ماذا تفعل في عطلة نهاية الأسبوع؟'
  },
  {
    id: 'v-extra-6',
    type: 'verb',
    level: 'A1',
    de: 'essen',
    ar: 'يأكل',
    conjugations: {
      ich: 'esse',
      du: 'isst',
      er: 'isst',
      wir: 'essen',
      ihr: 'esst',
      sie: 'essen',
      präteritum: 'aß',
      perfekt: 'gegessen',
      aux: 'haben'
    },
    exampleDe: 'Wir essen zusammen zu Abend.',
    exampleAr: 'نحن نتناول العشاء معاً.'
  },
  {
    id: 'v-extra-7',
    type: 'verb',
    level: 'A1',
    de: 'trinken',
    ar: 'يشرب',
    conjugations: {
      ich: 'trinke',
      du: 'trinkst',
      er: 'trinkt',
      wir: 'trinken',
      ihr: 'trinkt',
      sie: 'trinken',
      präteritum: 'trank',
      perfekt: 'getrunken',
      aux: 'haben'
    },
    exampleDe: 'Ich trinke gerne Kaffee am Morgen.',
    exampleAr: 'أحب شرب القهوة في الصباح.'
  },
  {
    id: 'v-extra-8',
    type: 'verb',
    level: 'A1',
    de: 'sprechen',
    ar: 'يتكلم',
    conjugations: {
      ich: 'spreche',
      du: 'sprichst',
      er: 'spricht',
      wir: 'sprechen',
      ihr: 'sprecht',
      sie: 'sprechen',
      präteritum: 'sprach',
      perfekt: 'gesprochen',
      aux: 'haben'
    },
    exampleDe: 'Er spricht drei Sprachen.',
    exampleAr: 'هو يتحدث ثلاث لغات.'
  },
  {
    id: 'v-extra-9',
    type: 'verb',
    level: 'A2',
    de: 'bleiben',
    ar: 'يبقى',
    conjugations: {
      ich: 'bleibe',
      du: 'bleibst',
      er: 'bleibt',
      wir: 'bleiben',
      ihr: 'bleibt',
      sie: 'bleiben',
      präteritum: 'blieb',
      perfekt: 'geblieben',
      aux: 'sein'
    },
    exampleDe: 'Wir bleiben heute zu Hause.',
    exampleAr: 'سنبقى في المنزل اليوم.'
  },
  {
    id: 'v-extra-10',
    type: 'verb',
    level: 'A2',
    de: 'geben',
    ar: 'يعطي',
    conjugations: {
      ich: 'gebe',
      du: 'gibst',
      er: 'gibt',
      wir: 'geben',
      ihr: 'gebt',
      sie: 'geben',
      präteritum: 'gab',
      perfekt: 'gegeben',
      aux: 'haben'
    },
    exampleDe: 'Kannst du mir bitte das Buch geben?',
    exampleAr: 'هل يمكنك أن تعطيني الكتاب من فضلك؟'
  },
  {
    id: 'v-extra-11',
    type: 'verb',
    level: 'A2',
    de: 'nehmen',
    ar: 'يأخذ',
    conjugations: {
      ich: 'nehme',
      du: 'nimmst',
      er: 'nimmt',
      wir: 'nehmen',
      ihr: 'nehmt',
      sie: 'nehmen',
      präteritum: 'nahm',
      perfekt: 'genommen',
      aux: 'haben'
    },
    exampleDe: 'Ich nehme den Bus zur Arbeit.',
    exampleAr: 'أنا آخذ الحافلة إلى العمل.'
  },
  {
    id: 'v-extra-12',
    type: 'verb',
    level: 'A2',
    de: 'bringen',
    ar: 'يجلب',
    conjugations: {
      ich: 'bringe',
      du: 'bringst',
      er: 'bringt',
      wir: 'bringen',
      ihr: 'bringt',
      sie: 'bringen',
      präteritum: 'brachte',
      perfekt: 'gebracht',
      aux: 'haben'
    },
    exampleDe: 'Sie bringt die Kinder zur Schule.',
    exampleAr: 'هي تجلب الأطفال إلى المدرسة.'
  },
  {
    id: 'v-extra-13',
    type: 'verb',
    level: 'A1',
    de: 'sehen',
    ar: 'يرى',
    conjugations: {
      ich: 'sehe',
      du: 'siehst',
      er: 'sieht',
      wir: 'sehen',
      ihr: 'seht',
      sie: 'sehen',
      präteritum: 'sah',
      perfekt: 'gesehen',
      aux: 'haben'
    },
    exampleDe: 'Ich sehe den Film heute Abend.',
    exampleAr: 'سأشاهد الفيلم الليلة.'
  },
  {
    id: 'v-extra-14',
    type: 'verb',
    level: 'A1',
    de: 'hören',
    ar: 'يسمع',
    conjugations: {
      ich: 'höre',
      du: 'hörst',
      er: 'hört',
      wir: 'hören',
      ihr: 'hört',
      sie: 'hören',
      präteritum: 'hörte',
      perfekt: 'gehört',
      aux: 'haben'
    },
    exampleDe: 'Hörst du die Musik?',
    exampleAr: 'هل تسمع الموسيقى؟'
  },
  {
    id: 'v-extra-15',
    type: 'verb',
    level: 'A2',
    de: 'helfen',
    ar: 'يساعد',
    conjugations: {
      ich: 'helfe',
      du: 'hilfst',
      er: 'hilft',
      wir: 'helfen',
      ihr: 'helft',
      sie: 'helfen',
      präteritum: 'half',
      perfekt: 'geholfen',
      aux: 'haben'
    },
    exampleDe: 'Kannst du mir beim Lernen helfen?',
    exampleAr: 'هل يمكنك مساعدتي في الدراسة؟'
  },
  {
    id: 'v-extra-16',
    type: 'noun',
    level: 'A1',
    de: 'Haus',
    ar: 'منزل',
    article: 'das',
    plural: 'Häuser',
    exampleDe: 'Das Haus ist groß und schön.',
    exampleAr: 'المنزل كبير وجميل.'
  },
  {
    id: 'v-extra-17',
    type: 'noun',
    level: 'A1',
    de: 'Auto',
    ar: 'سيارة',
    article: 'das',
    plural: 'Autos',
    exampleDe: 'Das Auto ist neu.',
    exampleAr: 'السيارة جديدة.'
  },
  {
    id: 'v-extra-18',
    type: 'noun',
    level: 'A1',
    de: 'Buch',
    ar: 'كتاب',
    article: 'das',
    plural: 'Bücher',
    exampleDe: 'Ich lese ein interessantes Buch.',
    exampleAr: 'أقرأ كتاباً مثيراً للاهتمام.'
  },
  {
    id: 'v-extra-19',
    type: 'noun',
    level: 'A1',
    de: 'Mann',
    ar: 'رجل',
    article: 'der',
    plural: 'Männer',
    exampleDe: 'Der Mann arbeitet im Büro.',
    exampleAr: 'الرجل يعمل في المكتب.'
  },
  {
    id: 'v-extra-20',
    type: 'noun',
    level: 'A1',
    de: 'Frau',
    ar: 'امرأة',
    article: 'die',
    plural: 'Frauen',
    exampleDe: 'Die Frau spricht Arabisch und Deutsch.',
    exampleAr: 'المرأة تتحدث العربية والألمانية.'
  },
  {
    id: 'v-extra-21',
    type: 'noun',
    level: 'A1',
    de: 'Kind',
    ar: 'طفل',
    article: 'das',
    plural: 'Kinder',
    exampleDe: 'Das Kind spielt im Garten.',
    exampleAr: 'الطفل يلعب في الحديقة.'
  },
  {
    id: 'v-extra-22',
    type: 'noun',
    level: 'A1',
    de: 'Stadt',
    ar: 'مدينة',
    article: 'die',
    plural: 'Städte',
    exampleDe: 'Die Stadt ist sehr groß.',
    exampleAr: 'المدينة كبيرة جداً.'
  },
  {
    id: 'v-extra-23',
    type: 'noun',
    level: 'A1',
    de: 'Straße',
    ar: 'شارع',
    article: 'die',
    plural: 'Straßen',
    exampleDe: 'Die Straße ist lang und breit.',
    exampleAr: 'الشارع طويل وواسع.'
  },
  {
    id: 'v-extra-24',
    type: 'noun',
    level: 'A2',
    de: 'Lampe',
    ar: 'مصباح',
    article: 'die',
    plural: 'Lampen',
    exampleDe: 'Die Lampe leuchtet hell.',
    exampleAr: 'المصباح يضيء بقوة.'
  },
  {
    id: 'v-extra-25',
    type: 'noun',
    level: 'A2',
    de: 'Computer',
    ar: 'حاسوب',
    article: 'der',
    plural: 'Computer',
    exampleDe: 'Der Computer ist schnell.',
    exampleAr: 'الحاسوب سريع.'
  },
  {
    id: 'v-extra-26',
    type: 'noun',
    level: 'A1',
    de: 'Handy',
    ar: 'هاتف محمول',
    article: 'das',
    plural: 'Handys',
    exampleDe: 'Wo ist mein Handy?',
    exampleAr: 'أين هاتفي المحمول؟'
  },
  {
    id: 'v-extra-27',
    type: 'noun',
    level: 'A1',
    de: 'Bett',
    ar: 'سرير',
    article: 'das',
    plural: 'Betten',
    exampleDe: 'Das Bett ist bequem.',
    exampleAr: 'السرير مريح.'
  },
  {
    id: 'v-extra-28',
    type: 'noun',
    level: 'A1',
    de: 'Küche',
    ar: 'مطبخ',
    article: 'die',
    plural: 'Küchen',
    exampleDe: 'Die Küche ist sauber.',
    exampleAr: 'المطبخ نظيف.'
  },
  {
    id: 'v-extra-29',
    type: 'noun',
    level: 'A1',
    de: 'Park',
    ar: 'حديقة عامة',
    article: 'der',
    plural: 'Parks',
    exampleDe: 'Wir gehen in den Park.',
    exampleAr: 'نذهب إلى الحديقة العامة.'
  },
  {
    id: 'v-extra-30',
    type: 'noun',
    level: 'A2',
    de: 'Museum',
    ar: 'متحف',
    article: 'das',
    plural: 'Museen',
    exampleDe: 'Das Museum ist am Sonntag geschlossen.',
    exampleAr: 'المتحف مغلق يوم الأحد.'
  },
  {
    id: 'v-extra-31',
    type: 'noun',
    level: 'A1',
    de: 'Restaurant',
    ar: 'مطعم',
    article: 'das',
    plural: 'Restaurants',
    exampleDe: 'Das Restaurant hat gutes Essen.',
    exampleAr: 'المطعم يقدم طعاماً جيداً.'
  },
  {
    id: 'v-extra-32',
    type: 'noun',
    level: 'A1',
    de: 'Hotel',
    ar: 'فندق',
    article: 'das',
    plural: 'Hotels',
    exampleDe: 'Wir übernachten im Hotel.',
    exampleAr: 'نبيت في الفندق.'
  },
  {
    id: 'v-extra-33',
    type: 'noun',
    level: 'A1',
    de: 'Uhr',
    ar: 'ساعة',
    article: 'die',
    plural: 'Uhren',
    exampleDe: 'Wie spät ist es? Die Uhr zeigt acht.',
    exampleAr: 'كم الساعة؟ الساعة تشير إلى الثامنة.'
  },
  {
    id: 'v-extra-34',
    type: 'verb',
    level: 'A1',
    de: 'arbeiten',
    ar: 'يعمل',
    conjugations: {
      ich: 'arbeite',
      du: 'arbeitest',
      er: 'arbeitet',
      wir: 'arbeiten',
      ihr: 'arbeitet',
      sie: 'arbeiten',
      präteritum: 'arbeitete',
      perfekt: 'gearbeitet',
      aux: 'haben'
    },
    exampleDe: 'Ich arbeite von Montag bis Freitag.',
    exampleAr: 'أعمل من الاثنين إلى الجمعة.'
  },
  {
    id: 'v-extra-35',
    type: 'verb',
    level: 'A2',
    de: 'lernen',
    ar: 'يتعلم',
    conjugations: {
      ich: 'lerne',
      du: 'lernst',
      er: 'lernt',
      wir: 'lernen',
      ihr: 'lernt',
      sie: 'lernen',
      präteritum: 'lernte',
      perfekt: 'gelernt',
      aux: 'haben'
    },
    exampleDe: 'Wir lernen Deutsch zusammen.',
    exampleAr: 'نتعلم الألمانية معاً.'
  }
];
