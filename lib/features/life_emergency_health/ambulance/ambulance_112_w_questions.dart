final class AmbulanceWQuestion {
  const AmbulanceWQuestion({
    required this.keywordDe,
    required this.promptDe,
    required this.promptAr,
    required this.exampleDe,
    required this.exampleAr,
  });

  final String keywordDe;
  final String promptDe;
  final String promptAr;
  final String exampleDe;
  final String exampleAr;
}

final class Ambulance112WQuestions {
  const Ambulance112WQuestions();

  String get callerIdentityDe =>
      'Mein Name ist Samir Haddad. Ich rufe von meinem Handy an.';
  String get callerIdentityAr =>
      'اسمي سمير حداد، وأنا أتصل من هاتفي المحمول.';

  List<AmbulanceWQuestion> get questions => _questions;

  static const List<AmbulanceWQuestion> _questions =
      <AmbulanceWQuestion>[
    AmbulanceWQuestion(
      keywordDe: 'Wo?',
      promptDe: 'Wo ist der Notfallort?',
      promptAr: 'أين موقع الطوارئ؟',
      exampleDe:
          'Der Notfall ist in der Lindenstraße 24, im zweiten Stock.',
      exampleAr:
          'حالة الطوارئ في شارع ليندن 24، في الطابق الثاني.',
    ),
    AmbulanceWQuestion(
      keywordDe: 'Was?',
      promptDe: 'Was ist passiert?',
      promptAr: 'ماذا حدث؟',
      exampleDe:
          'Eine Person ist gestürzt und reagiert nicht auf Ansprache.',
      exampleAr:
          'سقط شخص ولا يستجيب عند التحدث إليه.',
    ),
    AmbulanceWQuestion(
      keywordDe: 'Wie viele?',
      promptDe: 'Wie viele Personen sind betroffen?',
      promptAr: 'كم عدد الأشخاص المتأثرين؟',
      exampleDe: 'Eine Person ist verletzt, weitere Personen sind unverletzt.',
      exampleAr: 'هناك شخص واحد مصاب، والبقية دون إصابات.',
    ),
    AmbulanceWQuestion(
      keywordDe: 'Welche?',
      promptDe: 'Welche Beschwerden oder Verletzungen sehen Sie?',
      promptAr: 'ما الأعراض أو الإصابات التي تراها؟',
      exampleDe:
          'Die Person hat starke Atemnot und kann kaum sprechen.',
      exampleAr:
          'يعاني الشخص من ضيق تنفس شديد ويكاد لا يستطيع الكلام.',
    ),
    AmbulanceWQuestion(
      keywordDe: 'Warten!',
      promptDe: 'Warten Sie auf Rückfragen der Leitstelle.',
      promptAr: 'انتظر أسئلة مركز الطوارئ ولا تغلق الاتصال من نفسك.',
      exampleDe:
          'Ich bleibe am Telefon und beantworte Ihre Fragen.',
      exampleAr:
          'سأبقى على الهاتف وأجيب عن أسئلتكم.',
    ),
  ];
}
