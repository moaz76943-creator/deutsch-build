/// Task 1394: Pragmatic mapping of T/V distinction (du/Sie, tu/vous)
class HonorificTvMapper {
  String getPronoun(String lang, bool isFormal) => isFormal ? (lang == 'de' ? 'Sie' : 'vous') : (lang == 'de' ? 'du' : 'tu');
}
