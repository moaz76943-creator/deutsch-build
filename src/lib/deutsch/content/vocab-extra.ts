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
    exampleDe: 'Ich habe einen Bruder und eine Schwester.',
    exampleAr: 'لدي أخ وأخت.'
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
    exampleDe: 'Wir gehen heute ins Kino.',
    exampleAr: 'نذهب اليوم إلى السينما.'
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
    exampleDe: 'Kommst du aus Ägypten?',
    exampleAr: 'هل تأتي من مصر؟'
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
    exampleDe: 'Ich spreche Arabisch und Deutsch.',
    exampleAr: 'أتكلم العربية والألمانية.'
  },
  {
    id: 'v-extra-7',
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
    exampleAr: 'نتناول العشاء معاً.'
  },
  {
    id: 'v-extra-8',
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
    exampleDe: 'Trinkst du gerne Tee?',
    exampleAr: 'هل تحب شرب الشاي؟'
  },
  {
    id: 'v-extra-9',
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
    exampleDe: 'Ich sehe den Film im Kino.',
    exampleAr: 'أرى الفيلم في السينما.'
  },
  {
    id: 'v-extra-10',
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
    id: 'v-extra-11',
    type: 'noun',
    level: 'A1',
    de: 'Haus',
    ar: 'منزل / بيت',
    article: 'das',
    plural: 'Häuser',
    exampleDe: 'Das Haus ist groß und modern.',
    exampleAr: 'المنزل كبير وحديث.'
  },
  {
    id: 'v-extra-12',
    type: 'noun',
    level: 'A1',
    de: 'Stadt',
    ar: 'مدينة',
    article: 'die',
    plural: 'Städte',
    exampleDe: 'Die Stadt hat viele Parks.',
    exampleAr: 'المدينة لديها حدائق كثيرة.'
  },
  {
    id: 'v-extra-13',
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
    id: 'v-extra-14',
    type: 'noun',
    level: 'A1',
    de: 'Frau',
    ar: 'امرأة',
    article: 'die',
    plural: 'Frauen',
    exampleDe: 'Die Frau liest ein Buch.',
    exampleAr: 'المرأة تقرأ كتاباً.'
  },
  {
    id: 'v-extra-15',
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
    id: 'v-extra-16',
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
    id: 'v-extra-17',
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
    exampleAr: 'نتعلم الألمانية معاً.'
  },
  {
    id: 'v-extra-18',
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
    id: 'v-extra-19',
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
    id: 'v-extra-20',
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
    id: 'v-extra-21',
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
    id: 'v-extra-22',
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
    id: 'v-extra-23',
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
    id: 'v-extra-24',
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
    id: 'v-extra-25',
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
    id: 'v-extra-26',
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
    id: 'v-extra-27',
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
    id: 'v-extra-28',
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
    id: 'v-extra-29',
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
    id: 'v-extra-30',
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
    id: 'v-extra-31',
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
    id: 'v-extra-32',
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
    id: 'v-extra-33',
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
    id: 'v-extra-34',
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
    id: 'v-extra-35',
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
    id: 'v-extra-36',
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
    id: 'v-extra-37',
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
  },
  // --- New A1/A2 items (session 2026-11-05) ---
  {
    id: 'v-extra-38',
    type: 'verb',
    level: 'A1',
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
    id: 'v-extra-39',
    type: 'verb',
    level: 'A1',
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
    exampleDe: 'Ich schließe die Tür um acht Uhr.',
    exampleAr: 'أغلق الباب في الساعة الثامنة.'
  },
  {
    id: 'v-extra-40',
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
    id: 'v-extra-41',
    type: 'verb',
    level: 'A1',
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
    exampleDe: 'Ich frage den Lehrer nach dem Wort.',
    exampleAr: 'أسأل المعلم عن الكلمة.'
  },
  {
    id: 'v-extra-42',
    type: 'verb',
    level: 'A2',
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
    exampleDe: 'Er antwortet schnell auf die E-Mail.',
    exampleAr: 'هو يجيب بسرعة على البريد الإلكتروني.'
  },
  {
    id: 'v-extra-43',
    type: 'verb',
    level: 'A1',
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
    exampleDe: 'Der Kurs beginnt um neun Uhr.',
    exampleAr: 'تبدأ الدورة في الساعة التاسعة.'
  },
  {
    id: 'v-extra-44',
    type: 'verb',
    level: 'A2',
    de: 'enden',
    ar: 'ينتهي',
    conjugations: {
      ich: 'ende',
      du: 'endest',
      er: 'endet',
      wir: 'enden',
      ihr: 'endet',
      sie: 'enden',
      präteritum: 'endete',
      perfekt: 'geendet',
      aux: 'haben'
    },
    exampleDe: 'Der Film endet um zehn Uhr.',
    exampleAr: 'ينتهي الفيلم في الساعة العاشرة.'
  },
  {
    id: 'v-extra-45',
    type: 'verb',
    level: 'A1',
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
    exampleDe: 'Wir fahren mit dem Zug nach München.',
    exampleAr: 'نسافر بالقطار إلى ميونيخ.'
  },
  {
    id: 'v-extra-46',
    type: 'verb',
    level: 'A2',
    de: 'fliegen',
    ar: 'يطير',
    conjugations: {
      ich: 'fliege',
      du: 'fliegst',
      er: 'fliegt',
      wir: 'fliegen',
      ihr: 'fliegt',
      sie: 'fliegen',
      präteritum: 'flog',
      perfekt: 'geflogen',
      aux: 'sein'
    },
    exampleDe: 'Das Flugzeug fliegt nach Kairo.',
    exampleAr: 'الطائرة تطير إلى القاهرة.'
  },
  {
    id: 'v-extra-47',
    type: 'noun',
    level: 'A1',
    de: 'Auto',
    ar: 'سيارة',
    article: 'das',
    plural: 'Autos',
    exampleDe: 'Das Auto ist neu und blau.',
    exampleAr: 'السيارة جديدة وزرقاء.'
  },
  {
    id: 'v-extra-48',
    type: 'noun',
    level: 'A1',
    de: 'Buch',
    ar: 'كتاب',
    article: 'das',
    plural: 'Bücher',
    exampleDe: 'Das Buch liegt auf dem Tisch.',
    exampleAr: 'الكتاب موجود على الطاولة.'
  },
  {
    id: 'v-extra-49',
    type: 'noun',
    level: 'A2',
    de: 'Fenster',
    ar: 'نافذة',
    article: 'das',
    plural: 'Fenster',
    exampleDe: 'Das Fenster ist offen.',
    exampleAr: 'النافذة مفتوحة.'
  },
  {
    id: 'v-extra-50',
    type: 'noun',
    level: 'A1',
    de: 'Tür',
    ar: 'باب',
    article: 'die',
    plural: 'Türen',
    exampleDe: 'Die Tür ist geschlossen.',
    exampleAr: 'الباب مغلق.'
  },
  {
    id: 'v-extra-51',
    type: 'noun',
    level: 'A2',
    de: 'Schlüssel',
    ar: 'مفتاح',
    article: 'der',
    plural: 'Schlüssel',
    exampleDe: 'Hast du den Schlüssel?',
    exampleAr: 'هل لديك المفتاح؟'
  },
  {
    id: 'v-extra-52',
    type: 'noun',
    level: 'A1',
    de: 'Tisch',
    ar: 'طاولة',
    article: 'der',
    plural: 'Tische',
    exampleDe: 'Der Tisch ist aus Holz.',
    exampleAr: 'الطاولة مصنوعة من الخشب.'
  },
  {
    id: 'v-extra-53',
    type: 'noun',
    level: 'A2',
    de: 'Stuhl',
    ar: 'كرسي',
    article: 'der',
    plural: 'Stühle',
    exampleDe: 'Bitte setz dich auf den Stuhl.',
    exampleAr: 'من فضلك اجلس على الكرسي.'
  },
  {
    id: 'v-extra-54',
    type: 'verb',
    level: 'A2',
    de: 'brauchen',
    ar: 'يحتاج',
    conjugations: {
      ich: 'brauche',
      du: 'brauchst',
      er: 'braucht',
      wir: 'brauchen',
      ihr: 'braucht',
      sie: 'brauchen',
      präteritum: 'brauchte',
      perfekt: 'gebraucht',
      aux: 'haben'
    },
    exampleDe: 'Ich brauche Hilfe bei den Hausaufgaben.',
    exampleAr: 'أحتاج مساعدة في الواجبات المنزلية.'
  },
  {
    id: 'v-extra-55',
    type: 'verb',
    level: 'A1',
    de: 'suchen',
    ar: 'يبحث',
    conjugations: {
      ich: 'suche',
      du: 'suchst',
      er: 'sucht',
      wir: 'suchen',
      ihr: 'sucht',
      sie: 'suchen',
      präteritum: 'suchte',
      perfekt: 'gesucht',
      aux: 'haben'
    },
    exampleDe: 'Ich suche meine Brille.',
    exampleAr: 'أبحث عن نظارتي.'
  },
  {
    id: 'v-extra-56',
    type: 'noun',
    level: 'A2',
    de: 'Brille',
    ar: 'نظارة',
    article: 'die',
    plural: 'Brillen',
    exampleDe: 'Meine Brille ist kaputt.',
    exampleAr: 'نظارتي مكسورة.'
  },
  {
    id: 'v-extra-57',
    type: 'noun',
    level: 'A1',
    de: 'Uhr',
    ar: 'ساعة',
    article: 'die',
    plural: 'Uhren',
    exampleDe: 'Die Uhr zeigt fünf Minuten vor zwölf.',
    exampleAr: 'الساعة تشير إلى خمس دقائق قبل الثانية عشرة.'
  },
  {
    id: 'v-extra-58',
    type: 'verb',
    level: 'A2',
    de: 'zeigen',
    ar: 'يُظهر',
    conjugations: {
      ich: 'zeige',
      du: 'zeigst',
      er: 'zeigt',
      wir: 'zeigen',
      ihr: 'zeigt',
      sie: 'zeigen',
      präteritum: 'zeigte',
      perfekt: 'gezeigt',
      aux: 'haben'
    },
    exampleDe: 'Zeig mir bitte den Weg.',
    exampleAr: 'أرني الطريق من فضلك.'
  },
  {
    id: 'v-extra-59',
    type: 'verb',
    level: 'A1',
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
    exampleDe: 'Gib mir bitte das Buch.',
    exampleAr: 'أعطني الكتاب من فضلك.'
  },
  {
    id: 'v-extra-60',
    type: 'noun',
    level: 'A2',
    de: 'Weg',
    ar: 'طريق',
    article: 'der',
    plural: 'Wege',
    exampleDe: 'Der Weg zum Bahnhof ist kurz.',
    exampleAr: 'الطريق إلى محطة القطار قصير.'
  }
];
