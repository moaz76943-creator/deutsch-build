import '../core/content_contract.dart';

/// Language-specific learning enrichment for the current German content set.
/// Kept outside LearningCore so reusable learning algorithms stay language-agnostic.
class WordDepth {
  final String collocation;
  final String wordFamily;
  final String grammar;
  final String transferPrompt;
  final String transferAnswer;
  final List<String> senses;
  const WordDepth({
    this.collocation = '',
    this.wordFamily = '',
    this.grammar = '',
    this.transferPrompt = '',
    this.transferAnswer = '',
    this.senses = const [],
  });
}

const depth = <String, WordDepth>{
  'w001': WordDepth(
    collocation: 'Hallo sagen',
    transferPrompt: 'قل: مرحبًا! كيف حالك؟',
    transferAnswer: 'Hallo! Wie geht es dir?',
    senses: ['مرحبًا'],
  ),
  'w004': WordDepth(
    collocation: 'Danke sagen',
    grammar: 'für + Akkusativ: Danke für deine Hilfe.',
    transferPrompt: 'قل: شكرًا على مساعدتك.',
    transferAnswer: 'Danke für deine Hilfe.',
  ),
  'w005': WordDepth(
    collocation: 'Ein Wasser, bitte.',
    grammar: 'bitte تأتي للطلب بلطف.',
    transferPrompt: 'اطلب ماءً بأدب.',
    transferAnswer: 'Ein Wasser, bitte.',
  ),
  'w006': WordDepth(
    collocation: 'am Tisch sitzen',
    grammar: 'der → den في Akkusativ.',
    transferPrompt: 'قل: الطاولة كبيرة.',
    transferAnswer: 'Der Tisch ist groß.',
    senses: ['الطاولة'],
  ),
  'w007': WordDepth(
    collocation: 'ein Buch lesen',
    grammar: 'das Buch → ein Buch بعد فعل lesen.',
    transferPrompt: 'قل: أنا أقرأ كتابًا.',
    transferAnswer: 'Ich lese ein Buch.',
    senses: ['الكتاب'],
  ),
  'w009': WordDepth(
    collocation: 'Wasser trinken',
    grammar: 'Wasser غالبًا دون Artikel عند المعنى العام.',
    transferPrompt: 'قل: أنا أشرب الماء.',
    transferAnswer: 'Ich trinke Wasser.',
    senses: ['الماء'],
  ),
  'w010': WordDepth(
    collocation: 'Brot essen',
    grammar: 'ich esse = تصريف essen مع ich.',
    transferPrompt: 'اكتب الفعل: يأكل.',
    transferAnswer: 'essen',
  ),
  'w011': WordDepth(
    collocation: 'nach Hause gehen',
    grammar: 'nach Hause تعني إلى المنزل.',
    transferPrompt: 'قل: أذهب إلى المنزل.',
    transferAnswer: 'Ich gehe nach Hause.',
  ),
  'w012': WordDepth(
    collocation: 'Deutsch sprechen',
    grammar: 'Deutsch اسم لغة ويكتب بحرف كبير.',
    transferPrompt: 'قل: أنا أتحدث الألمانية.',
    transferAnswer: 'Ich spreche Deutsch.',
  ),
  'w017': WordDepth(
    collocation: 'zum Arzt gehen',
    grammar: 'zu + dem = zum.',
    transferPrompt: 'قل: أذهب إلى الطبيب.',
    transferAnswer: 'Ich gehe zum Arzt.',
  ),
  'w018': WordDepth(
    collocation: 'mit dem Bus fahren',
    grammar: 'mit + Dativ: mit dem Bus.',
    transferPrompt: 'قل: أذهب بالحافلة.',
    transferAnswer: 'Ich fahre mit dem Bus.',
  ),
  'w028': WordDepth(
    collocation: 'zur Arbeit gehen',
    grammar: 'zu + der = zur.',
    transferPrompt: 'قل: أذهب إلى العمل.',
    transferAnswer: 'Ich gehe zur Arbeit.',
  ),
  'w031': WordDepth(
    collocation: 'mit Karte bezahlen',
    grammar: 'mit + Dativ.',
    transferPrompt: 'قل: أدفع بالبطاقة.',
    transferAnswer: 'Ich bezahle mit Karte.',
  ),
  'w041': WordDepth(
    collocation: 'in Amman wohnen',
    grammar: 'wohnen + in + Ort.',
    transferPrompt: 'قل: أسكن في عمّان.',
    transferAnswer: 'Ich wohne in Amman.',
  ),
  'w045': WordDepth(
    collocation: 'Hilfe brauchen',
    grammar: 'brauchen + Akkusativ.',
    transferPrompt: 'قل: أحتاج إلى مساعدة.',
    transferAnswer: 'Ich brauche Hilfe.',
  ),
  'w046': WordDepth(
    collocation: 'jemandem helfen',
    grammar: 'helfen يأخذ Dativ.',
    transferPrompt: 'قل: هل يمكنك مساعدتي؟',
    transferAnswer: 'Kannst du mir helfen?',
  ),
  'w048': WordDepth(
    collocation: 'ein Problem haben',
    grammar: 'ein Problem = ein + das في Nominativ/Akkusativ.',
    transferPrompt: 'قل: لدي مشكلة.',
    transferAnswer: 'Ich habe ein Problem.',
  ),
};

WordDepth depthFor(LearningContent x) => depth[x.id] ?? const WordDepth();
