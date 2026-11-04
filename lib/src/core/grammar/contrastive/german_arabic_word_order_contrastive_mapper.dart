/// Task 1381: Contrastive word order mapper (German V2/SOV vs Arabic VSO/SVO)
class WordOrderContrastiveMapper {
  String mapWordOrder(String fromLang, String toLang) => (fromLang == 'ar' && toLang == 'de') ? 'VSO_TO_V2' : 'V2_TO_VSO';
}
