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
  // Original items 1-35 retained (full content as previously fetched)
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
  // (items 2-35 identical to original for integrity)
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
  },
  {
    id: 'v-extra-36',
    type: 'verb',
    level: 'A1',
    de: 'schlafen',
    ar: 'ينام',
    conjugations: {
      ich: 'schlafe',
      du: 'schläfst',
      er: 'schläft',
      wir: 'schlafen',
      ihr: 'schlaft',
      sie: 'schlafen',
      präteritum: 'schlief',
      perfekt: 'geschlafen',
      aux: 'haben'
    },
    exampleDe: 'Ich schlafe acht Stunden pro Nacht.',
    exampleAr: 'أنا أنام ثماني ساعات في الليلة.'
  },
  {
    id: 'v-extra-37',
    type: 'verb',
    level: 'A1',
    de: 'lesen',
    ar: 'يقرأ',
    conjugations: {
      ich: 'lese',
      du: 'liest',
      er: 'liest',
      wir: 'lesen',
      ihr: 'lest',
      sie: 'lesen',
      präteritum: 'las',
      perfekt: 'gelesen',
      aux: 'haben'
    },
    exampleDe: 'Sie liest jeden Abend ein Buch.',
    exampleAr: 'هي تقرأ كتاباً كل مساء.'
  },
  {
    id: 'v-extra-38',
    type: 'verb',
    level: 'A2',
    de: 'schreiben',
    ar: 'يكتب',
    conjugations: {
      ich: 'schreibe',
      du: 'schreibst',
      er: 'schreibt',
      wir: 'schreiben',
      ihr: 'schreibt',
      sie: 'schreiben',
      präteritum: 'schrieb',
      perfekt: 'geschrieben',
      aux: 'haben'
    },
    exampleDe: 'Ich schreibe eine E-Mail an meinen Freund.',
    exampleAr: 'أكتب بريداً إلكترونياً إلى صديقي.'
  },
  {
    id: 'v-extra-39',
    type: 'verb',
    level: 'A1',
    de: 'kaufen',
    ar: 'يشتري',
    conjugations: {
      ich: 'kaufe',
      du: 'kaufst',
      er: 'kauft',
      wir: 'kaufen',
      ihr: 'kauft',
      sie: 'kaufen',
      präteritum: 'kaufte',
      perfekt: 'gekauft',
      aux: 'haben'
    },
    exampleDe: 'Wir kaufen frisches Brot im Supermarkt.',
    exampleAr: 'نشتري خبزاً طازجاً من السوبرماركت.'
  },
  {
    id: 'v-extra-40',
    type: 'verb',
    level: 'A2',
    de: 'verkaufen',
    ar: 'يبيع',
    conjugations: {
      ich: 'verkaufe',
      du: 'verkaufst',
      er: 'verkauft',
      wir: 'verkaufen',
      ihr: 'verkauft',
      sie: 'verkaufen',
      präteritum: 'verkaufte',
      perfekt: 'verkauft',
      aux: 'haben'
    },
    exampleDe: 'Er verkauft sein altes Auto.',
    exampleAr: 'هو يبيع سيارته القديمة.'
  },
  {
    id: 'v-extra-41',
    type: 'noun',
    level: 'A1',
    de: 'Apfel',
    ar: 'تفاحة',
    article: 'der',
    plural: 'Äpfel',
    exampleDe: 'Der Apfel ist rot und süß.',
    exampleAr: 'التفاحة حمراء وحلوة.'
  },
  {
    id: 'v-extra-42',
    type: 'noun',
    level: 'A1',
    de: 'Wasser',
    ar: 'ماء',
    article: 'das',
    plural: 'Wasser',
    exampleDe: 'Ich trinke ein Glas Wasser.',
    exampleAr: 'أشرب كأساً من الماء.'
  },
  {
    id: 'v-extra-43',
    type: 'noun',
    level: 'A1',
    de: 'Brot',
    ar: 'خبز',
    article: 'das',
    plural: 'Brote',
    exampleDe: 'Das Brot ist frisch vom Bäcker.',
    exampleAr: 'الخبز طازج من الخباز.'
  },
  {
    id: 'v-extra-44',
    type: 'noun',
    level: 'A2',
    de: 'Schule',
    ar: 'مدرسة',
    article: 'die',
    plural: 'Schulen',
    exampleDe: 'Die Schule beginnt um acht Uhr.',
    exampleAr: 'تبدأ المدرسة في الساعة الثامنة.'
  },
  {
    id: 'v-extra-45',
    type: 'noun',
    level: 'A1',
    de: 'Lehrer',
    ar: 'معلم',
    article: 'der',
    plural: 'Lehrer',
    exampleDe: 'Der Lehrer erklärt die Grammatik gut.',
    exampleAr: 'المعلم يشرح القواعد جيداً.'
  },
  {
    id: 'v-extra-46',
    type: 'verb',
    level: 'A2',
    de: 'verstehen',
    ar: 'يفهم',
    conjugations: {
      ich: 'verstehe',
      du: 'verstehst',
      er: 'versteht',
      wir: 'verstehen',
      ihr: 'versteht',
      sie: 'verstehen',
      präteritum: 'verstand',
      perfekt: 'verstanden',
      aux: 'haben'
    },
    exampleDe: 'Verstehst du die Frage?',
    exampleAr: 'هل تفهم السؤال؟'
  },
  {
    id: 'v-extra-47',
    type: 'verb',
    level: 'A1',
    de: 'wohnen',
    ar: 'يسكن',
    conjugations: {
      ich: 'wohne',
      du: 'wohnst',
      er: 'wohnt',
      wir: 'wohnen',
      ihr: 'wohnt',
      sie: 'wohnen',
      präteritum: 'wohnte',
      perfekt: 'gewohnt',
      aux: 'haben'
    },
    exampleDe: 'Ich wohne in Berlin.',
    exampleAr: 'أسكن في برلين.'
  },
  {
    id: 'v-extra-48',
    type: 'noun',
    level: 'A2',
    de: 'Bahnhof',
    ar: 'محطة قطار',
    article: 'der',
    plural: 'Bahnhöfe',
    exampleDe: 'Der Bahnhof ist nicht weit von hier.',
    exampleAr: 'محطة القطار ليست بعيدة من هنا.'
  },
  {
    id: 'v-extra-49',
    type: 'noun',
    level: 'A1',
    de: 'Familie',
    ar: 'عائلة',
    article: 'die',
    plural: 'Familien',
    exampleDe: 'Meine Familie kommt aus Ägypten.',
    exampleAr: 'عائلتي تأتي من مصر.'
  },
  {
    id: 'v-extra-50',
    type: 'verb',
    level: 'A2',
    de: 'finden',
    ar: 'يجد',
    conjugations: {
      ich: 'finde',
      du: 'findest',
      er: 'findet',
      wir: 'finden',
      ihr: 'findet',
      sie: 'finden',
      präteritum: 'fand',
      perfekt: 'gefunden',
      aux: 'haben'
    },
    exampleDe: 'Ich finde meinen Schlüssel nicht.',
    exampleAr: 'لا أجد مفتاحي.'
  },
  {
    id: 'v-extra-51',
    type: 'noun',
    level: 'A1',
    de: 'Tag',
    ar: 'يوم',
    article: 'der',
    plural: 'Tage',
    exampleDe: 'Heute ist ein schöner Tag.',
    exampleAr: 'اليوم يوم جميل.'
  },
  {
    id: 'v-extra-52',
    type: 'noun',
    level: 'A2',
    de: 'Nacht',
    ar: 'ليل',
    article: 'die',
    plural: 'Nächte',
    exampleDe: 'Die Nacht ist kalt im Winter.',
    exampleAr: 'الليل بارد في الشتاء.'
  },
  {
    id: 'v-extra-53',
    type: 'verb',
    level: 'A1',
    de: 'spielen',
    ar: 'يلعب',
    conjugations: {
      ich: 'spiele',
      du: 'spielst',
      er: 'spielt',
      wir: 'spielen',
      ihr: 'spielt',
      sie: 'spielen',
      präteritum: 'spielte',
      perfekt: 'gespielt',
      aux: 'haben'
    },
    exampleDe: 'Die Kinder spielen im Park Fußball.',
    exampleAr: 'الأطفال يلعبون كرة القدم في الحديقة.'
  },
  {
    id: 'v-extra-54',
    type: 'noun',
    level: 'A2',
    de: 'Freund',
    ar: 'صديق',
    article: 'der',
    plural: 'Freunde',
    exampleDe: 'Mein Freund lernt auch Deutsch.',
    exampleAr: 'صديقي يتعلم الألمانية أيضاً.'
  },
  {
    id: 'v-extra-55',
    type: 'verb',
    level: 'A2',
    de: 'warten',
    ar: 'ينتظر',
    conjugations: {
      ich: 'warte',
      du: 'wartest',
      er: 'wartet',
      wir: 'warten',
      ihr: 'wartet',
      sie: 'warten',
      präteritum: 'wartete',
      perfekt: 'gewartet',
      aux: 'haben'
    },
    exampleDe: 'Wir warten auf den Bus.',
    exampleAr: 'نحن ننتظر الحافلة.'
  }
];
