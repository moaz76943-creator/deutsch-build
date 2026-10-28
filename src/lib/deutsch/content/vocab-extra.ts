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
  // Verbs A1/A2
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
    exampleDe: 'Ich bin müde heute.',
    exampleAr: 'أنا متعب اليوم.'
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
    exampleDe: 'Ich habe einen Bruder.',
    exampleAr: 'لدي أخ.'
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
    exampleDe: 'Wir gehen zur Schule.',
    exampleAr: 'نحن نذهب إلى المدرسة.'
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
    exampleDe: 'Er kommt aus Ägypten.',
    exampleAr: 'هو يأتي من مصر.'
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
    exampleDe: 'Was machst du heute?',
    exampleAr: 'ماذا تفعل اليوم؟'
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
    exampleDe: 'Ich esse Brot zum Frühstück.',
    exampleAr: 'آكل خبزاً على الإفطار.'
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
    exampleDe: 'Trinkst du Kaffee oder Tee?',
    exampleAr: 'هل تشرب قهوة أم شاي؟'
  },
  {
    id: 'v-extra-8',
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
    exampleDe: 'Ich sehe den Film.',
    exampleAr: 'أنا أشاهد الفيلم.'
  },
  {
    id: 'v-extra-9',
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
    exampleDe: 'Sie spricht Arabisch und Deutsch.',
    exampleAr: 'هي تتكلم العربية والألمانية.'
  },
  {
    id: 'v-extra-10',
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
    exampleDe: 'Wir wohnen in Berlin.',
    exampleAr: 'نحن نسكن في برلين.'
  },
  {
    id: 'v-extra-11',
    type: 'verb',
    level: 'A2',
    de: 'fahren',
    ar: 'يقود / يسافر',
    conjugations: {
      ich: 'fahre',
      du: 'fährst',
      er: 'fährt',
      wir: 'fahren',
      ihr: 'fahrt',
      sie: 'fahren',
      präteritum: 'fuhr',
      perfekt: 'gefahren',
      aux: 'sein'
    },
    exampleDe: 'Ich fahre mit dem Zug.',
    exampleAr: 'أسافر بالقطار.'
  },
  {
    id: 'v-extra-12',
    type: 'verb',
    level: 'A2',
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
    exampleDe: 'Sie kauft Gemüse auf dem Markt.',
    exampleAr: 'هي تشتري خضروات من السوق.'
  },
  {
    id: 'v-extra-13',
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
    exampleDe: 'Ich lerne jeden Tag Deutsch.',
    exampleAr: 'أتعلم الألمانية كل يوم.'
  },
  {
    id: 'v-extra-14',
    type: 'verb',
    level: 'A2',
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
    exampleDe: 'Er arbeitet in einem Büro.',
    exampleAr: 'هو يعمل في مكتب.'
  },
  {
    id: 'v-extra-15',
    type: 'verb',
    level: 'A2',
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
    exampleDe: 'Die Kinder schlafen schon.',
    exampleAr: 'الأطفال ينامون بالفعل.'
  },
  {
    id: 'v-extra-16',
    type: 'verb',
    level: 'A2',
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
    exampleDe: 'Ich lese ein interessantes Buch.',
    exampleAr: 'أقرأ كتاباً مثيراً للاهتمام.'
  },
  {
    id: 'v-extra-17',
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
    exampleDe: 'Sie schreibt eine E-Mail.',
    exampleAr: 'هي تكتب بريداً إلكترونياً.'
  },
  {
    id: 'v-extra-18',
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
    id: 'v-extra-19',
    type: 'verb',
    level: 'A1',
    de: 'heißen',
    ar: 'يُسمى',
    conjugations: {
      ich: 'heiße',
      du: 'heißt',
      er: 'heißt',
      wir: 'heißen',
      ihr: 'heißt',
      sie: 'heißen',
      präteritum: 'hieß',
      perfekt: 'geheißen',
      aux: 'haben'
    },
    exampleDe: 'Wie heißt du?',
    exampleAr: 'ما اسمك؟'
  },
  {
    id: 'v-extra-20',
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

  // Nouns A1/A2
  {
    id: 'v-extra-21',
    type: 'noun',
    level: 'A1',
    de: 'Mann',
    article: 'der',
    plural: 'Männer',
    ar: 'رجل',
    exampleDe: 'Der Mann liest die Zeitung.',
    exampleAr: 'الرجل يقرأ الجريدة.'
  },
  {
    id: 'v-extra-22',
    type: 'noun',
    level: 'A1',
    de: 'Frau',
    article: 'die',
    plural: 'Frauen',
    ar: 'امرأة',
    exampleDe: 'Die Frau kauft Brot.',
    exampleAr: 'المرأة تشتري خبزاً.'
  },
  {
    id: 'v-extra-23',
    type: 'noun',
    level: 'A1',
    de: 'Kind',
    article: 'das',
    plural: 'Kinder',
    ar: 'طفل',
    exampleDe: 'Das Kind spielt im Garten.',
    exampleAr: 'الطفل يلعب في الحديقة.'
  },
  {
    id: 'v-extra-24',
    type: 'noun',
    level: 'A1',
    de: 'Haus',
    article: 'das',
    plural: 'Häuser',
    ar: 'بيت',
    exampleDe: 'Das Haus ist groß und schön.',
    exampleAr: 'البيت كبير وجميل.'
  },
  {
    id: 'v-extra-25',
    type: 'noun',
    level: 'A1',
    de: 'Auto',
    article: 'das',
    plural: 'Autos',
    ar: 'سيارة',
    exampleDe: 'Das Auto ist neu.',
    exampleAr: 'السيارة جديدة.'
  },
  {
    id: 'v-extra-26',
    type: 'noun',
    level: 'A1',
    de: 'Buch',
    article: 'das',
    plural: 'Bücher',
    ar: 'كتاب',
    exampleDe: 'Ich lese ein interessantes Buch.',
    exampleAr: 'أقرأ كتاباً مثيراً للاهتمام.'
  },
  {
    id: 'v-extra-27',
    type: 'noun',
    level: 'A1',
    de: 'Schule',
    article: 'die',
    plural: 'Schulen',
    ar: 'مدرسة',
    exampleDe: 'Die Schule beginnt um acht Uhr.',
    exampleAr: 'تبدأ المدرسة في الساعة الثامنة.'
  },
  {
    id: 'v-extra-28',
    type: 'noun',
    level: 'A1',
    de: 'Tag',
    article: 'der',
    plural: 'Tage',
    ar: 'يوم',
    exampleDe: 'Heute ist ein schöner Tag.',
    exampleAr: 'اليوم يوم جميل.'
  },
  {
    id: 'v-extra-29',
    type: 'noun',
    level: 'A1',
    de: 'Wasser',
    article: 'das',
    plural: 'Wässer',
    ar: 'ماء',
    exampleDe: 'Ich trinke gerne Wasser.',
    exampleAr: 'أحب شرب الماء.'
  },
  {
    id: 'v-extra-30',
    type: 'noun',
    level: 'A1',
    de: 'Brot',
    article: 'das',
    plural: 'Brote',
    ar: 'خبز',
    exampleDe: 'Das Brot ist frisch.',
    exampleAr: 'الخبز طازج.'
  },
  {
    id: 'v-extra-31',
    type: 'noun',
    level: 'A2',
    de: 'Freund',
    article: 'der',
    plural: 'Freunde',
    ar: 'صديق',
    exampleDe: 'Mein Freund kommt heute Abend.',
    exampleAr: 'صديقي يأتي هذا المساء.'
  },
  {
    id: 'v-extra-32',
    type: 'noun',
    level: 'A2',
    de: 'Stadt',
    article: 'die',
    plural: 'Städte',
    ar: 'مدينة',
    exampleDe: 'Die Stadt ist sehr groß.',
    exampleAr: 'المدينة كبيرة جداً.'
  },
  {
    id: 'v-extra-33',
    type: 'noun',
    level: 'A2',
    de: 'Arbeit',
    article: 'die',
    plural: 'Arbeiten',
    ar: 'عمل',
    exampleDe: 'Die Arbeit beginnt um neun.',
    exampleAr: 'يبدأ العمل في الساعة التاسعة.'
  },
  {
    id: 'v-extra-34',
    type: 'noun',
    level: 'A2',
    de: 'Zeit',
    article: 'die',
    plural: 'Zeiten',
    ar: 'وقت',
    exampleDe: 'Ich habe keine Zeit heute.',
    exampleAr: 'ليس لدي وقت اليوم.'
  },
  {
    id: 'v-extra-35',
    type: 'noun',
    level: 'A2',
    de: 'Geld',
    article: 'das',
    plural: 'Gelder',
    ar: 'مال',
    exampleDe: 'Das Geld reicht nicht.',
    exampleAr: 'المال لا يكفي.'
  },
  // New A1/A2 items added 2026-10-28 session
  {
    id: 'v-extra-36',
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
    exampleDe: 'Ich mache meine Hausaufgaben.',
    exampleAr: 'أنا أفعل واجباتي المنزلية.'
  },
  {
    id: 'v-extra-37',
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
    exampleAr: 'نحن نأكل العشاء معاً.'
  },
  {
    id: 'v-extra-38',
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
    exampleDe: 'Ich trinke Kaffee am Morgen.',
    exampleAr: 'أشرب القهوة في الصباح.'
  },
  {
    id: 'v-extra-39',
    type: 'verb',
    level: 'A2',
    de: 'sprechen',
    ar: 'يتحدث',
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
    exampleDe: 'Sie spricht gut Deutsch.',
    exampleAr: 'هي تتحدث الألمانية جيداً.'
  },
  {
    id: 'v-extra-40',
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
    exampleDe: 'Ich verstehe die Frage nicht.',
    exampleAr: 'أنا لا أفهم السؤال.'
  },
  {
    id: 'v-extra-41',
    type: 'noun',
    level: 'A1',
    de: 'Haus',
    article: 'das',
    plural: 'Häuser',
    ar: 'بيت / منزل',
    exampleDe: 'Das Haus ist neu und schön.',
    exampleAr: 'البيت جديد وجميل.'
  },
  {
    id: 'v-extra-42',
    type: 'noun',
    level: 'A1',
    de: 'Auto',
    article: 'das',
    plural: 'Autos',
    ar: 'سيارة',
    exampleDe: 'Mein Auto ist blau.',
    exampleAr: 'سيارتي زرقاء.'
  },
  {
    id: 'v-extra-43',
    type: 'noun',
    level: 'A1',
    de: 'Buch',
    article: 'das',
    plural: 'Bücher',
    ar: 'كتاب',
    exampleDe: 'Ich lese ein interessantes Buch.',
    exampleAr: 'أنا أقرأ كتاباً مثيراً للاهتمام.'
  },
  {
    id: 'v-extra-44',
    type: 'noun',
    level: 'A1',
    de: 'Schule',
    article: 'die',
    plural: 'Schulen',
    ar: 'مدرسة',
    exampleDe: 'Die Schule beginnt um acht Uhr.',
    exampleAr: 'تبدأ المدرسة في الساعة الثامنة.'
  },
  {
    id: 'v-extra-45',
    type: 'noun',
    level: 'A1',
    de: 'Freundin',
    article: 'die',
    plural: 'Freundinnen',
    ar: 'صديقة',
    exampleDe: 'Meine Freundin kommt aus Ägypten.',
    exampleAr: 'صديقتي تأتي من مصر.'
  },
  {
    id: 'v-extra-46',
    type: 'verb',
    level: 'A2',
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
    exampleDe: 'Er arbeitet in einem Büro.',
    exampleAr: 'هو يعمل في مكتب.'
  },
  {
    id: 'v-extra-47',
    type: 'verb',
    level: 'A1',
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
    exampleAr: 'نحن نتعلم الألمانية معاً.'
  },
  {
    id: 'v-extra-48',
    type: 'noun',
    level: 'A2',
    de: 'Familie',
    article: 'die',
    plural: 'Familien',
    ar: 'عائلة',
    exampleDe: 'Meine Familie wohnt in Kairo.',
    exampleAr: 'عائلتي تسكن في القاهرة.'
  },
  {
    id: 'v-extra-49',
    type: 'noun',
    level: 'A2',
    de: 'Wasser',
    article: 'das',
    plural: 'Wässer',
    ar: 'ماء',
    exampleDe: 'Ich trinke viel Wasser.',
    exampleAr: 'أشرب كثيراً من الماء.'
  },
  {
    id: 'v-extra-50',
    type: 'noun',
    level: 'A1',
    de: 'Mann',
    article: 'der',
    plural: 'Männer',
    ar: 'رجل',
    exampleDe: 'Der Mann liest die Zeitung.',
    exampleAr: 'الرجل يقرأ الجريدة.'
  },
  {
    id: 'v-extra-51',
    type: 'noun',
    level: 'A1',
    de: 'Frau',
    article: 'die',
    plural: 'Frauen',
    ar: 'امرأة',
    exampleDe: 'Die Frau kocht das Essen.',
    exampleAr: 'المرأة تطبخ الطعام.'
  },
  {
    id: 'v-extra-52',
    type: 'verb',
    level: 'A2',
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
    exampleDe: 'Ich kaufe Brot im Supermarkt.',
    exampleAr: 'أشتري الخبز من السوبرماركت.'
  },
  {
    id: 'v-extra-53',
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
    exampleDe: 'Wir sehen einen Film heute Abend.',
    exampleAr: 'سنشاهد فيلماً هذا المساء.'
  },
  {
    id: 'v-extra-54',
    type: 'noun',
    level: 'A2',
    de: 'Problem',
    article: 'das',
    plural: 'Probleme',
    ar: 'مشكلة',
    exampleDe: 'Es gibt ein kleines Problem.',
    exampleAr: 'هناك مشكلة صغيرة.'
  },
  {
    id: 'v-extra-55',
    type: 'noun',
    level: 'A2',
    de: 'Idee',
    article: 'die',
    plural: 'Ideen',
    ar: 'فكرة',
    exampleDe: 'Das ist eine gute Idee!',
    exampleAr: 'هذه فكرة جيدة!'
  },
  // New items session 2026-10-28 19:04 +03
  {
    id: 'v-extra-56',
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
    exampleAr: 'أنام ثماني ساعات كل ليلة.'
  },
  {
    id: 'v-extra-57',
    type: 'verb',
    level: 'A1',
    de: 'wohnen',
    ar: 'يسكن / يعيش',
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
    exampleDe: 'Wir wohnen in Berlin.',
    exampleAr: 'نحن نسكن في برلين.'
  },
  {
    id: 'v-extra-58',
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
    exampleDe: 'Die Kinder spielen im Park.',
    exampleAr: 'الأطفال يلعبون في الحديقة.'
  },
  {
    id: 'v-extra-59',
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
    exampleDe: 'Kannst du mir bitte helfen?',
    exampleAr: 'هل يمكنك مساعدتي من فضلك؟'
  },
  {
    id: 'v-extra-60',
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
    exampleDe: 'Ich lese jeden Abend ein Buch.',
    exampleAr: 'أقرأ كتاباً كل مساء.'
  },
  {
    id: 'v-extra-61',
    type: 'verb',
    level: 'A1',
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
    exampleDe: 'Sie schreibt eine E-Mail an ihren Freund.',
    exampleAr: 'هي تكتب بريداً إلكترونياً إلى صديقها.'
  },
  {
    id: 'v-extra-62',
    type: 'verb',
    level: 'A1',
    de: 'hören',
    ar: 'يسمع / يستمع',
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
    exampleDe: 'Wir hören Musik im Auto.',
    exampleAr: 'نحن نستمع إلى الموسيقى في السيارة.'
  },
  {
    id: 'v-extra-63',
    type: 'verb',
    level: 'A2',
    de: 'fragen',
    ar: 'يسأل',
    conjugations: {
      ich: 'frage',
      du: 'fragst',
      er: 'fragt',
      wir: 'fragen',
      ihr: 'fragt',
      sie: 'fragen',
      präteritum: 'fragte',
      perfekt: 'gefragt',
      aux: 'haben'
    },
    exampleDe: 'Darf ich dich etwas fragen?',
    exampleAr: 'هل يمكنني أن أسألك شيئاً؟'
  },
  {
    id: 'v-extra-64',
    type: 'noun',
    level: 'A1',
    de: 'Tisch',
    article: 'der',
    plural: 'Tische',
    ar: 'طاولة',
    exampleDe: 'Der Tisch ist aus Holz.',
    exampleAr: 'الطاولة مصنوعة من الخشب.'
  },
  {
    id: 'v-extra-65',
    type: 'noun',
    level: 'A1',
    de: 'Stuhl',
    article: 'der',
    plural: 'Stühle',
    ar: 'كرسي',
    exampleDe: 'Bitte setz dich auf den Stuhl.',
    exampleAr: 'من فضلك اجلس على الكرسي.'
  },
  {
    id: 'v-extra-66',
    type: 'noun',
    level: 'A1',
    de: 'Tür',
    article: 'die',
    plural: 'Türen',
    ar: 'باب',
    exampleDe: 'Die Tür ist offen.',
    exampleAr: 'الباب مفتوح.'
  },
  {
    id: 'v-extra-67',
    type: 'noun',
    level: 'A1',
    de: 'Fenster',
    article: 'das',
    plural: 'Fenster',
    ar: 'نافذة',
    exampleDe: 'Das Fenster ist groß und hell.',
    exampleAr: 'النافذة كبيرة ومضيئة.'
  },
  {
    id: 'v-extra-68',
    type: 'noun',
    level: 'A1',
    de: 'Apfel',
    article: 'der',
    plural: 'Äpfel',
    ar: 'تفاحة',
    exampleDe: 'Ich esse gerne einen Apfel.',
    exampleAr: 'أحب أن آكل تفاحة.'
  },
  {
    id: 'v-extra-69',
    type: 'noun',
    level: 'A1',
    de: 'Milch',
    article: 'die',
    plural: '—',
    ar: 'حليب',
    exampleDe: 'Die Milch ist kalt.',
    exampleAr: 'الحليب بارد.'
  },
  {
    id: 'v-extra-70',
    type: 'noun',
    level: 'A1',
    de: 'Kaffee',
    article: 'der',
    plural: 'Kaffees',
    ar: 'قهوة',
    exampleDe: 'Möchtest du eine Tasse Kaffee?',
    exampleAr: 'هل تريد فنجان قهوة؟'
  },
  {
    id: 'v-extra-71',
    type: 'noun',
    level: 'A1',
    de: 'Kind',
    article: 'das',
    plural: 'Kinder',
    ar: 'طفل',
    exampleDe: 'Das Kind spielt mit dem Ball.',
    exampleAr: 'الطفل يلعب بالكرة.'
  },
  {
    id: 'v-extra-72',
    type: 'noun',
    level: 'A2',
    de: 'Hund',
    article: 'der',
    plural: 'Hunde',
    ar: 'كلب',
    exampleDe: 'Der Hund bellt laut.',
    exampleAr: 'الكلب ينبح بصوت عالٍ.'
  },
  {
    id: 'v-extra-73',
    type: 'noun',
    level: 'A2',
    de: 'Katze',
    article: 'die',
    plural: 'Katzen',
    ar: 'قطة',
    exampleDe: 'Die Katze schläft auf dem Sofa.',
    exampleAr: 'القطة تنام على الأريكة.'
  },
  {
    id: 'v-extra-74',
    type: 'verb',
    level: 'A2',
    de: 'öffnen',
    ar: 'يفتح',
    conjugations: {
      ich: 'öffne',
      du: 'öffnest',
      er: 'öffnet',
      wir: 'öffnen',
      ihr: 'öffnet',
      sie: 'öffnen',
      präteritum: 'öffnete',
      perfekt: 'geöffnet',
      aux: 'haben'
    },
    exampleDe: 'Bitte öffne das Fenster.',
    exampleAr: 'من فضلك افتح النافذة.'
  },
  {
    id: 'v-extra-75',
    type: 'verb',
    level: 'A2',
    de: 'schließen',
    ar: 'يغلق',
    conjugations: {
      ich: 'schließe',
      du: 'schließt',
      er: 'schließt',
      wir: 'schließen',
      ihr: 'schließt',
      sie: 'schließen',
      präteritum: 'schloss',
      perfekt: 'geschlossen',
      aux: 'haben'
    },
    exampleDe: 'Wir schließen die Tür abends.',
    exampleAr: 'نغلق الباب في المساء.'
  }
,
{
    id: 'v-extra-76',
    type: 'verb',
    level: 'A1',
    de: 'antworten',
    ar: 'يجيب',
    conjugations: {
      ich: 'antworte',
      du: 'antwortest',
      er: 'antwortet',
      wir: 'antworten',
      ihr: 'antwortet',
      sie: 'antworten',
      präteritum: 'antwortete',
      perfekt: 'geantwortet',
      aux: 'haben'
    },
    exampleDe: 'Ich antworte auf die Frage.',
    exampleAr: 'أجيب على السؤال.'
  },
  {
    id: 'v-extra-77',
    type: 'verb',
    level: 'A1',
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
    exampleDe: 'Wo findest du das Buch?',
    exampleAr: 'أين تجد الكتاب؟'
  },
  {
    id: 'v-extra-78',
    type: 'verb',
    level: 'A2',
    de: 'denken',
    ar: 'يفكر',
    conjugations: {
      ich: 'denke',
      du: 'denkst',
      er: 'denkt',
      wir: 'denken',
      ihr: 'denkt',
      sie: 'denken',
      präteritum: 'dachte',
      perfekt: 'gedacht',
      aux: 'haben'
    },
    exampleDe: 'Ich denke an meine Familie.',
    exampleAr: 'أفكر في عائلتي.'
  },
  {
    id: 'v-extra-79',
    type: 'verb',
    level: 'A1',
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
  },
  {
    id: 'v-extra-80',
    type: 'verb',
    level: 'A1',
    de: 'lachen',
    ar: 'يضحك',
    conjugations: {
      ich: 'lache',
      du: 'lachst',
      er: 'lacht',
      wir: 'lachen',
      ihr: 'lacht',
      sie: 'lachen',
      präteritum: 'lachte',
      perfekt: 'gelacht',
      aux: 'haben'
    },
    exampleDe: 'Die Kinder lachen laut.',
    exampleAr: 'الأطفال يضحكون بصوت عالٍ.'
  },
  {
    id: 'v-extra-81',
    type: 'verb',
    level: 'A2',
    de: 'kochen',
    ar: 'يطبخ',
    conjugations: {
      ich: 'koche',
      du: 'kochst',
      er: 'kocht',
      wir: 'kochen',
      ihr: 'kocht',
      sie: 'kochen',
      präteritum: 'kochte',
      perfekt: 'gekocht',
      aux: 'haben'
    },
    exampleDe: 'Meine Mutter kocht das Abendessen.',
    exampleAr: 'أمي تطبخ العشاء.'
  },
  {
    id: 'v-extra-82',
    type: 'verb',
    level: 'A2',
    de: 'fahren',
    ar: 'يقود / يسافر',
    conjugations: {
      ich: 'fahre',
      du: 'fährst',
      er: 'fährt',
      wir: 'fahren',
      ihr: 'fahrt',
      sie: 'fahren',
      präteritum: 'fuhr',
      perfekt: 'gefahren',
      aux: 'sein'
    },
    exampleDe: 'Ich fahre mit dem Zug nach Berlin.',
    exampleAr: 'أسافر بالقطار إلى برلين.'
  },
  {
    id: 'v-extra-83',
    type: 'verb',
    level: 'A1',
    de: 'stehen',
    ar: 'يقف',
    conjugations: {
      ich: 'stehe',
      du: 'stehst',
      er: 'steht',
      wir: 'stehen',
      ihr: 'steht',
      sie: 'stehen',
      präteritum: 'stand',
      perfekt: 'gestanden',
      aux: 'haben'
    },
    exampleDe: 'Das Auto steht vor dem Haus.',
    exampleAr: 'السيارة تقف أمام المنزل.'
  },
  {
    id: 'v-extra-84',
    type: 'verb',
    level: 'A2',
    de: 'beginnen',
    ar: 'يبدأ',
    conjugations: {
      ich: 'beginne',
      du: 'beginnst',
      er: 'beginnt',
      wir: 'beginnen',
      ihr: 'beginnt',
      sie: 'beginnen',
      präteritum: 'begann',
      perfekt: 'begonnen',
      aux: 'haben'
    },
    exampleDe: 'Der Unterricht beginnt um acht Uhr.',
    exampleAr: 'يبدأ الدرس في الساعة الثامنة.'
  },
  {
    id: 'v-extra-85',
    type: 'verb',
    level: 'A1',
    de: 'sitzen',
    ar: 'يجلس',
    conjugations: {
      ich: 'sitze',
      du: 'sitzt',
      er: 'sitzt',
      wir: 'sitzen',
      ihr: 'sitzt',
      sie: 'sitzen',
      präteritum: 'saß',
      perfekt: 'gesessen',
      aux: 'haben'
    },
    exampleDe: 'Wir sitzen im Café.',
    exampleAr: 'نحن نجلس في المقهى.'
  },
  {
    id: 'v-extra-86',
    type: 'noun',
    level: 'A1',
    de: 'Apotheke',
    article: 'die',
    plural: 'Apotheken',
    ar: 'صيدلية',
    exampleDe: 'Ich gehe zur Apotheke.',
    exampleAr: 'أذهب إلى الصيدلية.'
  },
  {
    id: 'v-extra-87',
    type: 'noun',
    level: 'A1',
    de: 'Bahnhof',
    article: 'der',
    plural: 'Bahnhöfe',
    ar: 'محطة قطار',
    exampleDe: 'Der Bahnhof ist groß.',
    exampleAr: 'محطة القطار كبيرة.'
  },
  {
    id: 'v-extra-88',
    type: 'noun',
    level: 'A1',
    de: 'Supermarkt',
    article: 'der',
    plural: 'Supermärkte',
    ar: 'سوبر ماركت',
    exampleDe: 'Wir kaufen im Supermarkt ein.',
    exampleAr: 'نحن نتسوق في السوبر ماركت.'
  },
  {
    id: 'v-extra-89',
    type: 'noun',
    level: 'A1',
    de: 'Geld',
    article: 'das',
    plural: '—',
    ar: 'مال',
    exampleDe: 'Ich habe kein Geld mehr.',
    exampleAr: 'لم يعد لدي مال.'
  },
  {
    id: 'v-extra-90',
    type: 'noun',
    level: 'A1',
    de: 'Zeit',
    article: 'die',
    plural: 'Zeiten',
    ar: 'وقت',
    exampleDe: 'Hast du Zeit heute?',
    exampleAr: 'هل لديك وقت اليوم؟'
  },
  {
    id: 'v-extra-91',
    type: 'noun',
    level: 'A1',
    de: 'Tag',
    article: 'der',
    plural: 'Tage',
    ar: 'يوم',
    exampleDe: 'Heute ist ein schöner Tag.',
    exampleAr: 'اليوم يوم جميل.'
  },
  {
    id: 'v-extra-92',
    type: 'noun',
    level: 'A1',
    de: 'Nacht',
    article: 'die',
    plural: 'Nächte',
    ar: 'ليل',
    exampleDe: 'Gute Nacht!',
    exampleAr: 'تصبح على خير!'
  },
  {
    id: 'v-extra-93',
    type: 'noun',
    level: 'A1',
    de: 'Woche',
    article: 'die',
    plural: 'Wochen',
    ar: 'أسبوع',
    exampleDe: 'Nächste Woche habe ich Urlaub.',
    exampleAr: 'الأسبوع القادم لدي إجازة.'
  },
  {
    id: 'v-extra-94',
    type: 'noun',
    level: 'A2',
    de: 'Stadt',
    article: 'die',
    plural: 'Städte',
    ar: 'مدينة',
    exampleDe: 'Berlin ist eine große Stadt.',
    exampleAr: 'برلين مدينة كبيرة.'
  },
  {
    id: 'v-extra-95',
    type: 'noun',
    level: 'A1',
    de: 'Straße',
    article: 'die',
    plural: 'Straßen',
    ar: 'شارع',
    exampleDe: 'Die Straße ist lang.',
    exampleAr: 'الشارع طويل.'
  }
];
