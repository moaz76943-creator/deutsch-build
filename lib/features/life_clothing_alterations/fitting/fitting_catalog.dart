import 'fitting_models.dart';

abstract final class FittingCatalog {
  static const List<FittingDialogue> dialogues = <FittingDialogue>[
    FittingDialogue(
      id: 'fitting-room-request',
      garment: FittingGarmentType.jacket,
      german: 'Kann ich diese Jacke in der Umkleidekabine anprobieren?',
      arabic: 'هل يمكنني تجربة هذه السترة في غرفة القياس؟',
      keywords: <String>{'Umkleidekabine', 'anprobieren', 'Jacke'},
    ),
    FittingDialogue(
      id: 'jacket-more-comfortable',
      garment: FittingGarmentType.jacket,
      german: 'Die Jacke sitzt an den Schultern etwas eng. Haben Sie sie etwas weiter?',
      arabic: 'السترة ضيقة قليلاً عند الكتفين. هل لديكم مقاس أوسع قليلاً؟',
      keywords: <String>{'Schultern', 'eng', 'weiter', 'Jacke'},
    ),
    FittingDialogue(
      id: 'shirt-size-up',
      garment: FittingGarmentType.shirt,
      german: 'Das Hemd ist mir zu eng. Haben Sie eine Nummer größer?',
      arabic: 'القميص ضيق عليّ. هل لديكم مقاس أكبر بدرجة؟',
      keywords: <String>{'Hemd', 'eng', 'Nummer größer'},
    ),
    FittingDialogue(
      id: 'shirt-sleeve-length',
      garment: FittingGarmentType.shirt,
      german: 'Ist die Ärmellänge bei diesem Hemd richtig, oder brauche ich eine längere Größe?',
      arabic: 'هل طول الأكمام في هذا القميص مناسب أم أحتاج مقاساً أطول؟',
      keywords: <String>{'Ärmellänge', 'Hemd', 'Länge'},
    ),
    FittingDialogue(
      id: 'trousers-length-check',
      garment: FittingGarmentType.trousers,
      german: 'Ist die Länge der Hose so passend, oder ist sie zu lang?',
      arabic: 'هل طول البنطال مناسب هكذا أم أنه طويل أكثر من اللازم؟',
      keywords: <String>{'Hose', 'Länge', 'zu lang'},
    ),
    FittingDialogue(
      id: 'trousers-width-check',
      garment: FittingGarmentType.trousers,
      german: 'Die Hose sitzt an der Taille zu eng. Haben Sie eine bequemere Weite?',
      arabic: 'البنطال ضيق عند الخصر. هل لديكم عرض أكثر راحة؟',
      keywords: <String>{'Hose', 'Taille', 'Weite', 'bequemer'},
    ),
  ];

  static const List<FabricCareNote> fabrics = <FabricCareNote>[
    FabricCareNote(
      fabric: NaturalFabric.cotton,
      materialQuestionDe: 'Ist dieses Hemd aus Baumwolle?',
      materialQuestionAr: 'هل هذا القميص مصنوع من القطن؟',
      careQuestionDe: 'Bei wie viel Grad darf ich es waschen und wie soll ich es bügeln?',
      careQuestionAr: 'على أي درجة حرارة يمكن غسله وكيف ينبغي كيه؟',
    ),
    FabricCareNote(
      fabric: NaturalFabric.wool,
      materialQuestionDe: 'Ist dieser Wintermantel aus Wolle oder aus einem Wollmix?',
      materialQuestionAr: 'هل هذا المعطف الشتوي من الصوف أم من خليط صوف؟',
      careQuestionDe: 'Welche Waschanleitung gilt für die Wolle, und darf sie gebügelt werden?',
      careQuestionAr: 'ما تعليمات غسل الصوف، وهل يمكن كيه؟',
    ),
  ];
}
